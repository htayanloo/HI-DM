import 'package:flutter/material.dart';

import '../../data/models/download_segment.dart';

class SegmentProgressBar extends StatelessWidget {
  final List<DownloadSegment> segments;
  final int totalSize;
  final double height;

  const SegmentProgressBar({
    super.key,
    required this.segments,
    required this.totalSize,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSize <= 0 || segments.isEmpty) {
      return SizedBox(
        height: height,
        child: const LinearProgressIndicator(value: 0),
      );
    }

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: CustomPaint(
          size: Size(double.infinity, height),
          painter: _SegmentPainter(
            segments: segments,
            totalSize: totalSize,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            downloadingColor: Theme.of(context).colorScheme.primary,
            completedColor: Colors.green,
            errorColor: Colors.red,
          ),
        ),
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  final List<DownloadSegment> segments;
  final int totalSize;
  final Color backgroundColor;
  final Color downloadingColor;
  final Color completedColor;
  final Color errorColor;

  _SegmentPainter({
    required this.segments,
    required this.totalSize,
    required this.backgroundColor,
    required this.downloadingColor,
    required this.completedColor,
    required this.errorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    if (totalSize <= 0) return;

    for (final segment in segments) {
      final startFraction = segment.startByte / totalSize;
      final downloadedFraction = segment.downloadedBytes / totalSize;

      final x = startFraction * size.width;
      final w = downloadedFraction * size.width;

      final color = switch (segment.status) {
        'completed' => completedColor,
        'error' => errorColor,
        'downloading' => downloadingColor,
        _ => downloadingColor.withValues(alpha: 0.3),
      };

      canvas.drawRect(
        Rect.fromLTWH(x, 0, w, size.height),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) => true;
}
