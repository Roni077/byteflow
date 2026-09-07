/// Riverpod state providers managing cellular SIM detection and permissions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:byteflow/models/sim_card.dart';
import 'package:byteflow/services/native_bridge.dart';

/// Provider querying the active telephony permission status.
final phonePermissionProvider = FutureProvider<bool>((ref) async {
  final bridge = ref.watch(nativeBridgeProvider);
  return bridge.hasPhonePermission();
});

/// State controller managing active SIM cards discovery and permission requests.
class SimCardsNotifier extends AsyncNotifier<List<SimCard>> {
  @override
  Future<List<SimCard>> build() async {
    return _fetchSimCards();
  }

  Future<List<SimCard>> _fetchSimCards() async {
    final bridge = ref.read(nativeBridgeProvider);
    final hasPerm = await bridge.hasPhonePermission();
    if (!hasPerm) {
      return <SimCard>[];
    }
    return bridge.getSimCards();
  }

  /// Manually re-scans active cellular subscriptions.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSimCards);
    ref.invalidate(phonePermissionProvider);
  }

  /// Requests the runtime READ_PHONE_STATE permission from the user.
  Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    final isGranted = status.isGranted;
    await refresh();
    return isGranted;
  }
}

/// Provides the list of detected [SimCard] subscriptions.
final simCardsProvider =
    AsyncNotifierProvider<SimCardsNotifier, List<SimCard>>(
  SimCardsNotifier.new,
);
