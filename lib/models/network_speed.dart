/// Network speed measurement models and serialization helpers.
library;

import 'package:flutter/foundation.dart';

/// An immutable measurement of real-time download and upload transfer rates.
@immutable
class NetworkSpeed {
  /// Creates an immutable [NetworkSpeed] measurement.
  const NetworkSpeed({
    required this.rxBytesPerSecond,
    required this.txBytesPerSecond,
    required this.timestamp,
  });

  /// Creates a zero-rate [NetworkSpeed] baseline.
  factory NetworkSpeed.zero({DateTime? timestamp}) {
    return NetworkSpeed(
      rxBytesPerSecond: 0,
      txBytesPerSecond: 0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Deserializes a [NetworkSpeed] from a platform channel map.
  factory NetworkSpeed.fromMap(Map<dynamic, dynamic> map) {
    final rx = (map['rxSpeed'] as num?)?.toInt() ?? 0;
    final tx = (map['txSpeed'] as num?)?.toInt() ?? 0;
    final tsRaw = map['timestamp'];

    final ts = switch (tsRaw) {
      int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      DateTime dt => dt,
      _ => DateTime.now(),
    };

    return NetworkSpeed(
      rxBytesPerSecond: rx >= 0 ? rx : 0,
      txBytesPerSecond: tx >= 0 ? tx : 0,
      timestamp: ts,
    );
  }

  /// The current download rate in bytes per second.
  final int rxBytesPerSecond;

  /// The current upload rate in bytes per second.
  final int txBytesPerSecond;

  /// The timestamp when this speed sample was collected.
  final DateTime timestamp;

  /// The combined transfer rate in bytes per second.
  int get totalBytesPerSecond => rxBytesPerSecond + txBytesPerSecond;

  /// Serializes this instance into a map for interop or storage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rxSpeed': rxBytesPerSecond,
      'txSpeed': txBytesPerSecond,
      'totalSpeed': totalBytesPerSecond,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkSpeed &&
          runtimeType == other.runtimeType &&
          rxBytesPerSecond == other.rxBytesPerSecond &&
          txBytesPerSecond == other.txBytesPerSecond &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(rxBytesPerSecond, txBytesPerSecond, timestamp);

  @override
  String toString() =>
      'NetworkSpeed(rx: $rxBytesPerSecond B/s, tx: $txBytesPerSecond B/s, time: $timestamp)';
}
