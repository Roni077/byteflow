/// State management providers for active network connectivity status.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/providers/speed_provider.dart';

/// Emits active [NetworkInfo] updates whenever transport or connectivity changes.
final networkInfoStreamProvider = StreamProvider<NetworkInfo>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.networkInfoStream;
});

/// Provides the current [NetworkInfo] snapshot with immediate fallback to cached state.
final currentNetworkInfoProvider = Provider<NetworkInfo>((ref) {
  final infoAsync = ref.watch(networkInfoStreamProvider);
  return infoAsync.value ?? ref.watch(networkServiceProvider).currentNetworkInfo;
});
