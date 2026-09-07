/// Data models representing per-SIM network usage statistics.
library;

import 'package:flutter/foundation.dart';

/// Immutable container holding cellular data transfer volumes for a specific SIM card.
@immutable
class SimUsage {
  /// Creates an immutable [SimUsage] instance.
  const SimUsage({
    required this.rxBytes,
    required this.txBytes,
    required this.totalBytes,
    required this.isPrivileged,
    this.subscriberId,
    this.subId,
  });

  /// Baseline zero usage container.
  factory SimUsage.zero({int? subId, String? subscriberId}) => SimUsage(
        rxBytes: 0,
        txBytes: 0,
        totalBytes: 0,
        isPrivileged: false,
        subscriberId: subscriberId,
        subId: subId,
      );

  /// Constructs a [SimUsage] from native platform channel dictionary.
  factory SimUsage.fromMap(Map<dynamic, dynamic> map, {int? subId}) {
    final rx = (map['rxBytes'] as num?)?.toInt() ?? 0;
    final tx = (map['txBytes'] as num?)?.toInt() ?? 0;
    final total = (map['totalBytes'] as num?)?.toInt() ?? (rx + tx);
    final privileged = map['isPrivileged'] as bool? ?? false;
    final subImsi = map['subscriberId'] as String?;

    return SimUsage(
      rxBytes: rx,
      txBytes: tx,
      totalBytes: total,
      isPrivileged: privileged,
      subscriberId: subImsi,
      subId: subId,
    );
  }

  /// Downloaded bytes on this cellular subscription.
  final int rxBytes;

  /// Uploaded bytes on this cellular subscription.
  final int txBytes;

  /// Combined aggregate bytes transferred.
  final int totalBytes;

  /// Whether this usage was queried with privileged IMSI subscriberId or aggregate fallback.
  final bool isPrivileged;

  /// The IMSI subscriber identifier associated with this SIM, if privileged.
  final String? subscriberId;

  /// Android subscription ID.
  final int? subId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimUsage &&
          runtimeType == other.runtimeType &&
          rxBytes == other.rxBytes &&
          txBytes == other.txBytes &&
          totalBytes == other.totalBytes &&
          isPrivileged == other.isPrivileged &&
          subscriberId == other.subscriberId &&
          subId == other.subId;

  @override
  int get hashCode =>
      Object.hash(rxBytes, txBytes, totalBytes, isPrivileged, subscriberId, subId);

  @override
  String toString() =>
      'SimUsage(subId: $subId, rx: $rxBytes, tx: $txBytes, total: $totalBytes, privileged: $isPrivileged)';
}
