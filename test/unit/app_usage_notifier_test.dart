import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/providers/app_usage_provider.dart';
import 'package:byteflow/services/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel(AppConstants.appUsageMethodChannelName);

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  final testAppList = <Map<String, dynamic>>[
    {
      'uid': 1001,
      'packageName': 'com.android.chrome',
      'appName': 'Chrome',
      'rxBytes': 2000000,
      'txBytes': 500000,
      'wifiRxBytes': 1500000,
      'wifiTxBytes': 400000,
      'mobileRxBytes': 500000,
      'mobileTxBytes': 100000,
      'totalBytes': 2500000,
      'isSystemApp': false,
    },
    {
      'uid': 1000,
      'packageName': 'android',
      'appName': 'Android System',
      'rxBytes': 1000000,
      'txBytes': 200000,
      'wifiRxBytes': 800000,
      'wifiTxBytes': 150000,
      'mobileRxBytes': 200000,
      'mobileTxBytes': 50000,
      'totalBytes': 1200000,
      'isSystemApp': true,
    },
    {
      'uid': 1002,
      'packageName': 'com.spotify.music',
      'appName': 'Spotify',
      'rxBytes': 5000000,
      'txBytes': 100000,
      'wifiRxBytes': 4000000,
      'wifiTxBytes': 80000,
      'mobileRxBytes': 1000000,
      'mobileTxBytes': 20000,
      'totalBytes': 5100000,
      'isSystemApp': false,
    },
  ];

  test('AppUsageNotifier loads usage when permission is granted', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) {
        return true;
      }
      if (call.method == AppConstants.methodGetAppUsage) {
        return testAppList;
      }
      return null;
    });

    final bridge = NativeBridge();
    final notifier = AppUsageNotifier(nativeBridge: bridge);

    // Initial load occurs in constructor
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.hasPermission, isTrue);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.apps.length, equals(3));
    expect(notifier.state.filteredApps.length, equals(3));
  });

  test('AppUsageNotifier marks hasPermission=false when denied', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) {
        return false;
      }
      return null;
    });

    final bridge = NativeBridge();
    final notifier = AppUsageNotifier(nativeBridge: bridge);

    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.hasPermission, isFalse);
    expect(notifier.state.apps, isEmpty);
  });

  test('filtering by category segments user and system apps', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) return true;
      if (call.method == AppConstants.methodGetAppUsage) return testAppList;
      return null;
    });

    final bridge = NativeBridge();
    final notifier = AppUsageNotifier(nativeBridge: bridge);
    await Future<void>.delayed(Duration.zero);

    // Default: all
    expect(notifier.state.filteredApps.length, equals(3));

    // User only
    notifier.setFilterOption(AppUsageFilterOption.userOnly);
    expect(notifier.state.filteredApps.length, equals(2));
    expect(notifier.state.filteredApps.every((a) => !a.isSystemApp), isTrue);

    // System only
    notifier.setFilterOption(AppUsageFilterOption.systemOnly);
    expect(notifier.state.filteredApps.length, equals(1));
    expect(notifier.state.filteredApps.first.packageName, equals('android'));
  });

  test('search query filters by app name and package name', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) return true;
      if (call.method == AppConstants.methodGetAppUsage) return testAppList;
      return null;
    });

    final bridge = NativeBridge();
    final notifier = AppUsageNotifier(nativeBridge: bridge);
    await Future<void>.delayed(Duration.zero);

    // Filter by name
    notifier.setSearchQuery('spot');
    expect(notifier.state.filteredApps.length, equals(1));
    expect(notifier.state.filteredApps.first.appName, equals('Spotify'));

    // Filter by package
    notifier.setSearchQuery('chrome');
    expect(notifier.state.filteredApps.length, equals(1));
    expect(notifier.state.filteredApps.first.packageName, equals('com.android.chrome'));

    // Clear search
    notifier.setSearchQuery('');
    expect(notifier.state.filteredApps.length, equals(3));
  });

  test('sorting reorders apps according to option', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == AppConstants.methodHasUsagePermission) return true;
      if (call.method == AppConstants.methodGetAppUsage) return testAppList;
      return null;
    });

    final bridge = NativeBridge();
    final notifier = AppUsageNotifier(nativeBridge: bridge);
    await Future<void>.delayed(Duration.zero);

    // Sort by Total Usage (descending): Spotify (5.1MB), Chrome (2.5MB), Android (1.2MB)
    notifier.setSortOption(AppUsageSortOption.totalUsage);
    expect(notifier.state.filteredApps.map((a) => a.appName).toList(),
        equals(['Spotify', 'Chrome', 'Android System']));

    // Sort by Upload (descending): Chrome (500K), Android (200K), Spotify (100K)
    notifier.setSortOption(AppUsageSortOption.upload);
    expect(notifier.state.filteredApps.map((a) => a.appName).toList(),
        equals(['Chrome', 'Android System', 'Spotify']));

    // Sort by Name (alphabetical): Android System, Chrome, Spotify
    notifier.setSortOption(AppUsageSortOption.appName);
    expect(notifier.state.filteredApps.map((a) => a.appName).toList(),
        equals(['Android System', 'Chrome', 'Spotify']));
  });
}
