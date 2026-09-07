/// Modal bottom sheet for configuring application sorting and category filtering.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/providers/app_usage_provider.dart';

/// Bottom sheet dialog allowing the user to switch sorting criteria and category filters.
class AppSortFilterSheet extends ConsumerWidget {
  /// Creates an [AppSortFilterSheet] widget.
  const AppSortFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUsageProvider);
    final notifier = ref.read(appUsageProvider.notifier);
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
                    'Sort & Filter',
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

              // Time Period Section
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
                children: AppUsageTimeRange.values.map((range) {
                  final isSelected = state.selectedTimeRange == range;
                  return ChoiceChip(
                    label: Text(range.label),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      if (selected) {
                        notifier.setTimeRange(range);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Sort Section
              Text(
                'Sort By',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppUsageSortOption.values.map((option) {
                  final isSelected = state.sortOption == option;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      if (selected) {
                        notifier.setSortOption(option);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Category Filter Section
              Text(
                'Category Filter',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppUsageFilterOption.values.map((option) {
                  final isSelected = state.filterOption == option;
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      if (selected) {
                        notifier.setFilterOption(option);
                      }
                    },
                  );
                }).toList(),
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
}
