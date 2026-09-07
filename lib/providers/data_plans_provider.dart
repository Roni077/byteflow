/// Riverpod state providers for reactive data plan queries, calculations, and CRUD actions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/utils/data_plan_calculator.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';
import 'package:byteflow/providers/database_provider.dart';
import 'package:byteflow/providers/shizuku_provider.dart';
import 'package:byteflow/providers/sim_provider.dart';
import 'package:byteflow/services/shizuku_service.dart';
import 'package:byteflow/services/widget_sync_service.dart';

/// Streams all configured [DataPlan] records from the local SQLite database.
final dataPlansStreamProvider = StreamProvider<List<DataPlan>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.dataPlansDao.watchAllPlans();
});

/// Computes usage and cycle progression for all configured data plans.
final dataPlansWithUsageProvider =
    FutureProvider<List<DataPlanUsageInfo>>((ref) async {
  final plansAsync = ref.watch(dataPlansStreamProvider);
  final plans = plansAsync.value ?? <DataPlan>[];
  final widgetSync = ref.watch(widgetSyncServiceProvider);

  if (plans.isEmpty) {
    await widgetSync.syncDataPlanWidget(<DataPlanUsageInfo>[]);
    return <DataPlanUsageInfo>[];
  }

  final usageRepo = ref.watch(usageRepositoryProvider);
  final shizukuService = ref.watch(shizukuServiceProvider);
  final shizukuStatus = ref.watch(shizukuStatusProvider).value;
  final simCards = ref.watch(simCardsProvider).value ?? [];
  final simSubscriberIds = ref.watch(simSubscriberIdsProvider).value ?? {};

  final now = DateTime.now();
  final result = <DataPlanUsageInfo>[];

  for (final plan in plans) {
    final (start, end) = DataPlanCalculator.calculateCycleWindow(
      cycleStartDate: plan.cycleStartDate,
      cycleType: plan.cycleType,
      now: now,
    );

    int usedBytes = 0;
    var resolvedViaShizuku = false;

    // Privileged Shizuku per-SIM tracking when plan is tied to a specific SIM slot
    if (plan.simSlot != null && shizukuStatus != null && shizukuStatus.hasPermission) {
      final matchingSim = simCards.where((s) => s.simSlotIndex == plan.simSlot).firstOrNull;
      if (matchingSim != null) {
        final subId = matchingSim.subscriptionId;
        final subscriberId = simSubscriberIds[subId];

        final simUsage = await shizukuService.querySimUsage(
          subId: subId,
          subscriberId: subscriberId,
          startTime: start,
          endTime: end,
        );

        if (simUsage.isPrivileged) {
          usedBytes = simUsage.totalBytes;
          resolvedViaShizuku = true;
        }
      }
    }

    if (!resolvedViaShizuku) {
      // Graceful fallback to device-wide cellular aggregate
      final aggregate = await usageRepo.getAggregateForRange(start, end);
      usedBytes = aggregate.mobileBytes;
    }

    final info = DataPlanCalculator.calculateUsageInfo(
      plan: plan,
      usedBytes: usedBytes,
      now: now,
    );
    result.add(info);
  }

  // Synchronize active data plan metrics with native home-screen widget
  await widgetSync.syncDataPlanWidget(result);

  return result;
});

/// Controller providing mutation actions (Create, Update, Delete) for data plans.
class DataPlanActionController {
  /// Creates a [DataPlanActionController] backed by the provided [AppDatabase].
  DataPlanActionController(this._db);

  final AppDatabase _db;

  /// Inserts a new data plan into the database.
  Future<int> addPlan(DataPlansCompanion companion) {
    return _db.dataPlansDao.insertPlan(companion);
  }

  /// Updates an existing data plan record.
  Future<bool> updatePlan(DataPlan plan) {
    return _db.dataPlansDao.updatePlan(plan);
  }

  /// Removes a data plan by its primary [id].
  Future<int> deletePlan(int id) {
    return _db.dataPlansDao.deletePlan(id);
  }

  /// Toggles the [isActive] flag of a [DataPlan].
  Future<bool> toggleActive(DataPlan plan) {
    return _db.dataPlansDao.updatePlan(plan.copyWith(isActive: !plan.isActive));
  }
}

/// Provides the singleton [DataPlanActionController] instance.
final dataPlanActionControllerProvider =
    Provider<DataPlanActionController>((ref) {
  final db = ref.watch(databaseProvider);
  return DataPlanActionController(db);
});
