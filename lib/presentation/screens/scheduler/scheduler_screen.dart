import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/download_queue.dart';
import '../../../domain/enums/post_action.dart';
import '../../providers/queue_providers.dart';
import 'queue_editor.dart';

class SchedulerScreen extends ConsumerWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queues = ref.watch(allQueuesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Queue',
            onPressed: () => _showQueueEditor(context, ref, null),
          ),
        ],
      ),
      body: queues.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No queues configured'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _buildQueueCard(context, ref, theme, list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildQueueCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    DownloadQueue queue,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  queue.isActive ? Icons.play_circle : Icons.pause_circle,
                  color: queue.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(queue.name, style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  label: Text('Max: ${queue.maxConcurrent}'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Post-action: ${PostAction.values.firstWhere((e) => e.name == queue.postAction, orElse: () => PostAction.nothing).label}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
                if (queue.schedule != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Scheduled',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(queue.isActive ? Icons.stop : Icons.play_arrow, size: 18),
                  label: Text(queue.isActive ? 'Stop' : 'Start'),
                  onPressed: () {
                    ref.read(queueRepositoryProvider).setQueueActive(queue.id!, !queue.isActive);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  onPressed: () => _showQueueEditor(context, ref, queue),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Queue'),
                        content: Text('Delete "${queue.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(queueRepositoryProvider).deleteQueue(queue.id!);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQueueEditor(BuildContext context, WidgetRef ref, DownloadQueue? existing) {
    showDialog(
      context: context,
      builder: (_) => QueueEditorDialog(queue: existing),
    );
  }
}
