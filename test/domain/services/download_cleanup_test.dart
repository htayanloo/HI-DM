import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// Hide the generated row class — the model class with the same name is used here.
import 'package:flutter_dm/data/datasources/database.dart' hide DownloadItem;
import 'package:flutter_dm/data/models/download_item.dart';
import 'package:flutter_dm/data/repositories/category_repository.dart';
import 'package:flutter_dm/data/repositories/download_repository.dart';
import 'package:flutter_dm/data/repositories/settings_repository.dart';
import 'package:flutter_dm/domain/services/download_manager.dart';

/// Startup and user-triggered disk cleanup must never destroy data that a
/// download still needs — and must actually free what it promises to free.
void main() {
  late AppDatabase db;
  late DownloadRepository repo;
  late DownloadManager manager;
  late Directory tempRoot;
  late Directory saveDir;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DownloadRepository(db);
    manager = DownloadManager(
      downloadRepo: repo,
      categoryRepo: CategoryRepository(db),
      settingsRepo: SettingsRepository(db),
    );
    tempRoot = Directory.systemTemp.createTempSync('hi_dm_cleanup_root');
    saveDir = Directory.systemTemp.createTempSync('hi_dm_cleanup_save');
    // Point the manager at an isolated temp root: initialize() would also
    // start the queue and spawn real isolates.
    manager.tempDirectoryRoot = tempRoot.path;
  });

  tearDown(() async {
    manager.dispose();
    await db.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
    try {
      saveDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<int> insert({
    required String name,
    required String status,
    bool streamMode = false,
  }) {
    return repo.insertDownload(DownloadItem(
      url: 'https://example.com/$name',
      fileName: name,
      savePath: saveDir.path,
      dateAdded: DateTime.now(),
      status: status,
      streamMode: streamMode,
    ));
  }

  /// Creates the per-download temp dir and a segment file inside it, the way a
  /// paused multi-connection download leaves things on disk.
  File seedTempDir(int id, {int bytes = 256}) {
    final dir = Directory('${tempRoot.path}/$id')..createSync(recursive: true);
    return File('${dir.path}/segment_0.tmp')
      ..writeAsBytesSync(List<int>.filled(bytes, 7));
  }

  group('cleanOrphanTempFiles', () {
    test('keeps partial data of failed downloads so they stay resumable',
        () async {
      final failed = await insert(name: 'failed.bin', status: 'error');
      final paused = await insert(name: 'paused.bin', status: 'paused');
      final queued = await insert(name: 'queued.bin', status: 'queued');
      final completed = await insert(name: 'done.bin', status: 'completed');

      final failedSegments = seedTempDir(failed);
      final pausedSegments = seedTempDir(paused);
      final queuedSegments = seedTempDir(queued);
      final completedDir = Directory('${tempRoot.path}/$completed')
        ..createSync(recursive: true);

      // A directory no download record claims any more.
      final orphan = Directory('${tempRoot.path}/orphan-42')
        ..createSync(recursive: true);

      final removed = await manager.cleanOrphanTempFiles();

      // Failed downloads are still resumable: their bytes are the only copy.
      expect(failedSegments.existsSync(), isTrue,
          reason: 'a failed download must keep its partial data');
      expect(pausedSegments.existsSync(), isTrue);
      expect(queuedSegments.existsSync(), isTrue);

      // Completed downloads and records that no longer exist are swept.
      expect(completedDir.existsSync(), isFalse);
      expect(orphan.existsSync(), isFalse);
      expect(removed, 2);
    });

    test('never touches the database records of retained downloads', () async {
      final failed = await insert(name: 'failed.bin', status: 'error');
      seedTempDir(failed);

      await manager.cleanOrphanTempFiles();

      final item = await repo.getDownloadById(failed);
      expect(item, isNotNull);
      expect(item!.status, 'error', reason: 'cleanup must not change status');
    });
  });

  group('clearUnfinishedTempData', () {
    test('removes stream-mode partial output files', () async {
      final streamed = await insert(
        name: 'partial.mp4',
        status: 'paused',
        streamMode: true,
      );
      final partialFile = File('${saveDir.path}/partial.mp4')
        ..writeAsBytesSync(List<int>.filled(4096, 3));
      // Stream mode keeps an (empty) temp dir too — it just has no segments.
      Directory('${tempRoot.path}/$streamed').createSync(recursive: true);

      await manager.clearUnfinishedTempData();

      expect(partialFile.existsSync(), isFalse,
          reason: 'the half-written stream file is the data to free');
      expect(Directory('${tempRoot.path}/$streamed').existsSync(), isFalse);

      final item = await repo.getDownloadById(streamed);
      expect(item!.downloadedSize, 0,
          reason: 'progress must reset with the data it described');
    });

    test('keeps completed files and multi-connection partials untouched',
        () async {
      final streamedDone = await insert(
        name: 'finished.mp4',
        status: 'completed',
        streamMode: true,
      );
      final finishedFile = File('${saveDir.path}/finished.mp4')
        ..writeAsBytesSync(List<int>.filled(64, 1));

      // A non-stream download never writes its final path by halves; a file
      // sitting there belongs to something else and must survive.
      final classic = await insert(name: 'classic.bin', status: 'paused');
      final unrelated = File('${saveDir.path}/classic.bin')
        ..writeAsBytesSync(List<int>.filled(32, 9));
      final classicSegments = seedTempDir(classic, bytes: 512);

      await manager.clearUnfinishedTempData();

      expect(finishedFile.existsSync(), isTrue,
          reason: 'completed downloads are not unfinished data');
      expect(unrelated.existsSync(), isTrue,
          reason: 'non-stream downloads have no partial file at the final path');
      expect(classicSegments.existsSync(), isFalse,
          reason: 'the classic download\'s temp segments are freed');
      expect(await repo.getDownloadById(streamedDone), isNotNull);
    });
  });
}
