import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/models/network_speed.dart';

void main() {
  group('NetworkSpeed Model', () {
    test('initializes zero speed baseline properly', () {
      final now = DateTime.now();
      final speed = NetworkSpeed.zero(timestamp: now);

      expect(speed.rxBytesPerSecond, equals(0));
      expect(speed.txBytesPerSecond, equals(0));
      expect(speed.totalBytesPerSecond, equals(0));
      expect(speed.timestamp, equals(now));
    });

    test('calculates totalBytesPerSecond correctly', () {
      final speed = NetworkSpeed(
        rxBytesPerSecond: 1000,
        txBytesPerSecond: 500,
        timestamp: DateTime(2026, 9, 5),
      );

      expect(speed.totalBytesPerSecond, equals(1500));
    });

    test('deserializes from valid map', () {
      final now = DateTime.now();
      final map = <String, dynamic>{
        'rxSpeed': 2048,
        'txSpeed': 1024,
        'timestamp': now.millisecondsSinceEpoch,
      };

      final speed = NetworkSpeed.fromMap(map);
      expect(speed.rxBytesPerSecond, equals(2048));
      expect(speed.txBytesPerSecond, equals(1024));
      expect(speed.totalBytesPerSecond, equals(3072));
      expect(speed.timestamp.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });

    test('handles negative and malformed values gracefully in fromMap', () {
      final map = <String, dynamic>{
        'rxSpeed': -100,
        'txSpeed': null,
        'timestamp': 'invalid',
      };

      final speed = NetworkSpeed.fromMap(map);
      expect(speed.rxBytesPerSecond, equals(0));
      expect(speed.txBytesPerSecond, equals(0));
      expect(speed.totalBytesPerSecond, equals(0));
    });

    test('supports equality and map serialization round-trip', () {
      final dt = DateTime.fromMillisecondsSinceEpoch(1725500000000);
      final speed1 = NetworkSpeed(
        rxBytesPerSecond: 5000,
        txBytesPerSecond: 2500,
        timestamp: dt,
      );
      final speed2 = NetworkSpeed(
        rxBytesPerSecond: 5000,
        txBytesPerSecond: 2500,
        timestamp: dt,
      );

      expect(speed1, equals(speed2));
      expect(speed1.hashCode, equals(speed2.hashCode));

      final serialized = speed1.toMap();
      final deserialized = NetworkSpeed.fromMap(serialized);
      expect(deserialized, equals(speed1));
    });
  });

  group('NetworkInfo Model', () {
    test('creates disconnected baseline', () {
      final info = NetworkInfo.disconnected();
      expect(info.type, equals(NetworkType.none));
      expect(info.isConnected, isFalse);
      expect(info.isMetered, isFalse);
      expect(info.ssid, isNull);
    });

    test('deserializes transports correctly', () {
      final wifiMap = <String, dynamic>{
        'type': 'wifi',
        'isConnected': true,
        'isMetered': false,
        'ssid': 'HomeNetwork_5G',
      };
      final wifiInfo = NetworkInfo.fromMap(wifiMap);
      expect(wifiInfo.type, equals(NetworkType.wifi));
      expect(wifiInfo.isConnected, isTrue);
      expect(wifiInfo.isMetered, isFalse);
      expect(wifiInfo.ssid, equals('HomeNetwork_5G'));

      final mobileMap = <String, dynamic>{
        'type': 'mobile',
        'isConnected': true,
        'isMetered': true,
        'ssid': null,
      };
      final mobileInfo = NetworkInfo.fromMap(mobileMap);
      expect(mobileInfo.type, equals(NetworkType.mobile));
      expect(mobileInfo.isConnected, isTrue);
      expect(mobileInfo.isMetered, isTrue);

      final vpnMap = <String, dynamic>{
        'type': 'vpn',
        'isConnected': true,
        'isMetered': false,
      };
      final vpnInfo = NetworkInfo.fromMap(vpnMap);
      expect(vpnInfo.type, equals(NetworkType.vpn));
    });
  });
}
