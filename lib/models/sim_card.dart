/// Data model representing an active physical or eSIM mobile subscription.
library;

import 'package:flutter/foundation.dart';

/// Represents a cellular SIM card subscription detected on the device.
@immutable
class SimCard {
  /// Creates a [SimCard] instance with subscription metadata.
  const SimCard({
    required this.subscriptionId,
    required this.simSlotIndex,
    required this.carrierName,
    required this.displayName,
    required this.countryIso,
    required this.isDefaultData,
  });

  /// The unique subscription identifier assigned by Android's SubscriptionManager.
  final int subscriptionId;

  /// The physical or logical SIM slot index (0 for SIM 1, 1 for SIM 2).
  final int simSlotIndex;

  /// The official network operator / carrier name (e.g., "Verizon", "T-Mobile").
  final String carrierName;

  /// The user-visible display name assigned by the OS or user.
  final String displayName;

  /// The two-letter ISO country code for the subscription's provider.
  final String countryIso;

  /// Whether this SIM card is currently set as the primary default for cellular data.
  final bool isDefaultData;

  /// Formatted slot index label (e.g., "SIM 1" or "SIM 2").
  String get slotLabel => 'SIM ${simSlotIndex + 1}';

  /// A descriptive user-friendly title combining the slot and name.
  String get formattedTitle {
    final name = displayName.isNotEmpty ? displayName : carrierName;
    return name.isNotEmpty ? '$slotLabel: $name' : slotLabel;
  }

  /// Deserializes a [SimCard] from a native platform channel map.
  factory SimCard.fromMap(Map<dynamic, dynamic> map) {
    return SimCard(
      subscriptionId: (map['subscriptionId'] as num?)?.toInt() ?? -1,
      simSlotIndex: (map['simSlotIndex'] as num?)?.toInt() ?? 0,
      carrierName: map['carrierName']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      countryIso: map['countryIso']?.toString() ?? '',
      isDefaultData: map['isDefaultData'] as bool? ?? false,
    );
  }

  /// Serializes this instance to a map representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subscriptionId': subscriptionId,
      'simSlotIndex': simSlotIndex,
      'carrierName': carrierName,
      'displayName': displayName,
      'countryIso': countryIso,
      'isDefaultData': isDefaultData,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimCard &&
          runtimeType == other.runtimeType &&
          subscriptionId == other.subscriptionId &&
          simSlotIndex == other.simSlotIndex &&
          carrierName == other.carrierName &&
          displayName == other.displayName &&
          countryIso == other.countryIso &&
          isDefaultData == other.isDefaultData;

  @override
  int get hashCode => Object.hash(
        subscriptionId,
        simSlotIndex,
        carrierName,
        displayName,
        countryIso,
        isDefaultData,
      );

  @override
  String toString() {
    return 'SimCard(id: $subscriptionId, slot: $simSlotIndex, name: $displayName, carrier: $carrierName, defaultData: $isDefaultData)';
  }
}
