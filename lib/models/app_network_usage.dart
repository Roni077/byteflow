/// Per-app network usage model and filtering/sorting criteria.
library;

import 'package:flutter/foundation.dart';

/// Available sorting criteria for per-app network usage lists.
enum AppUsageSortOption {
  /// Sort descending by total data usage (download + upload).
  totalUsage('Total Usage'),

  /// Sort descending by total download usage.
  download('Download'),

  /// Sort descending by total upload usage.
  upload('Upload'),

  /// Sort alphabetically ascending by app display name.
  appName('App Name');

  const AppUsageSortOption(this.label);

  /// User-facing label for the sorting option.
  final String label;
}

/// Filter options for segmenting applications by system or user category.
enum AppUsageFilterOption {
  /// Show all applications.
  all('All Apps'),

  /// Show only user-installed applications.
  userOnly('User Apps'),

  /// Show only Android system services and core components.
  systemOnly('System Apps');

  const AppUsageFilterOption(this.label);

  /// User-facing label for the filter option.
  final String label;
}

/// Supported time ranges for querying per-application usage.
enum AppUsageTimeRange {
  /// Range covering today (00:00 to now).
  today('Today'),

  /// Range covering yesterday.
  yesterday('Yesterday'),

  /// Range covering the past 7 days.
  last7Days('7 Days'),

  /// Range covering the past 30 days.
  last30Days('30 Days'),

  /// Range covering the current calendar month.
  currentMonth('This Month');

  const AppUsageTimeRange(this.label);

  /// User-facing label for the time range chip.
  final String label;
}

/// Immutable data model representing data consumption of a single application or system UID.
@immutable
class AppNetworkUsage {
  /// Creates an immutable [AppNetworkUsage] record.
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

  /// Deserializes an [AppNetworkUsage] from a platform channel map.
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

  /// Factory for generating mock/placeholder instances during skeleton loading states.
  factory AppNetworkUsage.placeholder([int id = 0]) {
    return AppNetworkUsage(
      uid: 10000 + id,
      packageName: 'com.example.placeholder$id',
      appName: 'Application Name Preview',
      rxBytes: 157286400,
      txBytes: 52428800,
      wifiRxBytes: 104857600,
      wifiTxBytes: 31457280,
      mobileRxBytes: 52428800,
      mobileTxBytes: 20971520,
      totalBytes: 209715200,
      isSystemApp: false,
    );
  }

  /// Android Linux UID (User Identifier) of the process.
  final int uid;

  /// Android package identifier (e.g. `com.google.android.youtube`).
  final String packageName;

  /// Human-readable application label.
  final String appName;

  /// Total downloaded bytes across all network interfaces.
  final int rxBytes;

  /// Total uploaded bytes across all network interfaces.
  final int txBytes;

  /// Downloaded bytes over Wi-Fi networks.
  final int wifiRxBytes;

  /// Uploaded bytes over Wi-Fi networks.
  final int wifiTxBytes;

  /// Downloaded bytes over Mobile / Cellular networks.
  final int mobileRxBytes;

  /// Uploaded bytes over Mobile / Cellular networks.
  final int mobileTxBytes;

  /// Total bytes transferred (rxBytes + txBytes).
  final int totalBytes;

  /// Whether the package belongs to the Android system partition or is a system app.
  final bool isSystemApp;

  /// Total Wi-Fi bytes transferred (download + upload).
  int get wifiTotalBytes => wifiRxBytes + wifiTxBytes;

  /// Total Mobile bytes transferred (download + upload).
  int get mobileTotalBytes => mobileRxBytes + mobileTxBytes;

  /// Creates a copy of this instance with optional updated fields.
  AppNetworkUsage copyWith({
    int? uid,
    String? packageName,
    String? appName,
    int? rxBytes,
    int? txBytes,
    int? wifiRxBytes,
    int? wifiTxBytes,
    int? mobileRxBytes,
    int? mobileTxBytes,
    int? totalBytes,
    bool? isSystemApp,
  }) {
    return AppNetworkUsage(
      uid: uid ?? this.uid,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      rxBytes: rxBytes ?? this.rxBytes,
      txBytes: txBytes ?? this.txBytes,
      wifiRxBytes: wifiRxBytes ?? this.wifiRxBytes,
      wifiTxBytes: wifiTxBytes ?? this.wifiTxBytes,
      mobileRxBytes: mobileRxBytes ?? this.mobileRxBytes,
      mobileTxBytes: mobileTxBytes ?? this.mobileTxBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      isSystemApp: isSystemApp ?? this.isSystemApp,
    );
  }

  /// Serializes this instance to a map representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'packageName': packageName,
      'appName': appName,
      'rxBytes': rxBytes,
      'txBytes': txBytes,
      'wifiRxBytes': wifiRxBytes,
      'wifiTxBytes': wifiTxBytes,
      'mobileRxBytes': mobileRxBytes,
      'mobileTxBytes': mobileTxBytes,
      'totalBytes': totalBytes,
      'isSystemApp': isSystemApp,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNetworkUsage &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          packageName == other.packageName &&
          appName == other.appName &&
          rxBytes == other.rxBytes &&
          txBytes == other.txBytes &&
          wifiRxBytes == other.wifiRxBytes &&
          wifiTxBytes == other.wifiTxBytes &&
          mobileRxBytes == other.mobileRxBytes &&
          mobileTxBytes == other.mobileTxBytes &&
          totalBytes == other.totalBytes &&
          isSystemApp == other.isSystemApp;

  @override
  int get hashCode => Object.hash(
        uid,
        packageName,
        appName,
        rxBytes,
        txBytes,
        wifiRxBytes,
        wifiTxBytes,
        mobileRxBytes,
        mobileTxBytes,
        totalBytes,
        isSystemApp,
      );

  @override
  String toString() =>
      'AppNetworkUsage($appName [$packageName], total: $totalBytes, wifi: $wifiTotalBytes, mobile: $mobileTotalBytes)';
}
