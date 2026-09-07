/// Data access object for querying and managing user data plans.
library;

import 'package:drift/drift.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/database/tables/data_plans_table.dart';

part 'plans_dao.g.dart';

/// DAO managing [DataPlans] operations.
@DriftAccessor(tables: [DataPlans])
class DataPlansDao extends DatabaseAccessor<AppDatabase>
    with _$DataPlansDaoMixin {
  /// Creates a [DataPlansDao] associated with the provided [db].
  DataPlansDao(super.db);

  /// Retrieves all configured data plans.
  Future<List<DataPlan>> getAllPlans() {
    return (select(dataPlans)..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();
  }

  /// Streams all configured data plans.
  Stream<List<DataPlan>> watchAllPlans() {
    return (select(dataPlans)..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).watch();
  }

  /// Retrieves the active plan, or null if none is configured.
  Future<DataPlan?> getActivePlan() {
    return (select(dataPlans)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Streams the primary active plan.
  Stream<DataPlan?> watchActivePlan() {
    return (select(dataPlans)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Inserts a new data plan.
  Future<int> insertPlan(DataPlansCompanion plan) {
    return into(dataPlans).insert(plan);
  }

  /// Updates an existing plan.
  Future<bool> updatePlan(DataPlan plan) {
    return update(dataPlans).replace(plan);
  }

  /// Deletes a data plan by its [id].
  Future<int> deletePlan(int id) {
    return (delete(dataPlans)..where((tbl) => tbl.id.equals(id))).go();
  }
}
