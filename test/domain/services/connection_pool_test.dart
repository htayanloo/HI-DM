import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/domain/services/connection_pool.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('hi_dm_pool_test');
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// Serves [body] honoring Range requests so multi-attempt resumes work.
  Future<HttpServer> startServer(List<int> body) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final range = req.headers.value('range');
      var start = 0;
      var end = body.length - 1;
      var partial = false;
      if (range != null) {
        final match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range);
        if (match != null) {
          start = int.parse(match.group(1)!);
          if (match.group(2)!.isNotEmpty) end = int.parse(match.group(2)!);
          partial = true;
        }
      }
      final slice = Uint8List.fromList(body.sublist(start, end + 1));
      if (partial) {
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set(
          'content-range',
          'bytes $start-$end/${body.length}',
        );
      }
      req.response.headers.contentLength = slice.length;
      req.response.add(slice);
      await req.response.close();
    });
    return server;
  }

  test('downloads a complete file in one attempt', () async {
    final body = List<int>.generate(4096, (i) => i % 251);
    final server = await startServer(body);
    final tempFile = File('${tempDir.path}/single.bin');

    final pool = ConnectionPool(
      url: 'http://127.0.0.1:${server.port}/file.bin',
      connectionTimeoutSeconds: 5,
      maxRetries: 3,
      retryDelaySeconds: 1,
      stallTimeoutSeconds: 2,
    );

    await pool.downloadAll({
      0: SegmentTask(startByte: 0, endByte: body.length - 1, tempFilePath: tempFile.path),
    });

    expect(tempFile.readAsBytesSync(), equals(body));
    await server.close(force: true);
  });

  test('retries after the server stalls mid-stream instead of hanging', () async {
    final body = List<int>.generate(8192, (i) => i % 251);
    var requestCount = 0;

    // First request: send half the bytes then go silent (simulates a dropped
    // network / laptop sleep). The stall watchdog must interrupt it.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      requestCount++;
      final range = req.headers.value('range');
      var start = 0;
      if (range != null) {
        final match = RegExp(r'bytes=(\d+)-').firstMatch(range);
        if (match != null) start = int.parse(match.group(1)!);
      }

      if (requestCount == 1) {
        // Half the payload, then hold the connection open without data.
        final half = Uint8List.fromList(body.sublist(start, (body.length / 2).floor()));
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set('content-range', 'bytes $start-${(body.length / 2).floor() - 1}/${body.length}');
        req.response.headers.contentLength = half.length;
        req.response.add(half);
        await req.response.flush();
        // Never close — the client's stall watchdog must fire.
        await Completer<void>().future;
        return;
      }

      // Recovery: serve the remainder correctly.
      final end = body.length - 1;
      final slice = Uint8List.fromList(body.sublist(start, end + 1));
      req.response.statusCode = HttpStatus.partialContent;
      req.response.headers.set('content-range', 'bytes $start-$end/${body.length}');
      req.response.headers.contentLength = slice.length;
      req.response.add(slice);
      await req.response.close();
    });

    final tempFile = File('${tempDir.path}/stall.bin');
    final statuses = <ConnectionStatus>[];
    final pool = ConnectionPool(
      url: 'http://127.0.0.1:${server.port}/file.bin',
      connectionTimeoutSeconds: 5,
      maxRetries: 5,
      retryDelaySeconds: 1,
      stallTimeoutSeconds: 1, // detect the silent connection quickly
      onStatusChange: (index, status, _) => statuses.add(status),
    );

    await pool.downloadAll({
      0: SegmentTask(startByte: 0, endByte: body.length - 1, tempFilePath: tempFile.path),
    });

    // The download recovered from the stall and produced the full file.
    expect(requestCount, greaterThan(1));
    expect(tempFile.readAsBytesSync(), equals(body));
    expect(statuses, contains(ConnectionStatus.completed));

    await server.close(force: true);
  });

  test('resumes an existing partial temp file from its real length', () async {
    final body = List<int>.generate(2048, (i) => i % 199);
    final server = await startServer(body);
    final tempFile = File('${tempDir.path}/resume.bin');
    tempFile.writeAsBytesSync(body.sublist(0, 500));

    final pool = ConnectionPool(
      url: 'http://127.0.0.1:${server.port}/file.bin',
      connectionTimeoutSeconds: 5,
      maxRetries: 3,
      retryDelaySeconds: 1,
      stallTimeoutSeconds: 2,
    );

    await pool.downloadAll({
      0: SegmentTask(
        startByte: 0,
        endByte: body.length - 1,
        alreadyDownloaded: 500,
        tempFilePath: tempFile.path,
      ),
    });

    expect(tempFile.readAsBytesSync(), equals(body));
    await server.close(force: true);
  });

  test('StallException reports how long the wire was silent', () {
    const error = StallException(Duration(seconds: 42));
    expect(error.idleFor.inSeconds, 42);
    expect(error.toString(), contains('42s'));
  });
}
