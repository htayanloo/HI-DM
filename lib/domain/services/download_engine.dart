import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path/path.dart' as p;

import 'connection_pool.dart';
import 'download_message.dart';
import 'file_assembler.dart';
import 'segment_manager.dart';
import 'speed_limiter.dart';

/// Entry point for the download isolate.
/// Receives a list: [SendPort mainSendPort, DownloadIsolateConfig config]
Future<void> downloadIsolateEntry(List<dynamic> args) async {
  final mainSendPort = args[0] as SendPort;
  final configMap = args[1] as Map<String, dynamic>;
  final config = DownloadIsolateConfig.fromMap(configMap);

  final engine = _IsolateDownloadEngine(
    config: config,
    sendPort: mainSendPort,
  );

  // Set up receive port for commands from main isolate
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      engine.handleCommand(message);
    }
  });

  await engine.start();
}

/// The download engine that runs inside an isolate.
class _IsolateDownloadEngine {
  final DownloadIsolateConfig config;
  final SendPort sendPort;

  late final Dio _dio;
  late final CookieJar _cookieJar;
  late final SegmentManager _segmentManager;
  late final FileAssembler _fileAssembler;
  late final SpeedLimiter _speedLimiter;
  ConnectionPool? _connectionPool;

  // Speed tracking
  final List<_SpeedSample> _speedSamples = [];
  Timer? _speedTimer;
  int _lastReportedBytes = 0;

  // State
  List<SegmentInfo> _segments = [];
  final Map<int, int> _segmentProgress = {};
  int _totalDownloaded = 0;
  int _totalSize = -1;
  bool _supportsRange = false;
  String? _resolvedUrl; // Final URL after redirects

