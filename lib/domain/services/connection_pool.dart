import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'speed_limiter.dart';

enum ConnectionStatus { idle, downloading, completed, error, paused }

typedef SegmentProgressCallback = void Function(int segmentIndex, int bytesDownloaded, int totalSegmentBytes);
typedef SegmentStatusCallback = void Function(int segmentIndex, ConnectionStatus status, String? errorMessage);

class ConnectionPool {
  final String url;
  final Map<String, String> headers;
  final int connectionTimeoutSeconds;
  final int maxRetries;
  final int retryDelaySeconds;
  final SpeedLimiter? speedLimiter;
  final SegmentProgressCallback? onProgress;
  final SegmentStatusCallback? onStatusChange;

  final List<Dio> _clients = [];
  final List<CancelToken> _cancelTokens = [];
  final List<ConnectionStatus> _statuses = [];
  bool _isPaused = false;
  bool _isCancelled = false;
  final List<Completer<void>?> _pauseCompleters = [];

  ConnectionPool({
    required this.url,
    this.headers = const {},
    this.connectionTimeoutSeconds = 30,
    this.maxRetries = 5,
    this.retryDelaySeconds = 5,
    this.speedLimiter,
    this.onProgress,
    this.onStatusChange,
  });

  Future<void> downloadAll(Map<int, SegmentTask> segments) async {
    if (segments.isEmpty) return; // Safety: nothing to download

    _isPaused = false;
    _isCancelled = false;
    _clients.clear();
    _cancelTokens.clear();
    _statuses.clear();
    _pauseCompleters.clear();

    final maxIndex = segments.keys.reduce((a, b) => a > b ? a : b) + 1;
    for (var i = 0; i < maxIndex; i++) {
      _clients.add(_createDio());
      _cancelTokens.add(CancelToken());
      _statuses.add(ConnectionStatus.idle);
      _pauseCompleters.add(null);
    }

    final futures = segments.entries.map(
      (entry) => _downloadSegmentSafe(entry.key, entry.value),
    );

    await Future.wait(futures);
  }

  /// Wrapper with try-catch so one segment crash doesn't kill the whole download.
  Future<void> _downloadSegmentSafe(int index, SegmentTask task) async {
    try {
      await _downloadSegment(index, task);
    } catch (e) {
      // Mark as error but don't rethrow — other segments can continue
      if (index < _statuses.length) {
        _statuses[index] = ConnectionStatus.error;
      }
      onStatusChange?.call(index, ConnectionStatus.error, e.toString());
    }
  }

  Future<void> _downloadSegment(int index, SegmentTask task) async {
    var retries = 0;
    var currentTask = task;

    while (retries <= maxRetries) {
      if (_isCancelled) return;

      try {
        if (index < _statuses.length) {
          _statuses[index] = ConnectionStatus.downloading;
        }
        onStatusChange?.call(index, ConnectionStatus.downloading, null);

        await _doDownload(index, currentTask);

        if (index < _statuses.length) {
          _statuses[index] = ConnectionStatus.completed;
        }
        onStatusChange?.call(index, ConnectionStatus.completed, null);
        return;
      } on DioException catch (e) {
        if (_isCancelled || e.type == DioExceptionType.cancel) return;

        retries++;
        if (retries > maxRetries) {
          if (index < _statuses.length) {
            _statuses[index] = ConnectionStatus.error;
          }
          onStatusChange?.call(index, ConnectionStatus.error, e.message);
          return; // Don't rethrow — let other segments continue
        }

        // Recalculate from temp file
        try {
          final tempFile = File(currentTask.tempFilePath);
          if (await tempFile.exists()) {
            currentTask = currentTask.copyWith(alreadyDownloaded: await tempFile.length());
          }
        } catch (_) {}

        final delay = retryDelaySeconds * retries;
        await Future<void>.delayed(Duration(seconds: delay));
      } catch (e) {
        // Non-Dio errors
        retries++;
        if (retries > maxRetries) {
          onStatusChange?.call(index, ConnectionStatus.error, e.toString());
          return;
        }
        await Future<void>.delayed(Duration(seconds: retryDelaySeconds * retries));
      }
    }
  }

