import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';
import 'download_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final settingProvider = FutureProvider.family<String, String>((ref, key) {
  return ref.watch(settingsRepositoryProvider).getValue(key);
});

final allSettingsProvider = FutureProvider<Map<String, String>>((ref) {
  return ref.watch(settingsRepositoryProvider).getAllSettings();
});

// Convenience providers for common settings
final defaultThreadCountProvider = FutureProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).getIntValue(AppSettings.defaultThreadCount);
});

final clipboardMonitoringProvider = FutureProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).getBoolValue(AppSettings.clipboardMonitoring);
});

final speedLimitEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).getBoolValue(AppSettings.speedLimitEnabled);
});

final speedLimitValueProvider = FutureProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).getIntValue(AppSettings.speedLimitValue);
});
