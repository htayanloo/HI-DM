import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/download_queue.dart';
import '../../data/repositories/queue_repository.dart';
import 'download_providers.dart';

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepository(ref.watch(databaseProvider));
});

final allQueuesProvider = StreamProvider<List<DownloadQueue>>((ref) {
  return ref.watch(queueRepositoryProvider).watchAllQueues();
});

final selectedQueueProvider = StateProvider<int?>((ref) => null);
