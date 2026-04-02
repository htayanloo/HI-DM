import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_providers.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return ThemeModeNotifier(settingsRepo);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _settingsRepo;

  ThemeModeNotifier(this._settingsRepo) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final value = await _settingsRepo.getValue(AppSettings.themeMode);
    state = _parseThemeMode(value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _settingsRepo.setValue(AppSettings.themeMode, mode.name);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
