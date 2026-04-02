import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/speed_formatter.dart';

class SpeedGraph extends StatelessWidget {
  final List<double> speedHistory; // last 60 speed samples (1 per second)
  final double averageSpeed;

  const SpeedGraph({
    super.key,
    required this.speedHistory,
    required this.averageSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = speedHistory.isEmpty
        ? 1.0
        : speedHistory.reduce((a, b) => a > b ? a : b) * 1.2;

    final spots = <FlSpot>[];
    for (var i = 0; i < speedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), speedHistory[i]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Speed: ${SpeedFormatter.format(speedHistory.isNotEmpty ? speedHistory.last : 0)}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Average: ${SpeedFormatter.format(averageSpeed)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 59,
                minY: 0,
                maxY: maxY.clamp(1024, double.infinity),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          SpeedFormatter.format(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      interval: maxY > 0 ? maxY / 4 : 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 15,
                      getTitlesWidget: (value, meta) {
                        final secondsAgo = 59 - value.toInt();
                        return Text(
                          '${secondsAgo}s',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: theme.dividerColor),
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                lineBarsData: [
                  // Speed line
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: theme.colorScheme.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  // Average line
                  LineChartBarData(
                    spots: [FlSpot(0, averageSpeed), FlSpot(59, averageSpeed)],
                    isCurved: false,
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                    barWidth: 1,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex != 0) return null;
                        return LineTooltipItem(
                          SpeedFormatter.format(spot.y),
                          TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 150),
            ),
          ),
        ),
      ],
    );
  }
}
