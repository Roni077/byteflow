import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/models/user_preferences.dart';
import 'package:byteflow/providers/permissions_provider.dart';

void main() {
  group('UserPreferences Model', () {
    test('default constructor initializes with standard defaults', () {
      const prefs = UserPreferences();
      expect(prefs.themeMode, equals(ThemeMode.system));
      expect(prefs.speedUnit, equals(SpeedUnit.auto));
      expect(prefs.dataUnit, equals(DataUnit.auto));
      expect(prefs.usageDisplayStyle, equals(UsageDisplayStyle.mobileAndWifi));
      expect(prefs.pollingIntervalMs, equals(1000));
      expect(prefs.showPersistentNotification, isTrue);
    });

    test('copyWith properly updates fields', () {
      const prefs = UserPreferences();
      final updated = prefs.copyWith(
        themeMode: ThemeMode.dark,
        speedUnit: SpeedUnit.mbs,
        dataUnit: DataUnit.gb,
        usageDisplayStyle: UsageDisplayStyle.downloadAndUpload,
        pollingIntervalMs: 2000,
        showPersistentNotification: false,
      );

      expect(updated.themeMode, equals(ThemeMode.dark));
      expect(updated.speedUnit, equals(SpeedUnit.mbs));
      expect(updated.dataUnit, equals(DataUnit.gb));
      expect(updated.usageDisplayStyle, equals(UsageDisplayStyle.downloadAndUpload));
      expect(updated.pollingIntervalMs, equals(2000));
      expect(updated.showPersistentNotification, isFalse);
    });

    test('UsageDisplayStyle.fromString parses valid and fallback values', () {
      expect(UsageDisplayStyle.fromString('mobileAndWifi'), equals(UsageDisplayStyle.mobileAndWifi));
      expect(UsageDisplayStyle.fromString('downloadAndUpload'), equals(UsageDisplayStyle.downloadAndUpload));
      expect(UsageDisplayStyle.fromString('download_and_upload'), equals(UsageDisplayStyle.downloadAndUpload));
      expect(UsageDisplayStyle.fromString('rx_tx'), equals(UsageDisplayStyle.downloadAndUpload));
      expect(UsageDisplayStyle.fromString('both'), equals(UsageDisplayStyle.both));
      expect(UsageDisplayStyle.fromString('all'), equals(UsageDisplayStyle.both));
      expect(UsageDisplayStyle.fromString('detailed'), equals(UsageDisplayStyle.both));
      expect(UsageDisplayStyle.fromString('unknown_value'), equals(UsageDisplayStyle.mobileAndWifi));
      expect(UsageDisplayStyle.fromString(null), equals(UsageDisplayStyle.mobileAndWifi));
    });

    test('equality and hashCode contract', () {
      const p1 = UserPreferences(themeMode: ThemeMode.light);
      const p2 = UserPreferences(themeMode: ThemeMode.light);
      const p3 = UserPreferences(themeMode: ThemeMode.dark);
      const p4 = UserPreferences(usageDisplayStyle: UsageDisplayStyle.both);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
      expect(p1, isNot(equals(p4)));
    });
  });

  group('SystemPermissionsState Model', () {
    test('calculates grantedCount correctly', () {
      const emptyState = SystemPermissionsState();
      expect(emptyState.grantedCount, equals(0));

      const partialState = SystemPermissionsState(
        usageAccess: true,
        notifications: true,
      );
      expect(partialState.grantedCount, equals(2));

      const fullState = SystemPermissionsState(
        usageAccess: true,
        notifications: true,
        batteryOptimizationIgnored: true,
        shizukuStatus: ShizukuStatus(
          isAvailable: true,
          hasPermission: true,
          version: 13,
          uid: 2000,
        ),
      );
      expect(fullState.grantedCount, equals(4));
    });
  });
}
