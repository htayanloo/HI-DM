import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/download_item.dart' as model;
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/app_settings.dart';
import 'download_engine.dart';
import 'download_message.dart';

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
    _maxConcurrent = await _settingsRepo.getIntValue(
      AppSettings.maxConcurrentDownloads,
    );
    if (_maxConcurrent <= 0) _maxConcurrent = AppConstants.defaultMaxConcurrentDownloads;

    final tempDir = await getTemporaryDirectory();
    _tempDirectory = '${tempDir.path}/hi-dm';
    _initialized = true;
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
      threadCount: threadCount ?? defaultThreads,
      headers: headers,
      category: category?.name,
      queueId: queueId,
      dateAdded: DateTime.now(),
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

    final config = DownloadIsolateConfig(
      downloadId: downloadId,
      url: item.url,
      savePath: item.savePath,
      fileName: item.fileName,
      tempDirectory: '$_tempDirectory/$downloadId',
      threadCount: item.threadCount,
      headers: item.headers,
      proxyConfigJson: item.proxy?.encode(),
      speedLimitBytesPerSecond: effectiveSpeedLimit,
      connectionTimeoutSeconds: await _settingsRepo.getIntValue(
        AppSettings.connectionTimeout,
      ),
      maxRetries: await _settingsRepo.getIntValue(AppSettings.retryCount),
      retryDelaySeconds: await _settingsRepo.getIntValue(AppSettings.retryDelay),
      existingTotalSize: item.totalSize > 0 ? item.totalSize : null,
      resumeSegments: resumeSegments,
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
    for (final active in _activeDownloads.values) {
      active.dispose();
    }
    _activeDownloads.clear();
    _eventController.close();
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
        break;

      case DownloadEventType.error:
        final fatal = event.data['fatal'] as bool? ?? false;
        if (fatal) {
          _flushPendingUpdate(event.downloadId);
          _onDownloadComplete(event.downloadId);
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

  /// Process queued downloads when a slot opens up.
  Future<void> _processQueue() async {
    if (_activeDownloads.length >= _maxConcurrent) return;

    final downloads = await _downloadRepo.getAllDownloads();
    final queued = downloads.where((d) => d.status == 'queued').toList();

    // Sort by date added (oldest first)
    queued.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));

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
