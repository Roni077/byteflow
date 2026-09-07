/// Widget displaying active SIM card slots, carrier metadata, and permission prompts.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/providers/shizuku_provider.dart';
import 'package:byteflow/providers/sim_provider.dart';

/// Card showing detected SIM cards and dual-SIM configuration.
class SimStatusCard extends ConsumerWidget {
  /// Creates a [SimStatusCard] widget.
  const SimStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final permAsync = ref.watch(phonePermissionProvider);
    final simCardsAsync = ref.watch(simCardsProvider);

    return permAsync.when(
      data: (hasPermission) {
        if (!hasPermission) {
          return _buildPermissionBanner(context, ref, theme, colorScheme);
        }

        return simCardsAsync.when(
          data: (simCards) {
            if (simCards.isEmpty) {
              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSimcard01,
                        color: colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Active SIM Detected',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mobile data plans will monitor device-wide cellular usage.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedRefresh,
                          size: 18,
                        ),
                        tooltip: 'Scan SIM cards',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(simCardsProvider.notifier).refresh();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              elevation: 0,
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedSimcard01,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              simCards.length > 1
                                  ? 'Dual SIM Detected'
                                  : 'Active SIM Card',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedRefresh,
                            size: 18,
                          ),
                          tooltip: 'Refresh SIM status',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref.read(simCardsProvider.notifier).refresh();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: simCards.map((sim) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sim.isDefaultData
                                  ? colorScheme.primary.withValues(alpha: 0.5)
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sim.slotLabel,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sim.carrierName.isNotEmpty
                                    ? sim.carrierName
                                    : (sim.displayName.isNotEmpty
                                        ? sim.displayName
                                        : 'Cellular Carrier'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (sim.isDefaultData) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Default Data',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    _buildShizukuStatus(context, ref, theme, colorScheme),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildShizukuStatus(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final shizukuAsync = ref.watch(shizukuStatusProvider);
    final status = shizukuAsync.value ?? ShizukuStatus.unavailable();

    return switch (status.trafficLight) {
      ShizukuTrafficLight.green => Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.downloadGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.downloadGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.downloadGreen,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.8, end: 1.2, duration: 1000.ms),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shizuku Active • Privileged Multi-SIM tracking enabled',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.downloadGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ShizukuTrafficLight.amber => Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warningAmber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.warningAmber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shizuku detected • Authorize for per-SIM stats',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.amber.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(shizukuStatusProvider.notifier).requestPermission();
                },
                child: const Text('Authorize'),
              ),
            ],
          ),
        ),
      ShizukuTrafficLight.red => const SizedBox.shrink(),
    };
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Multi-SIM Detection Available',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Grant phone state permission to detect Dual-SIM slots, carrier labels, and active data subscriptions.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(simCardsProvider.notifier).requestPhonePermission();
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  size: 16,
                ),
                label: const Text('Enable Multi-SIM Detection'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
