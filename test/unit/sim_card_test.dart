import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/models/sim_card.dart';

void main() {
  group('SimCard', () {
    test('deserializes from native platform map successfully', () {
      final map = <dynamic, dynamic>{
        'subscriptionId': 1,
        'simSlotIndex': 0,
        'carrierName': 'Verizon',
        'displayName': 'Personal',
        'countryIso': 'us',
        'isDefaultData': true,
      };

      final sim = SimCard.fromMap(map);

      expect(sim.subscriptionId, equals(1));
      expect(sim.simSlotIndex, equals(0));
      expect(sim.carrierName, equals('Verizon'));
      expect(sim.displayName, equals('Personal'));
      expect(sim.countryIso, equals('us'));
      expect(sim.isDefaultData, isTrue);
      expect(sim.slotLabel, equals('SIM 1'));
      expect(sim.formattedTitle, equals('SIM 1: Personal'));
    });

    test('serializes to map representation', () {
      const sim = SimCard(
        subscriptionId: 2,
        simSlotIndex: 1,
        carrierName: 'T-Mobile',
        displayName: 'Work',
        countryIso: 'us',
        isDefaultData: false,
      );

      final map = sim.toMap();

      expect(map['subscriptionId'], equals(2));
      expect(map['simSlotIndex'], equals(1));
      expect(map['carrierName'], equals('T-Mobile'));
      expect(map['displayName'], equals('Work'));
      expect(map['countryIso'], equals('us'));
      expect(map['isDefaultData'], isFalse);
    });

    test('handles missing or null map values cleanly', () {
      final map = <dynamic, dynamic>{};
      final sim = SimCard.fromMap(map);

      expect(sim.subscriptionId, equals(-1));
      expect(sim.simSlotIndex, equals(0));
      expect(sim.carrierName, isEmpty);
      expect(sim.displayName, isEmpty);
      expect(sim.countryIso, isEmpty);
      expect(sim.isDefaultData, isFalse);
      expect(sim.slotLabel, equals('SIM 1'));
      expect(sim.formattedTitle, equals('SIM 1'));
    });

    test('equality and hashcode are value-based', () {
      const a = SimCard(
        subscriptionId: 1,
        simSlotIndex: 0,
        carrierName: 'AT&T',
        displayName: 'Primary',
        countryIso: 'us',
        isDefaultData: true,
      );

      const b = SimCard(
        subscriptionId: 1,
        simSlotIndex: 0,
        carrierName: 'AT&T',
        displayName: 'Primary',
        countryIso: 'us',
        isDefaultData: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
