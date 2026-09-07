/// Summary stat cards displaying totals, averages, and peak metrics for history.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/providers/usage_history_provider.dart';

/// Grid of cards summarizing traffic metrics across the selected historical period.
class HistorySummaryCards extends StatelessWidget {
  /// Creates a [HistorySummaryCards] container with the computed [report].
  const HistorySummaryCards({
    required this.report,
    super.key,
  });

  /// The active historical analytics report.
  final HistoryReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agg = report.aggregate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryMetricTile(
                  title: 'Total Transfer',
                  value: Formatters.formatBytes(agg.totalBytes),
                  icon: HugeIcons.strokeRoundedDatabase01,
                  iconColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetricTile(
                  title: report.isHourly ? 'Hourly Avg' : 'Daily Avg',
                  value: Formatters.formatBytes(report.averageBytes.round()),
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  iconColor: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricTile(
                  title: 'Download',
                  value: Formatters.formatBytes(agg.downloadBytes),
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  iconColor: AppColors.downloadGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetricTile(
                  title: 'Upload',
                  value: Formatters.formatBytes(agg.uploadBytes),
                  icon: HugeIcons.strokeRoundedArrowUp01,
                  iconColor: AppColors.uploadBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricTile(
                  title: 'Wi-Fi Traffic',
                  value: Formatters.formatBytes(agg.wifiBytes),
                  icon: HugeIcons.strokeRoundedWifi01,
                  iconColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetricTile(
                  title: 'Mobile Traffic',
                  value: Formatters.formatBytes(agg.mobileBytes),
                  icon: HugeIcons.strokeRoundedCellularNetwork,
                  iconColor: AppColors.warningAmber,
                ),
              ),
            ],
          ),
          if (report.peakPoint != null && report.peakPoint!.value > 0) ...[
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                side: BorderSide(
                  color: AppColors.warningAmber.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.warningAmber.withValues(alpha: 0.15),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedFlash,
                        color: AppColors.warningAmber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peak Period (${report.peakPoint!.label})',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            Formatters.formatBytes(report.peakPoint!.value),
                            style: AppTheme.tabularMetricStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  const _SummaryMetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final dynamic icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withValues(alpha: 0.12),
              child: HugeIcon(icon: icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.tabularMetricStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
