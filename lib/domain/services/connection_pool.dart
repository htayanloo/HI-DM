import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:socks5_proxy/socks_client.dart';

import '../../data/models/proxy_config.dart';
import 'speed_limiter.dart';

enum ConnectionStatus { idle, downloading, completed, error, paused }

typedef SegmentProgressCallback = void Function(int segmentIndex, int bytesDownloaded, int totalSegmentBytes);
typedef SegmentStatusCallback = void Function(int segmentIndex, ConnectionStatus status, String? errorMessage);

/// Thrown when a connection stops delivering data for too long
/// (network drop, laptop sleep, server hang). Always retryable.
class StallException implements Exception {
  final Duration idleFor;
  const StallException(this.idleFor);

  @override
  String toString() =>
      'StallException: no data received for ${idleFor.inSeconds}s';
}

class ConnectionPool {
  final String url;
  final Map<String, String> headers;
  final int connectionTimeoutSeconds;
  final int maxRetries;
  final int retryDelaySeconds;
  final SpeedLimiter? speedLimiter;
  final CookieJar? cookieJar;
  final ProxyConfig? proxyConfig;
  final SegmentProgressCallback? onProgress;
  final SegmentStatusCallback? onStatusChange;

  /// Seconds without a single byte before a live connection is considered
  /// stalled and forcibly retried. Keeps downloads alive across network
  /// drops and laptop sleep instead of hanging forever.
  final int stallTimeoutSeconds;

  final List<Dio> _clients = [];
  final List<CancelToken> _cancelTokens = [];
  final List<ConnectionStatus> _statuses = [];
  bool _isPaused = false;
  bool _isCancelled = false;

  ConnectionPool({
    required this.url,
    this.headers = const {},
    this.connectionTimeoutSeconds = 30,
    this.maxRetries = 5,
    this.retryDelaySeconds = 5,
    this.speedLimiter,
    this.cookieJar,
    this.proxyConfig,
    this.onProgress,
    this.onStatusChange,
    this.stallTimeoutSeconds = 30,
  });

