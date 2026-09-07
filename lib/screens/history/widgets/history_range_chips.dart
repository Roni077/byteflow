/// Filter chips for selecting historical query periods.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Horizontally scrollable row of time-period selector chips.
class HistoryRangeChips extends ConsumerWidget {
  /// Creates a [HistoryRangeChips] widget.
  const HistoryRangeChips({super.key});

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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: HistoryPeriod.values.map((period) {
          final isSelected = filterState.period == period;
          String label = period.label;

          if (period == HistoryPeriod.custom && filterState.customRange != null) {
            final start = filterState.customRange!.start;
            final end = filterState.customRange!.end;
            label = '${start.month}/${start.day} - ${end.month}/${end.day}';
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                if (period == HistoryPeriod.custom) {
                  _pickCustomRange(context, ref, filterState.customRange);
                } else {
                  ref.read(historyFilterProvider.notifier).setPeriod(period);
                }
              },
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
