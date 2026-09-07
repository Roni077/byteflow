/// Interactive spline line chart visualization powered by fl_chart.
library;

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Line chart rendering historical network usage with curved gradients and tooltips.
class UsageLineChart extends StatelessWidget {
  /// Creates a [UsageLineChart] with the specified [report] and active [metric].
  const UsageLineChart({
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

    int maxBytes = 0;
    for (final p in points) {
      if (p.value > maxBytes) maxBytes = p.value;
    }

    final (unitLabel, divisor) = _resolveScale(maxBytes);
    final rawMaxY = maxBytes / divisor;
    final maxY = rawMaxY <= 0 ? 5.0 : rawMaxY * 1.25;

    final primaryColor = _metricColor(metric, theme);

    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      final toY = points[i].value / divisor;
      spots.add(FlSpot(i.toDouble(), toY));
    }

    final labelInterval = math.max(1, (points.length / 6).ceil());

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (points.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (touchedSpot) => theme.colorScheme.inverseSurface,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final index = barSpot.x.toInt();
                    if (index < 0 || index >= points.length) return null;
                    final point = points[index];

                    return LineTooltipItem(
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
                  }).toList();
                },
              ),
            ),
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
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.25,
                color: primaryColor,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: points.length <= 15,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 3.5,
                    color: primaryColor,
                    strokeWidth: 1.5,
                    strokeColor: theme.colorScheme.surface,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withValues(alpha: 0.35),
                      primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
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
