import 'package:drift/drift.dart';

import '../../data/datasources/database.dart';
import '../models/download_category.dart' as model;

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Future<List<model.DownloadCategory>> getAllCategories() async {
    final rows = await _db.select(_db.downloadCategories).get();
    return rows.map(_mapCategory).toList();
  }

  Stream<List<model.DownloadCategory>> watchAllCategories() {
    return _db.select(_db.downloadCategories).watch().map(
          (rows) => rows.map(_mapCategory).toList(),
        );
  }

  Future<model.DownloadCategory?> getCategoryById(int id) async {
    final row = await (_db.select(_db.downloadCategories)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapCategory(row);
  }

  Future<model.DownloadCategory?> matchCategory(String fileName) async {
    final categories = await getAllCategories();
    for (final cat in categories) {
      if (cat.matchesExtension(fileName)) return cat;
    }
    return null;
  }

  Future<int> insertCategory(model.DownloadCategory category) async {
    return _db.into(_db.downloadCategories).insert(
      DownloadCategoriesCompanion.insert(
        name: category.name,
        fileExtensions: category.fileExtensions,
        defaultSavePath: category.defaultSavePath,
        icon: Value(category.icon),
      ),
    );
  }

  Future<void> updateCategory(model.DownloadCategory category) async {
    await (_db.update(_db.downloadCategories)
          ..where((t) => t.id.equals(category.id!)))
        .write(
      DownloadCategoriesCompanion(
        name: Value(category.name),
        fileExtensions: Value(category.fileExtensions),
        defaultSavePath: Value(category.defaultSavePath),
        icon: Value(category.icon),
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.downloadCategories)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> seedDefaults(String baseSavePath) async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;

    final defaults = [
      model.DownloadCategory(
        name: 'Documents',
        fileExtensions: '.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.rtf,.odt',
        defaultSavePath: '$baseSavePath/Documents',
        icon: 'description',
      ),
      model.DownloadCategory(
        name: 'Compressed',
        fileExtensions: '.zip,.rar,.7z,.tar,.gz,.bz2,.xz,.tgz',
        defaultSavePath: '$baseSavePath/Compressed',
        icon: 'folder_zip',
      ),
      model.DownloadCategory(
        name: 'Music',
        fileExtensions: '.mp3,.wav,.flac,.aac,.ogg,.wma,.m4a',
        defaultSavePath: '$baseSavePath/Music',
        icon: 'music_note',
      ),
      model.DownloadCategory(
        name: 'Video',
        fileExtensions: '.mp4,.mkv,.avi,.mov,.wmv,.webm,.flv,.m4v',
        defaultSavePath: '$baseSavePath/Video',
        icon: 'movie',
      ),
      model.DownloadCategory(
        name: 'Programs',
        fileExtensions: '.exe,.msi,.dmg,.deb,.rpm,.apk,.appimage,.snap',
        defaultSavePath: '$baseSavePath/Programs',
        icon: 'apps',
      ),
      model.DownloadCategory(
        name: 'Images',
        fileExtensions: '.jpg,.jpeg,.png,.gif,.svg,.webp,.bmp,.ico,.tiff',
        defaultSavePath: '$baseSavePath/Images',
        icon: 'image',
      ),
    ];

    for (final cat in defaults) {
      await insertCategory(cat);
    }
  }

  model.DownloadCategory _mapCategory(DownloadCategory row) {
    return model.DownloadCategory(
      id: row.id,
      name: row.name,
      fileExtensions: row.fileExtensions,
      defaultSavePath: row.defaultSavePath,
      icon: row.icon,
    );
  }
}
