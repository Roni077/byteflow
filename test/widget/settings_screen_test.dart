/// Widget tests for SettingsScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';
import 'package:byteflow/models/foreground_service_config.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/models/user_preferences.dart';
import 'package:byteflow/providers/data_plans_provider.dart';
import 'package:byteflow/providers/foreground_service_provider.dart';
import 'package:byteflow/providers/package_info_provider.dart';
import 'package:byteflow/providers/permissions_provider.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';
import 'package:byteflow/screens/settings/settings_screen.dart';

class _FakeForegroundServiceNotifier extends ForegroundServiceNotifier {
  _FakeForegroundServiceNotifier(this._initial);
  final ForegroundServiceConfig _initial;

  @override
  Future<ForegroundServiceConfig> build() async => _initial;
}

class _FakeUserPreferencesNotifier extends UserPreferencesNotifier {
  _FakeUserPreferencesNotifier(this._initial);
  final UserPreferences _initial;

  @override
  Future<UserPreferences> build() async => _initial;
}

class _FakePermissionsNotifier extends PermissionsNotifier {
  _FakePermissionsNotifier(this._initial);
  final SystemPermissionsState _initial;

  @override
  Future<SystemPermissionsState> build() async => _initial;
}

void main() {
  const initialConfig = ForegroundServiceConfig(
    isServiceRunning: true,
    showStatusBarSpeed: true,
    speedDisplayMode: 'combined',
    startOnBoot: false,
    pollingIntervalMs: 1000,
    showPersistentNotification: true,
  );

  const initialPrefs = UserPreferences(
    themeMode: ThemeMode.system,
    speedUnit: SpeedUnit.auto,
    dataUnit: DataUnit.auto,
    pollingIntervalMs: 1000,
    showPersistentNotification: true,
  );

  const initialPerms = SystemPermissionsState(
    usageAccess: true,
    notifications: true,
    batteryOptimizationIgnored: true,
    shizukuStatus: ShizukuStatus(
      isAvailable: true,
      hasPermission: true,
      version: 13,
      uid: 1000,
    ),
  );

  final mockPackageInfo = PackageInfo(
    appName: 'ByteFlow',
    packageName: 'com.byteflow.network',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );

  Widget buildSubject({
    ForegroundServiceConfig config = initialConfig,
    UserPreferences prefs = initialPrefs,
    SystemPermissionsState perms = initialPerms,
  }) {
    return ProviderScope(
      overrides: [
        foregroundServiceProvider.overrideWith(
          () => _FakeForegroundServiceNotifier(config),
        ),
        userPreferencesProvider.overrideWith(
          () => _FakeUserPreferencesNotifier(prefs),
        ),
        permissionsProvider.overrideWith(
          () => _FakePermissionsNotifier(perms),
        ),
        packageInfoProvider.overrideWith(
          (ref) async => mockPackageInfo,
        ),
        dataPlansWithUsageProvider.overrideWith(
          (ref) async => <DataPlanUsageInfo>[],
        ),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all major section headers and status card',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // App bar title
      expect(find.text('Settings'), findsOneWidget);

      // Active monitoring card
      expect(find.text('Monitoring Active'), findsOneWidget);

      // Section headers
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Data Usage Display'), findsOneWidget);
      expect(find.text('Data Usage Display Style'), findsOneWidget);
      expect(find.text('Units of Measurement'), findsOneWidget);
      expect(find.text('Background Monitoring & Service'), findsOneWidget);
      expect(find.text('Status Bar Speed Indicator'), findsNWidgets(2));
      expect(find.text('System Startup'), findsOneWidget);
      expect(find.text('System Permissions & Hardware'), findsOneWidget);
      expect(find.text('About ByteFlow'), findsOneWidget);
    });

    testWidgets('renders appearance theme segmented buttons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('renders inactive status when foreground service stopped',
        (tester) async {
      const inactiveConfig = ForegroundServiceConfig(
        isServiceRunning: false,
        showStatusBarSpeed: false,
      );

      await tester.pumpWidget(buildSubject(config: inactiveConfig));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Monitoring Inactive'), findsOneWidget);
      expect(
        find.text('Background foreground service is currently stopped.'),
        findsOneWidget,
      );
    });

    testWidgets('renders version info in About section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });
  });
}
