import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/category_repository.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/services/download_manager.dart';
import '../../domain/services/download_message.dart';
import 'download_providers.dart';

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final db = ref.watch(databaseProvider);
  final manager = DownloadManager(
    downloadRepo: DownloadRepository(db),
    categoryRepo: CategoryRepository(db),
    settingsRepo: SettingsRepository(db),
  );
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Stream of download events from all active downloads.
final downloadEventsProvider = StreamProvider<DownloadEvent>((ref) {
  return ref.watch(downloadManagerProvider).events;
});
