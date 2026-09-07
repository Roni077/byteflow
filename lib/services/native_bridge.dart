/// Low-level platform channel bridge between Flutter and native Android.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/models/network_speed.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/models/sim_card.dart';
import 'package:byteflow/models/sim_usage.dart';

/// Interoperability bridge connecting Dart streams to Android Kotlin plugins.
class NativeBridge {
  /// Creates a [NativeBridge] instance with optional channel overrides.
  NativeBridge({
    MethodChannel? methodChannel,
    MethodChannel? appUsageMethodChannel,
    MethodChannel? simMethodChannel,
    MethodChannel? shizukuMethodChannel,
    EventChannel? speedEventChannel,
    EventChannel? networkEventChannel,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel(AppConstants.methodChannelName),
        _appUsageMethodChannel = appUsageMethodChannel ??
            const MethodChannel(AppConstants.appUsageMethodChannelName),
        _simMethodChannel = simMethodChannel ??
            const MethodChannel(AppConstants.simMethodChannelName),
        _shizukuMethodChannel = shizukuMethodChannel ??
            const MethodChannel(AppConstants.shizukuMethodChannelName),
        _speedEventChannel = speedEventChannel ??
            const EventChannel(AppConstants.speedEventChannelName),
        _networkEventChannel = networkEventChannel ??
            const EventChannel(AppConstants.networkEventChannelName);

  final MethodChannel _methodChannel;
  final MethodChannel _appUsageMethodChannel;
  final MethodChannel _simMethodChannel;
  final MethodChannel _shizukuMethodChannel;
  final EventChannel _speedEventChannel;
  final EventChannel _networkEventChannel;

  Stream<NetworkSpeed>? _speedStream;
  Stream<NetworkInfo>? _networkInfoStream;

  /// Emits real-time speed measurements collected at 1 Hz from native TrafficStats.
  Stream<NetworkSpeed> get speedStream {
    _speedStream ??= _speedEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map<dynamic, dynamic>) {
            return NetworkSpeed.fromMap(event);
          }
          return NetworkSpeed.zero();
        })
        .asBroadcastStream();
    return _speedStream!;
  }

  /// Emits network interface changes and transport updates from ConnectivityManager.
  Stream<NetworkInfo> get networkInfoStream {
    _networkInfoStream ??= _networkEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map<dynamic, dynamic>) {
            return NetworkInfo.fromMap(event);
          }
          return NetworkInfo.disconnected();
        })
        .asBroadcastStream();
    return _networkInfoStream!;
  }

  /// Queries the current network state immediately via MethodChannel.
  Future<NetworkInfo> getNetworkInfo() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        AppConstants.methodGetNetworkInfo,
      );
      if (result != null) {
        return NetworkInfo.fromMap(result);
      }
    } on PlatformException {
      // Fallback cleanly if platform invocation fails
    }
    return NetworkInfo.disconnected();
  }

  /// Queries cumulative byte counters immediately via MethodChannel.
  Future<Map<String, int>> getTrafficStats() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        AppConstants.methodGetTrafficStats,
      );
      if (result != null) {
        return <String, int>{
          'rxTotalBytes': (result['rxTotalBytes'] as num?)?.toInt() ?? 0,
          'txTotalBytes': (result['txTotalBytes'] as num?)?.toInt() ?? 0,
          'timestamp': (result['timestamp'] as num?)?.toInt() ?? 0,
        };
      }
    } on PlatformException {
      // Fallback cleanly if platform invocation fails
    }
    return <String, int>{'rxTotalBytes': 0, 'txTotalBytes': 0, 'timestamp': 0};
  }

  /// Queries whether the user has granted PACKAGE_USAGE_STATS permission.
  Future<bool> hasUsagePermission() async {
    try {
      final granted = await _appUsageMethodChannel.invokeMethod<bool>(
        AppConstants.methodHasUsagePermission,
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system Usage Access settings screen.
  Future<void> openUsageSettings() async {
    try {
      await _appUsageMethodChannel.invokeMethod<void>(
        AppConstants.methodOpenUsageSettings,
      );
    } on PlatformException {
      // Ignored if intent cannot be launched
    }
  }

  /// Queries per-app network usage statistics between [startTime] and [endTime].
  Future<List<AppNetworkUsage>> getAppUsage(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final result = await _appUsageMethodChannel.invokeListMethod<dynamic>(
        AppConstants.methodGetAppUsage,
        <String, dynamic>{
          'startTime': startTime.millisecondsSinceEpoch,
          'endTime': endTime.millisecondsSinceEpoch,
        },
      );

      if (result == null) return <AppNetworkUsage>[];

      return result
          .whereType<Map<dynamic, dynamic>>()
          .map(AppNetworkUsage.fromMap)
          .toList();
    } on PlatformException {
      return <AppNetworkUsage>[];
    }
  }

  /// Fetches an in-memory PNG icon byte array for the specified [packageName].
  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final result = await _appUsageMethodChannel.invokeMethod<Uint8List>(
        AppConstants.methodGetAppIcon,
        <String, dynamic>{'packageName': packageName},
      );
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// Queries whether the user has granted READ_PHONE_STATE permission.
  Future<bool> hasPhonePermission() async {
    try {
      final granted = await _simMethodChannel.invokeMethod<bool>(
        AppConstants.methodHasPhonePermission,
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Queries active SIM card subscriptions from Android SubscriptionManager.
  Future<List<SimCard>> getSimCards() async {
    try {
      final result = await _simMethodChannel.invokeListMethod<dynamic>(
        AppConstants.methodGetSimCards,
      );

      if (result == null) return <SimCard>[];

      return result
          .whereType<Map<dynamic, dynamic>>()
          .map(SimCard.fromMap)
          .toList();
    } on PlatformException {
      return <SimCard>[];
    }
  }

  /// Starts the Android foreground network speed monitoring service.
  Future<bool> startForegroundService({
    bool showStatusBarSpeed = true,
    String speedDisplayMode = 'combined',
    bool startOnBoot = false,
    int pollingIntervalMs = 1000,
    bool showPersistentNotification = true,
  }) async {
    try {
      final success = await _methodChannel.invokeMethod<bool>(
        AppConstants.methodStartForegroundService,
        <String, dynamic>{
          'showStatusBarSpeed': showStatusBarSpeed,
          'speedDisplayMode': speedDisplayMode,
          'startOnBoot': startOnBoot,
          'pollingIntervalMs': pollingIntervalMs,
          'showPersistentNotification': showPersistentNotification,
        },
      );
      return success ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stops the Android foreground network speed monitoring service.
  Future<bool> stopForegroundService() async {
    try {
      final success = await _methodChannel.invokeMethod<bool>(
        AppConstants.methodStopForegroundService,
      );
      return success ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Queries whether the foreground network monitoring service is currently running.
  Future<bool> isForegroundServiceRunning() async {
    try {
      final isRunning = await _methodChannel.invokeMethod<bool>(
        AppConstants.methodIsForegroundServiceRunning,
      );
      return isRunning ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Updates foreground service settings dynamically while the service runs.
  Future<bool> updateServiceConfig({
    bool? showStatusBarSpeed,
    String? speedDisplayMode,
    bool? startOnBoot,
    int? pollingIntervalMs,
    bool? showPersistentNotification,
  }) async {
    try {
      final args = <String, dynamic>{};
      if (showStatusBarSpeed != null) {
        args['showStatusBarSpeed'] = showStatusBarSpeed;
      }
      if (speedDisplayMode != null) {
        args['speedDisplayMode'] = speedDisplayMode;
      }
      if (startOnBoot != null) {
        args['startOnBoot'] = startOnBoot;
      }
      if (pollingIntervalMs != null) {
        args['pollingIntervalMs'] = pollingIntervalMs;
      }
      if (showPersistentNotification != null) {
        args['showPersistentNotification'] = showPersistentNotification;
      }

      final success = await _methodChannel.invokeMethod<bool>(
        AppConstants.methodUpdateServiceConfig,
        args,
      );
      return success ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Sets the polling interval in milliseconds for real-time speed monitoring.
  Future<bool> setPollingInterval(int intervalMs) async {
    try {
      final success = await _methodChannel.invokeMethod<bool>(
        AppConstants.methodSetPollingInterval,
        <String, dynamic>{'pollingIntervalMs': intervalMs},
      );
      return success ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Retrieves current foreground service preferences from Android SharedPreferences.
  Future<Map<String, dynamic>> getServiceConfig() async {
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        AppConstants.methodGetServiceConfig,
      );
      return result ?? <String, dynamic>{};
    } on PlatformException {
      return <String, dynamic>{};
    }
  }

  /// Queries current status of Shizuku IPC binder and permission state.
  Future<ShizukuStatus> getShizukuStatus() async {
    try {
      final result = await _shizukuMethodChannel.invokeMethod<Map<dynamic, dynamic>>(
        AppConstants.methodGetShizukuStatus,
      );
      if (result != null) {
        return ShizukuStatus.fromMap(result);
      }
    } on PlatformException {
      // Fallback
    } catch (_) {
      // Fallback
    }
    return ShizukuStatus.unavailable();
  }

  /// Requests Shizuku authorization dialog.
  Future<bool> requestShizukuPermission() async {
    try {
      final granted = await _shizukuMethodChannel.invokeMethod<bool>(
        AppConstants.methodRequestShizukuPermission,
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Discovers active IMSI / subscriber IDs associated with SIM cards.
  Future<Map<int, String>> getSimSubscriberIds() async {
    try {
      final result = await _shizukuMethodChannel.invokeMapMethod<String, String>(
        AppConstants.methodGetSimSubscriberIds,
      );
      if (result != null) {
        final mapped = <int, String>{};
        for (final entry in result.entries) {
          final subId = int.tryParse(entry.key);
          if (subId != null && entry.value.isNotEmpty) {
            mapped[subId] = entry.value;
          }
        }
        return mapped;
      }
    } on PlatformException {
      // Fallback
    } catch (_) {
      // Fallback
    }
    return <int, String>{};
  }

  /// Queries cellular usage for a specific SIM card over a time window.
  Future<SimUsage> querySimUsage({
    required int subId,
    String? subscriberId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final result = await _shizukuMethodChannel.invokeMethod<Map<dynamic, dynamic>>(
        AppConstants.methodQuerySimUsage,
        <String, dynamic>{
          'subId': subId,
          'subscriberId': subscriberId,
          'startTime': startTime.millisecondsSinceEpoch,
          'endTime': endTime.millisecondsSinceEpoch,
        },
      );
      if (result != null) {
        return SimUsage.fromMap(result, subId: subId);
      }
    } on PlatformException {
      // Fallback
    } catch (_) {
      // Fallback
    }
    return SimUsage.zero(subId: subId, subscriberId: subscriberId);
  }
}

/// Provides the singleton [NativeBridge] instance.
final nativeBridgeProvider = Provider<NativeBridge>((ref) {
  return NativeBridge();
});

