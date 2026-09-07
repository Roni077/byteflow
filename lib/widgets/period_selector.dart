/// Period selector component offering toggleable time interval segments.
library;

import 'package:flutter/material.dart';

/// Available time range filter intervals.
enum TimePeriod {
  /// Single 24-hour calendar day period.
  today('Today'),

  /// Rolling 7-day period.
  week('This Week'),

  /// Calendar month period.
  month('This Month');

  const TimePeriod(this.label);

  /// User-facing display title.
  final String label;
}

/// Material 3 segmented control allowing users to switch time period filters.
class PeriodSelector extends StatelessWidget {
  /// Creates a [PeriodSelector] with the currently selected [selectedPeriod] and change callback [onChanged].
  const PeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
    super.key,
  });

  /// The active selected time filter period.
  final TimePeriod selectedPeriod;

  /// Callback triggered when a new segment is chosen.
  final ValueChanged<TimePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TimePeriod>(
      segments: TimePeriod.values
          .map(
            (period) => ButtonSegment<TimePeriod>(
              value: period,
              label: Text(period.label),
            ),
          )
          .toList(),
      selected: <TimePeriod>{selectedPeriod},
      onSelectionChanged: (Set<TimePeriod> newSelection) {
        if (newSelection.isNotEmpty) {
          onChanged(newSelection.first);
        }
      },
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
