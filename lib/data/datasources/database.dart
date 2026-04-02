import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';

part 'database.g.dart';

// --- Tables ---

class DownloadItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get fileName => text()();
  TextColumn get savePath => text()();
  IntColumn get totalSize => integer().withDefault(const Constant(-1))();
  IntColumn get downloadedSize => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get threadCount => integer().withDefault(const Constant(8))();
  RealColumn get speed => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get dateCompleted => dateTime().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get queueId => integer().nullable().references(DownloadQueues, #id)();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get customHeaders => text().withDefault(const Constant('{}'))();
  TextColumn get proxyConfig => text().nullable()();
  IntColumn get speedLimit => integer().withDefault(const Constant(0))(); // bytes/sec, 0=unlimited
}

class DownloadSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get downloadItemId => integer().references(DownloadItems, #id)();
  IntColumn get startByte => integer()();
  IntColumn get endByte => integer()();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get tempFilePath => text().withDefault(const Constant(''))();
}

class DownloadQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get maxConcurrent => integer().withDefault(const Constant(3))();
  TextColumn get scheduleConfig => text().nullable()();
  TextColumn get postAction => text().withDefault(const Constant('nothing'))();
  TextColumn get postActionProgram => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
}

class DownloadCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get fileExtensions => text()();
  TextColumn get defaultSavePath => text()();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
}

class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// --- Database ---

@DriftDatabase(tables: [
  DownloadItems,
  DownloadSegments,
  DownloadQueues,
  DownloadCategories,
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add speedLimit column to download_items
        await m.addColumn(downloadItems, downloadItems.speedLimit);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
