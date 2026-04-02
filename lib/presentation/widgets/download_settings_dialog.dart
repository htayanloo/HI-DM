import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/speed_formatter.dart';
import '../../data/models/download_item.dart';
import '../providers/download_manager_provider.dart';

/// Dialog for per-download settings: connection count and speed limit.
class DownloadSettingsDialog extends ConsumerStatefulWidget {
  final DownloadItem item;

  const DownloadSettingsDialog({super.key, required this.item});

  @override
  ConsumerState<DownloadSettingsDialog> createState() => _DownloadSettingsDialogState();
}

class _DownloadSettingsDialogState extends ConsumerState<DownloadSettingsDialog> {
  late int _threadCount;
  late bool _hasSpeedLimit;
  late double _speedLimitKBs; // in KB/s for slider

  @override
  void initState() {
    super.initState();
    _threadCount = widget.item.threadCount;
    _hasSpeedLimit = widget.item.speedLimit > 0;
    _speedLimitKBs = widget.item.speedLimit > 0
        ? (widget.item.speedLimit / 1024).clamp(1, 102400)
        : 512;
  }

  Future<void> _save() async {
    final speedLimitBytes = _hasSpeedLimit ? (_speedLimitKBs * 1024).round() : 0;
    final manager = ref.read(downloadManagerProvider);
    await manager.updateDownloadSettings(
      widget.item.id!,
      threadCount: _threadCount,
      speedLimit: speedLimitBytes,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded, size: 20, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Download Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          widget.item.fileName,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Connection count
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cable_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Connections', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_threadCount',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
                      child: Slider(
                        value: _threadCount.toDouble(),
                        min: 1,
                        max: 32,
                        divisions: 31,
                        label: '$_threadCount',
                        onChanged: (v) => setState(() => _threadCount = v.round()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          Text('8', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          Text('16', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          Text('24', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          Text('32', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Speed limit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Speed Limit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const Spacer(),
                        Switch(
                          value: _hasSpeedLimit,
                          onChanged: (v) => setState(() => _hasSpeedLimit = v),
                        ),
                      ],
                    ),
                    if (_hasSpeedLimit) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
                              child: Slider(
                                value: _speedLimitKBs.clamp(1, 102400),
                                min: 1,
                                max: 102400,
                                onChanged: (v) => setState(() => _speedLimitKBs = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              SpeedFormatter.format(_speedLimitKBs * 1024),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Limit download speed for this file only',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'No limit (uses global setting if enabled)',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info about current state
              if (widget.item.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Speed limit changes apply immediately. Connection count changes take effect on next start.',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.tertiary),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
