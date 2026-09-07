import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/screens/apps/apps_screen.dart';
import 'package:byteflow/screens/apps/widgets/app_usage_tile.dart';
import 'package:byteflow/screens/apps/widgets/permission_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel(AppConstants.appUsageMethodChannelName);

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  final mockApps = <Map<String, dynamic>>[
    {
      'uid': 1001,
      'packageName': 'com.android.chrome',
      'appName': 'Google Chrome',
      'rxBytes': 4000000,
      'txBytes': 1000000,
      'wifiRxBytes': 3000000,
      'wifiTxBytes': 800000,
      'mobileRxBytes': 1000000,
      'mobileTxBytes': 200000,
      'totalBytes': 5000000,
      'isSystemApp': false,
    },
    {
      'uid': 1002,
      'packageName': 'com.spotify.music',
      'appName': 'Spotify',
      'rxBytes': 2000000,
      'txBytes': 500000,
      'wifiRxBytes': 1500000,
      'wifiTxBytes': 400000,
      'mobileRxBytes': 500000,
      'mobileTxBytes': 100000,
      'totalBytes': 2500000,
      'isSystemApp': false,
    },
  ];

  testWidgets('AppsScreen displays PermissionCard when permission is missing',
      (WidgetTester tester) async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) {
        return false;
      }
      return null;
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PermissionCard), findsOneWidget);
    expect(find.text('Usage Access Required'), findsOneWidget);
    expect(find.text('Open Usage Access Settings'), findsOneWidget);
    expect(find.byType(AppUsageTile), findsNothing);
  });

  testWidgets('AppsScreen displays app list and filters with search',
      (WidgetTester tester) async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) {
        return true;
      }
      if (call.method == AppConstants.methodGetAppUsage) {
        return mockApps;
      }
      return null;
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify permission card is hidden and list is shown
    expect(find.byType(PermissionCard), findsNothing);
    expect(find.text('Google Chrome'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.byType(AppUsageTile), findsNWidgets(2));

    // Test Search Functionality
    final searchFinder = find.byType(TextField);
    expect(searchFinder, findsOneWidget);

    await tester.enterText(searchFinder, 'Spotify');
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Google Chrome'), findsNothing);
    expect(find.byType(AppUsageTile), findsOneWidget);

    // Clear search
    await tester.enterText(searchFinder, '');
    await tester.pumpAndSettle();

    expect(find.text('Google Chrome'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.byType(AppUsageTile), findsNWidgets(2));
  });
}
