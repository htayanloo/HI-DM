import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/size_formatter.dart';
import '../../core/utils/speed_formatter.dart';
import '../../data/models/download_item.dart';
import '../providers/live_download_state.dart';

class DownloadTile extends ConsumerWidget {
  final DownloadItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final void Function(TapDownDetails)? onSecondaryTapDown;

  const DownloadTile({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use live data if available (real-time from isolate), fallback to DB data
    final liveData = item.id != null ? ref.watch(liveDownloadDataProvider(item.id!)) : null;
    final speed = liveData?.speed ?? item.speed;
    final downloadedBytes = liveData?.downloadedBytes ?? item.downloadedSize;
    final totalBytes = (liveData?.totalBytes ?? item.totalSize);
    final progress = totalBytes > 0 ? (downloadedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;
    final isActive = liveData != null
        ? (liveData.status == 'downloading' || liveData.status == 'connecting')
        : item.isActive;
    final status = liveData?.status ?? item.status;
    final segments = liveData?.segments ?? {};
    final statusColor = _getStatusColor(status, isDark);

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onSecondaryTapDown: onSecondaryTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: statusColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _buildStatusIndicator(theme, statusColor, isActive, progress),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Filename + category
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (item.category != null)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.category!,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.colorScheme.onSecondaryContainer),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row 2: Overall progress bar
                        if (totalBytes > 0)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 6,
                              child: Stack(
                                children: [
                                  Container(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: status == 'completed'
                                              ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                                              : [statusColor, statusColor.withValues(alpha: 0.7)],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Row 3: Per-segment connection bars (IDM style) — only when downloading
                        if (isActive && segments.isNotEmpty && totalBytes > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _buildSegmentBars(theme, segments, totalBytes, statusColor),
                          ),

                        const SizedBox(height: 8),

                        // Row 4: Info row
                        Row(
                          children: [
                            // Size + progress %
                            Text(
                              _buildSizeText(status, downloadedBytes, totalBytes, progress),
                              style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                            ),
                            // ETA
                            if (isActive && speed > 0 && totalBytes > 0) ...[
                              _dot(theme),
                              Text(
                                SpeedFormatter.formatEta(Duration(
                                  seconds: ((totalBytes - downloadedBytes) / speed).ceil(),
                                )),
                                style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                            // Connection count
                            if (isActive && segments.isNotEmpty) ...[
                              _dot(theme),
                              Icon(Icons.cable_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(width: 2),
                              Text(
                                '${segments.values.where((s) => s.status == "downloading").length}/${segments.length}',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                            const Spacer(),
                            // Speed badge
                            if (isActive && speed > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_downward_rounded, size: 12, color: statusColor),
                                    const SizedBox(width: 3),
                                    Text(
                                      SpeedFormatter.format(speed),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                    ),
                                  ],
                                ),
                              )
                            else if (status == 'error')
                              _statusBadge(Icons.error_outline, 'Failed', theme.colorScheme.error)
                            else if (status == 'completed')
                              _statusBadge(Icons.check_circle, 'Done', const Color(0xFF10B981))
                            else if (status == 'paused')
                              _statusBadge(Icons.pause_circle_outline, 'Paused', _getStatusColor('paused', isDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// IDM-style per-segment mini progress bars
  Widget _buildSegmentBars(ThemeData theme, Map<int, LiveSegmentData> segments, int totalBytes, Color statusColor) {
    final sortedSegments = segments.values.toList()..sort((a, b) => a.index.compareTo(b.index));

    return Row(
      children: [
        for (var i = 0; i < sortedSegments.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Tooltip(
              message: 'Conn ${sortedSegments[i].index + 1}: ${SizeFormatter.formatCompact(sortedSegments[i].downloadedBytes)} (${sortedSegments[i].status})',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _segmentProgress(sortedSegments[i]),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation(_segmentColor(sortedSegments[i], statusColor)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  double _segmentProgress(LiveSegmentData seg) {
    if (seg.status == 'completed') return 1.0;
    // We don't know individual segment total here, show indeterminate-ish
    // Just show relative based on bytes downloaded
    return seg.downloadedBytes > 0 ? 0.5 : 0.0; // simplified
  }

  Color _segmentColor(LiveSegmentData seg, Color activeColor) {
    return switch (seg.status) {
      'completed' => const Color(0xFF10B981),
      'downloading' => activeColor,
      'error' => const Color(0xFFEF4444),
      _ => Colors.grey,
    };
  }

  Widget _dot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3, height: 3,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _statusBadge(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, Color statusColor, bool isActive, double progress) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isActive
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 2.5,
                  color: statusColor,
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                ),
              )
            : Icon(_getStatusIcon(), size: 20, color: statusColor),
      ),
    );
  }

  IconData _getStatusIcon() {
    return switch (item.status) {
      'completed' => Icons.check_rounded,
      'paused' => Icons.pause_rounded,
      'error' => Icons.close_rounded,
      'queued' => Icons.schedule_rounded,
      'assembling' || 'merging' => Icons.build_rounded,
      _ => Icons.download_rounded,
    };
  }

  String _buildSizeText(String status, int downloaded, int total, double progress) {
    if (status == 'completed') return SizeFormatter.format(total);
    if (total > 0) {
      return '${SizeFormatter.format(downloaded)} / ${SizeFormatter.format(total)}'
          '  (${(progress * 100).toStringAsFixed(1)}%)';
    }
    if (downloaded > 0) return SizeFormatter.format(downloaded);
    return 'Waiting...';
  }

  static Color _getStatusColor(String status, bool isDark) {
    return switch (status) {
      'downloading' || 'connecting' => isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
      'completed' => const Color(0xFF10B981),
      'paused' => isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
      'error' => isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444),
      'assembling' || 'merging' => isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6),
      'queued' => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      _ => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    };
  }
}
