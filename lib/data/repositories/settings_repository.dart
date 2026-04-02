import '../../data/datasources/database.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<String> getValue(String key) async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? AppSettings.defaults[key] ?? '';
  }

  Future<int> getIntValue(String key) async {
    final value = await getValue(key);
    return int.tryParse(value) ?? 0;
  }

  Future<bool> getBoolValue(String key) async {
    final value = await getValue(key);
    return value == 'true';
  }

  Future<double> getDoubleValue(String key) async {
    final value = await getValue(key);
    return double.tryParse(value) ?? 0.0;
  }

  Future<void> setValue(String key, String value) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
      AppSettingsTableCompanion.insert(
        key: key,
        value: value,
      ),
    );
  }

  Future<void> setIntValue(String key, int value) async {
    await setValue(key, value.toString());
  }

  Future<void> setBoolValue(String key, bool value) async {
    await setValue(key, value.toString());
  }

  Future<Map<String, String>> getAllSettings() async {
    final rows = await _db.select(_db.appSettingsTable).get();
    final map = <String, String>{};
    // Start with defaults
    map.addAll(AppSettings.defaults);
    // Override with stored values
    for (final row in rows) {
      map[row.key] = row.value;
    }
    return map;
  }

  Future<void> seedDefaults() async {
    for (final entry in AppSettings.defaults.entries) {
      final existing = await (_db.select(_db.appSettingsTable)
            ..where((t) => t.key.equals(entry.key)))
          .getSingleOrNull();
      if (existing == null) {
        await setValue(entry.key, entry.value);
      }
    }
  }

  Stream<String> watchValue(String key) {
    return (_db.select(_db.appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value ?? AppSettings.defaults[key] ?? '');
  }
}
