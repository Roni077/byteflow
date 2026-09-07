/// Unit tests for UsageRepository batched persistence and delta buffering using package:checks.
library;

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/repositories/usage_repository.dart';

void main() {
  late AppDatabase db;
  late UsageRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    // Disable automatic periodic timer to test deterministic flushing
    repository = UsageRepository(db, enablePeriodicFlush: false);
  });

  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  group('UsageRepository Batched Persistence Tests', () {
    test('accumulates deltas in memory without writing to database before flush', () async {
      repository.recordDelta(
        rxDelta: 1000,
        txDelta: 500,
        transport: NetworkType.wifi,
      );

      repository.recordDelta(
        rxDelta: 2000,
        txDelta: 1000,
        transport: NetworkType.mobile,
      );

      check(repository.pendingDownloadBytes).equals(3000);
      check(repository.pendingUploadBytes).equals(1500);
      check(repository.pendingWifiBytes).equals(1500);
      check(repository.pendingMobileBytes).equals(3000);

      // Verify no snapshots written to database yet
      final beforeFlush = await db.usageDao.getSnapshotsBetween(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 1)),
      );
      check(beforeFlush).isEmpty();
    });

    test('flushes buffered deltas into a single snapshot and resets counters', () async {
      repository.recordDelta(
        rxDelta: 4000,
        txDelta: 1000,
        transport: NetworkType.wifi,
      );

      await repository.flush();

      // Pending counters should reset to 0
      check(repository.pendingDownloadBytes).equals(0);
      check(repository.pendingUploadBytes).equals(0);
      check(repository.pendingWifiBytes).equals(0);
      check(repository.pendingMobileBytes).equals(0);

      // Snapshot is persisted
      final snapshots = await db.usageDao.getSnapshotsBetween(
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().add(const Duration(hours: 1)),
      );
      check(snapshots).length.equals(1);
      check(snapshots.first.downloadBytes).equals(4000);
      check(snapshots.first.uploadBytes).equals(1000);
      check(snapshots.first.wifiBytes).equals(5000);
    });

    test('flush with zero deltas is a no-op', () async {
      await repository.flush();

      final snapshots = await db.usageDao.getSnapshotsBetween(
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now().add(const Duration(hours: 1)),
      );
      check(snapshots).isEmpty();
    });

    test('retrieves today and monthly aggregates', () async {
      final now = DateTime.now();

      repository.recordDelta(
        rxDelta: 1024 * 1024 * 20, // 20 MB
        txDelta: 1024 * 1024 * 5,  // 5 MB
        transport: NetworkType.wifi,
      );
      await repository.flush();

      final todayAgg = await repository.getTodayAggregate(now);
      check(todayAgg.downloadBytes).equals(1024 * 1024 * 20);
      check(todayAgg.uploadBytes).equals(1024 * 1024 * 5);
      check(todayAgg.totalBytes).equals(1024 * 1024 * 25);

      final monthAgg = await repository.getCurrentMonthAggregate(now);
      check(monthAgg.totalBytes).equals(1024 * 1024 * 25);
    });
  });
}
