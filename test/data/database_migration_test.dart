import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// Hide the generated row class — this test builds the DB itself.
import 'package:flutter_dm/data/datasources/database.dart' hide DownloadItem;

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('hi_dm_migration_test');
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('fresh database creates schema v3 without errors', () async {
    final db = AppDatabase.forTesting(
      NativeDatabase(File('${tempDir.path}/fresh.db')),
    );
    addTearDown(db.close);

    await db.select(db.downloadItems).get();

    final version = await db.customSelect('PRAGMA user_version;').getSingle();
    expect(version.read<int>('user_version'), 3);
  });

  test('upgrade skips columns that already exist (stale schema marker)',
      () async {
    final path = '${tempDir.path}/skewed.db';

    // 1. Create a fully-migrated v3 database first.
    final created = AppDatabase.forTesting(NativeDatabase(File(path)));
    await created.select(created.downloadItems).get();
    await created.close();

    // 2. Simulate the field failure: the file physically has the columns,
    //    but its schema marker still says 2.
    final marker = AppDatabase.forTesting(NativeDatabase(File(path)));
    await marker.customStatement('PRAGMA user_version = 2;');
    await marker.close();

    // 3. Opening must migrate WITHOUT throwing:
    //    "SqliteException(1): duplicate column name: stream_mode".
    final reopened = AppDatabase.forTesting(NativeDatabase(File(path)));
    addTearDown(reopened.close);

    final rows = await reopened.select(reopened.downloadItems).get();
    expect(rows, isEmpty);

    final version =
        await reopened.customSelect('PRAGMA user_version;').getSingle();
    expect(version.read<int>('user_version'), 3);
  });
}
