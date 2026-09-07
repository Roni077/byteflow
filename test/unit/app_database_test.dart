/// Unit tests for Drift database, DAOs, and SQLite queries using package:checks.
library;

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:byteflow/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory isolated SQLite database for unit testing
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('UsageDao Tests', () {
    test('inserts and queries discrete snapshots within date range', () async {
      final now = DateTime(2026, 9, 5, 12, 0);

      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now.subtract(const Duration(hours: 2)),
          downloadBytes: 1024 * 1024 * 10, // 10 MB
          uploadBytes: 1024 * 1024 * 2, // 2 MB
          wifiBytes: 1024 * 1024 * 12,
          mobileBytes: 0,
        ),
      );

      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now.subtract(const Duration(hours: 1)),
          downloadBytes: 1024 * 1024 * 5, // 5 MB
          uploadBytes: 1024 * 1024 * 1, // 1 MB
          wifiBytes: 0,
          mobileBytes: 1024 * 1024 * 6,
        ),
      );

      // Snapshot outside query range
      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now.subtract(const Duration(days: 2)),
          downloadBytes: 1024 * 1024 * 50,
          uploadBytes: 1024 * 1024 * 10,
          wifiBytes: 1024 * 1024 * 60,
          mobileBytes: 0,
        ),
      );

      final queryStart = now.subtract(const Duration(hours: 3));
      final queryEnd = now;

      final snapshots = await db.usageDao.getSnapshotsBetween(queryStart, queryEnd);
      check(snapshots).length.equals(2);

      final aggregate = await db.usageDao.getAggregateBetween(queryStart, queryEnd);
      check(aggregate.downloadBytes).equals(1024 * 1024 * 15);
      check(aggregate.uploadBytes).equals(1024 * 1024 * 3);
      check(aggregate.totalBytes).equals(1024 * 1024 * 18);
      check(aggregate.wifiBytes).equals(1024 * 1024 * 12);
      check(aggregate.mobileBytes).equals(1024 * 1024 * 6);
    });

    test('deletes snapshots older than threshold', () async {
      final now = DateTime(2026, 9, 5, 12, 0);

      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now.subtract(const Duration(days: 100)),
          downloadBytes: 500,
          uploadBytes: 500,
          wifiBytes: 1000,
          mobileBytes: 0,
        ),
      );

      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now,
          downloadBytes: 1000,
          uploadBytes: 1000,
          wifiBytes: 2000,
          mobileBytes: 0,
        ),
      );

      final deletedCount = await db.usageDao.deleteOlderThan(
        now.subtract(const Duration(days: 30)),
      );
      check(deletedCount).equals(1);

      final remaining = await db.usageDao.getSnapshotsBetween(
        now.subtract(const Duration(days: 365)),
        now.add(const Duration(days: 1)),
      );
      check(remaining).length.equals(1);
    });
  });

  group('DataPlansDao Tests', () {
    test('inserts, queries, and updates data plans', () async {
      final planId = await db.dataPlansDao.insertPlan(
        DataPlansCompanion.insert(
          name: 'Primary SIM Plan',
          limitBytes: 1024 * 1024 * 1024 * 50, // 50 GB
          cycleStartDate: DateTime(2026, 9, 1),
        ),
      );

      check(planId).isGreaterThan(0);

      final activePlan = await db.dataPlansDao.getActivePlan();
      check(activePlan).isNotNull();
      check(activePlan!.name).equals('Primary SIM Plan');
      check(activePlan.limitBytes).equals(1024 * 1024 * 1024 * 50);

      // Update plan
      final updated = await db.dataPlansDao.updatePlan(
        activePlan.copyWith(name: 'Updated SIM Plan'),
      );
      check(updated).isTrue();

      final reFetched = await db.dataPlansDao.getActivePlan();
      check(reFetched!.name).equals('Updated SIM Plan');

      // Delete plan
      final deleted = await db.dataPlansDao.deletePlan(planId);
      check(deleted).equals(1);

      final afterDelete = await db.dataPlansDao.getActivePlan();
      check(afterDelete).isNull();
    });
  });

  group('SettingsDao Tests', () {
    test('stores, retrieves, and updates key-value preferences', () async {
      await db.settingsDao.setSetting('theme_mode', 'dark');
      final value = await db.settingsDao.getSetting('theme_mode');
      check(value).equals('dark');

      // Overwrite setting
      await db.settingsDao.setSetting('theme_mode', 'light');
      final updatedValue = await db.settingsDao.getSetting('theme_mode');
      check(updatedValue).equals('light');

      // Default fallback
      final fallback = await db.settingsDao.getSetting(
        'non_existent',
        defaultValue: 'default_val',
      );
      check(fallback).equals('default_val');

      // Remove setting
      await db.settingsDao.removeSetting('theme_mode');
      final afterRemove = await db.settingsDao.getSetting('theme_mode');
      check(afterRemove).isNull();
    });
  });
}
