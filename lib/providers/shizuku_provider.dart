/// Riverpod providers exposing reactive Shizuku daemon status and SIM subscriber mappings.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/models/shizuku_status.dart';
import 'package:byteflow/services/shizuku_service.dart';

/// StateNotifier managing reactive [ShizukuStatus] checks and permission requests.
class ShizukuStatusNotifier extends StateNotifier<AsyncValue<ShizukuStatus>> {
  /// Initializes the notifier by querying the initial status.
  ShizukuStatusNotifier(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  final ShizukuService _service;

  /// Re-evaluates Shizuku binder and permission availability.
  Future<void> refresh() async {
    try {
      final status = await _service.getStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Triggers the native Shizuku permission dialog and updates state on completion.
  Future<bool> requestPermission() async {
    final granted = await _service.requestPermission();
    await refresh();
    return granted;
  }
}

/// Provides the reactive [ShizukuStatusNotifier].
final shizukuStatusProvider =
    StateNotifierProvider<ShizukuStatusNotifier, AsyncValue<ShizukuStatus>>(
        (ref) {
  final service = ref.watch(shizukuServiceProvider);
  return ShizukuStatusNotifier(service);
});

/// Maps active subscription IDs to discovered IMSI subscriber IDs.
final simSubscriberIdsProvider = FutureProvider<Map<int, String>>((ref) async {
  final service = ref.watch(shizukuServiceProvider);
  final status = ref.watch(shizukuStatusProvider).value;

  if (status == null || !status.hasPermission) {
    return <int, String>{};
  }

  return service.getSimSubscriberIds();
});
