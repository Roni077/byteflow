/// Preferences, background service toggles, appearance, units, and about section.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/foreground_service_config.dart';
import 'package:byteflow/models/user_preferences.dart';
import 'package:byteflow/providers/data_plans_provider.dart';
import 'package:byteflow/providers/foreground_service_provider.dart';
import 'package:byteflow/providers/package_info_provider.dart';
import 'package:byteflow/providers/permissions_provider.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';
import 'package:byteflow/widgets/theme_ripple_switcher.dart';

/// Screen configuring background network monitoring, appearance, units, and system access.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen] widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serviceAsync = ref.watch(foregroundServiceProvider);
    final prefsAsync = ref.watch(userPreferencesProvider);
    final permsAsync = ref.watch(permissionsProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: serviceAsync.when(
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
                  'Failed to load settings',
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
                    ref.read(foregroundServiceProvider.notifier).refresh();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (config) {
          final prefs = prefsAsync.value ?? const UserPreferences();

          return ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              _buildServiceStatusCard(context, config),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Appearance'),
              const SizedBox(height: 8),
              _buildAppearanceSection(context, ref, prefs),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Data Usage Display'),
              const SizedBox(height: 8),
              _buildUsageDisplaySection(context, ref, prefs),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Units of Measurement'),
              const SizedBox(height: 8),
              _buildUnitsSection(context, ref, prefs),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Background Monitoring & Service'),
              const SizedBox(height: 8),
              _buildMonitoringSection(context, ref, config, prefs),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Status Bar Speed Indicator'),
              const SizedBox(height: 8),
              _buildStatusBarSection(context, ref, config),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'System Startup'),
              const SizedBox(height: 8),
              _buildStartupSection(context, ref, config),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Data Plans & Allowances'),
              const SizedBox(height: 8),
              _buildDataPlansTile(context, ref),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'System Permissions & Hardware'),
              const SizedBox(height: 8),
              _buildPermissionsTile(context, permsAsync),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'About ByteFlow'),
              const SizedBox(height: 8),
              _buildAboutCard(context, packageInfoAsync),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard(
    BuildContext context,
    ForegroundServiceConfig config,
  ) {
    final theme = Theme.of(context);
    final isRunning = config.isServiceRunning;

    return Card(
      elevation: 0,
      color: isRunning
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
          : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: isRunning
                        ? HugeIcons.strokeRoundedDashboardSpeed01
                        : HugeIcons.strokeRoundedPauseCircle,
                    color: isRunning
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 26,
                  ),
                ),
                if (isRunning)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.downloadGreen,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 0.8, end: 1.3, duration: 1000.ms),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRunning ? 'Monitoring Active' : 'Monitoring Inactive',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isRunning
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRunning
                        ? 'Real-time throughput updates active in notification & status bar.'
                        : 'Background foreground service is currently stopped.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isRunning
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

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    UserPreferences prefs,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedPaintBoard,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ThemeRippleSwitcher(
                  size: 38.0,
                  iconSize: 18.0,
                  isDark: prefs.themeMode == ThemeMode.dark ||
                      (prefs.themeMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark),
                  onToggle: () {
                    final isDarkNow = prefs.themeMode == ThemeMode.dark ||
                        (prefs.themeMode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark);
                    notifier.setThemeMode(
                        isDarkNow ? ThemeMode.light : ThemeMode.dark);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      size: 16,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSun01,
                      size: 16,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedMoon02,
                      size: 16,
                    ),
                  ),
                ],
                selected: {prefs.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  HapticFeedback.selectionClick();
                  notifier.setThemeMode(newSelection.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageDisplaySection(
    BuildContext context,
    WidgetRef ref,
    UserPreferences prefs,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: HugeIcon(
          icon: HugeIcons.strokeRoundedChartHistogram,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        title: const Text('Data Usage Display Style'),
        subtitle: Text(
          'Currently: ${prefs.usageDisplayStyle.label} (${_formatUsageStyleDesc(prefs.usageDisplayStyle)})',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          HapticFeedback.selectionClick();
          _showUsageDisplayStyleDialog(context, prefs, notifier);
        },
      ),
    );
  }

  Widget _buildUnitsSection(
    BuildContext context,
    WidgetRef ref,
    UserPreferences prefs,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedDashboardSpeed01,
              color: null,
              size: 22,
            ),
            title: const Text('Speed Units'),
            subtitle: Text(
              'Currently: ${prefs.speedUnit.label} (${_formatSpeedUnitDesc(prefs.speedUnit)})',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              _showSpeedUnitDialog(context, prefs, notifier);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedDatabase01,
              color: null,
              size: 22,
            ),
            title: const Text('Data Volume Units'),
            subtitle: Text(
              'Currently: ${prefs.dataUnit.label} (${_formatDataUnitDesc(prefs.dataUnit)})',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              _showDataUnitDialog(context, prefs, notifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringSection(
    BuildContext context,
    WidgetRef ref,
    ForegroundServiceConfig config,
    UserPreferences prefs,
  ) {
    final theme = Theme.of(context);
    final serviceNotifier = ref.read(foregroundServiceProvider.notifier);
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);

    final intervalSec = (prefs.pollingIntervalMs / 1000.0).clamp(1.0, 5.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Background Monitoring Service'),
            subtitle: const Text(
              'Keeps speed calculation active when ByteFlow is minimized',
            ),
            secondary: HugeIcon(
              icon: HugeIcons.strokeRoundedActivity01,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            value: config.isServiceRunning,
            onChanged: (val) async {
              HapticFeedback.selectionClick();
              if (val) {
                final status = await Permission.notification.status;
                if (status.isDenied) {
                  await Permission.notification.request();
                }
              }
              await serviceNotifier.toggleService(val);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Persistent Notification'),
            subtitle: const Text(
              'Displays ongoing speed stats and connection type in notification shade',
            ),
            secondary: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification03,
              color: config.isServiceRunning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22,
            ),
            value: config.showPersistentNotification,
            onChanged: config.isServiceRunning
                ? (val) {
                    HapticFeedback.selectionClick();
                    serviceNotifier.togglePersistentNotification(val);
                    prefsNotifier.togglePersistentNotification(val);
                  }
                : null,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Polling Interval',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${intervalSec.toStringAsFixed(1)} s',
                      style: AppTheme.tabularMetricStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: intervalSec,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: '${intervalSec.toStringAsFixed(1)} s',
                  onChanged: (val) {
                    final ms = (val * 1000).round();
                    prefsNotifier.setPollingInterval(ms);
                    serviceNotifier.setPollingInterval(ms);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Controls how frequently TrafficStats counters poll bytes. Shorter intervals offer faster response; longer intervals maximize battery life.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBarSection(
    BuildContext context,
    WidgetRef ref,
    ForegroundServiceConfig config,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(foregroundServiceProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Status Bar Speed Indicator'),
            subtitle: const Text(
              'Renders dynamic speed digits directly in Android status bar',
            ),
            secondary: HugeIcon(
              icon: HugeIcons.strokeRoundedFlash,
              color: config.isServiceRunning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22,
            ),
            value: config.showStatusBarSpeed,
            onChanged: config.isServiceRunning
                ? (val) {
                    HapticFeedback.selectionClick();
                    notifier.toggleStatusBarSpeed(val);
                  }
                : null,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowUpDown,
              color: config.isServiceRunning
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22,
            ),
            title: const Text('Speed Display Mode'),
            subtitle: Text(_formatDisplayMode(config.speedDisplayMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            enabled: config.isServiceRunning,
            onTap: () {
              HapticFeedback.selectionClick();
              _showDisplayModeDialog(context, config, notifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartupSection(
    BuildContext context,
    WidgetRef ref,
    ForegroundServiceConfig config,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(foregroundServiceProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        title: const Text('Start on Boot'),
        subtitle: const Text(
          'Automatically start background monitoring when device powers on',
        ),
        secondary: HugeIcon(
          icon: HugeIcons.strokeRoundedPower,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        value: config.startOnBoot,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          notifier.toggleStartOnBoot(val);
        },
      ),
    );
  }

  Widget _buildDataPlansTile(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final plansAsync = ref.watch(dataPlansWithUsageProvider);
    final plans = plansAsync.value ?? [];
    final activeCount = plans.where((p) => p.plan.isActive).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: HugeIcon(
          icon: HugeIcons.strokeRoundedSimcard01,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        title: const Text('Data Plans & Allowances'),
        subtitle: Text(
          plansAsync.isLoading
              ? 'Loading plans...'
              : plans.isEmpty
                  ? 'No plans configured (Tap to create)'
                  : '$activeCount active • ${plans.length} total (Multi-SIM quotas & limits)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${plans.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/settings/plans');
        },
      ),
    );
  }

  Widget _buildPermissionsTile(
    BuildContext context,
    AsyncValue<SystemPermissionsState> permsAsync,
  ) {
    final theme = Theme.of(context);
    final perms = permsAsync.value;
    final granted = perms?.grantedCount ?? 0;
    final total = SystemPermissionsState.totalCount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: HugeIcon(
          icon: HugeIcons.strokeRoundedShield02,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        title: const Text('Permissions & System Access'),
        subtitle: Text(
          permsAsync.isLoading
              ? 'Checking status...'
              : '$granted of $total configured (Usage, Notifications, Battery, Shizuku)',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (granted == total
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$granted / $total',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: granted == total
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/settings/permissions');
        },
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    AsyncValue<dynamic> packageInfoAsync,
  ) {
    final theme = Theme.of(context);
    final info = packageInfoAsync.value;
    final versionStr = info != null
        ? 'Version ${info.version} (Build ${info.buildNumber})'
        : 'Version 1.0.0 (Phase 9 Complete)';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedActivity01,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            title: const Text('ByteFlow Network Monitor'),
            subtitle: Text(versionStr),
            trailing: Text(
              'ARM64',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedDocumentCode,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            title: const Text('Open Source Licenses'),
            subtitle: const Text('Legal notices and dependency acknowledgments'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              showLicensePage(
                context: context,
                applicationName: 'ByteFlow',
                applicationVersion: info != null
                    ? '${info.version}+${info.buildNumber}'
                    : '1.0.0+1',
                applicationLegalese:
                    '© 2026 ByteFlow Contributors. Open source under Apache 2.0 / MIT licenses.',
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            title: const Text('About & Architecture'),
            subtitle: const Text('Traffic Light pattern, Drift SQLite, Kotlin core'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              HapticFeedback.selectionClick();
              _showAboutDialog(context, versionStr);
            },
          ),
        ],
      ),
    );
  }

  String _formatSpeedUnitDesc(SpeedUnit unit) {
    return switch (unit) {
      SpeedUnit.auto => 'Automatic dynamic scaling',
      SpeedUnit.kbs => 'Fixed Kilobytes per second',
      SpeedUnit.mbs => 'Fixed Megabytes per second',
      SpeedUnit.gbs => 'Fixed Gigabytes per second',
    };
  }

  String _formatDataUnitDesc(DataUnit unit) {
    return switch (unit) {
      DataUnit.auto => 'Automatic dynamic scaling (B, KB, MB, GB, TB)',
      DataUnit.mb => 'Fixed Megabytes',
      DataUnit.gb => 'Fixed Gigabytes',
    };
  }

  String _formatUsageStyleDesc(UsageDisplayStyle style) {
    return switch (style) {
      UsageDisplayStyle.mobileAndWifi => 'Mobile Data & Wi-Fi breakdown',
      UsageDisplayStyle.downloadAndUpload => 'Download & Upload breakdown',
      UsageDisplayStyle.both => 'Complete breakdown (All Metrics)',
    };
  }

  String _formatDisplayMode(String mode) {
    switch (mode) {
      case 'download':
        return 'Download Speed Only (↓)';
      case 'upload':
        return 'Upload Speed Only (↑)';
      case 'combined':
      default:
        return 'Combined Throughput (↓ + ↑)';
    }
  }

  void _showSpeedUnitDialog(
    BuildContext context,
    UserPreferences prefs,
    UserPreferencesNotifier notifier,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Select Preferred Speed Unit'),
        children: SpeedUnit.values.map((unit) {
          final isSelected = prefs.speedUnit == unit;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(unit.label),
            subtitle: Text(_formatSpeedUnitDesc(unit)),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setSpeedUnit(unit);
              Navigator.of(dialogCtx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDataUnitDialog(
    BuildContext context,
    UserPreferences prefs,
    UserPreferencesNotifier notifier,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Select Preferred Data Volume Unit'),
        children: DataUnit.values.map((unit) {
          final isSelected = prefs.dataUnit == unit;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(unit.label),
            subtitle: Text(_formatDataUnitDesc(unit)),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setDataUnit(unit);
              Navigator.of(dialogCtx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showUsageDisplayStyleDialog(
    BuildContext context,
    UserPreferences prefs,
    UserPreferencesNotifier notifier,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Select Data Usage Display Style'),
        children: UsageDisplayStyle.values.map((style) {
          final isSelected = prefs.usageDisplayStyle == style;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: Text(style.label),
            subtitle: Text(_formatUsageStyleDesc(style)),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setUsageDisplayStyle(style);
              Navigator.of(dialogCtx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDisplayModeDialog(
    BuildContext context,
    ForegroundServiceConfig config,
    ForegroundServiceNotifier notifier,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Select Status Bar Speed Mode'),
        children: [
          ListTile(
            leading: Icon(
              config.speedDisplayMode == 'combined'
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Combined Throughput'),
            subtitle: const Text('Total download + upload rate (↓ + ↑)'),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setSpeedDisplayMode('combined');
              Navigator.of(dialogCtx).pop();
            },
          ),
          ListTile(
            leading: Icon(
              config.speedDisplayMode == 'download'
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Download Only'),
            subtitle: const Text('Only incoming data rate (↓)'),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setSpeedDisplayMode('download');
              Navigator.of(dialogCtx).pop();
            },
          ),
          ListTile(
            leading: Icon(
              config.speedDisplayMode == 'upload'
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Upload Only'),
            subtitle: const Text('Only outgoing data rate (↑)'),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setSpeedDisplayMode('upload');
              Navigator.of(dialogCtx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, String versionStr) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedActivity01,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('ByteFlow'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              versionStr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A modern, production-grade Android network monitor built with Flutter, Drift SQLite, and Kotlin.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '• Real-time TrafficStats 1 Hz delta stream\n'
              '• In-memory dynamic status bar Canvas speed icon\n'
              '• High-performance coroutine-based per-app tracking\n'
              '• Shizuku Traffic Light pattern for privileged multi-SIM IMSI mapping\n'
              '• Screen-off battery preservation',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
