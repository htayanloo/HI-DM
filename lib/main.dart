import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'platform/desktop/window_config.dart';

import 'app.dart';
import 'data/models/app_settings.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/queue_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/providers/download_providers.dart';

Future<void> main() async {
  // Global error handlers — app must NEVER crash
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[HI-DM] Flutter error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[HI-DM] Unhandled error: $error');
    debugPrint('[HI-DM] Stack: $stack');
    return true; // Handled — don't crash
  };

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await WindowConfig.initialize();
      }
    } catch (e) {
      debugPrint('[HI-DM] Window init error (non-fatal): $e');
    }

    final container = ProviderContainer();

    try {
      await _seedDefaults(container);
    } catch (e) {
      debugPrint('[HI-DM] Seed defaults error (non-fatal): $e');
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const HiDMApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('[HI-DM] Zone error: $error');
    debugPrint('[HI-DM] Stack: $stack');
  });
}

Future<void> _seedDefaults(ProviderContainer container) async {
  final db = container.read(databaseProvider);
  final docsDir = await getApplicationDocumentsDirectory();
  final basePath = '${docsDir.path}/HI-DM';

  final categoryRepo = CategoryRepository(db);
  await categoryRepo.seedDefaults(basePath);

  final queueRepo = QueueRepository(db);
  await queueRepo.seedDefaults();

  final settingsRepo = SettingsRepository(db);
  await settingsRepo.seedDefaults();

  // Set default save path to ~/Downloads/HI-DM if not already set
  try {
    final currentSavePath = await settingsRepo.getValue(AppSettings.defaultSavePath);
    if (currentSavePath.isEmpty) {
      final home = Platform.environment['HOME'] ?? docsDir.path;
      final downloadsDir = '$home/Downloads/HI-DM';
      await Directory(downloadsDir).create(recursive: true);
      await settingsRepo.setValue(AppSettings.defaultSavePath, downloadsDir);
    }
  } catch (e) {
    debugPrint('[HI-DM] Default save path error: $e');
  }
}
