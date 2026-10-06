import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../../data/models/download_item.dart' as model;
import '../../data/repositories/download_repository.dart';
import '../../domain/services/download_manager.dart' show sortQueueBy;
import 'live_download_state.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository provider
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository(ref.watch(databaseProvider));
});

// All downloads stream
final allDownloadsProvider = StreamProvider<List<model.DownloadItem>>((ref) {
  return ref.watch(downloadRepositoryProvider).watchAllDownloads();
});

// Downloads by status
final downloadsByStatusProvider =
    StreamProvider.family<List<model.DownloadItem>, String>((ref, status) {
  return ref.watch(downloadRepositoryProvider).watchDownloadsByStatus(status);
});

// Downloads by category
final downloadsByCategoryProvider =
    StreamProvider.family<List<model.DownloadItem>, String>((ref, category) {
  return ref.watch(downloadRepositoryProvider).watchDownloadsByCategory(category);
});

// Active downloads count
final activeDownloadsCountProvider = Provider<int>((ref) {
  final downloads = ref.watch(allDownloadsProvider);
  return downloads.when(
    data: (list) => list.where((d) => d.isActive).length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

// Total speed — uses live state for real-time updates
final totalSpeedProvider = Provider<double>((ref) {
  final liveState = ref.watch(liveDownloadStateProvider);
  if (liveState.isNotEmpty) {
    return liveState.values.fold(0.0, (sum, d) => sum + d.speed);
  }
  final downloads = ref.watch(allDownloadsProvider);
  return downloads.when(
    data: (list) => list.fold(0.0, (sum, d) => sum + d.speed),
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Selected status filter
final selectedStatusFilterProvider = StateProvider<String?>((ref) => null);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Display order of the download list — changed from the toolbar's sort
/// button. Defaults to oldest-first (the historical behavior).
///
/// Keys match [sortQueueBy] so the same option set drives the list display
/// and the queue processing order.
final sortOrderProvider = StateProvider<String>((ref) => 'fifo');

// Filtered + sorted downloads
final filteredDownloadsProvider = Provider<AsyncValue<List<model.DownloadItem>>>((ref) {
  final downloads = ref.watch(allDownloadsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final statusFilter = ref.watch(selectedStatusFilterProvider);
  final sortOrder = ref.watch(sortOrderProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return downloads.whenData((list) {
    var filtered = list;

    if (category != null) {
      filtered = filtered.where((d) => d.category == category).toList();
    }

    if (statusFilter != null) {
      filtered = filtered.where((d) => d.status == statusFilter).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.fileName.toLowerCase().contains(query) ||
              d.url.toLowerCase().contains(query))
          .toList();
    }

    // sortQueueBy sorts in place — copy first so the source stream's list
    // is never mutated.
    final sorted = List<model.DownloadItem>.from(filtered);
    sortQueueBy(sorted, sortOrder);
    return sorted;
  });
});

// Selected download IDs (for multi-select)
final selectedDownloadIdsProvider = StateProvider<Set<int>>((ref) => {});
