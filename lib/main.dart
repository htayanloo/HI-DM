import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'platform/desktop/window_config.dart';

import 'app.dart';
import 'core/utils/seed_utils.dart';
import 'data/models/app_settings.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/queue_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'domain/services/notification_service.dart';
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

    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('[HI-DM] Notification init error (non-fatal): $e');
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

  // Resolve (and create) the default base dir first — falls back to the
  // sandbox container when the real Downloads folder isn't writable.
  final basePath = await _createOrFallback(await _defaultBasePath());

  final categoryRepo = CategoryRepository(db);
  await categoryRepo.seedDefaults(basePath);

  final queueRepo = QueueRepository(db);
  await queueRepo.seedDefaults();

  final settingsRepo = SettingsRepository(db);
  await settingsRepo.seedDefaults();

  // Only seed the default save path when the user has NEVER customized it.
  // A user-chosen path must never be overwritten on startup — that was the
  // bug where the path reset to the default on every relaunch.
  try {
    final customized =
        await settingsRepo.getBoolValue(AppSettings.savePathCustomized);
    final currentSavePath =
        await settingsRepo.getValue(AppSettings.defaultSavePath);

    if (SeedUtils.shouldSeedSavePath(
      customized: customized,
      currentPath: currentSavePath,
      containerHome: _containerHome(),
    )) {
      await settingsRepo.setValue(AppSettings.defaultSavePath, basePath);
    }
  } catch (e) {
    debugPrint('[HI-DM] Default save path error: $e');
  }
}

/// Create [path], returning the directory that was actually created.
/// Falls back to a path inside the sandbox container when the real
/// location cannot be written (missing entitlement, read-only volume).
Future<String> _createOrFallback(String path) async {
  try {
    await Directory(path).create(recursive: true);
    return path;
  } catch (e) {
    debugPrint('[HI-DM] Could not create $path ($e) — falling back');
    final fallback = '${_containerHome()}/Downloads/HI-DM';
    await Directory(fallback).create(recursive: true);
    return fallback;
  }
}

/// The sandbox container home (or plain $HOME when not sandboxed).
String _containerHome() {
  final home = Platform.environment['HOME'] ?? '/tmp';
  if (home.contains('/Containers/') || home.contains('/.sandboxed/')) {
    return home;
  }
  return '$home/__no_such_dir__';
}

/// The real user home directory.
///
/// Inside the macOS app sandbox `$HOME` points at
/// `<real home>/Library/Containers/<bundle>/Data`, which makes every default
/// path land in a folder the user can't see in Finder. Strip the container
/// suffix to recover the real home.
String _realHome() {
  final home = Platform.environment['HOME'] ?? '/tmp';
  final match = RegExp(r'^(.*?)/Library/Containers/[^/]+/Data')
      .firstMatch(home);
  return match?.group(1) ?? home;
}

/// Resolve a stable, user-visible default base path: `<user Downloads>/HI-DM`.
Future<String> _defaultBasePath() async {
  // Prefer path_provider's answer when it points outside the container.
  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null && !downloads.path.contains('/Containers/')) {
      return '${downloads.path}/HI-DM';
    }
  } catch (_) {}
  // Derive the real Downloads folder even when sandboxed.
  return '${_realHome()}/Downloads/HI-DM';
}
