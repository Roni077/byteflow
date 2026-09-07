/// System permissions and privileged service status management screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/providers/permissions_provider.dart';

/// Screen displaying the status of Android permissions and background exemptions.
class PermissionsScreen extends ConsumerStatefulWidget {
  /// Creates a [PermissionsScreen] widget.
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permsAsync = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions & Access'),
      ),
      body: permsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
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
                  'Failed to evaluate permissions',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$err',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(permissionsProvider.notifier).refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (perms) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            _buildSummaryCard(context, perms),
            const SizedBox(height: 20),
            _buildUsageAccessCard(context, perms.usageAccess),
            const SizedBox(height: 16),
            _buildNotificationCard(context, perms.notifications),
            const SizedBox(height: 16),
            _buildBatteryOptimizationCard(
              context,
              perms.batteryOptimizationIgnored,
            ),
            const SizedBox(height: 16),
            _buildShizukuCard(context, perms.shizukuStatus),
            const SizedBox(height: 24),
            _buildPrivacyNoticeCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    SystemPermissionsState perms,
  ) {
    final theme = Theme.of(context);
    final granted = perms.grantedCount;
    final total = SystemPermissionsState.totalCount;
    final allConfigured = granted == total;

    return Card(
      elevation: 0,
      color: allConfigured
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
          : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: allConfigured
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: allConfigured
                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                    : HugeIcons.strokeRoundedShield02,
                color: theme.colorScheme.onPrimary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allConfigured
                        ? 'All Permissions Configured'
                        : '$granted of $total Services Configured',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: allConfigured
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    allConfigured
                        ? 'ByteFlow has all necessary system access for full multi-SIM and per-app monitoring.'
                        : 'Grant the permissions below for real-time tracking, background efficiency, and per-app history.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: allConfigured
                          ? theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8)
                          : theme.colorScheme.onSurfaceVariant,
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

  Widget _buildUsageAccessCard(BuildContext context, bool granted) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: granted
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : AppColors.errorRed.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedDatabase01,
                  color: granted
                      ? theme.colorScheme.primary
                      : AppColors.errorRed,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usage Access',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(
                  context,
                  isGranted: granted,
                  grantedLabel: 'Granted',
                  deniedLabel: 'Required',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Required by Android NetworkStatsManager to measure cellular and Wi-Fi data consumption per individual application UID and populate historical usage charts.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(permissionsProvider.notifier).requestUsageAccess();
                },
                icon: HugeIcon(
                  icon: granted
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedSettings02,
                  size: 18,
                ),
                label: Text(
                  granted ? 'Modify in Settings' : 'Open Usage Settings',
                ),
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

  Widget _buildNotificationCard(BuildContext context, bool granted) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: granted
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : AppColors.errorRed.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification03,
                  color: granted
                      ? theme.colorScheme.primary
                      : AppColors.errorRed,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications (Android 13+)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(
                  context,
                  isGranted: granted,
                  grantedLabel: 'Allowed',
                  deniedLabel: 'Required',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enables the ongoing status bar network throughput indicator and delivers automated data plan threshold warnings when you approach your plan allowance.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(permissionsProvider.notifier)
                      .requestNotifications();
                },
                icon: HugeIcon(
                  icon: granted
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedNotificationSquare,
                  size: 18,
                ),
                label: Text(
                  granted ? 'Granted' : 'Grant Permission',
                ),
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

  Widget _buildBatteryOptimizationCard(BuildContext context, bool isIgnored) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: isIgnored
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : theme.colorScheme.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBatteryCharging01,
                  color: isIgnored
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Battery Optimization',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(
                  context,
                  isGranted: isIgnored,
                  grantedLabel: 'Unrestricted',
                  deniedLabel: 'Optimized',
                  deniedColor: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Exempting ByteFlow from Android battery optimization prevents aggressive OEM background task killers from stopping the foreground speed monitor when your device enters Doze mode.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(permissionsProvider.notifier)
                      .requestBatteryOptimizationExemption();
                },
                icon: HugeIcon(
                  icon: isIgnored
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedPower,
                  size: 18,
                ),
                label: Text(
                  isIgnored ? 'Exemption Active' : 'Disable Optimization',
                ),
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

  Widget _buildShizukuCard(BuildContext context, ShizukuStatus status) {
    final theme = Theme.of(context);

    final (badgeLabel, badgeColor, iconColor) = switch (status.trafficLight) {
      ShizukuTrafficLight.green => (
        'Authorized (Active)',
        AppColors.downloadGreen,
        AppColors.downloadGreen,
      ),
      ShizukuTrafficLight.amber => (
        'Pending Authorization',
        AppColors.warningAmber,
        AppColors.warningAmber,
      ),
      ShizukuTrafficLight.red => (
        'Not Connected',
        theme.colorScheme.outline,
        theme.colorScheme.outline,
      ),
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: status.isPrivileged
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCommand,
                  color: iconColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Shizuku Privileged Multi-SIM',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  ),
                  child: Text(
                    badgeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Android 10+ restricts TelephonyManager subscriberId access. Shizuku grants READ_PRIVILEGED_PHONE_STATE via ADB/root without modifying system partitions, enabling independent cellular tracking per physical SIM slot.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: status.isAvailable && !status.hasPermission
                    ? () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(permissionsProvider.notifier)
                            .requestShizukuAccess();
                      }
                    : null,
                icon: HugeIcon(
                  icon: status.hasPermission
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedSecurityCheck,
                  size: 18,
                ),
                label: Text(
                  status.hasPermission
                      ? 'Authorized'
                      : (status.isAvailable
                          ? 'Authorize Shizuku'
                          : 'Shizuku Not Running'),
                ),
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

  Widget _buildStatusBadge(
    BuildContext context, {
    required bool isGranted,
    required String grantedLabel,
    required String deniedLabel,
    Color? deniedColor,
  }) {
    final theme = Theme.of(context);
    final color = isGranted
        ? theme.colorScheme.primary
        : (deniedColor ?? AppColors.errorRed);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      ),
      child: Text(
        isGranted ? grantedLabel : deniedLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPrivacyNoticeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedLock,
              color: theme.colorScheme.secondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ByteFlow is 100% local, privacy-first, and open source. None of your network counters, app data, or device identifiers ever leave your device.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