  _IsolateDownloadEngine({
    required this.config,
    required this.sendPort,
  }) {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: config.connectionTimeoutSeconds),
      receiveTimeout: const Duration(minutes: 30),
      followRedirects: true,
      maxRedirects: 10,
    ));
    _dio.interceptors.add(CookieManager(_cookieJar));
    _segmentManager = SegmentManager(_dio);
    _fileAssembler = FileAssembler(
      tempDirectory: config.tempDirectory,
      downloadId: config.downloadId,
    );
    _speedLimiter = SpeedLimiter(
      bytesPerSecond: config.speedLimitBytesPerSecond ?? 0,
      enabled: config.speedLimitBytesPerSecond != null && config.speedLimitBytesPerSecond! > 0,
    );
  }

  Future<void> start() async {
    try {
      _sendLog('Starting download: ${config.url}');
      _sendLog('Config: threads=${config.threadCount}, speedLimit=${config.speedLimitBytesPerSecond ?? "none"} B/s');
      _sendStatus('connecting');

      await _fileAssembler.ensureTempDirectory();

      // Phase 1: Analyze URL
      final analysis = await _analyzeUrl();
      if (analysis == null) return;

      _totalSize = analysis.contentLength;
      _supportsRange = analysis.supportsRange;
      // Use resolved URL (after redirects) for actual download
      _resolvedUrl = analysis.resolvedUrl ?? config.url;
      if (_resolvedUrl != config.url) {
        _sendLog('Redirected to: $_resolvedUrl');
      }

      final fileName = analysis.suggestedFileName ?? config.fileName;
      _sendEvent('fileInfo', {
        'fileName': fileName,
        'totalSize': _totalSize,
        'supportsRange': _supportsRange,
      });

      // Phase 2: Create or restore segments
      _segments = _createOrRestoreSegments();
      _sendLog('Segments: ${_segments.length} (range=${_supportsRange}, threads=${config.threadCount})');

      // Phase 3: Prepare segment tasks
      final tasks = await _prepareSegmentTasks();

      // Phase 4: Start speed reporting
      _startSpeedReporting();

      // Phase 5: Download
      _sendStatus('downloading');
      await _startDownloading(tasks);

      // Phase 6: Assemble
      if (_segments.length > 1) {
        _sendStatus('assembling');
        _sendLog('Assembling ${_segments.length} segments...');
        await _assembleFile(fileName);
      } else {
        // Single segment: just move/rename the temp file
        await _finalizeSingleSegment(fileName);
      }

      // Phase 7: Cleanup
      await _fileAssembler.cleanupTempFiles(_segments.length);
      _stopSpeedReporting();

      _sendStatus('completed');
      _sendEvent('completed', {});
      _sendLog('Download completed successfully');
    } catch (e) {
      _stopSpeedReporting();
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _sendLog('Download cancelled');
        return;
      }
      _sendLog('Error: $e');
      _sendEvent('error', {'message': e.toString(), 'fatal': true});
      _sendStatus('error');
    }
  }

  void handleCommand(Map<String, dynamic> message) {
    final command = message['command'] as String;
    final data = message['data'] as Map<String, dynamic>?;
    switch (command) {
      case 'pause':
        _connectionPool?.pause();
        _sendStatus('paused');
        _sendLog('Download paused');
        break;
      case 'resume':
        _connectionPool?.resume();
        _sendStatus('downloading');
        _sendLog('Download resumed');
        break;
      case 'cancel':
        _connectionPool?.cancel();
        _sendLog('Download cancellation requested');
        break;
      case 'updateSpeedLimit':
        final limit = data?['bytesPerSecond'] as int?;
        final enabled = data?['enabled'] as bool?;
        _speedLimiter.update(bytesPerSecond: limit, enabled: enabled);
        _sendLog('Speed limit updated: ${enabled == true ? "$limit B/s" : "unlimited"}');
        break;
    }
  }

  Future<UrlAnalysis?> _analyzeUrl() async {
    try {
      final analysis = await _segmentManager.analyzeUrl(
        config.url,
        headers: config.headers,
        timeoutSeconds: config.connectionTimeoutSeconds,
      );
      _sendLog(
        'File info: size=${analysis.contentLength}, '
        'range=${analysis.supportsRange}, '
        'name=${analysis.suggestedFileName}',
      );
      return analysis;
    } catch (e) {
      _sendLog('URL analysis failed: $e');
      _sendEvent('error', {'message': 'Failed to analyze URL: $e', 'fatal': true});
      _sendStatus('error');
      return null;
    }
  }

  List<SegmentInfo> _createOrRestoreSegments() {
    if (config.resumeSegments != null && config.resumeSegments!.isNotEmpty) {
      // Restore from resume data
      return config.resumeSegments!.map((r) => SegmentInfo(
        index: r.segmentIndex,
        startByte: r.startByte,
        endByte: r.endByte,
      )).toList();
    }

    final effectiveThreads = _supportsRange ? config.threadCount : 1;
    return _segmentManager.createSegments(_totalSize, effectiveThreads);
  }

  Future<Map<int, SegmentTask>> _prepareSegmentTasks() async {
    final tasks = <int, SegmentTask>{};

    for (final segment in _segments) {
      final tempPath = _fileAssembler.getTempFilePath(segment.index);
      var alreadyDownloaded = 0;

      // Check for resume data
      if (config.resumeSegments != null) {
        final resumeData = config.resumeSegments!
            .where((r) => r.segmentIndex == segment.index)
            .firstOrNull;
        if (resumeData != null) {
          alreadyDownloaded = resumeData.downloadedBytes;
        }
      }

      // Also check actual temp file size
      final existing = await _fileAssembler.detectExistingSegments(1);
      if (existing.containsKey(0)) {
        // Re-check against the actual temp file
        final detected = await _fileAssembler.detectExistingSegments(_segments.length);
        if (detected.containsKey(segment.index)) {
          alreadyDownloaded = detected[segment.index]!;
        }
      }

      _segmentProgress[segment.index] = alreadyDownloaded;
      _totalDownloaded += alreadyDownloaded;

      // Skip fully downloaded segments
      if (segment.endByte >= 0 && alreadyDownloaded >= segment.totalBytes) {
        continue;
      }

      tasks[segment.index] = SegmentTask(
        startByte: segment.startByte,
        endByte: segment.endByte,
        alreadyDownloaded: alreadyDownloaded,
        tempFilePath: tempPath,
      );
    }

    return tasks;
  }

  Future<void> _startDownloading(Map<int, SegmentTask> tasks) async {
    if (tasks.isEmpty) {
      _sendLog('All segments already downloaded');
      return;
    }

    _connectionPool = ConnectionPool(
      url: _resolvedUrl ?? config.url,
      headers: config.headers,
      cookieJar: _cookieJar,
      connectionTimeoutSeconds: config.connectionTimeoutSeconds,
      maxRetries: config.maxRetries,
      retryDelaySeconds: config.retryDelaySeconds,
      speedLimiter: _speedLimiter,
      onProgress: _onSegmentProgress,
      onStatusChange: _onSegmentStatusChange,
    );

    await _connectionPool!.downloadAll(tasks);
  }

  void _onSegmentProgress(int segmentIndex, int bytesDownloaded, int totalSegmentBytes) {
    _segmentProgress[segmentIndex] = bytesDownloaded;
    _totalDownloaded = _segmentProgress.values.fold(0, (a, b) => a + b);

    _sendEvent('progress', {
      'downloadedBytes': _totalDownloaded,
      'totalBytes': _totalSize,
    });

    _sendEvent('segmentUpdate', {
      'segmentIndex': segmentIndex,
      'downloadedBytes': bytesDownloaded,
      'status': 'downloading',
    });
  }

  void _onSegmentStatusChange(int segmentIndex, ConnectionStatus status, String? errorMessage) {
    final statusStr = switch (status) {
      ConnectionStatus.idle => 'pending',
      ConnectionStatus.downloading => 'downloading',
      ConnectionStatus.completed => 'completed',
      ConnectionStatus.error => 'error',
      ConnectionStatus.paused => 'paused',
    };

    _sendEvent('segmentUpdate', {
      'segmentIndex': segmentIndex,
      'downloadedBytes': _segmentProgress[segmentIndex] ?? 0,
      'status': statusStr,
    });

    if (status == ConnectionStatus.completed) {
      _sendLog('Segment $segmentIndex completed');

      // Try dynamic rebalancing
      final newSegments = _segmentManager.dynamicRebalance(
        completedIndex: segmentIndex,
        segmentProgress: _segmentProgress,
        segmentInfos: _segments,
      );
      if (newSegments != null) {
        _sendLog('Rebalanced: split work from slowest segment to segment $segmentIndex');
        _segments = newSegments;
      }
    }

    if (status == ConnectionStatus.error && errorMessage != null) {
      _sendLog('Segment $segmentIndex error: $errorMessage');
    }
  }

  void _startSpeedReporting() {
    _lastReportedBytes = _totalDownloaded;
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final currentBytes = _totalDownloaded;
      final bytesThisSecond = currentBytes - _lastReportedBytes;
      _lastReportedBytes = currentBytes;

      _speedSamples.add(_SpeedSample(now, bytesThisSecond));

      // Keep last 5 seconds for rolling average
      final cutoff = now.subtract(const Duration(seconds: 5));
      _speedSamples.removeWhere((s) => s.timestamp.isBefore(cutoff));

      final avgSpeed = _speedSamples.isEmpty
          ? 0.0
          : _speedSamples.fold<double>(0, (sum, s) => sum + s.bytes) /
              _speedSamples.length;

      _sendEvent('speed', {'bytesPerSecond': avgSpeed});
    });
  }

  void _stopSpeedReporting() {
    _speedTimer?.cancel();
    _speedTimer = null;
  }

  Future<void> _assembleFile(String fileName) async {
    final outputPath = p.join(config.savePath, fileName);

    await _fileAssembler.assemble(
      outputPath: outputPath,
      segmentCount: _segments.length,
      expectedTotalSize: _totalSize,
      onProgress: (assembled) {
        _sendLog('Assembling: $assembled / $_totalSize bytes');
      },
    );

    _sendLog('File assembled at: $outputPath');
  }

  Future<void> _finalizeSingleSegment(String fileName) async {
    final tempPath = _fileAssembler.getTempFilePath(0);
    final outputPath = p.join(config.savePath, fileName);

    try {
      await Directory(p.dirname(outputPath)).create(recursive: true);
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        // Try rename first (fast, same filesystem)
        try {
          await tempFile.rename(outputPath);
        } catch (_) {
          // Cross-filesystem: copy then delete
          await tempFile.copy(outputPath);
          await tempFile.delete();
        }
        _sendLog('File saved at: $outputPath');
      } else {
        _sendLog('Warning: temp file not found at $tempPath');
      }
    } catch (e) {
      _sendLog('Error finalizing file: $e');
      rethrow;
    }
  }

  void _sendEvent(String type, Map<String, dynamic> data) {
    sendPort.send({
      'type': type,
      'downloadId': config.downloadId,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _sendStatus(String status) {
    _sendEvent('statusChange', {'status': status});
  }

  void _sendLog(String message) {
    _sendEvent('log', {'message': message});
  }
}

class _SpeedSample {
  final DateTime timestamp;
  final int bytes;
  const _SpeedSample(this.timestamp, this.bytes);
}
