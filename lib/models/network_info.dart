/// Network connectivity status models and transport classifications.
library;

import 'package:flutter/foundation.dart';

/// The physical or virtual network transport type.
enum NetworkType {
  /// Connected to a Wi-Fi wireless local area network.
  wifi('Wi-Fi'),

  /// Connected to a cellular mobile data network (LTE, 5G, etc.).
  mobile('Mobile'),

  /// Connected to a wired Ethernet local area network.
  ethernet('Ethernet'),

  /// Connected through a virtual private network tunnel.
  vpn('VPN'),

  /// Connected through a Bluetooth tethered connection.
  bluetooth('Bluetooth'),

  /// No active network connection available.
  none('None'),

  /// Unrecognized or undetermined transport type.
  unknown('Unknown');

  const NetworkType(this.label);

  /// The human-readable label for this transport type.
  final String label;
}

/// An immutable description of the active network interface and connection state.
@immutable
class NetworkInfo {
  /// Creates an immutable [NetworkInfo] state.
  const NetworkInfo({
    required this.type,
    required this.isConnected,
    required this.isMetered,
    this.ssid,
  });

  /// Creates a disconnected network state baseline.
  factory NetworkInfo.disconnected() {
    return const NetworkInfo(
      type: NetworkType.none,
      isConnected: false,
      isMetered: false,
      ssid: null,
    );
  }

  /// Deserializes a [NetworkInfo] from a platform channel map.
  factory NetworkInfo.fromMap(Map<dynamic, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'unknown';
    final type = switch (typeStr.toLowerCase()) {
      'wifi' => NetworkType.wifi,
      'mobile' => NetworkType.mobile,
      'ethernet' => NetworkType.ethernet,
      'vpn' => NetworkType.vpn,
      'bluetooth' => NetworkType.bluetooth,
      'none' => NetworkType.none,
      _ => NetworkType.unknown,
    };

    return NetworkInfo(
      type: type,
      isConnected: map['isConnected'] as bool? ?? false,
      isMetered: map['isMetered'] as bool? ?? false,
      ssid: map['ssid'] as String?,
    );
  }

  /// The active network transport classification.
  final NetworkType type;

  /// Whether an active internet connection is present and validated.
  final bool isConnected;

  /// Whether the network connection is subject to bandwidth limits or metered billing.
  final bool isMetered;

  /// The Wi-Fi Service Set Identifier (SSID), if permitted and connected.
  final String? ssid;

  /// Serializes this instance into a map for interop or storage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'isConnected': isConnected,
      'isMetered': isMetered,
      'ssid': ssid,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkInfo &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          isConnected == other.isConnected &&
          isMetered == other.isMetered &&
          ssid == other.ssid;

  @override
  int get hashCode => Object.hash(type, isConnected, isMetered, ssid);

  @override
  String toString() =>
      'NetworkInfo(type: ${type.label}, isConnected: $isConnected, isMetered: $isMetered, ssid: $ssid)';
}
