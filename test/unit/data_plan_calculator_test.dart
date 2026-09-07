import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/utils/data_plan_calculator.dart';
import 'package:byteflow/database/app_database.dart';

void main() {
  group('DataPlanCalculator', () {
    group('daysInMonth', () {
      test('correctly calculates days in months for standard and leap years', () {
        expect(DataPlanCalculator.daysInMonth(2026, 1), equals(31)); // Jan
        expect(DataPlanCalculator.daysInMonth(2026, 2), equals(28)); // Feb non-leap
        expect(DataPlanCalculator.daysInMonth(2024, 2), equals(29)); // Feb leap
        expect(DataPlanCalculator.daysInMonth(2026, 4), equals(30)); // Apr
        expect(DataPlanCalculator.daysInMonth(2026, 12), equals(31)); // Dec
      });
    });

    group('calculateCycleWindow - Monthly', () {
      test('computes active monthly cycle when now is after cycle anchor day', () {
        final anchor = DateTime(2026, 1, 15, 0, 0, 0);
        final now = DateTime(2026, 9, 20, 10, 0, 0);

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'monthly',
          now: now,
        );

        expect(start, equals(DateTime(2026, 9, 15, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 10, 14, 23, 59, 59, 999)));
      });

      test('computes active monthly cycle when now is before cycle anchor day', () {
        final anchor = DateTime(2026, 1, 15, 0, 0, 0);
        final now = DateTime(2026, 9, 5, 10, 0, 0);

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'monthly',
          now: now,
        );

        expect(start, equals(DateTime(2026, 8, 15, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 9, 14, 23, 59, 59, 999)));
      });

      test('handles month-end boundary clamp (day 31 in 30-day month)', () {
        final anchor = DateTime(2026, 1, 31, 0, 0, 0);
        final now = DateTime(2026, 4, 15, 12, 0, 0);

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'monthly',
          now: now,
        );

        // In April (30 days), anchor day 31 is clamped to 30.
        // Since now is April 15 (before April 30), current cycle started in March (31 days)
        expect(start, equals(DateTime(2026, 3, 31, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 4, 29, 23, 59, 59, 999)));
      });

      test('handles year transition across December and January', () {
        final anchor = DateTime(2025, 5, 20, 0, 0, 0);
        final now = DateTime(2026, 1, 10, 8, 0, 0);

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'monthly',
          now: now,
        );

        // Before Jan 20 -> started Dec 20, 2025
        expect(start, equals(DateTime(2025, 12, 20, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 1, 19, 23, 59, 59, 999)));
      });
    });

    group('calculateCycleWindow - Weekly & Daily', () {
      test('computes weekly 7-day cycle aligned with start date', () {
        final anchor = DateTime(2026, 9, 1, 0, 0, 0);
        final now = DateTime(2026, 9, 10, 14, 0, 0); // 9 days after anchor -> 2nd cycle

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'weekly',
          now: now,
        );

        expect(start, equals(DateTime(2026, 9, 8, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 9, 14, 23, 59, 59, 999)));
      });

      test('computes daily 24-hour cycle', () {
        final anchor = DateTime(2026, 1, 1, 0, 0, 0);
        final now = DateTime(2026, 9, 5, 15, 30, 0);

        final (start, end) = DataPlanCalculator.calculateCycleWindow(
          cycleStartDate: anchor,
          cycleType: 'daily',
          now: now,
        );

        expect(start, equals(DateTime(2026, 9, 5, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 9, 5, 23, 59, 59, 999)));
      });
    });

    group('calculateDaysRemaining & calculateTotalDays', () {
      test('calculates days remaining until cycle end date', () {
        final cycleEnd = DateTime(2026, 9, 14, 23, 59, 59, 999);
        final now = DateTime(2026, 9, 5, 10, 0, 0);

        final days = DataPlanCalculator.calculateDaysRemaining(cycleEnd, now);
        // Sep 5 to Sep 14 inclusive = 10 calendar days
        expect(days, equals(10));
      });

      test('returns 1 day remaining on the final cycle day', () {
        final cycleEnd = DateTime(2026, 9, 14, 23, 59, 59, 999);
        final now = DateTime(2026, 9, 14, 18, 0, 0);

        final days = DataPlanCalculator.calculateDaysRemaining(cycleEnd, now);
        expect(days, equals(1));
      });

      test('returns 0 when now has passed cycleEnd', () {
        final cycleEnd = DateTime(2026, 9, 14, 23, 59, 59, 999);
        final now = DateTime(2026, 9, 15, 0, 0, 1);

        final days = DataPlanCalculator.calculateDaysRemaining(cycleEnd, now);
        expect(days, equals(0));
      });

      test('calculates total calendar days in cycle', () {
        final cycleStart = DateTime(2026, 9, 1, 0, 0, 0);
        final cycleEnd = DateTime(2026, 9, 30, 23, 59, 59, 999);

        final total = DataPlanCalculator.calculateTotalDays(cycleStart, cycleEnd);
        expect(total, equals(30));
      });
    });

    group('calculateUsageInfo', () {
      const gigabyte = 1024 * 1024 * 1024;
      final testPlan = DataPlan(
        id: 1,
        name: 'Test 10GB Plan',
        limitBytes: 10 * gigabyte,
        cycleStartDate: DateTime(2026, 9, 1, 0, 0, 0),
        cycleType: 'monthly',
        simSlot: 0,
        warningPercent: 80,
        isActive: true,
        createdAt: DateTime(2026, 9, 1),
      );

      test('computes normal usage state below warning threshold', () {
        final now = DateTime(2026, 9, 11, 12, 0, 0); // Day 11 of 30, 20 days left
        final usedBytes = 2 * gigabyte; // 20% used

        final info = DataPlanCalculator.calculateUsageInfo(
          plan: testPlan,
          usedBytes: usedBytes,
          now: now,
        );

        expect(info.usedBytes, equals(usedBytes));
        expect(info.remainingBytes, equals(8 * gigabyte));
        expect(info.percentUsed, closeTo(20.0, 0.01));
        expect(info.isWarning, isFalse);
        expect(info.isExceeded, isFalse);
        expect(info.daysRemaining, equals(20));
        // Remaining 8 GB over 20 days = 8 * 1024 * 1024 * 1024 ~/ 20
        expect(info.recommendedDailyBytes, equals((8 * gigabyte / 20).round()));
      });

      test('computes warning state when usage reaches threshold', () {
        final now = DateTime(2026, 9, 20, 12, 0, 0);
        final usedBytes = (8.5 * gigabyte).round(); // 85% used, >= 80%

        final info = DataPlanCalculator.calculateUsageInfo(
          plan: testPlan,
          usedBytes: usedBytes,
          now: now,
        );

        expect(info.isWarning, isTrue);
        expect(info.isExceeded, isFalse);
        expect(info.percentUsed, closeTo(85.0, 0.1));
      });

      test('computes exceeded state when usage crosses 100%', () {
        final now = DateTime(2026, 9, 25, 12, 0, 0);
        final usedBytes = (10.5 * gigabyte).round(); // 105% used

        final info = DataPlanCalculator.calculateUsageInfo(
          plan: testPlan,
          usedBytes: usedBytes,
          now: now,
        );

        expect(info.isExceeded, isTrue);
        expect(info.isWarning, isFalse);
        expect(info.remainingBytes, equals(0));
        expect(info.recommendedDailyBytes, equals(0));
        expect(info.percentUsed, closeTo(105.0, 0.1));
      });
    });
  });
}
