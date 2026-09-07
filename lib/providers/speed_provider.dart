/// State management providers for real-time network speed streams.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/network_speed.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';
import 'package:byteflow/services/network_service.dart';

/// Provides the singleton [NetworkService] instance.
final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService();
  ref.onDispose(service.dispose);
  return service;
});

/// Emits real-time [NetworkSpeed] readings collected from native counters.
final speedStreamProvider = StreamProvider<NetworkSpeed>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.speedStream;
});

/// Computes human-readable speed strings for download, upload, and total throughput.
final formattedSpeedProvider =
    Provider<({String rx, String tx, String total})>((ref) {
  final speedAsync = ref.watch(speedStreamProvider);
  final speed = speedAsync.value ?? NetworkSpeed.zero();
  final prefsAsync = ref.watch(userPreferencesProvider);
  final preferredUnit = prefsAsync.value?.speedUnit ?? SpeedUnit.auto;

  return (
    rx: Formatters.formatSpeed(
      speed.rxBytesPerSecond,
      preferredUnit: preferredUnit,
    ),
    tx: Formatters.formatSpeed(
      speed.txBytesPerSecond,
      preferredUnit: preferredUnit,
    ),
    total: Formatters.formatSpeed(
      speed.totalBytesPerSecond,
      preferredUnit: preferredUnit,
    ),
  );
});
