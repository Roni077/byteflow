import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';
import 'package:byteflow/models/sim_card.dart';
import 'package:byteflow/providers/data_plans_provider.dart';
import 'package:byteflow/providers/sim_provider.dart';
import 'package:byteflow/screens/data_plans/data_plans_screen.dart';
import 'package:byteflow/screens/data_plans/widgets/data_plan_card.dart';
import 'package:byteflow/screens/data_plans/widgets/sim_status_card.dart';

void main() {
  const gigabyte = 1024 * 1024 * 1024;

  final samplePlan1 = DataPlan(
    id: 1,
    name: 'Primary 10GB',
    limitBytes: 10 * gigabyte,
    cycleStartDate: DateTime(2026, 9, 1),
    cycleType: 'monthly',
    simSlot: 0,
    warningPercent: 80,
    isActive: true,
    createdAt: DateTime(2026, 9, 1),
  );

  final samplePlan2 = DataPlan(
    id: 2,
    name: 'Backup SIM 5GB',
    limitBytes: 5 * gigabyte,
    cycleStartDate: DateTime(2026, 9, 1),
    cycleType: 'monthly',
    simSlot: 1,
    warningPercent: 80,
    isActive: true,
    createdAt: DateTime(2026, 9, 1),
  );

  final sampleUsageInfo1 = DataPlanUsageInfo(
    plan: samplePlan1,
    cycleStart: DateTime(2026, 9, 1),
    cycleEnd: DateTime(2026, 9, 30, 23, 59, 59, 999),
    daysRemaining: 15,
    totalDaysInCycle: 30,
    usedBytes: 3 * gigabyte,
    remainingBytes: 7 * gigabyte,
    percentUsed: 30.0,
    recommendedDailyBytes: (7 * gigabyte / 15).round(),
    averageDailyBytes: (3 * gigabyte / 15).round(),
    isWarning: false,
    isExceeded: false,
  );

  final sampleUsageInfoWarning = DataPlanUsageInfo(
    plan: samplePlan2,
    cycleStart: DateTime(2026, 9, 1),
    cycleEnd: DateTime(2026, 9, 30, 23, 59, 59, 999),
    daysRemaining: 5,
    totalDaysInCycle: 30,
    usedBytes: (4.2 * gigabyte).round(),
    remainingBytes: (0.8 * gigabyte).round(),
    percentUsed: 84.0,
    recommendedDailyBytes: ((0.8 * gigabyte) / 5).round(),
    averageDailyBytes: ((4.2 * gigabyte) / 25).round(),
    isWarning: true,
    isExceeded: false,
  );

  final mockSimCards = [
    const SimCard(
      subscriptionId: 1,
      simSlotIndex: 0,
      carrierName: 'Verizon',
      displayName: 'Personal',
      countryIso: 'us',
      isDefaultData: true,
    ),
    const SimCard(
      subscriptionId: 2,
      simSlotIndex: 1,
      carrierName: 'T-Mobile',
      displayName: 'Work',
      countryIso: 'us',
      isDefaultData: false,
    ),
  ];

  testWidgets('DataPlansScreen displays empty state when no plans exist',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          phonePermissionProvider.overrideWith((ref) async => true),
          simCardsProvider.overrideWith(() => _MockSimCardsNotifier([])),
          dataPlansWithUsageProvider
              .overrideWith((ref) async => <DataPlanUsageInfo>[]),
        ],
        child: const MaterialApp(
          home: DataPlansScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SimStatusCard), findsOneWidget);
    expect(find.text('No Data Plans Configured'), findsOneWidget);
    expect(find.text('Create First Plan'), findsOneWidget);
    expect(find.byType(DataPlanCard), findsNothing);
  });

  testWidgets('DataPlansScreen displays SIM cards and configured plans with metrics',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          phonePermissionProvider.overrideWith((ref) async => true),
          simCardsProvider.overrideWith(() => _MockSimCardsNotifier(mockSimCards)),
          dataPlansWithUsageProvider.overrideWith(
            (ref) async => [sampleUsageInfo1, sampleUsageInfoWarning],
          ),
        ],
        child: const MaterialApp(
          home: DataPlansScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify SIM header
    expect(find.text('Dual SIM Detected'), findsOneWidget);
    expect(find.text('Verizon'), findsOneWidget);
    expect(find.text('T-Mobile'), findsOneWidget);
    expect(find.text('Default Data'), findsOneWidget);

    // Verify Plan Cards
    expect(find.byType(DataPlanCard), findsNWidgets(2));
    expect(find.text('Primary 10GB'), findsOneWidget);
    expect(find.text('Backup SIM 5GB'), findsOneWidget);

    // Verify Warning banner appears on second card
    expect(find.textContaining('Approaching limit'), findsOneWidget);
  });

  testWidgets('Tapping Add Plan button opens dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          phonePermissionProvider.overrideWith((ref) async => true),
          simCardsProvider.overrideWith(() => _MockSimCardsNotifier(mockSimCards)),
          dataPlansWithUsageProvider
              .overrideWith((ref) async => <DataPlanUsageInfo>[]),
        ],
        child: const MaterialApp(
          home: DataPlansScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    expect(find.text('New Data Plan'), findsOneWidget);
    expect(find.text('Plan Name'), findsOneWidget);
    expect(find.text('Quota Limit'), findsOneWidget);
    expect(find.text('Create Plan'), findsOneWidget);
  });
}

class _MockSimCardsNotifier extends SimCardsNotifier {
  _MockSimCardsNotifier(this._initial);
  final List<SimCard> _initial;

  @override
  Future<List<SimCard>> build() async => _initial;
}
