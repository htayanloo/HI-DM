import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final String status;
  final double size;

  const StatusIcon({
    super.key,
    required this.status,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Icon(
      _getIcon(),
      size: size,
      color: _getColor(isDark),
    );
  }

  IconData _getIcon() {
    return switch (status) {
      'downloading' => Icons.downloading,
      'completed' => Icons.check_circle,
      'paused' => Icons.pause_circle,
      'error' => Icons.error,
      'queued' => Icons.hourglass_empty,
      'connecting' => Icons.sync,
      'assembling' || 'merging' => Icons.build_circle,
      _ => Icons.download,
    };
  }

  Color _getColor(bool isDark) {
    return switch (status) {
      'downloading' => isDark ? Colors.cyanAccent : Colors.blue,
      'completed' => Colors.green,
      'paused' => Colors.amber,
      'error' => Colors.red,
      'connecting' => isDark ? Colors.lightBlueAccent : Colors.blueAccent,
      'assembling' || 'merging' => Colors.purple,
      _ => Colors.grey,
    };
  }
}
