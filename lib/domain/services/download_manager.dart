import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/download_item.dart' as model;
import '../../data/models/proxy_config.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/app_settings.dart';
import 'download_engine.dart';
import 'download_message.dart';
import 'notification_service.dart';

/// Tracks an active download isolate.
class _ActiveDownload {
  final int downloadId;
  final Isolate isolate;
  final SendPort commandPort;
  final ReceivePort eventPort;
  final StreamSubscription<dynamic> subscription;

  _ActiveDownload({
    required this.downloadId,
    required this.isolate,
    required this.commandPort,
    required this.eventPort,
    required this.subscription,
  });

  void dispose() {
    subscription.cancel();
    eventPort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

/// Manages all active downloads from the main isolate.
/// Handles concurrency limits, queue processing, and isolate lifecycle.
class DownloadManager {
  final DownloadRepository _downloadRepo;
  final CategoryRepository _categoryRepo;
  final SettingsRepository _settingsRepo;

  final Map<int, _ActiveDownload> _activeDownloads = {};
  final StreamController<DownloadEvent> _eventController =
      StreamController<DownloadEvent>.broadcast();

  int _maxConcurrent = AppConstants.defaultMaxConcurrentDownloads;
  String? _tempDirectory;
  bool _initialized = false;
  bool _shuttingDown = false;
  String _queueOrder = 'fifo';

  // Throttled DB writes to prevent SQLite concurrent access crash
  final Map<int, _PendingDbUpdate> _pendingUpdates = {};
  Timer? _dbWriteTimer;

  DownloadManager({
    required DownloadRepository downloadRepo,
    required CategoryRepository categoryRepo,
    required SettingsRepository settingsRepo,
  })  : _downloadRepo = downloadRepo,
        _categoryRepo = categoryRepo,
        _settingsRepo = settingsRepo;

  /// Stream of all download events (progress, status, speed, etc.)
  Stream<DownloadEvent> get events => _eventController.stream;

  /// Number of currently active downloads.
  int get activeCount => _activeDownloads.length;

  /// Initialize the manager — call once at startup.
  Future<void> initialize() async {
    // Idempotent: a second call must not re-run startup recovery, otherwise
    // it would re-queue downloads that are legitimately running right now.
    if (_initialized) return;

    _maxConcurrent = await _settingsRepo.getIntValue(
      AppSettings.maxConcurrentDownloads,
    );
    if (_maxConcurrent <= 0) _maxConcurrent = AppConstants.defaultMaxConcurrentDownloads;

    _queueOrder = await _settingsRepo.getValue(AppSettings.queueOrder);
    if (_queueOrder.isEmpty) _queueOrder = 'fifo';

    // path_provider can fail on unusual setups — fall back to the system temp
    // dir rather than leaving the manager unable to start.
    try {
      final tempDir = await getTemporaryDirectory();
      _tempDirectory = '${tempDir.path}/hi-dm';
    } catch (e) {
      debugPrint('[DM] Temp dir lookup failed (non-fatal): $e');
      _tempDirectory = '${Directory.systemTemp.path}/hi-dm';
    }
    _initialized = true;

    // Downloads that were running when the app was killed are stuck in an
    // "active" status with no isolate behind them — re-queue them so the
    // queue processor picks them up instead of showing a frozen state.
    await recoverInterruptedDownloads();
    await _processQueue();

    // Remove temp dirs that no longer belong to any download (leftovers from
    // deleted/completed downloads) so half-downloaded files don't pile up.
    unawaited(cleanOrphanTempFiles());
  }

  /// Re-queue downloads left in an active status after a crash or force-quit.
  ///
  /// Public so startup recovery can be exercised in tests.
  Future<void> recoverInterruptedDownloads() async {
    try {
      final downloads = await _downloadRepo.getAllDownloads();
      for (final d in downloads) {
        if (d.id == null) continue;
        if (isInterruptedStatus(d.status)) {
          debugPrint('[DM] Recovering interrupted download ${d.id} (${d.status})');
          await _downloadRepo.updateDownloadStatus(d.id!, 'queued');
        }
      }
    } catch (e) {
      debugPrint('[DM] Interrupted-download recovery error (non-fatal): $e');
    }
  }

  /// Delete temp directories that don't map to an active download.
  /// Returns the number of directories removed.
  Future<int> cleanOrphanTempFiles() async {
    if (_tempDirectory == null) return 0;
    try {
      final root = Directory(_tempDirectory!);
      if (!await root.exists()) return 0;

      final downloads = await _downloadRepo.getAllDownloads();
      final keepIds = <String>{
        for (final d in downloads)
          if (d.id != null &&
              d.status != 'completed' &&
              d.status != 'error')
            d.id.toString(),
      };

      var removed = 0;
      await for (final entity in root.list()) {
        if (entity is! Directory) continue;
        final id = p.basename(entity.path);
        if (keepIds.contains(id)) continue;
        try {
          await entity.delete(recursive: true);
          removed++;
        } catch (_) {}
      }
      if (removed > 0) {
        debugPrint('[DM] Removed $removed orphaned temp dir(s)');
      }
      return removed;
    } catch (e) {
      debugPrint('[DM] Temp cleanup error (non-fatal): $e');
      return 0;
    }
  }

  /// Delete temp data for every download that is not currently running —
  /// the user-facing "remove half-downloaded files" action.
  /// Returns the number of downloads whose temp data was removed.
  Future<int> clearUnfinishedTempData() async {
    if (_tempDirectory == null) return 0;
    var removed = 0;
    try {
      final downloads = await _downloadRepo.getAllDownloads();
      for (final d in downloads) {
        if (d.id == null) continue;
        if (_activeDownloads.containsKey(d.id)) continue;
        if (d.status == 'completed') continue;

        final dir = Directory('$_tempDirectory/${d.id}');
        if (await dir.exists()) {
          try {
            await dir.delete(recursive: true);
            removed++;
          } catch (_) {}
        }
        // Reset progress so the UI reflects that partial data is gone.
        await _downloadRepo.updateDownloadProgress(d.id!, 0, 0);
        await _downloadRepo.deleteSegments(d.id!);
      }
      await cleanOrphanTempFiles();
    } catch (e) {
      debugPrint('[DM] Clear unfinished temp error (non-fatal): $e');
    }
    return removed;
  }

  /// Gracefully stop everything so the process can exit: pause active
  /// downloads (persisting their state for resume), flush throttled DB
  /// writes, then kill all isolates.
  Future<void> shutdown() async {
    if (_shuttingDown) return;
    _shuttingDown = true;

    try {
      for (final active in _activeDownloads.values) {
        try {
          active.commandPort.send({'command': 'pause'});
        } catch (_) {}
      }
      // Give isolates a moment to flush their final progress event.
      if (_activeDownloads.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    } catch (_) {}

    // Mark anything still active as paused in the DB so it is resumable.
    try {
      for (final id in _activeDownloads.keys) {
        await _downloadRepo.updateDownloadStatus(id, 'paused');
      }
    } catch (_) {}

    // Flush throttled progress writes before the process dies.
    _dbWriteTimer?.cancel();
    _dbWriteTimer = null;
    try {
      await _flushAllPendingUpdates();
    } catch (_) {}

    for (final active in _activeDownloads.values) {
      try {
        active.dispose();
      } catch (_) {}
    }
    _activeDownloads.clear();
    try {
      if (!_eventController.isClosed) await _eventController.close();
    } catch (_) {}
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  /// Add a new download and optionally start it immediately.
  Future<int> addDownload({
    required String url,
    required String savePath,
    String? fileName,
    int? threadCount,
    Map<String, String> headers = const {},
    String? proxyConfigJson,
    int? queueId,
    bool startImmediately = true,
    bool streamMode = false,
  }) async {
    await _ensureInitialized();
    final resolvedFileName = fileName ?? FileUtils.getFileNameFromUrl(url);
    final sanitizedName = FileUtils.sanitizeFileName(resolvedFileName);

    // Auto-detect category
    final category = await _categoryRepo.matchCategory(sanitizedName);
    // Use the provided savePath; only fall back to category path if savePath is empty
    final effectiveSavePath = savePath.isNotEmpty
        ? savePath
        : (category?.defaultSavePath ?? savePath);

    // Get default thread count from settings
    final defaultThreads = await _settingsRepo.getIntValue(
      AppSettings.defaultThreadCount,
    );

    final item = model.DownloadItem(
      url: url,
      fileName: sanitizedName,
      savePath: effectiveSavePath,
      // Stream mode is sequential by definition — force a single connection.
      threadCount: streamMode ? 1 : (threadCount ?? defaultThreads),
      headers: headers,
      category: category?.name,
      queueId: queueId,
      dateAdded: DateTime.now(),
      streamMode: streamMode,
    );

    final id = await _downloadRepo.insertDownload(item);
    debugPrint('[DM] Download inserted with id=$id, startImmediately=$startImmediately');

    if (startImmediately) {
      await startDownload(id);
    }

    return id;
  }

  /// Start a download by its ID.
  Future<void> startDownload(int downloadId) async {
    await _ensureInitialized();
    if (_shuttingDown) return;
    if (_activeDownloads.containsKey(downloadId)) return;

    // Check concurrency limit
    if (_activeDownloads.length >= _maxConcurrent) {
      await _downloadRepo.updateDownloadStatus(downloadId, 'queued');
      return;
    }

    final item = await _downloadRepo.getDownloadById(downloadId);
    if (item == null) return;

    // Get resume data if available
    List<SegmentResumeData>? resumeSegments;
    if (item.segments.isNotEmpty) {
      resumeSegments = item.segments
          .map((s) => SegmentResumeData(
                segmentIndex: s.id! - item.segments.first.id!,
                startByte: s.startByte,
                endByte: s.endByte,
                downloadedBytes: s.downloadedBytes,
                tempFilePath: s.tempFilePath,
              ))
          .toList();
    }

    // Per-download speed limit takes priority, then global setting
    int? effectiveSpeedLimit;
    if (item.speedLimit > 0) {
      effectiveSpeedLimit = item.speedLimit;
    } else {
      final speedLimitEnabled = await _settingsRepo.getBoolValue(
        AppSettings.speedLimitEnabled,
      );
      if (speedLimitEnabled) {
        effectiveSpeedLimit = await _settingsRepo.getIntValue(
          AppSettings.speedLimitValue,
        );
      }
    }

    // Resolve proxy: per-download proxy takes priority over global proxy
    String? effectiveProxyJson;
    if (item.proxy != null && item.proxy!.type != 'none') {
      effectiveProxyJson = item.proxy!.encode();
    } else {
      final globalProxyEnabled = await _settingsRepo.getBoolValue(
        AppSettings.globalProxyEnabled,
      );
      if (globalProxyEnabled) {
        final globalProxyConfigStr = await _settingsRepo.getValue(
          AppSettings.globalProxyConfig,
        );
        if (globalProxyConfigStr.isNotEmpty) {
          effectiveProxyJson = globalProxyConfigStr;
        }
      }
    }

    final config = DownloadIsolateConfig(
      downloadId: downloadId,
      url: item.url,
      savePath: item.savePath,
      fileName: item.fileName,
      tempDirectory: '$_tempDirectory/$downloadId',
      threadCount: item.threadCount,
      headers: item.headers,
      proxyConfigJson: effectiveProxyJson,
      speedLimitBytesPerSecond: effectiveSpeedLimit,
      connectionTimeoutSeconds: await _settingsRepo.getIntValue(
        AppSettings.connectionTimeout,
      ),
      maxRetries: await _settingsRepo.getIntValue(AppSettings.retryCount),
      retryDelaySeconds: await _settingsRepo.getIntValue(AppSettings.retryDelay),
      existingTotalSize: item.totalSize > 0 ? item.totalSize : null,
      resumeSegments: resumeSegments,
      streamMode: item.streamMode,
      existingDownloadedBytes: item.downloadedSize,
    );

    try {
      debugPrint('[DM] Spawning isolate for download $downloadId: ${item.url}');
      debugPrint('[DM] tempDir=$_tempDirectory, threads=${item.threadCount}');
      await _spawnIsolate(downloadId, config);
      debugPrint('[DM] Isolate spawned successfully for $downloadId');
    } catch (e, stack) {
      debugPrint('[DM] ERROR spawning isolate: $e');
      debugPrint('[DM] Stack: $stack');
      await _downloadRepo.updateDownloadStatus(downloadId, 'error', errorMessage: e.toString());
    }
  }

  /// Pause a download.
  Future<void> pauseDownload(int downloadId) async {
    final active = _activeDownloads[downloadId];
    if (active == null) return;

    active.commandPort.send({'command': 'pause'});
  }

  /// Resume a paused download.
  Future<void> resumeDownload(int downloadId) async {
    final active = _activeDownloads[downloadId];
    if (active != null) {
      active.commandPort.send({'command': 'resume'});
      return;
    }

    // Re-start the download if it was fully stopped
    await startDownload(downloadId);
  }

  /// Cancel and remove a download from active list.
  Future<void> cancelDownload(int downloadId) async {
    final active = _activeDownloads[downloadId];
    if (active != null) {
      active.commandPort.send({'command': 'cancel'});
      await Future<void>.delayed(const Duration(milliseconds: 500));
      active.dispose();
      _activeDownloads.remove(downloadId);
    }

    await _downloadRepo.updateDownloadStatus(downloadId, 'paused');
    _processQueue();
  }

  /// Delete a download entirely.
  Future<void> deleteDownload(int downloadId, {bool deleteFile = false}) async {
    await cancelDownload(downloadId);

    if (deleteFile) {
      final item = await _downloadRepo.getDownloadById(downloadId);
      if (item != null) {
        // Try to delete the downloaded file
        try {
          final file = await _getDownloadedFile(item);
          if (file != null && await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    }

    await _downloadRepo.deleteDownload(downloadId);

    // Remove the download's temp dir so partial segments don't pile up.
    if (_tempDirectory != null) {
      try {
        final dir = Directory('$_tempDirectory/$downloadId');
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (_) {}
    }
  }

  /// Update per-download proxy config. Requires restart to take effect.
  Future<void> updateDownloadProxy(int downloadId, ProxyConfig? proxy) async {
    await _downloadRepo.updateDownloadProxy(downloadId, proxy);
  }

  /// Update per-download settings (thread count, speed limit).
  /// Speed limit updates in real-time. Thread count requires restart.
  Future<void> updateDownloadSettings(
    int downloadId, {
    int? threadCount,
    int? speedLimit,
  }) async {
    await _downloadRepo.updateDownloadSettings(downloadId,
        threadCount: threadCount, speedLimit: speedLimit);

    final active = _activeDownloads[downloadId];
    if (active != null) {
      // Update speed limiter in real-time
      if (speedLimit != null) {
        try {
          active.commandPort.send({
            'command': 'updateSpeedLimit',
            'data': {'bytesPerSecond': speedLimit, 'enabled': speedLimit > 0},
          });
        } catch (_) {}
      }

      // Thread count change: kill current isolate, delete segments, restart
      if (threadCount != null) {
        debugPrint('[DM] Thread count changed to $threadCount — restarting download $downloadId');
        // 1. Kill the isolate directly
        try {
          active.commandPort.send({'command': 'cancel'});
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 800));
        active.dispose();
        _activeDownloads.remove(downloadId);

        // 2. Delete old segments so new thread count creates fresh segments
        await _downloadRepo.deleteSegments(downloadId);

        // 3. Reset progress (keep downloadedSize for reference but restart fresh)
        await _downloadRepo.updateDownloadStatus(downloadId, 'queued');

        // 4. Start with new thread count
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await startDownload(downloadId);
      }
    }
  }

  /// Pause all active downloads.
  Future<void> pauseAll() async {
    for (final active in _activeDownloads.values) {
      active.commandPort.send({'command': 'pause'});
    }
  }

  /// Resume all paused downloads.
  Future<void> resumeAll() async {
    final downloads = await _downloadRepo.getAllDownloads();
    for (final d in downloads) {
      if (d.status == 'paused' && d.id != null) {
        await resumeDownload(d.id!);
      }
    }
  }

  /// Update speed limit for all active downloads.
  void updateSpeedLimit(int bytesPerSecond, bool enabled) {
    for (final active in _activeDownloads.values) {
      active.commandPort.send({
        'command': 'updateSpeedLimit',
        'data': {'bytesPerSecond': bytesPerSecond, 'enabled': enabled},
      });
    }
  }

  /// Dispose the manager and kill all isolates.
  void dispose() {
    _shuttingDown = true;
    for (final active in _activeDownloads.values) {
      active.dispose();
    }
    _activeDownloads.clear();
    _dbWriteTimer?.cancel();
    if (!_eventController.isClosed) _eventController.close();
  }

  // --- Private ---

  Future<void> _spawnIsolate(int downloadId, DownloadIsolateConfig config) async {
    final eventPort = ReceivePort();
    final completer = Completer<SendPort>();

    final subscription = eventPort.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      } else if (message is Map<String, dynamic>) {
        _handleMapEvent(message);
      }
    });

    final isolate = await Isolate.spawn(
      downloadIsolateEntry,
      [eventPort.sendPort, config.toMap()],
      debugName: 'download_$downloadId',
    );

    final commandPort = await completer.future;

    _activeDownloads[downloadId] = _ActiveDownload(
      downloadId: downloadId,
      isolate: isolate,
      commandPort: commandPort,
      eventPort: eventPort,
      subscription: subscription,
    );

    await _downloadRepo.updateDownloadStatus(downloadId, 'connecting');
  }

  void _handleMapEvent(Map<String, dynamic> map) {
    final event = DownloadEvent(
      downloadId: map['downloadId'] as int,
      type: DownloadEventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DownloadEventType.log,
      ),
      data: (map['data'] as Map<String, dynamic>?) ?? {},
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
    );
    _handleEvent(event);
  }

  void _handleEvent(DownloadEvent event) {
    // Broadcast to UI listeners (always, immediately)
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }

    switch (event.type) {
      case DownloadEventType.progress:
        // Batch progress updates — write to DB max every 500ms per download
        final id = event.downloadId;
        _pendingUpdates[id] = (_pendingUpdates[id] ?? _PendingDbUpdate())
          ..downloadedBytes = event.data['downloadedBytes'] as int;
        _scheduleDbWrite();
        break;

      case DownloadEventType.speed:
        final id = event.downloadId;
        _pendingUpdates[id] = (_pendingUpdates[id] ?? _PendingDbUpdate())
          ..speed = event.data['bytesPerSecond'] as double;
        _scheduleDbWrite();
        break;

      case DownloadEventType.statusChange:
        // Status changes are important — write immediately but safely
        final status = event.data['status'] as String;
        _safeDbWrite(() => _downloadRepo.updateDownloadStatus(event.downloadId, status));
        break;

      case DownloadEventType.fileInfo:
        _safeDbWrite(() => _handleFileInfo(event));
        break;

      case DownloadEventType.completed:
        // Flush pending writes before completing
        _flushPendingUpdate(event.downloadId);
        _onDownloadComplete(event.downloadId);
        _notifyCompleted(event.downloadId);
        break;

      case DownloadEventType.error:
        final fatal = event.data['fatal'] as bool? ?? false;
        if (fatal) {
          _flushPendingUpdate(event.downloadId);
          _onDownloadComplete(event.downloadId);
          _notifyError(event.downloadId, event.data['message'] as String? ?? 'Unknown error');
        }
        break;

      case DownloadEventType.segmentUpdate:
      case DownloadEventType.log:
        break;
    }
  }

  void _scheduleDbWrite() {
    _dbWriteTimer ??= Timer(const Duration(milliseconds: 500), _flushAllPendingUpdates);
  }

  Future<void> _flushAllPendingUpdates() async {
    _dbWriteTimer = null;
    final updates = Map<int, _PendingDbUpdate>.from(_pendingUpdates);
    _pendingUpdates.clear();

    for (final entry in updates.entries) {
      await _flushSingleUpdate(entry.key, entry.value);
    }
  }

  void _flushPendingUpdate(int downloadId) {
    final pending = _pendingUpdates.remove(downloadId);
    if (pending != null) {
      _flushSingleUpdate(downloadId, pending);
    }
  }

  Future<void> _flushSingleUpdate(int id, _PendingDbUpdate update) async {
    try {
      if (update.downloadedBytes != null) {
        await _downloadRepo.updateDownloadProgress(id, update.downloadedBytes!, update.speed ?? 0);
      } else if (update.speed != null) {
        await _downloadRepo.updateDownloadSpeed(id, update.speed!);
      }
    } catch (e) {
      debugPrint('[DM] DB write error (non-fatal): $e');
    }
  }

  Future<void> _safeDbWrite(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('[DM] DB write error (non-fatal): $e');
    }
  }

  Future<void> _handleFileInfo(DownloadEvent event) async {
    final item = await _downloadRepo.getDownloadById(event.downloadId);
    if (item == null) return;

    await _downloadRepo.updateDownload(item.copyWith(
      totalSize: event.data['totalSize'] as int,
      fileName: event.data['fileName'] as String,
    ));
  }

  void _onDownloadComplete(int downloadId) {
    final active = _activeDownloads.remove(downloadId);
    active?.dispose();
    _processQueue();
  }

  /// Show an OS notification when a download finishes (if enabled).
  Future<void> _notifyCompleted(int downloadId) async {
    try {
      final enabled = await _settingsRepo.getBoolValue(
        AppSettings.notificationsEnabled,
      );
      if (!enabled) return;
      final item = await _downloadRepo.getDownloadById(downloadId);
      if (item == null) return;
      final path = '${item.savePath}/${item.fileName}';
      await NotificationService.showDownloadComplete(item.fileName, filePath: path);
    } catch (e) {
      debugPrint('[DM] Completion notification error (non-fatal): $e');
    }
  }

  /// Show an OS notification when a download fails permanently.
  Future<void> _notifyError(int downloadId, String message) async {
    try {
      final enabled = await _settingsRepo.getBoolValue(
        AppSettings.notificationsEnabled,
      );
      if (!enabled) return;
      final item = await _downloadRepo.getDownloadById(downloadId);
      if (item == null) return;
      await NotificationService.showDownloadError(item.fileName, message);
    } catch (e) {
      debugPrint('[DM] Error notification error (non-fatal): $e');
    }
  }

  /// Update the queue ordering preference at runtime (from Settings).
  Future<void> setQueueOrder(String order) async {
    _queueOrder = order;
    await _settingsRepo.setValue(AppSettings.queueOrder, order);
    await _processQueue();
  }

  /// Process queued downloads when a slot opens up.
  Future<void> _processQueue() async {
    if (_shuttingDown) return;
    if (_activeDownloads.length >= _maxConcurrent) return;

    final downloads = await _downloadRepo.getAllDownloads();
    final queued = downloads.where((d) => d.status == 'queued').toList();

    sortQueueBy(queued, _queueOrder);

    for (final item in queued) {
      if (_activeDownloads.length >= _maxConcurrent) break;
      if (item.id != null) {
        await startDownload(item.id!);
      }
    }
  }

  Future<File?> _getDownloadedFile(model.DownloadItem item) async {
    try {
      final path = '${item.savePath}/${item.fileName}';
      final file = File(path);
      if (await file.exists()) return file;
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Batched DB update for a single download.
class _PendingDbUpdate {
  int? downloadedBytes;
  double? speed;
}

/// Statuses that mean "this download's isolate died with the app".
///
/// A row still in one of these statuses after a restart has no worker behind
/// it, so it would otherwise show a frozen progress bar forever.
bool isInterruptedStatus(String status) {
  return status == 'connecting' ||
      status == 'downloading' ||
      status == 'assembling' ||
      status == 'merging';
}

/// Sorts queued downloads in place according to the user's chosen order.
///
/// Orders: `fifo` (oldest first, default), `lifo` (newest first),
/// `largest`, `smallest`, `name` (A–Z).
void sortQueueBy(List<model.DownloadItem> queued, String order) {
  switch (order) {
    case 'lifo': // Newest first
      queued.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    case 'largest': // Biggest file first
      queued.sort((a, b) => b.totalSize.compareTo(a.totalSize));
    case 'smallest': // Smallest file first
      queued.sort((a, b) => a.totalSize.compareTo(b.totalSize));
    case 'name': // Alphabetical
      queued.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
    case 'fifo':
    default: // Oldest first (default)
      queued.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
  }
}
