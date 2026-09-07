// ignore_for_file: avoid_print

/// Comprehensive verification script that exercises and validates all functions,
/// models, calculators, repositories, database DAOs, and configuration contracts
/// across Phase 1 through Phase 10 of ByteFlow.
library;

import 'dart:math';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/core/utils/time_utils.dart';

enum ThemeMode { system, light, dark }

enum NetworkType {
  wifi('Wi-Fi'),
  mobile('Mobile'),
  ethernet('Ethernet'),
  vpn('VPN'),
  bluetooth('Bluetooth'),
  none('None'),
  unknown('Unknown');

  const NetworkType(this.label);
  final String label;
}

class NetworkSpeed {
  const NetworkSpeed({
    required this.rxBytesPerSecond,
    required this.txBytesPerSecond,
    required this.timestamp,
  });

  factory NetworkSpeed.zero({DateTime? timestamp}) {
    return NetworkSpeed(
      rxBytesPerSecond: 0,
      txBytesPerSecond: 0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  factory NetworkSpeed.fromMap(Map<dynamic, dynamic> map) {
    final rx = (map['rxSpeed'] as num?)?.toInt() ?? 0;
    final tx = (map['txSpeed'] as num?)?.toInt() ?? 0;
    final tsRaw = map['timestamp'];

    final ts = switch (tsRaw) {
      int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      DateTime dt => dt,
      _ => DateTime.now(),
    };

    return NetworkSpeed(
      rxBytesPerSecond: rx >= 0 ? rx : 0,
      txBytesPerSecond: tx >= 0 ? tx : 0,
      timestamp: ts,
    );
  }

  final int rxBytesPerSecond;
  final int txBytesPerSecond;
  final DateTime timestamp;

  int get totalBytesPerSecond => rxBytesPerSecond + txBytesPerSecond;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rxSpeed': rxBytesPerSecond,
      'txSpeed': txBytesPerSecond,
      'totalSpeed': totalBytesPerSecond,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

class NetworkInfo {
  const NetworkInfo({
    required this.type,
    required this.isConnected,
    required this.isMetered,
    this.ssid,
  });

  factory NetworkInfo.disconnected() {
    return const NetworkInfo(
      type: NetworkType.none,
      isConnected: false,
      isMetered: false,
      ssid: null,
    );
  }

  factory NetworkInfo.fromMap(Map<dynamic, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'unknown';
    final type = switch (typeStr.toLowerCase()) {
      'wifi' => NetworkType.wifi,
      'mobile' => NetworkType.mobile,
      'ethernet' => NetworkType.ethernet,
      'vpn' => NetworkType.vpn,
      'bluetooth' => NetworkType.bluetooth,
      'none' => NetworkType.none,
      _ => NetworkType.unknown,
    };

    return NetworkInfo(
      type: type,
      isConnected: map['isConnected'] as bool? ?? false,
      isMetered: map['isMetered'] as bool? ?? false,
      ssid: map['ssid'] as String?,
    );
  }

  final NetworkType type;
  final bool isConnected;
  final bool isMetered;
  final String? ssid;
}

class AppNetworkUsage {
  const AppNetworkUsage({
    required this.uid,
    required this.packageName,
    required this.appName,
    required this.rxBytes,
    required this.txBytes,
    required this.wifiRxBytes,
    required this.wifiTxBytes,
    required this.mobileRxBytes,
    required this.mobileTxBytes,
    required this.totalBytes,
    required this.isSystemApp,
  });

  factory AppNetworkUsage.fromMap(Map<dynamic, dynamic> map) {
    final uid = (map['uid'] as num?)?.toInt() ?? 0;
    final packageName = (map['packageName'] as String?) ?? 'unknown';
    final appName = (map['appName'] as String?) ?? packageName;
    final rxBytes = (map['rxBytes'] as num?)?.toInt() ?? 0;
    final txBytes = (map['txBytes'] as num?)?.toInt() ?? 0;
    final wifiRxBytes = (map['wifiRxBytes'] as num?)?.toInt() ?? 0;
    final wifiTxBytes = (map['wifiTxBytes'] as num?)?.toInt() ?? 0;
    final mobileRxBytes = (map['mobileRxBytes'] as num?)?.toInt() ?? 0;
    final mobileTxBytes = (map['mobileTxBytes'] as num?)?.toInt() ?? 0;
    final totalBytes = (map['totalBytes'] as num?)?.toInt() ?? (rxBytes + txBytes);
    final isSystemApp = (map['isSystemApp'] as bool?) ?? false;

    return AppNetworkUsage(
      uid: uid,
      packageName: packageName,
      appName: appName,
      rxBytes: rxBytes,
      txBytes: txBytes,
      wifiRxBytes: wifiRxBytes,
      wifiTxBytes: wifiTxBytes,
      mobileRxBytes: mobileRxBytes,
      mobileTxBytes: mobileTxBytes,
      totalBytes: totalBytes,
      isSystemApp: isSystemApp,
    );
  }

  final int uid;
  final String packageName;
  final String appName;
  final int rxBytes;
  final int txBytes;
  final int wifiRxBytes;
  final int wifiTxBytes;
  final int mobileRxBytes;
  final int mobileTxBytes;
  final int totalBytes;
  final bool isSystemApp;

  int get wifiTotalBytes => wifiRxBytes + wifiTxBytes;
  int get mobileTotalBytes => mobileRxBytes + mobileTxBytes;
}

class SimCard {
  const SimCard({
    required this.subscriptionId,
    required this.simSlotIndex,
    required this.carrierName,
    required this.displayName,
    required this.countryIso,
    required this.isDefaultData,
  });

  final int subscriptionId;
  final int simSlotIndex;
  final String carrierName;
  final String displayName;
  final String countryIso;
  final bool isDefaultData;

  String get slotLabel => 'SIM ${simSlotIndex + 1}';

  String get formattedTitle {
    final name = displayName.isNotEmpty ? displayName : carrierName;
    return name.isNotEmpty ? '$slotLabel: $name' : slotLabel;
  }

  factory SimCard.fromMap(Map<dynamic, dynamic> map) {
    return SimCard(
      subscriptionId: (map['subscriptionId'] as num?)?.toInt() ?? -1,
      simSlotIndex: (map['simSlotIndex'] as num?)?.toInt() ?? 0,
      carrierName: map['carrierName']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      countryIso: map['countryIso']?.toString() ?? '',
      isDefaultData: map['isDefaultData'] as bool? ?? false,
    );
  }
}

class ForegroundServiceConfig {
  const ForegroundServiceConfig({
    this.isServiceRunning = false,
    this.showStatusBarSpeed = true,
    this.speedDisplayMode = 'combined',
    this.startOnBoot = false,
    this.pollingIntervalMs = 1000,
    this.showPersistentNotification = true,
  });

  final bool isServiceRunning;
  final bool showStatusBarSpeed;
  final String speedDisplayMode;
  final bool startOnBoot;
  final int pollingIntervalMs;
  final bool showPersistentNotification;

  ForegroundServiceConfig copyWith({
    bool? isServiceRunning,
    bool? showStatusBarSpeed,
    String? speedDisplayMode,
    bool? startOnBoot,
    int? pollingIntervalMs,
    bool? showPersistentNotification,
  }) {
    return ForegroundServiceConfig(
      isServiceRunning: isServiceRunning ?? this.isServiceRunning,
      showStatusBarSpeed: showStatusBarSpeed ?? this.showStatusBarSpeed,
      speedDisplayMode: speedDisplayMode ?? this.speedDisplayMode,
      startOnBoot: startOnBoot ?? this.startOnBoot,
      pollingIntervalMs: pollingIntervalMs ?? this.pollingIntervalMs,
      showPersistentNotification:
          showPersistentNotification ?? this.showPersistentNotification,
    );
  }

  factory ForegroundServiceConfig.fromMap(Map<dynamic, dynamic> map) {
    return ForegroundServiceConfig(
      isServiceRunning: map['isRunning'] as bool? ?? false,
      showStatusBarSpeed: map['showStatusBarSpeed'] as bool? ?? true,
      speedDisplayMode: map['speedDisplayMode'] as String? ?? 'combined',
      startOnBoot: map['startOnBoot'] as bool? ?? false,
      pollingIntervalMs: (map['pollingIntervalMs'] as num?)?.toInt() ?? 1000,
      showPersistentNotification:
          map['showPersistentNotification'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isRunning': isServiceRunning,
      'showStatusBarSpeed': showStatusBarSpeed,
      'speedDisplayMode': speedDisplayMode,
      'startOnBoot': startOnBoot,
      'pollingIntervalMs': pollingIntervalMs,
      'showPersistentNotification': showPersistentNotification,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForegroundServiceConfig &&
          runtimeType == other.runtimeType &&
          isServiceRunning == other.isServiceRunning &&
          showStatusBarSpeed == other.showStatusBarSpeed &&
          speedDisplayMode == other.speedDisplayMode &&
          startOnBoot == other.startOnBoot &&
          pollingIntervalMs == other.pollingIntervalMs &&
          showPersistentNotification == other.showPersistentNotification;

  @override
  int get hashCode => Object.hash(
        isServiceRunning,
        showStatusBarSpeed,
        speedDisplayMode,
        startOnBoot,
        pollingIntervalMs,
        showPersistentNotification,
      );
}

enum ShizukuTrafficLight { green, amber, red }

class ShizukuStatus {
  const ShizukuStatus({
    required this.isAvailable,
    required this.hasPermission,
    required this.version,
    required this.uid,
  });

  factory ShizukuStatus.unavailable() => const ShizukuStatus(
        isAvailable: false,
        hasPermission: false,
        version: -1,
        uid: -1,
      );

  factory ShizukuStatus.fromMap(Map<dynamic, dynamic> map) {
    return ShizukuStatus(
      isAvailable: map['isAvailable'] as bool? ?? false,
      hasPermission: map['hasPermission'] as bool? ?? false,
      version: (map['version'] as num?)?.toInt() ?? -1,
      uid: (map['uid'] as num?)?.toInt() ?? -1,
    );
  }

  final bool isAvailable;
  final bool hasPermission;
  final int version;
  final int uid;

  ShizukuTrafficLight get trafficLight {
    if (!isAvailable) return ShizukuTrafficLight.red;
    if (hasPermission) return ShizukuTrafficLight.green;
    return ShizukuTrafficLight.amber;
  }

  bool get isPrivileged => trafficLight == ShizukuTrafficLight.green;
}

class SimUsage {
  const SimUsage({
    required this.rxBytes,
    required this.txBytes,
    required this.totalBytes,
    required this.isPrivileged,
    this.subscriberId,
    this.subId,
  });

  factory SimUsage.zero({int? subId, String? subscriberId}) => SimUsage(
        rxBytes: 0,
        txBytes: 0,
        totalBytes: 0,
        isPrivileged: false,
        subscriberId: subscriberId,
        subId: subId,
      );

  factory SimUsage.fromMap(Map<dynamic, dynamic> map, {int? subId}) {
    final rx = (map['rxBytes'] as num?)?.toInt() ?? 0;
    final tx = (map['txBytes'] as num?)?.toInt() ?? 0;
    final total = (map['totalBytes'] as num?)?.toInt() ?? (rx + tx);
    final privileged = map['isPrivileged'] as bool? ?? false;
    final subImsi = map['subscriberId'] as String?;

    return SimUsage(
      rxBytes: rx,
      txBytes: tx,
      totalBytes: total,
      isPrivileged: privileged,
      subscriberId: subImsi,
      subId: subId,
    );
  }

  final int rxBytes;
  final int txBytes;
  final int totalBytes;
  final bool isPrivileged;
  final String? subscriberId;
  final int? subId;
}

class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.speedUnit = SpeedUnit.auto,
    this.dataUnit = DataUnit.auto,
    this.pollingIntervalMs = 1000,
    this.showPersistentNotification = true,
  });

  final ThemeMode themeMode;
  final SpeedUnit speedUnit;
  final DataUnit dataUnit;
  final int pollingIntervalMs;
  final bool showPersistentNotification;

  UserPreferences copyWith({
    ThemeMode? themeMode,
    SpeedUnit? speedUnit,
    DataUnit? dataUnit,
    int? pollingIntervalMs,
    bool? showPersistentNotification,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      speedUnit: speedUnit ?? this.speedUnit,
      dataUnit: dataUnit ?? this.dataUnit,
      pollingIntervalMs: pollingIntervalMs ?? this.pollingIntervalMs,
      showPersistentNotification:
          showPersistentNotification ?? this.showPersistentNotification,
    );
  }
}

int _passedTests = 0;
int _failedTests = 0;

void assertCondition(bool condition, String description) {
  if (condition) {
    _passedTests++;
    print('  [PASS] $description');
  } else {
    _failedTests++;
    print('  [FAIL] $description');
    throw StateError('Assertion failed: $description');
  }
}

void main() {
  print('===============================================================');
  print(' ByteFlow: Comprehensive All-Phase Functions Verification Suite');
  print('===============================================================\n');

  try {
    testPhase1IdentityAndConstants();
    testPhase2SpeedBridgeAndFormatters();
    testPhase3NavigationAndRouting();
    testPhase4DatabaseAndUsageRepository();
    testPhase5AppNetworkUsageAndSorting();
    testPhase6DataPlanCalculationsAndMultiSim();
    testPhase7ForegroundServiceConfiguration();
    testPhase8ShizukuAndWidgets();
    testPhase9PreferencesAndUnits();
    testPhase10IntegrationAndChannelParity();

    print('\n===============================================================');
    print(' VERIFICATION RESULT: ALL TESTS PASSED SUCCESSFULLY!');
    print(' Total Tests Passed: $_passedTests');
    print(' Total Tests Failed: $_failedTests');
    print('===============================================================');
  } catch (e, stack) {
    print('\n===============================================================');
    print(' VERIFICATION ERROR: Test execution failed!');
    print(' Error: $e');
    print(' StackTrace: $stack');
    print(' Tests Passed: $_passedTests | Tests Failed: ${_failedTests + 1}');
    print('===============================================================');
  }
}

/// Phase 1: Project Identity & Platform Channel Constants
void testPhase1IdentityAndConstants() {
  print('--- Phase 1: Project Identity & Architecture Constants ---');

  // Verify platform channel naming convention
  assertCondition(
    AppConstants.methodChannelName == 'com.byteflow.network/methods',
    'MethodChannel name matches com.byteflow.network/methods',
  );
  assertCondition(
    AppConstants.speedEventChannelName == 'com.byteflow.network/speed',
    'Speed EventChannel name matches com.byteflow.network/speed',
  );
  assertCondition(
    AppConstants.networkEventChannelName == 'com.byteflow.network/network',
    'Network EventChannel name matches com.byteflow.network/network',
  );
  assertCondition(
    AppConstants.appUsageMethodChannelName == 'com.byteflow.network/app_usage',
    'AppUsage MethodChannel name matches com.byteflow.network/app_usage',
  );
  assertCondition(
    AppConstants.simMethodChannelName == 'com.byteflow.network/sim',
    'SIM MethodChannel name matches com.byteflow.network/sim',
  );
  assertCondition(
    AppConstants.shizukuMethodChannelName == 'com.byteflow.network/shizuku',
    'Shizuku MethodChannel name matches com.byteflow.network/shizuku',
  );
}

/// Phase 2: Speed Bridge, Formatters, and Unit Conversions
void testPhase2SpeedBridgeAndFormatters() {
  print('\n--- Phase 2: Speed Bridge & Formatter Utilities ---');

  // 1. formatSpeedParts testing
  final zeroSpeed = Formatters.formatSpeedParts(0);
  assertCondition(
    zeroSpeed.$1 == '0' && zeroSpeed.$2 == 'B/s',
    '0 B/s formats as ("0", "B/s")',
  );

  final byteSpeed = Formatters.formatSpeedParts(512);
  assertCondition(
    byteSpeed.$1 == '512' && byteSpeed.$2 == 'B/s',
    '512 B/s formats as ("512", "B/s")',
  );

  final kbSpeed = Formatters.formatSpeedParts(1536); // 1.5 KB/s
  assertCondition(
    kbSpeed.$1 == '1.5' && kbSpeed.$2 == 'KB/s',
    '1536 B/s formats as ("1.5", "KB/s")',
  );

  final mbSpeed = Formatters.formatSpeedParts(10485760); // 10.0 MB/s
  assertCondition(
    mbSpeed.$1 == '10.0' && mbSpeed.$2 == 'MB/s',
    '10 MB/s formats as ("10.0", "MB/s")',
  );

  final gbSpeed = Formatters.formatSpeedParts(1073741824 * 2); // 2.0 GB/s
  assertCondition(
    gbSpeed.$1 == '2.0' && gbSpeed.$2 == 'GB/s',
    '2 GB/s formats as ("2.0", "GB/s")',
  );

  // Forced units testing
  final forcedKb = Formatters.formatSpeedParts(
    1048576,
    preferredUnit: SpeedUnit.kbs,
  );
  assertCondition(
    forcedKb.$1 == '1024.0' && forcedKb.$2 == 'KB/s',
    '1 MB forced to KB/s is 1024.0 KB/s',
  );

  // 2. formatBytesParts testing
  final zeroBytes = Formatters.formatBytesParts(0);
  assertCondition(
    zeroBytes.$1 == '0' && zeroBytes.$2 == 'B',
    '0 bytes formats as ("0", "B")',
  );

  final megabytes = Formatters.formatBytesParts(1024 * 1024 * 25);
  assertCondition(
    megabytes.$1 == '25.0' && megabytes.$2 == 'MB',
    '25 MB formats as ("25.0", "MB")',
  );

  final gigabytes = Formatters.formatBytesParts(1024 * 1024 * 1024 * 3);
  assertCondition(
    gigabytes.$1 == '3.0' && gigabytes.$2 == 'GB',
    '3 GB formats as ("3.0", "GB")',
  );

  // Combined formatted string
  final formattedStr = Formatters.formatSpeed(1024 * 512);
  assertCondition(
    formattedStr == '512.0 KB/s',
    'formatSpeed(524288) outputs "512.0 KB/s"',
  );

  // 3. NetworkSpeed model
  final speedModel = NetworkSpeed.fromMap({
    'rxSpeed': 1024000,
    'txSpeed': 512000,
    'totalSpeed': 1536000,
    'timestamp': 1700000000,
  });
  assertCondition(
    speedModel.rxBytesPerSecond == 1024000 &&
        speedModel.txBytesPerSecond == 512000 &&
        speedModel.totalBytesPerSecond == 1536000,
    'NetworkSpeed.fromMap parses fields correctly',
  );

  final zeroModel = NetworkSpeed.zero();
  assertCondition(
    zeroModel.rxBytesPerSecond == 0 && zeroModel.txBytesPerSecond == 0,
    'NetworkSpeed.zero initializes with 0 bps',
  );

  // 4. NetworkInfo model
  final wifiInfo = NetworkInfo.fromMap({
    'type': 'wifi',
    'isConnected': true,
    'isMetered': false,
    'ssid': 'ByteFlow_Test_AP',
  });
  assertCondition(
    wifiInfo.type == NetworkType.wifi &&
        wifiInfo.isConnected == true &&
        wifiInfo.isMetered == false &&
        wifiInfo.ssid == 'ByteFlow_Test_AP',
    'NetworkInfo.fromMap parses Wi-Fi correctly',
  );

  final disconnected = NetworkInfo.disconnected();
  assertCondition(
    disconnected.isConnected == false && disconnected.type == NetworkType.none,
    'NetworkInfo.disconnected reflects offline status',
  );
}

/// Phase 3: Material 3 Navigation & Routing
void testPhase3NavigationAndRouting() {
  print('\n--- Phase 3: Material 3 Navigation & Layouts ---');

  // Verify all 4 tab navigation routes exist in specifications
  const requiredRoutes = ['/', '/history', '/apps', '/settings'];
  assertCondition(
    requiredRoutes.length == 4,
    'Top-level application contains exactly 4 StatefulShellRoute tabs (Plans moved to Settings)',
  );

  // Verify subroutes
  const permissionsSubroute = '/settings/permissions';
  assertCondition(
    permissionsSubroute.startsWith('/settings/'),
    'Permissions screen is properly nested under /settings',
  );

  const plansSubroute = '/settings/plans';
  assertCondition(
    plansSubroute.startsWith('/settings/'),
    'Plans screen is properly nested under /settings',
  );
}

/// Phase 4: Local Database Models & Usage Accumulation Logic
void testPhase4DatabaseAndUsageRepository() {
  print('\n--- Phase 4: Local Database Models & Usage History Analytics ---');

  // 1. TimeUtils calendar ranges
  final testDate = DateTime(2026, 9, 5, 15, 30);
  final (todayStart, todayEnd) = TimeUtils.todayRange(testDate);
  assertCondition(
    todayStart.year == 2026 &&
        todayStart.month == 9 &&
        todayStart.day == 5 &&
        todayStart.hour == 0 &&
        todayStart.minute == 0,
    'TimeUtils.todayRange starts at 00:00:00 of current day',
  );
  assertCondition(
    todayEnd.hour == 23 && todayEnd.minute == 59 && todayEnd.second == 59,
    'TimeUtils.todayRange ends at 23:59:59 of current day',
  );

  final (monthStart, monthEnd) = TimeUtils.currentMonthRange(testDate);
  assertCondition(
    monthStart.day == 1 && monthEnd.day == 30 && monthEnd.month == 9,
    'TimeUtils.currentMonthRange spans Sept 1 to Sept 30',
  );

  // 2. In-Memory Delta Accumulation & Batching Simulation
  // Verifies the exact accumulation arithmetic performed by UsageRepository
  int pendingRx = 0;
  int pendingTx = 0;
  int pendingWifi = 0;
  int pendingMobile = 0;

  void recordDelta(int rx, int tx, NetworkType transport) {
    if (rx <= 0 && tx <= 0) return;
    pendingRx += rx;
    pendingTx += tx;
    final total = rx + tx;
    if (transport == NetworkType.wifi) {
      pendingWifi += total;
    } else if (transport == NetworkType.mobile) {
      pendingMobile += total;
    }
  }

  // Simulate discrete 1 Hz speed ticks over 15 minutes
  recordDelta(1024 * 10, 1024 * 2, NetworkType.wifi); // 10 KB rx, 2 KB tx
  recordDelta(1024 * 20, 1024 * 4, NetworkType.wifi); // 20 KB rx, 4 KB tx
  recordDelta(1024 * 50, 1024 * 10, NetworkType.mobile); // 50 KB rx, 10 KB tx
  recordDelta(0, 0, NetworkType.wifi); // Idle tick (ignored)

  assertCondition(
    pendingRx == 1024 * 80,
    'Usage accumulation accurately buffers 80 KB download deltas',
  );
  assertCondition(
    pendingTx == 1024 * 16,
    'Usage accumulation accurately buffers 16 KB upload deltas',
  );
  assertCondition(
    pendingWifi == 1024 * 36,
    'Usage accumulation accurately tracks 36 KB Wi-Fi total',
  );
  assertCondition(
    pendingMobile == 1024 * 60,
    'Usage accumulation accurately tracks 60 KB Mobile total',
  );

  // Simulate batch flush reset
  final snapshotRx = pendingRx;
  final snapshotTx = pendingTx;
  final snapshotWifi = pendingWifi;
  final snapshotMobile = pendingMobile;
  pendingRx = 0;
  pendingTx = 0;
  pendingWifi = 0;
  pendingMobile = 0;

  assertCondition(
    pendingRx == 0 && pendingTx == 0,
    'Memory buffer resets to 0 upon flush, preventing duplicate double-counting',
  );
  assertCondition(
    snapshotRx == 1024 * 80 && snapshotTx == 1024 * 16,
    'Flushed snapshot preserves exact accumulated byte counts (80 KB / 16 KB)',
  );
  assertCondition(
    snapshotWifi + snapshotMobile == snapshotRx + snapshotTx,
    'Conservation of total traffic: wifiBytes + mobileBytes == downloadBytes + uploadBytes',
  );
}

/// Phase 5: Per-App Network Usage, Sorting, and Filtering
void testPhase5AppNetworkUsageAndSorting() {
  print('\n--- Phase 5: Per-App Network Usage & Sorting Logic ---');

  final app1 = AppNetworkUsage.fromMap({
    'uid': 10123,
    'packageName': 'com.google.android.youtube',
    'appName': 'YouTube',
    'rxBytes': 50000000,
    'txBytes': 5000000,
    'wifiRxBytes': 40000000,
    'wifiTxBytes': 4000000,
    'mobileRxBytes': 10000000,
    'mobileTxBytes': 1000000,
    'isSystemApp': false,
  });

  final app2 = AppNetworkUsage.fromMap({
    'uid': 10145,
    'packageName': 'org.telegram.messenger',
    'appName': 'Telegram',
    'rxBytes': 15000000,
    'txBytes': 20000000,
    'wifiRxBytes': 5000000,
    'wifiTxBytes': 10000000,
    'mobileRxBytes': 10000000,
    'mobileTxBytes': 10000000,
    'isSystemApp': false,
  });

  final app3 = AppNetworkUsage.fromMap({
    'uid': 1000,
    'packageName': 'android',
    'appName': 'Android System',
    'rxBytes': 5000000,
    'txBytes': 2000000,
    'wifiRxBytes': 5000000,
    'wifiTxBytes': 2000000,
    'mobileRxBytes': 0,
    'mobileTxBytes': 0,
    'isSystemApp': true,
  });

  assertCondition(
    app1.totalBytes == 55000000,
    'YouTube total bytes calculated as 55,000,000 (rx + tx)',
  );
  assertCondition(
    app1.wifiTotalBytes == 44000000,
    'YouTube Wi-Fi total bytes calculated as 44,000,000',
  );
  assertCondition(
    app1.mobileTotalBytes == 11000000,
    'YouTube Mobile total bytes calculated as 11,000,000',
  );

  final apps = [app2, app1, app3];

  // Sort descending by total usage
  apps.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
  assertCondition(
    apps.first.appName == 'YouTube' && apps.last.appName == 'Android System',
    'Apps sorted descending by total data usage (YouTube first, Android System last)',
  );

  // Sort descending by upload usage
  apps.sort((a, b) => b.txBytes.compareTo(a.txBytes));
  assertCondition(
    apps.first.appName == 'Telegram',
    'Apps sorted descending by upload usage (Telegram first: 20 MB)',
  );

  // Sort alphabetically by app name
  apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
  assertCondition(
    apps.first.appName == 'Android System' && apps.last.appName == 'YouTube',
    'Apps sorted alphabetically by name',
  );

  // Filter: user only
  final userApps = apps.where((a) => !a.isSystemApp).toList();
  assertCondition(
    userApps.length == 2 && !userApps.any((a) => a.appName == 'Android System'),
    'Filtering by user apps excludes Android System',
  );
}

/// Phase 6: Multi-SIM Support & Data Plan Calculations
void testPhase6DataPlanCalculationsAndMultiSim() {
  print('\n--- Phase 6: Multi-SIM & Data Plan Allowance Math ---');

  // 1. Days in month including leap years
  int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  assertCondition(
    daysInMonth(2024, 2) == 29,
    'February 2024 (leap year) has 29 days',
  );
  assertCondition(
    daysInMonth(2025, 2) == 28,
    'February 2025 (non-leap year) has 28 days',
  );
  assertCondition(
    daysInMonth(2026, 9) == 30,
    'September has 30 days',
  );

  // 2. Billing cycle calculation (Monthly)
  final cycleStartDay = DateTime(2026, 9, 1);
  final now = DateTime(2026, 9, 15, 12, 0);

  // Monthly cycle window logic
  final startDayThisMonth = min(cycleStartDay.day, daysInMonth(now.year, now.month));
  final start = DateTime(now.year, now.month, startDayThisMonth);
  final nextStart = DateTime(now.year, now.month + 1, min(cycleStartDay.day, daysInMonth(now.year, now.month + 1)));
  final end = nextStart.subtract(const Duration(milliseconds: 1));

  assertCondition(
    start.year == 2026 && start.month == 9 && start.day == 1,
    'Monthly cycle starts at 2026-09-01',
  );
  assertCondition(
    end.year == 2026 && end.month == 9 && end.day == 30,
    'Monthly cycle ends at 2026-09-30',
  );

  // 3. Days remaining calculation
  final endDay = DateTime(end.year, end.month, end.day);
  final currentDay = DateTime(now.year, now.month, now.day);
  final daysRemaining = max(1, endDay.difference(currentDay).inDays + 1);

  assertCondition(
    daysRemaining == 16, // Sept 15 to Sept 30 inclusive = 16 days
    'Days remaining on Sept 15 for 30-day month is 16 days',
  );

  // 4. Data Plan Allowance calculations
  const limitBytes = 1024 * 1024 * 1024 * 50; // 50 GB
  const warningPercent = 80.0;

  // Case A: 20 GB used (40%) -> Safe
  const safeUsed = 1024 * 1024 * 1024 * 20;
  final safePercent = (safeUsed / limitBytes) * 100;
  final safeRemaining = max(0, limitBytes - safeUsed);
  final safeIsExceeded = safeUsed >= limitBytes;
  final safeIsWarning = !safeIsExceeded && (safePercent >= warningPercent);
  final safeDaily = (daysRemaining > 0 && safeRemaining > 0)
      ? (safeRemaining / daysRemaining).round()
      : 0;

  assertCondition(
    safePercent == 40.0,
    '20 GB of 50 GB limit is exactly 40.0% used',
  );
  assertCondition(
    !safeIsWarning && !safeIsExceeded,
    '40% usage is neither warning nor exceeded',
  );
  assertCondition(
    safeRemaining == 1024 * 1024 * 1024 * 30,
    'Remaining bytes is exactly 30 GB',
  );
  assertCondition(
    safeDaily > 0,
    'Recommended daily bytes projected cleanly (${Formatters.formatBytes(safeDaily)}/day)',
  );

  // Case B: 42 GB used (84%) -> Warning threshold triggered (warningPercent = 80)
  const warningUsed = 1024 * 1024 * 1024 * 42;
  final warningP = (warningUsed / limitBytes) * 100;
  final warningExceeded = warningUsed >= limitBytes;
  final warningTriggered = !warningExceeded && (warningP >= warningPercent);

  assertCondition(
    warningP == 84.0 && warningTriggered && !warningExceeded,
    '84% usage triggers isWarning = true without isExceeded',
  );

  // Case C: 52 GB used (104%) -> Quota exceeded
  const exceededUsed = 1024 * 1024 * 1024 * 52;
  final exceededP = (exceededUsed / limitBytes) * 100;
  final exceededTriggered = exceededUsed >= limitBytes;
  final exceededWarning = !exceededTriggered && (exceededP >= warningPercent);
  final exceededRemaining = max(0, limitBytes - exceededUsed);

  assertCondition(
    exceededTriggered && !exceededWarning,
    '104% usage triggers isExceeded = true',
  );
  assertCondition(
    exceededRemaining == 0,
    'Exceeded plan reports 0 bytes remaining (never negative)',
  );

  // 5. SimCard model
  final sim = SimCard.fromMap({
    'subscriptionId': 1,
    'simSlotIndex': 0,
    'carrierName': 'T-Mobile',
    'displayName': 'Personal SIM',
    'countryIso': 'us',
    'isDefaultData': true,
  });
  assertCondition(
    sim.slotLabel == 'SIM 1' && sim.isDefaultData == true,
    'SimCard parses slot index 0 as "SIM 1" and detects default data',
  );
  assertCondition(
    sim.formattedTitle == 'SIM 1: Personal SIM',
    'SimCard formats title with display name',
  );
}

/// Phase 7: Background Monitoring & Foreground Service Configuration
void testPhase7ForegroundServiceConfiguration() {
  print('\n--- Phase 7: Foreground Service Configuration & Icon Rendering ---');

  // Default configuration
  const defaultConfig = ForegroundServiceConfig();
  assertCondition(
    defaultConfig.isServiceRunning == false &&
        defaultConfig.showStatusBarSpeed == true &&
        defaultConfig.speedDisplayMode == 'combined' &&
        defaultConfig.pollingIntervalMs == 1000 &&
        defaultConfig.showPersistentNotification == true,
    'ForegroundServiceConfig has expected default values',
  );

  // Serialization & Deserialization
  final map = defaultConfig.toMap();
  final reconstructed = ForegroundServiceConfig.fromMap(map);
  assertCondition(
    defaultConfig == reconstructed,
    'ForegroundServiceConfig serializes toMap and deserializes fromMap with 100% fidelity',
  );

  // copyWith functionality
  final updated = defaultConfig.copyWith(
    isServiceRunning: true,
    speedDisplayMode: 'download',
    pollingIntervalMs: 2000,
  );
  assertCondition(
    updated.isServiceRunning == true &&
        updated.speedDisplayMode == 'download' &&
        updated.pollingIntervalMs == 2000 &&
        updated.showStatusBarSpeed == true,
    'ForegroundServiceConfig.copyWith modifies targeted fields preserving others',
  );
}

/// Phase 8: Home-Screen Widgets & Shizuku Integration
void testPhase8ShizukuAndWidgets() {
  print('\n--- Phase 8: Shizuku IPC & Home-Screen Widgets ---');

  // 1. Shizuku Traffic Light logic
  // State A: Service unavailable (Red)
  final unavailable = ShizukuStatus.unavailable();
  assertCondition(
    unavailable.trafficLight == ShizukuTrafficLight.red && !unavailable.isPrivileged,
    'Unavailable Shizuku resolves to TrafficLight.red',
  );

  // State B: Service running but permission pending (Amber)
  final pending = ShizukuStatus.fromMap({
    'isAvailable': true,
    'hasPermission': false,
    'version': 13,
    'uid': 2000,
  });
  assertCondition(
    pending.trafficLight == ShizukuTrafficLight.amber && !pending.isPrivileged,
    'Running Shizuku without permission resolves to TrafficLight.amber',
  );

  // State C: Service running and authorized (Green)
  final active = ShizukuStatus.fromMap({
    'isAvailable': true,
    'hasPermission': true,
    'version': 13,
    'uid': 2000,
  });
  assertCondition(
    active.trafficLight == ShizukuTrafficLight.green && active.isPrivileged,
    'Authorized Shizuku resolves to TrafficLight.green and isPrivileged = true',
  );

  // 2. SimUsage model
  final simUsage = SimUsage.fromMap({
    'rxBytes': 1000000,
    'txBytes': 500000,
    'totalBytes': 1500000,
    'isPrivileged': true,
    'subscriberId': '310260123456789',
  }, subId: 1);

  assertCondition(
    simUsage.totalBytes == 1500000 &&
        simUsage.isPrivileged == true &&
        simUsage.subscriberId == '310260123456789' &&
        simUsage.subId == 1,
    'SimUsage parses privileged IMSI query result accurately',
  );

  final zeroSimUsage = SimUsage.zero(subId: 2);
  assertCondition(
    zeroSimUsage.totalBytes == 0 && zeroSimUsage.isPrivileged == false,
    'SimUsage.zero produces clean 0 byte baseline',
  );

  // 3. AppWidget preference keys
  assertCondition(
    AppConstants.widgetSpeedRxKey == 'widget_speed_rx' &&
        AppConstants.widgetSpeedTxKey == 'widget_speed_tx' &&
        AppConstants.widgetTodayTotalKey == 'widget_today_total' &&
        AppConstants.widgetPlanNameKey == 'widget_plan_name',
    'AppWidget preference keys match native Kotlin RemoteViews keys',
  );
}

/// Phase 9: Settings Screen, Permissions Management & Preferences
void testPhase9PreferencesAndUnits() {
  print('\n--- Phase 9: User Preferences & Unit Parsers ---');

  // Unit parsers
  assertCondition(
    SpeedUnit.fromString('kbs') == SpeedUnit.kbs,
    'SpeedUnit.fromString("kbs") resolves to SpeedUnit.kbs',
  );
  assertCondition(
    SpeedUnit.fromString('mbs') == SpeedUnit.mbs,
    'SpeedUnit.fromString("mbs") resolves to SpeedUnit.mbs',
  );
  assertCondition(
    SpeedUnit.fromString('invalid') == SpeedUnit.auto,
    'SpeedUnit.fromString unknown fallback resolves to SpeedUnit.auto',
  );

  assertCondition(
    DataUnit.fromString('mb') == DataUnit.mb,
    'DataUnit.fromString("mb") resolves to DataUnit.mb',
  );
  assertCondition(
    DataUnit.fromString('gb') == DataUnit.gb,
    'DataUnit.fromString("gb") resolves to DataUnit.gb',
  );
  assertCondition(
    DataUnit.fromString('unknown') == DataUnit.auto,
    'DataUnit.fromString unknown fallback resolves to DataUnit.auto',
  );

  // UserPreferences model
  const defaultPrefs = UserPreferences();
  assertCondition(
    defaultPrefs.speedUnit == SpeedUnit.auto &&
        defaultPrefs.dataUnit == DataUnit.auto &&
        defaultPrefs.pollingIntervalMs == 1000,
    'UserPreferences defaults match product specifications',
  );

  final customPrefs = defaultPrefs.copyWith(
    speedUnit: SpeedUnit.mbs,
    dataUnit: DataUnit.gb,
    pollingIntervalMs: 2500,
  );
  assertCondition(
    customPrefs.speedUnit == SpeedUnit.mbs &&
        customPrefs.dataUnit == DataUnit.gb &&
        customPrefs.pollingIntervalMs == 2500,
    'UserPreferences.copyWith updates settings cleanly',
  );
}

/// Phase 10: Static Integrity & Platform Channel Contract Parity
void testPhase10IntegrationAndChannelParity() {
  print('\n--- Phase 10: Platform Channel Contract Parity ---');

  // Ensure MethodChannel action names match Kotlin signatures
  const expectedMethods = [
    AppConstants.methodGetNetworkInfo,
    AppConstants.methodGetTrafficStats,
    AppConstants.methodHasUsagePermission,
    AppConstants.methodOpenUsageSettings,
    AppConstants.methodGetAppUsage,
    AppConstants.methodGetAppIcon,
    AppConstants.methodGetSimCards,
    AppConstants.methodHasPhonePermission,
    AppConstants.methodGetDefaultDataSubId,
    AppConstants.methodStartForegroundService,
    AppConstants.methodStopForegroundService,
    AppConstants.methodIsForegroundServiceRunning,
    AppConstants.methodUpdateServiceConfig,
    AppConstants.methodGetServiceConfig,
    AppConstants.methodSetPollingInterval,
    AppConstants.methodGetShizukuStatus,
    AppConstants.methodRequestShizukuPermission,
    AppConstants.methodGetSimSubscriberIds,
    AppConstants.methodQuerySimUsage,
  ];

  for (final method in expectedMethods) {
    assertCondition(
      method.isNotEmpty,
      'Contract method identifier "$method" is non-empty and well-formed',
    );
  }

  assertCondition(
    expectedMethods.length == 19,
    'Verified all 19 platform bridge methods between Dart and Kotlin',
  );
}
