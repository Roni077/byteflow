/// Modal bottom sheet for configuring History time periods, metrics, and chart views.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Bottom sheet dialog allowing the user to switch historical query periods,
/// active metrics, and chart visualization styles.
class HistoryFilterSheet extends ConsumerWidget {
  /// Creates a [HistoryFilterSheet] widget.
  const HistoryFilterSheet({super.key});

  Future<void> _pickCustomRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange? currentRange,
  ) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: currentRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      ref.read(historyFilterProvider.notifier).setPeriod(
            HistoryPeriod.custom,
            customRange: picked,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(historyFilterProvider);
    final notifier = ref.read(historyFilterProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History Filters & Metrics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Time Period Section
              Text(
                'Time Period',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HistoryPeriod.values.map((period) {
                  final isSelected = filterState.period == period;
                  String label = period.label;

                  if (period == HistoryPeriod.custom &&
                      filterState.customRange != null) {
                    final start = filterState.customRange!.start;
                    final end = filterState.customRange!.end;
                    label =
                        '${start.month}/${start.day} - ${end.month}/${end.day}';
                  }

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    avatar: period == HistoryPeriod.custom
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            size: 16,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      if (period == HistoryPeriod.custom) {
                        _pickCustomRange(context, ref, filterState.customRange);
                      } else {
                        notifier.setPeriod(period);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 2. Metric Section
              Text(
                'Metric Filter',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HistoryMetric.values.map((metric) {
                  final isSelected = filterState.metric == metric;
                  final color = _metricColor(metric, theme);

                  return ChoiceChip(
                    label: Text(metric.label),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    selectedColor: color.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: isSelected
                          ? color
                          : theme.colorScheme.outlineVariant,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? color
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      if (selected) {
                        notifier.setMetric(metric);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 3. Chart Visualization Type
              Text(
                'Chart Visualization',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ChartViewType>(
                segments: const [
                  ButtonSegment<ChartViewType>(
                    value: ChartViewType.bar,
                    label: Text('Bar Chart'),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedBarChart,
                      size: 16,
                    ),
                  ),
                  ButtonSegment<ChartViewType>(
                    value: ChartViewType.line,
                    label: Text('Line Chart'),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedAnalytics01,
                      size: 16,
                    ),
                  ),
                ],
                selected: {filterState.chartViewType},
                onSelectionChanged: (newSelection) {
                  HapticFeedback.selectionClick();
                  notifier.setChartViewType(newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
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
