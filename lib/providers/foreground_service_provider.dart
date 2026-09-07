/// Riverpod state providers managing background speed monitoring foreground service.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/models/foreground_service_config.dart';
import 'package:byteflow/services/native_bridge.dart';

/// Controller managing foreground service configuration and lifecycle states.
class ForegroundServiceNotifier extends AsyncNotifier<ForegroundServiceConfig> {
  @override
  Future<ForegroundServiceConfig> build() async {
    return _fetchConfig();
  }

  Future<ForegroundServiceConfig> _fetchConfig() async {
    final bridge = ref.read(nativeBridgeProvider);
    final rawConfig = await bridge.getServiceConfig();
    final isRunning = await bridge.isForegroundServiceRunning();

    return ForegroundServiceConfig(
      isServiceRunning: isRunning,
      showStatusBarSpeed: rawConfig['showStatusBarSpeed'] as bool? ?? true,
      speedDisplayMode: rawConfig['speedDisplayMode'] as String? ?? 'combined',
      startOnBoot: rawConfig['startOnBoot'] as bool? ?? false,
      pollingIntervalMs: (rawConfig['pollingIntervalMs'] as num?)?.toInt() ?? 1000,
      showPersistentNotification:
          rawConfig['showPersistentNotification'] as bool? ?? true,
    );
  }

  /// Toggles the background foreground monitoring service on or off.
  Future<bool> toggleService(bool enable) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    bool success;
    if (enable) {
      success = await bridge.startForegroundService(
        showStatusBarSpeed: current.showStatusBarSpeed,
        speedDisplayMode: current.speedDisplayMode,
        startOnBoot: current.startOnBoot,
        pollingIntervalMs: current.pollingIntervalMs,
        showPersistentNotification: current.showPersistentNotification,
      );
    } else {
      success = await bridge.stopForegroundService();
    }

    if (success) {
      state = AsyncValue.data(
        current.copyWith(isServiceRunning: enable),
      );
    }
    return success;
  }

  /// Toggles whether the dynamic speed number is rendered in the Android status bar.
  Future<void> toggleStatusBarSpeed(bool show) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    await bridge.updateServiceConfig(showStatusBarSpeed: show);
    state = AsyncValue.data(
      current.copyWith(showStatusBarSpeed: show),
    );
  }

  /// Sets the active speed calculation mode ('combined', 'download', or 'upload').
  Future<void> setSpeedDisplayMode(String mode) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    await bridge.updateServiceConfig(speedDisplayMode: mode);
    state = AsyncValue.data(
      current.copyWith(speedDisplayMode: mode),
    );
  }

  /// Toggles auto-starting the foreground service on Android device boot.
  Future<void> toggleStartOnBoot(bool autoStart) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    await bridge.updateServiceConfig(startOnBoot: autoStart);
    state = AsyncValue.data(
      current.copyWith(startOnBoot: autoStart),
    );
  }

  /// Sets the polling interval in milliseconds.
  Future<void> setPollingInterval(int intervalMs) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    await bridge.updateServiceConfig(pollingIntervalMs: intervalMs);
    await bridge.setPollingInterval(intervalMs);
    state = AsyncValue.data(
      current.copyWith(pollingIntervalMs: intervalMs),
    );
  }

  /// Toggles the persistent notification display.
  Future<void> togglePersistentNotification(bool show) async {
    final current = state.value ?? const ForegroundServiceConfig();
    final bridge = ref.read(nativeBridgeProvider);

    await bridge.updateServiceConfig(showPersistentNotification: show);
    state = AsyncValue.data(
      current.copyWith(showPersistentNotification: show),
    );
  }

  /// Re-syncs native service status and preferences.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchConfig);
  }
}

/// Exposes the active [ForegroundServiceConfig] and lifecycle controls.
final foregroundServiceProvider =
    AsyncNotifierProvider<ForegroundServiceNotifier, ForegroundServiceConfig>(
  ForegroundServiceNotifier.new,
);
