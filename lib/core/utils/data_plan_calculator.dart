/// Billing cycle windows, allowance projections, and data quota mathematics.
library;

import 'dart:math';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';

/// Pure computational utility for billing cycles, quota tracking, and daily allowances.
abstract final class DataPlanCalculator {
  /// Returns the number of days in the specified [month] of [year].
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Calculates the active billing cycle `(cycleStart, cycleEnd)` window for the given [now].
  static (DateTime start, DateTime end) calculateCycleWindow({
    required DateTime cycleStartDate,
    required String cycleType,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();

    return switch (cycleType.toLowerCase()) {
      'daily' => _calculateDailyWindow(cycleStartDate, current),
      'weekly' => _calculateWeeklyWindow(cycleStartDate, current),
      _ => _calculateMonthlyWindow(cycleStartDate, current),
    };
  }

  static (DateTime start, DateTime end) _calculateDailyWindow(
    DateTime cycleStartDate,
    DateTime current,
  ) {
    final todayCandidate = DateTime(
      current.year,
      current.month,
      current.day,
      cycleStartDate.hour,
      cycleStartDate.minute,
      cycleStartDate.second,
      cycleStartDate.millisecond,
    );

    final DateTime start;
    if (current.isBefore(todayCandidate)) {
      start = todayCandidate.subtract(const Duration(days: 1));
    } else {
      start = todayCandidate;
    }

    final end = start.add(const Duration(days: 1)).subtract(
          const Duration(milliseconds: 1),
        );
    return (start, end);
  }

  static (DateTime start, DateTime end) _calculateWeeklyWindow(
    DateTime cycleStartDate,
    DateTime current,
  ) {
    if (current.isBefore(cycleStartDate)) {
      final end = cycleStartDate.add(const Duration(days: 7)).subtract(
            const Duration(milliseconds: 1),
          );
      return (cycleStartDate, end);
    }

    final diffDays = current.difference(cycleStartDate).inDays;
    final cycleIndex = diffDays ~/ 7;
    final start = cycleStartDate.add(Duration(days: cycleIndex * 7));
    final end = start.add(const Duration(days: 7)).subtract(
          const Duration(milliseconds: 1),
        );
    return (start, end);
  }

  static (DateTime start, DateTime end) _calculateMonthlyWindow(
    DateTime cycleStartDate,
    DateTime current,
  ) {
    final targetDay = cycleStartDate.day;

    final startDayThisMonth = min(targetDay, daysInMonth(current.year, current.month));
    final candidateThisMonth = DateTime(
      current.year,
      current.month,
      startDayThisMonth,
      cycleStartDate.hour,
      cycleStartDate.minute,
      cycleStartDate.second,
      cycleStartDate.millisecond,
    );

    final DateTime start;
    final DateTime nextCycleStart;

    if (current.isBefore(candidateThisMonth)) {
      // Current cycle started in previous month
      final prevYear = current.month == 1 ? current.year - 1 : current.year;
      final prevMonth = current.month == 1 ? 12 : current.month - 1;
      final startDayPrevMonth = min(targetDay, daysInMonth(prevYear, prevMonth));

      start = DateTime(
        prevYear,
        prevMonth,
        startDayPrevMonth,
        cycleStartDate.hour,
        cycleStartDate.minute,
        cycleStartDate.second,
        cycleStartDate.millisecond,
      );
      nextCycleStart = candidateThisMonth;
    } else {
      // Current cycle started in this month
      start = candidateThisMonth;

      final nextYear = current.month == 12 ? current.year + 1 : current.year;
      final nextMonth = current.month == 12 ? 1 : current.month + 1;
      final startDayNextMonth = min(targetDay, daysInMonth(nextYear, nextMonth));

      nextCycleStart = DateTime(
        nextYear,
        nextMonth,
        startDayNextMonth,
        cycleStartDate.hour,
        cycleStartDate.minute,
        cycleStartDate.second,
        cycleStartDate.millisecond,
      );
    }

    final end = nextCycleStart.subtract(const Duration(milliseconds: 1));
    return (start, end);
  }

  /// Calculates calendar days remaining in the billing cycle including today.
  static int calculateDaysRemaining(DateTime cycleEnd, [DateTime? now]) {
    final current = now ?? DateTime.now();
    if (current.isAfter(cycleEnd)) {
      return 0;
    }

    final endDay = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);
    final currentDay = DateTime(current.year, current.month, current.day);
    final days = endDay.difference(currentDay).inDays + 1;
    return max(1, days);
  }

  /// Calculates total calendar days across the given cycle range.
  static int calculateTotalDays(DateTime cycleStart, DateTime cycleEnd) {
    final startDay = DateTime(cycleStart.year, cycleStart.month, cycleStart.day);
    final endDay = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);
    final days = endDay.difference(startDay).inDays + 1;
    return max(1, days);
  }

  /// Computes complete [DataPlanUsageInfo] for a [DataPlan] and actual [usedBytes].
  static DataPlanUsageInfo calculateUsageInfo({
    required DataPlan plan,
    required int usedBytes,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final (cycleStart, cycleEnd) = calculateCycleWindow(
      cycleStartDate: plan.cycleStartDate,
      cycleType: plan.cycleType,
      now: current,
    );

    final daysRemaining = calculateDaysRemaining(cycleEnd, current);
    final totalDaysInCycle = calculateTotalDays(cycleStart, cycleEnd);
    final remainingBytes = max(0, plan.limitBytes - usedBytes);
    final percentUsed =
        plan.limitBytes > 0 ? (usedBytes / plan.limitBytes) * 100 : 0.0;
    final isExceeded = usedBytes >= plan.limitBytes;
    final isWarning = !isExceeded && (percentUsed >= plan.warningPercent);

    final recommendedDailyBytes = (daysRemaining > 0 && remainingBytes > 0)
        ? (remainingBytes / daysRemaining).round()
        : 0;

    final startDay = DateTime(cycleStart.year, cycleStart.month, cycleStart.day);
    final currentDay = DateTime(current.year, current.month, current.day);
    final daysElapsed = max(1, currentDay.difference(startDay).inDays + 1);
    final averageDailyBytes = usedBytes ~/ daysElapsed;

    return DataPlanUsageInfo(
      plan: plan,
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
      daysRemaining: daysRemaining,
      totalDaysInCycle: totalDaysInCycle,
      usedBytes: usedBytes,
      remainingBytes: remainingBytes,
      percentUsed: percentUsed,
      recommendedDailyBytes: recommendedDailyBytes,
      averageDailyBytes: averageDailyBytes,
      isWarning: isWarning,
      isExceeded: isExceeded,
    );
  }
}
