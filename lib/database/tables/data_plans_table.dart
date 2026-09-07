/// Drift table definition for mobile and broadband data plans.
library;

import 'package:drift/drift.dart';

/// Table storing user data plans, billing cycles, and thresholds.
class DataPlans extends Table {
  /// Unique plan identifier.
  IntColumn get id => integer().autoIncrement()();

  /// User-assigned label for the plan (e.g., 'Primary SIM - 100GB').
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Total data quota limit in bytes.
  IntColumn get limitBytes => integer()();

  /// Start date and time of the current billing cycle.
  DateTimeColumn get cycleStartDate => dateTime()();

  /// Cycle recurrence type: 'daily', 'weekly', or 'monthly'.
  TextColumn get cycleType => text().withDefault(const Constant('monthly'))();

  /// Associated SIM slot index (0, 1) or null for all / generic plans.
  IntColumn get simSlot => integer().nullable()();

  /// Warning threshold percentage (e.g. 80 for 80%).
  IntColumn get warningPercent => integer().withDefault(const Constant(80))();

  /// Whether this plan is actively tracked.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
