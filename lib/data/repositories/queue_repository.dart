import 'package:drift/drift.dart';

import '../../data/datasources/database.dart';
import '../models/download_queue.dart' as model;
import '../models/schedule_config.dart' as model;

class QueueRepository {
  final AppDatabase _db;

  QueueRepository(this._db);

  Future<List<model.DownloadQueue>> getAllQueues() async {
    final rows = await _db.select(_db.downloadQueues).get();
    return rows.map(_mapQueue).toList();
  }

  Stream<List<model.DownloadQueue>> watchAllQueues() {
    return _db.select(_db.downloadQueues).watch().map(
          (rows) => rows.map(_mapQueue).toList(),
        );
  }

  Future<model.DownloadQueue?> getQueueById(int id) async {
    final row = await (_db.select(_db.downloadQueues)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapQueue(row);
  }

  Future<int> insertQueue(model.DownloadQueue queue) async {
    return _db.into(_db.downloadQueues).insert(
      DownloadQueuesCompanion.insert(
        name: queue.name,
        maxConcurrent: Value(queue.maxConcurrent),
        scheduleConfig: Value(queue.schedule?.encode()),
        postAction: Value(queue.postAction),
        postActionProgram: Value(queue.postActionProgram),
        isActive: Value(queue.isActive),
      ),
    );
  }

  Future<void> updateQueue(model.DownloadQueue queue) async {
    await (_db.update(_db.downloadQueues)
          ..where((t) => t.id.equals(queue.id!)))
        .write(
      DownloadQueuesCompanion(
        name: Value(queue.name),
        maxConcurrent: Value(queue.maxConcurrent),
        scheduleConfig: Value(queue.schedule?.encode()),
        postAction: Value(queue.postAction),
        postActionProgram: Value(queue.postActionProgram),
        isActive: Value(queue.isActive),
      ),
    );
  }

  Future<void> deleteQueue(int id) async {
    await (_db.delete(_db.downloadQueues)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setQueueActive(int id, bool active) async {
    await (_db.update(_db.downloadQueues)..where((t) => t.id.equals(id)))
        .write(DownloadQueuesCompanion(isActive: Value(active)));
  }

  Future<void> seedDefaults() async {
    final existing = await getAllQueues();
    if (existing.isNotEmpty) return;

    await insertQueue(const model.DownloadQueue(
      name: 'Main Queue',
      maxConcurrent: 3,
      postAction: 'nothing',
    ));
  }

  model.DownloadQueue _mapQueue(DownloadQueue row) {
    return model.DownloadQueue(
      id: row.id,
      name: row.name,
      maxConcurrent: row.maxConcurrent,
      schedule: row.scheduleConfig != null
          ? model.ScheduleConfig.decode(row.scheduleConfig!)
          : null,
      postAction: row.postAction,
      postActionProgram: row.postActionProgram,
      isActive: row.isActive,
    );
  }
}
