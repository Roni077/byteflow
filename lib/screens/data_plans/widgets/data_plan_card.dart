/// Interactive Material 3 card presenting data plan usage, allowances, and alerts.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/core/utils/time_utils.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';

/// Card widget visualizing a single data plan's quota progress and projections.
class DataPlanCard extends StatelessWidget {
  /// Creates a [DataPlanCard] widget.
  const DataPlanCard({
    required this.info,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    super.key,
  });

  /// Computed metrics and configuration for this plan.
  final DataPlanUsageInfo info;

  /// Callback to edit plan properties.
  final VoidCallback onEdit;

  /// Callback to delete this plan.
  final VoidCallback onDelete;

  /// Callback to toggle plan active state.
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = info.plan;

    // Determine semantic status color based on warning & exceeded thresholds
    final Color progressColor;
    if (info.isExceeded) {
      progressColor = AppColors.errorRed;
    } else if (info.isWarning) {
      progressColor = AppColors.warningAmber;
    } else {
      progressColor = colorScheme.primary;
    }

    final double progressFraction =
        plan.limitBytes > 0 ? (info.usedBytes / plan.limitBytes).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: info.isExceeded
              ? AppColors.errorRed.withValues(alpha: 0.5)
              : (info.isWarning
                  ? AppColors.warningAmber.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant),
          width: info.isExceeded || info.isWarning ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, SIM badge, and Menu
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              plan.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!plan.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Paused',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.simSlot != null
                                  ? 'SIM ${plan.simSlot! + 1}'
                                  : 'All Mobile Traffic',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${plan.cycleType[0].toUpperCase()}${plan.cycleType.substring(1)} cycle',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMoreVertical,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (action) {
                    HapticFeedback.selectionClick();
                    switch (action) {
                      case 'edit':
                        onEdit();
                      case 'toggle':
                        onToggleActive();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 10),
                          const Text('Edit Plan'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: plan.isActive
                                ? HugeIcons.strokeRoundedPauseCircle
                                : HugeIcons.strokeRoundedPlayCircle,
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 10),
                          Text(plan.isActive ? 'Pause Plan' : 'Resume Plan'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            size: 18,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 10),
                          const Text('Delete Plan',
                              style: TextStyle(color: AppColors.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),

            // Quota Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Used: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${Formatters.formatBytes(info.usedBytes)} (${info.percentUsed.toStringAsFixed(1)}%)',
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Limit: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          Formatters.formatBytes(plan.limitBytes),
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      info.isExceeded
                          ? 'Over quota'
                          : '${Formatters.formatBytes(info.remainingBytes)} left',
                      style: AppTheme.tabularMetricStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: info.isExceeded ? AppColors.errorRed : null,
                      ),
                    ),
                    Text(
                      '${info.daysRemaining} days remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recommended Daily Allowance & Rate Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Recommended',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info.isExceeded
                              ? '0 B / day'
                              : '${Formatters.formatBytes(info.recommendedDailyBytes)} / day',
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Average Pace',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.formatBytes(info.averageDailyBytes)} / day',
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Warning or Exceeded Alert Container
            if (info.isExceeded) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Quota limit reached! Consumption is currently ${Formatters.formatBytes(info.usedBytes - plan.limitBytes)} over allowance.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (info.isWarning) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      color: AppColors.warningAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Approaching limit: ${info.percentUsed.toStringAsFixed(0)}% used (Warning threshold: ${plan.warningPercent}%).',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Renews on ${TimeUtils.formatDate(info.cycleEnd)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
