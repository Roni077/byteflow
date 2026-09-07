/// Interactive bar chart visualization powered by fl_chart.
library;

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Bar chart rendering historical network usage with interactive tooltips.
class UsageBarChart extends StatelessWidget {
  /// Creates a [UsageBarChart] with the specified [report] and active [metric].
  const UsageBarChart({
    required this.report,
    required this.metric,
    super.key,
  });

  /// The active historical analytics report.
  final HistoryReport report;

  /// The active metric filter.
  final HistoryMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = report.dataPoints;

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine maximal value to scale the Y-axis comfortably
    int maxBytes = 0;
    for (final p in points) {
      if (p.value > maxBytes) maxBytes = p.value;
    }

    final (unitLabel, divisor) = _resolveScale(maxBytes);
    final rawMaxY = maxBytes / divisor;
    final maxY = rawMaxY <= 0 ? 5.0 : rawMaxY * 1.25;

    final primaryColor = _metricColor(metric, theme);

    // Calculate bar width based on bucket density
    final barWidth = points.length <= 7
        ? 18.0
        : points.length <= 15
            ? 12.0
            : points.length <= 24
                ? 7.0
                : 5.0;

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final toY = p.value / divisor;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: toY,
              color: primaryColor,
              width: barWidth,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    // Interval for bottom labels to avoid text overlapping
    final labelInterval = math.max(1, (points.length / 6).ceil());

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 0.8,
                dashArray: const [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: maxY > 0 ? maxY / 4 : 1,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value >= maxY * 0.98) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '${value.toStringAsFixed(value < 10 ? 1 : 0)} $unitLabel',
                      style: AppTheme.tabularMetricStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }

                    // Display spaced subset of labels
                    if (index % labelInterval != 0 && index != points.length - 1) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        points[index].label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (group) => theme.colorScheme.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final point = points[group.x.toInt()];
                  return BarTooltipItem(
                    '${point.label}\n',
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    children: [
                      TextSpan(
                        text: Formatters.formatBytes(point.value),
                        style: AppTheme.tabularMetricStyle(
                          color: theme.colorScheme.primaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  (String unit, double divisor) _resolveScale(int bytes) {
    const kb = 1024.0;
    const mb = 1024.0 * kb;
    const gb = 1024.0 * mb;

    if (bytes >= gb) {
      return ('GB', gb);
    } else if (bytes >= mb) {
      return ('MB', mb);
    } else if (bytes >= kb) {
      return ('KB', kb);
    } else {
      return ('B', 1.0);
    }
  }

  Color _metricColor(HistoryMetric metric, ThemeData theme) {
    return switch (metric) {
      HistoryMetric.total => theme.colorScheme.primary,
      HistoryMetric.download => AppColors.downloadGreen,
      HistoryMetric.upload => AppColors.uploadBlue,
      HistoryMetric.wifi => Colors.blue,
      HistoryMetric.mobile => AppColors.warningAmber,
    };
  }
}
