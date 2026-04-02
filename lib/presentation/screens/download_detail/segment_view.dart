import 'package:flutter/material.dart';

import '../../../core/utils/size_formatter.dart';
import '../../../data/models/download_segment.dart';
import '../../widgets/segment_progress_bar.dart';

class SegmentView extends StatelessWidget {
  final List<DownloadSegment> segments;
  final int totalSize;

  const SegmentView({
    super.key,
    required this.segments,
    required this.totalSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Visual progress bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Segment Progress', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentProgressBar(
                segments: segments,
                totalSize: totalSize,
                height: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '${segments.length} segment(s)',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Segment table
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 32,
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Downloaded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              ],
              rows: segments.asMap().entries.map((entry) {
                final i = entry.key;
                final seg = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('$i', style: const TextStyle(fontSize: 11))),
                    DataCell(Text(
                      '${SizeFormatter.formatCompact(seg.startByte)} - ${SizeFormatter.formatCompact(seg.endByte)}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    )),
                    DataCell(Text(
                      SizeFormatter.format(seg.downloadedBytes),
                      style: const TextStyle(fontSize: 11),
                    )),
                    DataCell(Text(
                      '${(seg.progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 11),
                    )),
                    DataCell(_buildStatusChip(seg.status, theme)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final color = switch (status) {
      'completed' => Colors.green,
      'downloading' => theme.colorScheme.primary,
      'error' => Colors.red,
      'pending' => Colors.grey,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
