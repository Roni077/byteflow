/// Widget tests for PermissionsScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/providers/permissions_provider.dart';
import 'package:byteflow/screens/settings/permissions_screen.dart';

class _FakePermissionsNotifier extends PermissionsNotifier {
  _FakePermissionsNotifier(this._initial);
  final SystemPermissionsState _initial;

  @override
  Future<SystemPermissionsState> build() async => _initial;
}

void main() {
  const allGrantedPerms = SystemPermissionsState(
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

  const partialPerms = SystemPermissionsState(
    usageAccess: true,
    notifications: false,
    batteryOptimizationIgnored: false,
    shizukuStatus: ShizukuStatus(
      isAvailable: false,
      hasPermission: false,
      version: -1,
      uid: -1,
    ),
  );

  Widget buildSubject({SystemPermissionsState perms = allGrantedPerms}) {
    return ProviderScope(
      overrides: [
        permissionsProvider.overrideWith(
          () => _FakePermissionsNotifier(perms),
        ),
      ],
      child: const MaterialApp(
        home: PermissionsScreen(),
      ),
    );
  }

  group('PermissionsScreen Widget Tests', () {
    testWidgets('renders all permission cards and privacy notice',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('Permissions & Access'), findsOneWidget);

      // Section cards
      expect(find.text('Usage Access'), findsOneWidget);
      expect(find.text('Notifications (Android 13+)'), findsOneWidget);
      expect(find.text('Battery Optimization'), findsOneWidget);
      expect(find.text('Shizuku Privileged Multi-SIM'), findsOneWidget);
      expect(find.text('Privacy & Data Security'), findsOneWidget);
    });

    testWidgets('renders all configured banner when all permissions granted',
        (tester) async {
      await tester.pumpWidget(buildSubject(perms: allGrantedPerms));
      await tester.pumpAndSettle();

      expect(find.text('All Permissions Configured'), findsOneWidget);
      expect(
        find.text(
          'ByteFlow has all necessary system access for full multi-SIM and per-app monitoring.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders partial count banner when permissions missing',
        (tester) async {
      await tester.pumpWidget(buildSubject(perms: partialPerms));
      await tester.pumpAndSettle();

      expect(find.text('1 of 4 Services Configured'), findsOneWidget);
      expect(
        find.text(
          'Grant the permissions below for real-time tracking, background efficiency, and per-app history.',
        ),
        findsOneWidget,
      );
    });
  });
}
