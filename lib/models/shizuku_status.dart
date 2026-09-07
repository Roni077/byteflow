/// Data models representing Shizuku service status and the Traffic Light pattern.
library;

import 'package:flutter/foundation.dart';

/// Traffic Light status indicating the operational mode of Shizuku integration.
enum ShizukuTrafficLight {
  /// Green: Shizuku IPC is active and READ_PRIVILEGED_PHONE_STATE is granted.
  /// Enables independent per-SIM mobile usage tracking via IMSI (subscriberId).
  green,

  /// Amber: Shizuku daemon is running on device, but authorization is not yet granted.
  /// User can be prompted to grant Shizuku permission.
  amber,

  /// Red: Shizuku service is not running or not installed.
  /// App gracefully falls back to aggregate device-wide cellular tracking.
  red,
}

/// Immutable container holding Shizuku IPC daemon state and permissions.
@immutable
class ShizukuStatus {
  /// Creates an immutable [ShizukuStatus] instance.
  const ShizukuStatus({
    required this.isAvailable,
    required this.hasPermission,
    required this.version,
    required this.uid,
  });

  /// Creates a default disconnected baseline when Shizuku is not running.
  factory ShizukuStatus.unavailable() => const ShizukuStatus(
        isAvailable: false,
        hasPermission: false,
        version: -1,
        uid: -1,
      );

  /// Constructs a [ShizukuStatus] from a native platform channel map.
  factory ShizukuStatus.fromMap(Map<dynamic, dynamic> map) {
    return ShizukuStatus(
      isAvailable: map['isAvailable'] as bool? ?? false,
      hasPermission: map['hasPermission'] as bool? ?? false,
      version: (map['version'] as num?)?.toInt() ?? -1,
      uid: (map['uid'] as num?)?.toInt() ?? -1,
    );
  }

  /// Whether the Shizuku IPC binder is alive and responsive.
  final bool isAvailable;

  /// Whether the app has been granted Shizuku authorization.
  final bool hasPermission;

  /// Shizuku daemon server version code.
  final int version;

  /// Shizuku binder caller UID (typically 2000 for ADB shell or 0 for root).
  final int uid;

  /// Resolves the current Traffic Light status for UI badges and routing.
  ShizukuTrafficLight get trafficLight {
    if (!isAvailable) return ShizukuTrafficLight.red;
    if (hasPermission) return ShizukuTrafficLight.green;
    return ShizukuTrafficLight.amber;
  }

  /// Human-readable description of the current Shizuku connection state.
  String get statusMessage {
    switch (trafficLight) {
      case ShizukuTrafficLight.green:
        return 'Connected & Privileged (Multi-SIM Active)';
      case ShizukuTrafficLight.amber:
        return 'Shizuku Detected (Permission Required)';
      case ShizukuTrafficLight.red:
        return 'Shizuku Unavailable (Standard Aggregate Mode)';
    }
  }

  /// Whether privileged per-SIM queries can be performed safely.
  bool get isPrivileged => trafficLight == ShizukuTrafficLight.green;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShizukuStatus &&
          runtimeType == other.runtimeType &&
          isAvailable == other.isAvailable &&
          hasPermission == other.hasPermission &&
          version == other.version &&
          uid == other.uid;

  @override
  int get hashCode => Object.hash(isAvailable, hasPermission, version, uid);

  @override
  String toString() =>
      'ShizukuStatus(available: $isAvailable, permission: $hasPermission, ver: $version, uid: $uid, light: $trafficLight)';
}
