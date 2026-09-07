/// List item widget rendering application data usage statistics and metadata.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/services/app_icon_service.dart';

/// Renders a single app usage entry with icon, network counters, and ratio bar.
class AppUsageTile extends ConsumerWidget {
  /// Creates an [AppUsageTile] widget.
  const AppUsageTile({
    required this.app,
    required this.maxBytes,
    super.key,
  });

  /// The application usage data record.
  final AppNetworkUsage app;

  /// The highest usage in the active list, used to scale the progress bar.
  final int maxBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final iconAsync = ref.watch(appIconBytesProvider(app.packageName));
    final ratio = maxBytes > 0 ? (app.totalBytes / maxBytes).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: iconAsync.when(
                        data: (bytes) {
                          if (bytes != null && bytes.isNotEmpty) {
                            return Image.memory(
                              bytes,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => _buildFallbackIcon(theme),
                            );
                          }
                          return _buildFallbackIcon(theme);
                        },
                        loading: () => _buildFallbackIcon(theme),
                        error: (_, _) => _buildFallbackIcon(theme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // App Name & Package Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                app.appName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (app.isSystemApp) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SYSTEM',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.packageName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Total Usage Counter
                  Text(
                    Formatters.formatBytes(app.totalBytes),
                    style: AppTheme.tabularMetricStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Relative Consumption Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 5,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    app.isSystemApp
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Detailed Transfer Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        size: 13,
                        color: AppColors.downloadGreen,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Formatters.formatBytes(app.rxBytes),
                        style: AppTheme.tabularMetricStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowUp01,
                        size: 13,
                        color: AppColors.uploadBlue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Formatters.formatBytes(app.txBytes),
                        style: AppTheme.tabularMetricStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (app.wifiTotalBytes > 0) ...[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedWifi01,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatBytes(app.wifiTotalBytes),
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (app.wifiTotalBytes > 0 && app.mobileTotalBytes > 0)
                        const SizedBox(width: 8),
                      if (app.mobileTotalBytes > 0) ...[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCellularNetwork,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatBytes(app.mobileTotalBytes),
                          style: AppTheme.tabularMetricStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: app.isSystemApp
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: HugeIcon(
          icon: app.isSystemApp
              ? HugeIcons.strokeRoundedSettings01
              : HugeIcons.strokeRoundedAndroid,
          size: 22,
          color: app.isSystemApp
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
