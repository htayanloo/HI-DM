import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dm/domain/services/download_engine.dart';
import 'package:flutter_dm/domain/services/download_message.dart';

/// End-to-end test of the download isolate against a local HTTP server:
/// analyze → segments → download → assemble → completed.
void main() {
  late Directory tempDir;
  late Directory saveDir;
  late HttpServer server;

  const bodySize = 64 * 1024;
  final body = List<int>.generate(bodySize, (i) => i % 251);

  /// Filename advertised by the server — the engine legitimately prefers it
  /// over the configured name (same behavior for streamed and normal runs).
  var servedName = 'movie.bin';

  setUp(() async {
    servedName = 'movie.bin';
    tempDir = Directory.systemTemp.createTempSync('hi_dm_engine_temp');
    saveDir = Directory.systemTemp.createTempSync('hi_dm_engine_save')
      ..createSync(recursive: true);

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
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
      final slice = body.sublist(start, end + 1);
      if (partial) {
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set('content-range', 'bytes $start-$end/${body.length}');
      }
      req.response.headers.contentLength = slice.length;
      req.response.headers.set('accept-ranges', 'bytes');
      req.response.headers.set('content-disposition', 'attachment; filename="$servedName"');
      req.response.add(slice);
      await req.response.close();
    });
  });

  tearDown(() {
    try {
      server.close(force: true);
    } catch (_) {}
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
    try {
      saveDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// Runs the download isolate and returns all events until completed/error.
  Future<List<Map<String, dynamic>>> runDownload(
    DownloadIsolateConfig config,
  ) async {
    final mainPort = ReceivePort();
    final events = <Map<String, dynamic>>[];
    final done = Completer<void>();

    mainPort.listen((message) {
      // First message is the isolate's command SendPort — nothing to send back.
      if (message is SendPort) return;
      if (message is Map<String, dynamic>) {
        events.add(message);
        final type = message['type'];
        if (type == 'completed' || type == 'error') {
          if (!done.isCompleted) done.complete();
        }
      }
    });

    await Isolate.spawn(downloadIsolateEntry, [mainPort.sendPort, config.toMap()]);
    // Timeout so a hung engine fails the test instead of hanging it.
    await done.future.timeout(const Duration(seconds: 60));
    mainPort.close();
    return events;
  }

  test('multi-segment download assembles the complete file', () async {
    final config = DownloadIsolateConfig(
      downloadId: 1,
      url: 'http://127.0.0.1:${server.port}/movie.bin',
      savePath: saveDir.path,
      fileName: 'movie.bin',
      tempDirectory: tempDir.path,
      threadCount: 4,
      connectionTimeoutSeconds: 5,
      maxRetries: 3,
      retryDelaySeconds: 1,
    );

    final events = await runDownload(config);
    final types = events.map((e) => e['type']).toSet();

    expect(types, contains('completed'), reason: 'events: $types');
    expect(types, isNot(contains('error')));

    final outputFile = File('${saveDir.path}/movie.bin');
    expect(outputFile.existsSync(), isTrue);
    expect(outputFile.readAsBytesSync(), equals(body));
  });

  test('stream mode writes straight to the final file', () async {
    servedName = 'streamed.bin';
    final config = DownloadIsolateConfig(
      downloadId: 2,
      url: 'http://127.0.0.1:${server.port}/movie.bin',
      savePath: saveDir.path,
      fileName: 'streamed.bin',
      tempDirectory: tempDir.path,
      threadCount: 8, // stream mode must override this to a single segment
      streamMode: true,
      connectionTimeoutSeconds: 5,
      maxRetries: 3,
      retryDelaySeconds: 1,
    );

    final events = await runDownload(config);
    final types = events.map((e) => e['type']).toSet();

    expect(types, contains('completed'), reason: 'events: $types');

    final outputFile = File('${saveDir.path}/streamed.bin');
    expect(outputFile.existsSync(), isTrue);
    expect(outputFile.readAsBytesSync(), equals(body));

    // Stream mode must not leave segment temp files behind.
    final tempFiles = tempDir.listSync(recursive: true).whereType<File>();
    expect(tempFiles, isEmpty,
        reason: 'stream mode writes in place, no segment temp files expected');
  });

  test('partial file from a previous run is resumed, not duplicated', () async {
    servedName = 'resume.bin';
    // Simulate an interrupted download: first 10KB already on disk.
    final target = File('${saveDir.path}/resume.bin');
    target.writeAsBytesSync(body.sublist(0, 10 * 1024));

    final config = DownloadIsolateConfig(
      downloadId: 3,
      url: 'http://127.0.0.1:${server.port}/movie.bin',
      savePath: saveDir.path,
      fileName: 'resume.bin',
      tempDirectory: tempDir.path,
      threadCount: 1,
      streamMode: true,
      connectionTimeoutSeconds: 5,
      maxRetries: 3,
      retryDelaySeconds: 1,
      // Tells the engine the existing bytes are our own partial download.
      existingDownloadedBytes: 10 * 1024,
    );

    final events = await runDownload(config);
    final types = events.map((e) => e['type']).toSet();
    expect(types, contains('completed'), reason: 'events: $types');
    expect(target.readAsBytesSync(), equals(body));
  });
}
