/// Riverpod state management for Android system permissions and Shizuku status.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/providers/shizuku_provider.dart';
import 'package:byteflow/services/native_bridge.dart';

/// Immutable model holding status of all system permissions required by ByteFlow.
@immutable
class SystemPermissionsState {
  /// Creates a [SystemPermissionsState] instance.
  const SystemPermissionsState({
    this.usageAccess = false,
    this.notifications = false,
    this.batteryOptimizationIgnored = false,
    this.shizukuStatus = const ShizukuStatus(
      isAvailable: false,
      hasPermission: false,
      version: -1,
      uid: -1,
    ),
  });

  /// Whether PACKAGE_USAGE_STATS permission is granted.
  final bool usageAccess;

  /// Whether POST_NOTIFICATIONS permission is granted.
  final bool notifications;

  /// Whether app is exempt from battery optimization.
  final bool batteryOptimizationIgnored;

  /// Active Shizuku IPC connection and authorization status.
  final ShizukuStatus shizukuStatus;

  /// Total count of configured permissions.
  int get grantedCount {
    var count = 0;
    if (usageAccess) count++;
    if (notifications) count++;
    if (batteryOptimizationIgnored) count++;
    if (shizukuStatus.hasPermission) count++;
    return count;
  }

  /// Total number of trackable permissions.
  static const int totalCount = 4;

  /// Creates a copy with the given fields replaced.
  SystemPermissionsState copyWith({
    bool? usageAccess,
    bool? notifications,
    bool? batteryOptimizationIgnored,
    ShizukuStatus? shizukuStatus,
  }) {
    return SystemPermissionsState(
      usageAccess: usageAccess ?? this.usageAccess,
      notifications: notifications ?? this.notifications,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      shizukuStatus: shizukuStatus ?? this.shizukuStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemPermissionsState &&
          runtimeType == other.runtimeType &&
          usageAccess == other.usageAccess &&
          notifications == other.notifications &&
          batteryOptimizationIgnored == other.batteryOptimizationIgnored &&
          shizukuStatus == other.shizukuStatus;

  @override
  int get hashCode => Object.hash(
        usageAccess,
        notifications,
        batteryOptimizationIgnored,
        shizukuStatus,
      );
}

/// Riverpod controller managing permission checks, requests, and lifecycle refreshes.
class PermissionsNotifier extends AsyncNotifier<SystemPermissionsState> {
  @override
  Future<SystemPermissionsState> build() async {
    return _checkAllPermissions();
  }

  Future<SystemPermissionsState> _checkAllPermissions() async {
    final bridge = ref.read(nativeBridgeProvider);
    final shizuku = ref.watch(shizukuStatusProvider).value ??
        ShizukuStatus.unavailable();

    final usageGranted = await bridge.hasUsagePermission();
    final notifStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    return SystemPermissionsState(
      usageAccess: usageGranted,
      notifications: notifStatus.isGranted,
      batteryOptimizationIgnored: batteryStatus.isGranted,
      shizukuStatus: shizuku,
    );
  }

  /// Refreshes all permission states.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_checkAllPermissions);
  }

  /// Opens the system Usage Access settings.
  Future<void> requestUsageAccess() async {
    final bridge = ref.read(nativeBridgeProvider);
    await bridge.openUsageSettings();
  }

  /// Requests Android 13+ POST_NOTIFICATIONS permission.
  Future<PermissionStatus> requestNotifications() async {
    final status = await Permission.notification.request();
    await refresh();
    return status;
  }

  /// Requests battery optimization exemption.
  Future<PermissionStatus> requestBatteryOptimizationExemption() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    await refresh();
    return status;
  }

  /// Requests Shizuku authorization dialog.
  Future<bool> requestShizukuAccess() async {
    final granted = await ref
        .read(shizukuStatusProvider.notifier)
        .requestPermission();
    await refresh();
    return granted;
  }
}

/// Exposes the active [SystemPermissionsState] and permission operations.
final permissionsProvider =
    AsyncNotifierProvider<PermissionsNotifier, SystemPermissionsState>(
  PermissionsNotifier.new,
);
