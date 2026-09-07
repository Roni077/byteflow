/// Historical network usage analytics and data visualization screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/providers/usage_history_provider.dart';
import 'package:byteflow/screens/history/widgets/history_filter_sheet.dart';
import 'package:byteflow/screens/history/widgets/history_summary_cards.dart';
import 'package:byteflow/screens/history/widgets/usage_bar_chart.dart';
import 'package:byteflow/screens/history/widgets/usage_line_chart.dart';

/// Screen displaying historical network analytics, interactive charts, and summaries.
class HistoryScreen extends ConsumerWidget {
  /// Creates a [HistoryScreen] widget.
  const HistoryScreen({super.key});

  void _showFilterSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.sheetRadius),
        ),
      ),
      builder: (_) => const HistoryFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(historyReportProvider);
    final filterState = ref.watch(historyFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage History'),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedFilter,
              size: 20,
            ),
            tooltip: 'Filter & Metrics',
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Filter Summary & Quick Switcher Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _showFilterSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCalendar03,
                                  size: 13,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  filterState.period == HistoryPeriod.custom && filterState.customRange != null
                                      ? '${filterState.customRange!.start.month}/${filterState.customRange!.start.day} - ${filterState.customRange!.end.month}/${filterState.customRange!.end.day}'
                                      : filterState.period.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filterState.metric.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown01,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Quick chart view switcher
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
                          visualDensity: VisualDensity.compact,
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
                          visualDensity: VisualDensity.compact,
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
            ),
          ),

          // 3. Chart Container
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: reportAsync.when(
                    data: (report) {
                      final hasData = report.aggregate.totalBytes > 0;
                      if (!hasData) {
                        return _buildEmptyChartState(theme);
                      }

                      return filterState.chartViewType == ChartViewType.bar
                          ? UsageBarChart(
                              report: report,
                              metric: filterState.metric,
                            )
                          : UsageLineChart(
                              report: report,
                              metric: filterState.metric,
                            );
                    },
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          'Error loading history: $error',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Analytics Summary Cards
          reportAsync.when(
            data: (report) => SliverToBoxAdapter(
              child: HistorySummaryCards(report: report),
            ),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // 5. Detailed Breakdown Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Breakdown Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 6. Detailed Bucket Breakdown List
          reportAsync.when(
            data: (report) {
              final nonZeroPoints =
                  report.dataPoints.where((p) => p.totalBytes > 0).toList();

              if (nonZeroPoints.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Center(
                      child: Text(
                        'No traffic recorded for this interval.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final point = nonZeroPoints[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        color: theme.colorScheme.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            point.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '↓ ${Formatters.formatBytes(point.downloadBytes)}   '
                            '↑ ${Formatters.formatBytes(point.uploadBytes)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Text(
                            Formatters.formatBytes(point.totalBytes),
                            style: AppTheme.tabularMetricStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: nonZeroPoints.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState(ThemeData theme) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAnalyticsUp,
                size: 44,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No usage data recorded',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Traffic snapshots will populate here as network activity occurs.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
