/// Domain model capturing computed data plan usage, cycle windows, and alert states.
library;

import 'package:flutter/foundation.dart';
import 'package:byteflow/database/app_database.dart';

/// Computed usage metrics and billing cycle status for a configured [DataPlan].
@immutable
class DataPlanUsageInfo {
  /// Creates a [DataPlanUsageInfo] instance.
  const DataPlanUsageInfo({
    required this.plan,
    required this.cycleStart,
    required this.cycleEnd,
    required this.daysRemaining,
    required this.totalDaysInCycle,
    required this.usedBytes,
    required this.remainingBytes,
    required this.percentUsed,
    required this.recommendedDailyBytes,
    required this.averageDailyBytes,
    required this.isWarning,
    required this.isExceeded,
  });

  /// The underlying database data plan record.
  final DataPlan plan;

  /// The timestamp marking the start of the current active billing cycle.
  final DateTime cycleStart;

  /// The timestamp marking the conclusion of the current active billing cycle.
  final DateTime cycleEnd;

  /// Number of full or partial calendar days remaining until the cycle resets.
  final int daysRemaining;

  /// Total number of calendar days in the current billing cycle.
  final int totalDaysInCycle;

  /// Total data volume consumed in bytes within this billing cycle.
  final int usedBytes;

  /// Remaining data allowance in bytes before reaching the quota limit (clamped to 0).
  final int remainingBytes;

  /// Percentage of quota consumed (0.0 to 100.0+).
  final double percentUsed;

  /// Calculated recommended daily data allowance (in bytes) to last through the cycle.
  final int recommendedDailyBytes;

  /// Actual average daily consumption rate (in bytes) during this cycle.
  final int averageDailyBytes;

  /// Whether the plan has crossed the warning threshold percentage but not exceeded the limit.
  final bool isWarning;

  /// Whether data consumption has met or exceeded 100% of the quota limit.
  final bool isExceeded;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataPlanUsageInfo &&
          runtimeType == other.runtimeType &&
          plan.id == other.plan.id &&
          cycleStart == other.cycleStart &&
          cycleEnd == other.cycleEnd &&
          daysRemaining == other.daysRemaining &&
          totalDaysInCycle == other.totalDaysInCycle &&
          usedBytes == other.usedBytes &&
          remainingBytes == other.remainingBytes &&
          percentUsed == other.percentUsed &&
          recommendedDailyBytes == other.recommendedDailyBytes &&
          averageDailyBytes == other.averageDailyBytes &&
          isWarning == other.isWarning &&
          isExceeded == other.isExceeded;

  @override
  int get hashCode => Object.hash(
        plan.id,
        cycleStart,
        cycleEnd,
        daysRemaining,
        totalDaysInCycle,
        usedBytes,
        remainingBytes,
        percentUsed,
        recommendedDailyBytes,
        averageDailyBytes,
        isWarning,
        isExceeded,
      );
}
