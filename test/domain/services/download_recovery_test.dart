import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// Hide the generated row class — the model class with the same name is used here.
import 'package:flutter_dm/data/datasources/database.dart' hide DownloadItem;
import 'package:flutter_dm/data/models/download_item.dart';
import 'package:flutter_dm/data/repositories/category_repository.dart';
import 'package:flutter_dm/data/repositories/download_repository.dart';
import 'package:flutter_dm/data/repositories/settings_repository.dart';
import 'package:flutter_dm/domain/services/download_manager.dart';

void main() {
  late AppDatabase db;
  late DownloadRepository repo;
  late DownloadManager manager;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DownloadRepository(db);
    manager = DownloadManager(
      downloadRepo: repo,
      categoryRepo: CategoryRepository(db),
      settingsRepo: SettingsRepository(db),
    );
  });

  tearDown(() async {
    manager.dispose();
    await db.close();
  });

  Future<int> insert(String name, String status) {
    return repo.insertDownload(DownloadItem(
      url: 'https://example.com/$name',
      fileName: name,
      savePath: '/tmp',
      dateAdded: DateTime.now(),
      status: status,
    ));
  }

  group('isInterruptedStatus', () {
    test('flags statuses whose isolate died with the app', () {
      expect(isInterruptedStatus('connecting'), isTrue);
      expect(isInterruptedStatus('downloading'), isTrue);
      expect(isInterruptedStatus('assembling'), isTrue);
      expect(isInterruptedStatus('merging'), isTrue);
    });

    test('does not flag terminal or paused statuses', () {
      expect(isInterruptedStatus('completed'), isFalse);
      expect(isInterruptedStatus('paused'), isFalse);
      expect(isInterruptedStatus('error'), isFalse);
      expect(isInterruptedStatus('queued'), isFalse);
    });
  });

  group('recoverInterruptedDownloads', () {
    test('re-queues downloads left active by a crash, leaves the rest alone',
        () async {
      // Simulates the exact state after the app is force-killed mid-download:
      // these rows claim to be active but no isolate exists any more.
      final stuckDownloading = await insert('stuck1.bin', 'downloading');
      final stuckConnecting = await insert('stuck2.bin', 'connecting');
      final stuckAssembling = await insert('stuck3.bin', 'assembling');
      final doneOk = await insert('finished.bin', 'completed');
      final userPaused = await insert('paused.bin', 'paused');
      final failed = await insert('failed.bin', 'error');
      final waiting = await insert('waiting.bin', 'queued');

      await manager.recoverInterruptedDownloads();

      Future<String> statusOf(int id) async =>
          (await repo.getDownloadById(id))!.status;

      // The frozen ones become resumable instead of stuck forever.
      expect(await statusOf(stuckDownloading), 'queued');
      expect(await statusOf(stuckConnecting), 'queued');
      expect(await statusOf(stuckAssembling), 'queued');

      // Everything else keeps its meaning.
      expect(await statusOf(doneOk), 'completed');
      expect(await statusOf(userPaused), 'paused');
      expect(await statusOf(failed), 'error');
      expect(await statusOf(waiting), 'queued');
    });

    test('is safe to call with no downloads', () async {
      await manager.recoverInterruptedDownloads();
      expect(await repo.getAllDownloads(), isEmpty);
    });

    test('is safe to call twice', () async {
      final id = await insert('stuck.bin', 'downloading');
      await manager.recoverInterruptedDownloads();
      await manager.recoverInterruptedDownloads();
      expect((await repo.getDownloadById(id))!.status, 'queued');
    });
  });
}
