/// Usage summary card displaying today's and current month's aggregated data usage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/user_preferences.dart';
import 'package:byteflow/providers/usage_provider.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';

/// Renders today's data metrics and current monthly aggregate usage in a Material 3 card.
class UsageSummaryCard extends ConsumerWidget {
  /// Creates a [UsageSummaryCard] widget.
  const UsageSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(usageSummaryProvider);
    final prefs = ref.watch(userPreferencesProvider).value ?? const UserPreferences();
    final theme = Theme.of(context);

    final todayTotal = summary.today.totalBytes;
    final todayRx = summary.today.rxBytes;
    final todayTx = summary.today.txBytes;
    final todayWifi = summary.today.wifiBytes;
    final todayMobile = summary.today.mobileBytes;
    final monthTotal = summary.currentMonth.totalBytes;

    final style = prefs.usageDisplayStyle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedDatabase01,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TODAY\'S USAGE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  Formatters.formatBytes(todayTotal),
                  style: AppTheme.tabularMetricStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Distribution Progress Bar
            if (style == UsageDisplayStyle.downloadAndUpload) ...[
              _buildDistributionBar(
                ratio: todayTotal > 0 ? todayRx / todayTotal : 0.5,
                primaryColor: AppTheme.rxColor,
                secondaryColor: AppTheme.txColor,
              ),
            ] else ...[
              // Wi-Fi vs Mobile ratio for mobileAndWifi and both
              _buildDistributionBar(
                ratio: (todayWifi + todayMobile) > 0
                    ? todayWifi / (todayWifi + todayMobile)
                    : 0.5,
                primaryColor: Colors.blue,
                secondaryColor: AppColors.warningAmber,
              ),
            ],
            const SizedBox(height: 16),

            // Metric Breakdown Tiles based on user preference
            if (style == UsageDisplayStyle.mobileAndWifi) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Wi-Fi Traffic',
                      value: Formatters.formatBytes(todayWifi),
                      icon: HugeIcons.strokeRoundedWifi01,
                      color: Colors.blue,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Mobile Traffic',
                      value: Formatters.formatBytes(todayMobile),
                      icon: HugeIcons.strokeRoundedCellularNetwork,
                      color: AppColors.warningAmber,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ] else if (style == UsageDisplayStyle.downloadAndUpload) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Downloaded',
                      value: Formatters.formatBytes(todayRx),
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      color: AppTheme.rxColor,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Uploaded',
                      value: Formatters.formatBytes(todayTx),
                      icon: HugeIcons.strokeRoundedArrowUp01,
                      color: AppTheme.txColor,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Both (All Metrics)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Wi-Fi Traffic',
                      value: Formatters.formatBytes(todayWifi),
                      icon: HugeIcons.strokeRoundedWifi01,
                      color: Colors.blue,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Mobile Traffic',
                      value: Formatters.formatBytes(todayMobile),
                      icon: HugeIcons.strokeRoundedCellularNetwork,
                      color: AppColors.warningAmber,
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Downloaded',
                      value: Formatters.formatBytes(todayRx),
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      color: AppTheme.rxColor,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Uploaded',
                      value: Formatters.formatBytes(todayTx),
                      icon: HugeIcons.strokeRoundedArrowUp01,
                      color: AppTheme.txColor,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 32),

            // Current Month Aggregated Usage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Month Total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (style == UsageDisplayStyle.mobileAndWifi &&
                            (summary.currentMonth.wifiBytes > 0 ||
                                summary.currentMonth.mobileBytes > 0)) ...[
                          Text(
                            'Wi-Fi: ${Formatters.formatBytes(summary.currentMonth.wifiBytes)} • Mobile: ${Formatters.formatBytes(summary.currentMonth.mobileBytes)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Text(
                  Formatters.formatBytes(monthTotal),
                  style: AppTheme.tabularMetricStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar({
    required double ratio,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: 0.5,
            end: ratio.clamp(0.01, 0.99),
          ),
          builder: (context, r, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(color: secondaryColor),
                ),
                FractionallySizedBox(
                  widthFactor: r,
                  alignment: Alignment.centerLeft,
                  child: Container(color: primaryColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required dynamic icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.tabularMetricStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
