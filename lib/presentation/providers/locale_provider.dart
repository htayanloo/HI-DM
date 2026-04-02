import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';
import 'download_providers.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final settingsRepo = SettingsRepository(ref.watch(databaseProvider));
  return LocaleNotifier(settingsRepo);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _settingsRepo;

  LocaleNotifier(this._settingsRepo) : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final value = await _settingsRepo.getValue(AppSettings.locale);
    state = Locale(value.isEmpty ? 'en' : value);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _settingsRepo.setValue(AppSettings.locale, locale.languageCode);
  }
}