  Future<void> _doDownload(int index, SegmentTask task) async {
    if (index >= _clients.length || index >= _cancelTokens.length) return;

    final dio = _clients[index];
    final cancelToken = _cancelTokens[index];
    final requestHeaders = Map<String, String>.from(headers);

    final effectiveStart = task.startByte + task.alreadyDownloaded;
    if (task.endByte >= 0) {
      if (effectiveStart > task.endByte) {
        onProgress?.call(index, task.endByte - task.startByte + 1, task.endByte - task.startByte + 1);
        return;
      }
      requestHeaders['Range'] = 'bytes=$effectiveStart-${task.endByte}';
    } else if (task.alreadyDownloaded > 0) {
      requestHeaders['Range'] = 'bytes=$effectiveStart-';
    }

    final response = await dio.get<ResponseBody>(
      url,
      options: Options(
        headers: requestHeaders,
        responseType: ResponseType.stream,
        followRedirects: true,
        maxRedirects: 10,
      ),
      cancelToken: cancelToken,
    );

    if (response.data == null) return; // Safety: no response body

    final tempFile = File(task.tempFilePath);
    final sink = tempFile.openWrite(mode: FileMode.append);
    var downloaded = task.alreadyDownloaded;
    final totalSegmentBytes = task.endByte >= 0 ? task.endByte - task.startByte + 1 : -1;

    try {
      await for (final chunk in response.data!.stream) {
        if (_isPaused) {
          if (index < _statuses.length) _statuses[index] = ConnectionStatus.paused;
          onStatusChange?.call(index, ConnectionStatus.paused, null);

          final completer = Completer<void>();
          if (index < _pauseCompleters.length) _pauseCompleters[index] = completer;
          await completer.future;
          if (index < _pauseCompleters.length) _pauseCompleters[index] = null;

          if (_isCancelled) break;
          if (index < _statuses.length) _statuses[index] = ConnectionStatus.downloading;
          onStatusChange?.call(index, ConnectionStatus.downloading, null);
        }

        if (_isCancelled) break;

        // Speed limiting
        if (speedLimiter != null && speedLimiter!.enabled) {
          await speedLimiter!.consumeAsync(chunk.length);
        }

        sink.add(chunk);
        downloaded += chunk.length;
        onProgress?.call(index, downloaded, totalSegmentBytes);
      }
    } finally {
      try {
        await sink.flush();
        await sink.close();
      } catch (_) {}
    }
  }

  void pause() => _isPaused = true;

  void resume() {
    _isPaused = false;
    for (var i = 0; i < _pauseCompleters.length; i++) {
      _pauseCompleters[i]?.complete();
    }
  }

  void cancel() {
    _isCancelled = true;
    _isPaused = false;
    for (final token in _cancelTokens) {
      try {
        if (!token.isCancelled) token.cancel('Download cancelled');
      } catch (_) {}
    }
    for (var i = 0; i < _pauseCompleters.length; i++) {
      _pauseCompleters[i]?.complete();
    }
  }

  ConnectionStatus getStatus(int index) {
    if (index < _statuses.length) return _statuses[index];
    return ConnectionStatus.idle;
  }

  Dio _createDio() {
    return Dio(BaseOptions(
      connectTimeout: Duration(seconds: connectionTimeoutSeconds),
      receiveTimeout: const Duration(minutes: 30),
      sendTimeout: Duration(seconds: connectionTimeoutSeconds),
      followRedirects: true,
      maxRedirects: 10,
    ));
  }

  void dispose() {
    cancel();
    for (final client in _clients) {
      try { client.close(); } catch (_) {}
    }
    _clients.clear();
  }
}

class SegmentTask {
  final int startByte;
  final int endByte;
  final int alreadyDownloaded;
  final String tempFilePath;

  const SegmentTask({
    required this.startByte,
    required this.endByte,
    this.alreadyDownloaded = 0,
    required this.tempFilePath,
  });

  SegmentTask copyWith({int? startByte, int? endByte, int? alreadyDownloaded, String? tempFilePath}) =>
      SegmentTask(
        startByte: startByte ?? this.startByte,
        endByte: endByte ?? this.endByte,
        alreadyDownloaded: alreadyDownloaded ?? this.alreadyDownloaded,
        tempFilePath: tempFilePath ?? this.tempFilePath,
      );
}
