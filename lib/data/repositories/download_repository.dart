import 'package:drift/drift.dart';

import '../../data/datasources/database.dart';
import '../models/download_item.dart' as model;
import '../models/download_segment.dart' as model;
import '../models/proxy_config.dart' as model;

class DownloadRepository {
  final AppDatabase _db;

  DownloadRepository(this._db);

  // --- Download Items ---

  Future<List<model.DownloadItem>> getAllDownloads() async {
    final rows = await _db.select(_db.downloadItems).get();
    return Future.wait(rows.map(_mapDownloadItem));
  }

  Stream<List<model.DownloadItem>> watchAllDownloads() {
    return _db.select(_db.downloadItems).watch().asyncMap(
      (rows) => Future.wait(rows.map(_mapDownloadItem)),
    );
  }

  Future<model.DownloadItem?> getDownloadById(int id) async {
    final row = await (_db.select(_db.downloadItems)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapDownloadItem(row);
  }

  Stream<List<model.DownloadItem>> watchDownloadsByStatus(String status) {
    return (_db.select(_db.downloadItems)
          ..where((t) => t.status.equals(status)))
        .watch()
        .asyncMap((rows) => Future.wait(rows.map(_mapDownloadItem)));
  }

  Stream<List<model.DownloadItem>> watchDownloadsByCategory(String category) {
    return (_db.select(_db.downloadItems)
          ..where((t) => t.category.equals(category)))
        .watch()
        .asyncMap((rows) => Future.wait(rows.map(_mapDownloadItem)));
  }

  Future<int> insertDownload(model.DownloadItem item) async {
    return _db.into(_db.downloadItems).insert(
      DownloadItemsCompanion.insert(
        url: item.url,
        fileName: item.fileName,
        savePath: item.savePath,
        totalSize: Value(item.totalSize),
        downloadedSize: Value(item.downloadedSize),
        status: Value(item.status),
        threadCount: Value(item.threadCount),
        speed: Value(item.speed),
        dateAdded: item.dateAdded,
        dateCompleted: Value(item.dateCompleted),
        category: Value(item.category),
        queueId: Value(item.queueId),
        errorMessage: Value(item.errorMessage),
        retryCount: Value(item.retryCount),
        customHeaders: Value(item.headersJson),
        proxyConfig: Value(item.proxy?.encode()),
        speedLimit: Value(item.speedLimit),
      ),
    );
  }

  Future<void> updateDownloadSettings(int id, {int? threadCount, int? speedLimit}) async {
    final companion = DownloadItemsCompanion(
      threadCount: threadCount != null ? Value(threadCount) : const Value.absent(),
      speedLimit: speedLimit != null ? Value(speedLimit) : const Value.absent(),
    );
    await (_db.update(_db.downloadItems)..where((t) => t.id.equals(id))).write(companion);
  }

  Future<void> updateDownload(model.DownloadItem item) async {
    await (_db.update(_db.downloadItems)..where((t) => t.id.equals(item.id!)))
        .write(
      DownloadItemsCompanion(
        url: Value(item.url),
        fileName: Value(item.fileName),
        savePath: Value(item.savePath),
        totalSize: Value(item.totalSize),
        downloadedSize: Value(item.downloadedSize),
        status: Value(item.status),
        threadCount: Value(item.threadCount),
        speed: Value(item.speed),
        dateCompleted: Value(item.dateCompleted),
        category: Value(item.category),
        queueId: Value(item.queueId),
        errorMessage: Value(item.errorMessage),
        retryCount: Value(item.retryCount),
        customHeaders: Value(item.headersJson),
        proxyConfig: Value(item.proxy?.encode()),
        speedLimit: Value(item.speedLimit),
      ),
    );
  }

  Future<void> updateDownloadStatus(int id, String status, {String? errorMessage}) async {
    await (_db.update(_db.downloadItems)..where((t) => t.id.equals(id)))
        .write(
      DownloadItemsCompanion(
        status: Value(status),
        errorMessage: Value(errorMessage),
        dateCompleted: status == 'completed' ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  Future<void> updateDownloadProgress(int id, int downloadedSize, double speed) async {
    await (_db.update(_db.downloadItems)..where((t) => t.id.equals(id)))
        .write(
      DownloadItemsCompanion(
        downloadedSize: Value(downloadedSize),
        speed: Value(speed),
      ),
    );
  }

  Future<void> updateDownloadSpeed(int id, double speed) async {
    await (_db.update(_db.downloadItems)..where((t) => t.id.equals(id)))
        .write(
      DownloadItemsCompanion(
        speed: Value(speed),
      ),
    );
  }

  Future<void> deleteDownload(int id) async {
    await (_db.delete(_db.downloadSegments)
          ..where((t) => t.downloadItemId.equals(id)))
        .go();
    await (_db.delete(_db.downloadItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllCompleted() async {
    final completed = await (_db.select(_db.downloadItems)
          ..where((t) => t.status.equals('completed')))
        .get();
    for (final item in completed) {
      await deleteDownload(item.id);
    }
  }

  // --- Segments ---

  Future<List<model.DownloadSegment>> getSegments(int downloadItemId) async {
    final rows = await (_db.select(_db.downloadSegments)
          ..where((t) => t.downloadItemId.equals(downloadItemId)))
        .get();
    return rows.map(_mapSegment).toList();
  }

  Future<void> insertSegments(List<model.DownloadSegment> segments) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.downloadSegments,
        segments.map(
          (s) => DownloadSegmentsCompanion.insert(
            downloadItemId: s.downloadItemId,
            startByte: s.startByte,
            endByte: s.endByte,
            downloadedBytes: Value(s.downloadedBytes),
            status: Value(s.status),
            tempFilePath: Value(s.tempFilePath),
          ),
        ),
      );
    });
  }

  Future<void> updateSegment(model.DownloadSegment segment) async {
    await (_db.update(_db.downloadSegments)
          ..where((t) => t.id.equals(segment.id!)))
        .write(
      DownloadSegmentsCompanion(
        downloadedBytes: Value(segment.downloadedBytes),
        status: Value(segment.status),
        tempFilePath: Value(segment.tempFilePath),
      ),
    );
  }

  Future<void> deleteSegments(int downloadItemId) async {
    await (_db.delete(_db.downloadSegments)
          ..where((t) => t.downloadItemId.equals(downloadItemId)))
        .go();
  }

  // --- Helpers ---

  Future<model.DownloadItem> _mapDownloadItem(DownloadItem row) async {
    final segments = await getSegments(row.id);
    return model.DownloadItem(
      id: row.id,
      url: row.url,
      fileName: row.fileName,
      savePath: row.savePath,
      totalSize: row.totalSize,
      downloadedSize: row.downloadedSize,
      status: row.status,
      threadCount: row.threadCount,
      speed: row.speed,
      dateAdded: row.dateAdded,
      dateCompleted: row.dateCompleted,
      category: row.category,
      queueId: row.queueId,
      errorMessage: row.errorMessage,
      retryCount: row.retryCount,
      headers: model.DownloadItem.headersFromJson(row.customHeaders),
      proxy: row.proxyConfig != null ? model.ProxyConfig.decode(row.proxyConfig!) : null,
      speedLimit: row.speedLimit,
      segments: segments,
    );
  }

  model.DownloadSegment _mapSegment(DownloadSegment row) {
    return model.DownloadSegment(
      id: row.id,
      downloadItemId: row.downloadItemId,
      startByte: row.startByte,
      endByte: row.endByte,
      downloadedBytes: row.downloadedBytes,
      status: row.status,
      tempFilePath: row.tempFilePath,
    );
  }
}
