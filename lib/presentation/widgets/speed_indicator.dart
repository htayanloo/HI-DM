import 'package:flutter/material.dart';

import '../../core/utils/speed_formatter.dart';

class SpeedIndicator extends StatelessWidget {
  final double bytesPerSecond;
  final TextStyle? style;

  const SpeedIndicator({
    super.key,
    required this.bytesPerSecond,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          bytesPerSecond > 0 ? Icons.speed : Icons.speed_outlined,
          size: 14,
          color: bytesPerSecond > 0
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          SpeedFormatter.format(bytesPerSecond),
          style: style ?? TextStyle(
            fontSize: 12,
            color: bytesPerSecond > 0
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}