  Future<void> downloadAll(Map<int, SegmentTask> segments) async {
    if (segments.isEmpty) return; // Safety: nothing to download

    _isPaused = false;
    _isCancelled = false;
    _clients.clear();
    _cancelTokens.clear();
    _statuses.clear();

    final maxIndex = segments.keys.reduce((a, b) => a > b ? a : b) + 1;
    for (var i = 0; i < maxIndex; i++) {
      _clients.add(_createDio());
      _cancelTokens.add(CancelToken());
      _statuses.add(ConnectionStatus.idle);
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

      // Wait out an explicit pause before every attempt so a download that
      // stalled while paused doesn't burn retries in the background.
      if (_isPaused) {
        if (index < _statuses.length) {
          _statuses[index] = ConnectionStatus.paused;
        }
        onStatusChange?.call(index, ConnectionStatus.paused, null);
        await _awaitResume(index);
        if (_isCancelled) return;
      }

      final bytesBeforeAttempt = await _tempFileLength(currentTask);

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

        // Pause requested while the request was in flight — wait, then retry
        // from the current temp file offset without counting a retry.
        if (_isPaused) continue;

        currentTask = await _recoverTask(currentTask);
        retries = _nextRetryCount(retries, bytesBeforeAttempt, currentTask);
        if (retries > maxRetries) {
          if (index < _statuses.length) {
            _statuses[index] = ConnectionStatus.error;
          }
          onStatusChange?.call(index, ConnectionStatus.error, e.message);
          return; // Don't rethrow — let other segments continue
        }

        await _backoff(retries, index);
      } catch (e) {
        // StallException and other non-Dio errors: recoverable, keep going.
        if (_isCancelled) return;
        if (_isPaused) continue;

        currentTask = await _recoverTask(currentTask);
        retries = _nextRetryCount(retries, bytesBeforeAttempt, currentTask);
        if (retries > maxRetries) {
          if (index < _statuses.length) {
            _statuses[index] = ConnectionStatus.error;
          }
          onStatusChange?.call(index, ConnectionStatus.error, e.toString());
          return;
        }

        await _backoff(retries, index);
      }
    }
  }

  /// Reset the retry counter whenever the attempt actually made progress —
  /// flaky-but-alive connections keep downloading instead of giving up.
  int _nextRetryCount(int retries, int bytesBefore, SegmentTask recovered) {
    if (recovered.alreadyDownloaded > bytesBefore) return 1;
    return retries + 1;
  }

  /// Re-read the temp file so the next attempt resumes from real bytes on
  /// disk (this is what makes recovery after sleep/network loss correct).
  Future<SegmentTask> _recoverTask(SegmentTask task) async {
    try {
      final tempFile = File(task.tempFilePath);
      if (await tempFile.exists()) {
        return task.copyWith(alreadyDownloaded: await tempFile.length());
      }
    } catch (_) {}
    return task;
  }

  Future<int> _tempFileLength(SegmentTask task) async {
    try {
      final tempFile = File(task.tempFilePath);
      if (await tempFile.exists()) return tempFile.lengthSync();
    } catch (_) {}
    return 0;
  }

  /// Sleep between retries, waking early on pause/cancel so the UI stays
  /// responsive while a download is waiting out a network outage.
  Future<void> _backoff(int retries, int index) async {
    final delay = Duration(seconds: retryDelaySeconds * retries);
    final deadline = DateTime.now().add(delay);
    while (DateTime.now().isBefore(deadline)) {
      if (_isCancelled || _isPaused) return;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _awaitResume(int index) async {
    // Polling keeps pause/resume race-free across the segment workers.
    while (_isPaused && !_isCancelled) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _doDownload(int index, SegmentTask task) async {
    if (index >= _clients.length || index >= _cancelTokens.length) return;

    // Fresh token per attempt — a previous stall/pause may have consumed it.
    final cancelToken = CancelToken();
    _cancelTokens[index] = cancelToken;

    final dio = _clients[index];
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

    // Server ignored our Range header — restart this attempt's file from 0
    // instead of appending a full body to a partial file (corruption).
    var alreadyDownloaded = task.alreadyDownloaded;
    final serverSentRange = response.statusCode == 206;
    if (alreadyDownloaded > 0 && !serverSentRange) {
      alreadyDownloaded = 0;
      try {
        final f = File(task.tempFilePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }

    final tempFile = File(task.tempFilePath);
    final sink = tempFile.openWrite(
      mode: alreadyDownloaded > 0 ? FileMode.append : FileMode.write,
    );
    var downloaded = alreadyDownloaded;
    final totalSegmentBytes = task.endByte >= 0 ? task.endByte - task.startByte + 1 : -1;
    var lastDataAt = DateTime.now();
    final stallLimit = Duration(seconds: stallTimeoutSeconds);

    final iterator = StreamIterator(response.data!.stream);
    try {
      while (true) {
        if (_isCancelled) break;

        if (_isPaused) {
          if (index < _statuses.length) _statuses[index] = ConnectionStatus.paused;
          onStatusChange?.call(index, ConnectionStatus.paused, null);

          await _awaitResume(index);
          if (_isCancelled) break;
          if (index < _statuses.length) _statuses[index] = ConnectionStatus.downloading;
          onStatusChange?.call(index, ConnectionStatus.downloading, null);
        }

        bool hasChunk;
        try {
          // Stall watchdog: if the wire goes silent (network drop, laptop
          // sleep), moveNext times out and we retry with a fresh request
          // instead of hanging forever.
          hasChunk = await iterator.moveNext().timeout(stallLimit);
        } on TimeoutException {
          throw StallException(DateTime.now().difference(lastDataAt));
        }

        if (!hasChunk) break; // Stream finished

        final chunk = iterator.current;
        lastDataAt = DateTime.now();

        // Speed limiting
        if (speedLimiter != null && speedLimiter!.enabled) {
          await speedLimiter!.consumeAsync(chunk.length);
        }

        sink.add(chunk);
        downloaded += chunk.length;
        onProgress?.call(index, downloaded, totalSegmentBytes);
      }

      // The server closed the connection before delivering the whole
      // segment — treat it as a retryable failure, not a completion.
      if (totalSegmentBytes > 0 && downloaded < totalSegmentBytes) {
        throw StallException(const Duration(seconds: 0));
      }
    } finally {
      try {
        await sink.flush();
        await sink.close();
      } catch (_) {}
      try {
        await iterator.cancel();
      } catch (_) {}
    }
  }

  void pause() => _isPaused = true;

  void resume() => _isPaused = false;

  void cancel() {
    _isCancelled = true;
    _isPaused = false;
    for (final token in _cancelTokens) {
      try {
        if (!token.isCancelled) token.cancel('Download cancelled');
      } catch (_) {}
    }
  }

  ConnectionStatus getStatus(int index) {
    if (index < _statuses.length) return _statuses[index];
    return ConnectionStatus.idle;
  }

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: connectionTimeoutSeconds),
      receiveTimeout: const Duration(minutes: 30),
      sendTimeout: Duration(seconds: connectionTimeoutSeconds),
      followRedirects: true,
      maxRedirects: 10,
    ));
    if (cookieJar != null) {
      dio.interceptors.add(CookieManager(cookieJar!));
    }
    applyProxy(dio, proxyConfig);
    return dio;
  }

  static void applyProxy(Dio dio, ProxyConfig? proxy) {
    if (proxy == null || proxy.type == 'none') return;

    final type = proxy.type;
    final host = proxy.host;
    final port = proxy.port;
    final username = proxy.username;
    final password = proxy.password;

    if (type == 'http' || type == 'https') {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) => 'PROXY $host:$port';
          if (username != null && username.isNotEmpty) {
            client.addProxyCredentials(
              host,
              port,
              'basic',
              HttpClientBasicCredentials(username, password ?? ''),
            );
          }
          return client;
        },
      );
    } else if (type == 'socks4' || type == 'socks5') {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          SocksTCPClient.assignToHttpClient(client, [
            ProxySettings(
              InternetAddress.tryParse(host) ?? InternetAddress(host),
              port,
              username: username != null && username.isNotEmpty ? username : null,
              password: username != null && username.isNotEmpty ? (password ?? '') : null,
            ),
          ]);
          return client;
        },
      );
    }
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
