/// Screen displaying per-application network consumption breakdowns.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/providers/app_usage_provider.dart';
import 'package:byteflow/screens/apps/widgets/app_sort_filter_sheet.dart';
import 'package:byteflow/screens/apps/widgets/app_usage_tile.dart';
import 'package:byteflow/screens/apps/widgets/permission_card.dart';

/// Screen displaying per-application network consumption breakdowns, search, and filters.
class AppsScreen extends ConsumerStatefulWidget {
  /// Creates an [AppsScreen] widget.
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.sheetRadius),
        ),
      ),
      builder: (_) => const AppSortFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUsageProvider);
    final notifier = ref.read(appUsageProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Data Usage'),
        actions: [
          if (state.hasPermission)
            IconButton(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFilter,
                size: 20,
              ),
              tooltip: 'Sort & Filter',
              onPressed: _showSortFilterSheet,
            ),
        ],
      ),
      body: !state.hasPermission
          ? PermissionCard(
              onGrantPressed: () => notifier.openUsageSettings(),
              onCheckPressed: () => notifier.checkPermission(),
            )
          : Column(
              children: [
                // 1. Search Bar
                _buildSearchBar(notifier, theme),

                // 2. Summary & Filter Info Bar
                _buildSummaryBar(state, theme),

                // 3. App List or Status
                Expanded(
                  child: _buildListContent(state, notifier, theme),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(AppUsageNotifier notifier, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => notifier.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: 'Search applications...',
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12.0),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              size: 20,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 18,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _searchController.clear();
                    notifier.setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(AppUsageState state, ThemeData theme) {
    final filtered = state.filteredApps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${filtered.length} apps • Total: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Formatters.formatBytes(state.totalFilteredBytes),
                style: AppTheme.tabularMetricStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: _showSortFilterSheet,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          size: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.selectedTimeRange.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedSorting05,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.sortOption.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(
    AppUsageState state,
    AppUsageNotifier notifier,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24.0),
          itemCount: 8,
          itemBuilder: (context, index) {
            return AppUsageTile(
              app: AppNetworkUsage.placeholder(index),
              maxBytes: 209715200,
            );
          },
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlertCircle,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load application usage',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.refresh();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = state.filteredApps;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No apps match "${state.searchQuery}"'
                    : 'No network usage recorded for this period',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxBytes = state.maxAppBytes;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.selectionClick();
        notifier.refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24.0),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final app = filtered[index];
          return AppUsageTile(
            key: ValueKey(app.packageName),
            app: app,
            maxBytes: maxBytes,
          );
        },
      ),
    );
  }
}
