/// Widget tests for HistoryScreen and historical data visualizations.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:byteflow/database/daos/usage_dao.dart';
import 'package:byteflow/providers/usage_history_provider.dart';
import 'package:byteflow/screens/history/history_screen.dart';

void main() {
  final sampleReport = HistoryReport(
    isHourly: false,
    averageBytes: 60 * 1024 * 1024,
    peakPoint: null,
    aggregate: const UsageAggregate(
      downloadBytes: 1024 * 1024 * 50,
      uploadBytes: 1024 * 1024 * 10,
      wifiBytes: 1024 * 1024 * 60,
      mobileBytes: 0,
    ),
    dataPoints: [
      HistoryDataPoint(
        label: '12:00',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        value: 1024 * 1024 * 60,
        downloadBytes: 1024 * 1024 * 50,
        uploadBytes: 1024 * 1024 * 10,
        wifiBytes: 1024 * 1024 * 60,
        mobileBytes: 0,
      ),
    ],
  );

  Widget buildSubject({HistoryReport? report}) {
    return ProviderScope(
      overrides: [
        historyReportProvider.overrideWith((ref) {
          ref.watch(historyFilterProvider);
          if (report != null) {
            return Stream.value(report);
          }
          return Stream.value(HistoryReport.empty());
        }),
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
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Download'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Upload'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('switching metric in filter sheet updates active filter state', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Open filter sheet
      await tester.tap(find.byTooltip('Filter & Metrics'));
      await tester.pumpAndSettle();

      final downloadChip = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Download'),
      );
      check(downloadChip.evaluate().isNotEmpty).isTrue();

      await tester.tap(downloadChip);
      await tester.pumpAndSettle();

      // Close sheet
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Summary bar now reflects Download metric
      expect(find.text('Download'), findsWidgets);
      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets('renders summary cards and data when snapshots exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSubject(report: sampleReport));
      await tester.pumpAndSettle();

      // Summary stat cards should appear
      expect(find.text('Total Transfer'), findsOneWidget);
      expect(find.text('Wi-Fi Traffic'), findsOneWidget);
      expect(find.text('Mobile Traffic'), findsOneWidget);
    });
  });
}
