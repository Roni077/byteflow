/// Widget tests for HistoryScreen and historical data visualizations.
library;

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/providers/database_provider.dart';
import 'package:byteflow/repositories/usage_repository.dart';
import 'package:byteflow/screens/history/history_screen.dart';

void main() {
  late AppDatabase db;
  late UsageRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = UsageRepository(db, enablePeriodicFlush: false);
  });

  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        usageRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: HistoryScreen(),
      ),
    );
  }

  group('HistoryScreen Widget Tests', () {
    testWidgets('renders app bar, filter summary bar, and filter sheet', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('Usage History'), findsOneWidget);

      // Filter button in AppBar
      final filterButton = find.byTooltip('Filter & Metrics');
      expect(filterButton, findsOneWidget);

      // Active summary bar indicators
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Empty state when no data exists
      expect(find.text('No usage data recorded'), findsOneWidget);

      // Tap filter button to open sheet
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Period chips in sheet
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('30 Days'), findsOneWidget);

      // Metric filter chips in sheet
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('switching metric in filter sheet updates active filter state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Open filter sheet
      await tester.tap(find.byTooltip('Filter & Metrics'));
      await tester.pumpAndSettle();

      final downloadChip = find.text('Download');
      check(downloadChip.evaluate().isNotEmpty).isTrue();

      await tester.tap(downloadChip);
      await tester.pumpAndSettle();

      // Close sheet
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Summary bar now reflects Download metric
      expect(find.text('Download'), findsOneWidget);
      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets('renders summary cards and data when snapshots exist', (tester) async {
      final now = DateTime.now();

      await db.usageDao.insertSnapshot(
        UsageSnapshotsCompanion.insert(
          timestamp: now.subtract(const Duration(hours: 1)),
          downloadBytes: 1024 * 1024 * 50, // 50 MB
          uploadBytes: 1024 * 1024 * 10,   // 10 MB
          wifiBytes: 1024 * 1024 * 60,
          mobileBytes: 0,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Summary stat cards should appear
      expect(find.text('Total Transfer'), findsOneWidget);
      expect(find.text('Wi-Fi Traffic'), findsOneWidget);
      expect(find.text('Mobile Traffic'), findsOneWidget);
    });
  });
}
