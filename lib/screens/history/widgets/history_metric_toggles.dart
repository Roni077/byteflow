/// Metric filter chips and chart view switcher.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Row of metric filter options with a Bar/Line chart view toggle.
class HistoryMetricToggles extends ConsumerWidget {
  /// Creates a [HistoryMetricToggles] widget.
  const HistoryMetricToggles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(historyFilterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HistoryMetric.values.map((metric) {
                  final isSelected = filterState.metric == metric;
                  final color = _metricColor(metric, theme);

                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(metric.label),
                      selected: isSelected,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                      ),
                      selectedColor: color.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: isSelected ? color : theme.colorScheme.outlineVariant,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (selected) {
                        HapticFeedback.selectionClick();
                        if (selected) {
                          ref.read(historyFilterProvider.notifier).setMetric(metric);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedBarChart,
                    size: 18,
                    color: filterState.chartViewType == ChartViewType.bar
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  isSelected: filterState.chartViewType == ChartViewType.bar,
                  tooltip: 'Bar Chart',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(historyFilterProvider.notifier)
                        .setChartViewType(ChartViewType.bar);
                  },
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedAnalytics01,
                    size: 18,
                    color: filterState.chartViewType == ChartViewType.line
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  isSelected: filterState.chartViewType == ChartViewType.line,
                  tooltip: 'Line Chart',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(historyFilterProvider.notifier)
                        .setChartViewType(ChartViewType.line);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
