/// Real-time speed metrics card displaying combined throughput and directional transfer rates.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/network_speed.dart';
import 'package:byteflow/providers/speed_provider.dart';

/// Isolated widget rendering real-time network speed metrics without causing parent scaffold rebuilds.
class SpeedCard extends ConsumerWidget {
  /// Creates a [SpeedCard] widget.
  const SpeedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speedAsync = ref.watch(speedStreamProvider);
    final speed = speedAsync.value ?? NetworkSpeed.zero();
    final theme = Theme.of(context);

    final (rxVal, rxUnit) = Formatters.formatSpeedParts(speed.rxBytesPerSecond);
    final (txVal, txUnit) = Formatters.formatSpeedParts(speed.txBytesPerSecond);
    final (totalVal, totalUnit) =
        Formatters.formatSpeedParts(speed.totalBytesPerSecond);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Live Indicator & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDashboardSpeed01,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'REAL-TIME SPEED',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LivePulseDot(),
                      const SizedBox(width: 6),
                      Text(
                        '1 Hz',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Combined Throughput Display
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalVal,
                    style: AppTheme.tabularMetricStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    totalUnit,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Directional Transfer Rates
            Row(
              children: [
                // Download Sub-card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowDown01,
                              size: 16,
                              color: AppTheme.rxColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Download',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              rxVal,
                              style: AppTheme.tabularMetricStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rxUnit,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Upload Sub-card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowUp01,
                              size: 16,
                              color: AppTheme.txColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              txVal,
                              style: AppTheme.tabularMetricStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              txUnit,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Isolated pulsing live dot that animates continuously without parent rebuild disruption.
class _LivePulseDot extends StatelessWidget {
  const _LivePulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.rxColor,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.75,
          end: 1.35,
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}
