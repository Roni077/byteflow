/// High-level service communicating with native Shizuku IPC bridge.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/models/sim_usage.dart';

/// Service interfacing with native Shizuku plugin over MethodChannel.
class ShizukuService {
  /// Creates a [ShizukuService] instance with optional channel override.
  ShizukuService({MethodChannel? channel})
      : _channel =
            channel ?? const MethodChannel(AppConstants.shizukuMethodChannelName);

  final MethodChannel _channel;

  /// Queries the current status of the Shizuku IPC binder and permission state.
  Future<ShizukuStatus> getStatus() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        AppConstants.methodGetShizukuStatus,
      );
      if (result != null) {
        return ShizukuStatus.fromMap(result);
      }
    } on PlatformException {
      // Safe fallback on platform invocation errors
    } catch (_) {
      // Fallback
    }
    return ShizukuStatus.unavailable();
  }

  /// Initiates an interactive Shizuku authorization dialog request.
  Future<bool> requestPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>(
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
      final result = await _channel.invokeMapMethod<String, String>(
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
      // Fallback cleanly
    } catch (_) {
      // Fallback
    }
    return <int, String>{};
  }

  /// Queries cellular data consumption for a given SIM card over a time window.
  Future<SimUsage> querySimUsage({
    required int subId,
    String? subscriberId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
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
      // Fallback cleanly
    } catch (_) {
      // Fallback
    }
    return SimUsage.zero(subId: subId, subscriberId: subscriberId);
  }
}

/// Provides the singleton [ShizukuService] instance.
final shizukuServiceProvider = Provider<ShizukuService>((ref) {
  return ShizukuService();
});
