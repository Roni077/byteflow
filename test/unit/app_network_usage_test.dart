import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/models/app_network_usage.dart';

void main() {
  group('AppNetworkUsage Model Tests', () {
    test('deserializes from Map accurately with explicit values', () {
      final map = <String, dynamic>{
        'uid': 10123,
        'packageName': 'com.example.browser',
        'appName': 'Fast Browser',
        'rxBytes': 5000000,
        'txBytes': 1000000,
        'wifiRxBytes': 4000000,
        'wifiTxBytes': 800000,
        'mobileRxBytes': 1000000,
        'mobileTxBytes': 200000,
        'totalBytes': 6000000,
        'isSystemApp': false,
      };

      final usage = AppNetworkUsage.fromMap(map);

      expect(usage.uid, equals(10123));
      expect(usage.packageName, equals('com.example.browser'));
      expect(usage.appName, equals('Fast Browser'));
      expect(usage.rxBytes, equals(5000000));
      expect(usage.txBytes, equals(1000000));
      expect(usage.wifiRxBytes, equals(4000000));
      expect(usage.wifiTxBytes, equals(800000));
      expect(usage.mobileRxBytes, equals(1000000));
      expect(usage.mobileTxBytes, equals(200000));
      expect(usage.totalBytes, equals(6000000));
      expect(usage.isSystemApp, isFalse);
      expect(usage.wifiTotalBytes, equals(4800000));
      expect(usage.mobileTotalBytes, equals(1200000));
    });

    test('handles missing or null fields gracefully in fromMap', () {
      final map = <String, dynamic>{};

      final usage = AppNetworkUsage.fromMap(map);

      expect(usage.uid, equals(0));
      expect(usage.packageName, equals('unknown'));
      expect(usage.appName, equals('unknown'));
      expect(usage.rxBytes, equals(0));
      expect(usage.txBytes, equals(0));
      expect(usage.totalBytes, equals(0));
      expect(usage.isSystemApp, isFalse);
      expect(usage.wifiTotalBytes, equals(0));
      expect(usage.mobileTotalBytes, equals(0));
    });

    test('serializes toMap correctly', () {
      const usage = AppNetworkUsage(
        uid: 1000,
        packageName: 'android',
        appName: 'Android System',
        rxBytes: 1000,
        txBytes: 500,
        wifiRxBytes: 600,
        wifiTxBytes: 300,
        mobileRxBytes: 400,
        mobileTxBytes: 200,
        totalBytes: 1500,
        isSystemApp: true,
      );

      final map = usage.toMap();

      expect(map['uid'], equals(1000));
      expect(map['packageName'], equals('android'));
      expect(map['appName'], equals('Android System'));
      expect(map['rxBytes'], equals(1000));
      expect(map['txBytes'], equals(500));
      expect(map['wifiRxBytes'], equals(600));
      expect(map['wifiTxBytes'], equals(300));
      expect(map['mobileRxBytes'], equals(400));
      expect(map['mobileTxBytes'], equals(200));
      expect(map['totalBytes'], equals(1500));
      expect(map['isSystemApp'], isTrue);
    });

    test('copyWith updates specified fields only', () {
      const original = AppNetworkUsage(
        uid: 101,
        packageName: 'com.test',
        appName: 'Test',
        rxBytes: 100,
        txBytes: 50,
        wifiRxBytes: 100,
        wifiTxBytes: 50,
        mobileRxBytes: 0,
        mobileTxBytes: 0,
        totalBytes: 150,
        isSystemApp: false,
      );

      final updated = original.copyWith(
        appName: 'Updated Test',
        rxBytes: 200,
        totalBytes: 250,
      );

      expect(updated.appName, equals('Updated Test'));
      expect(updated.rxBytes, equals(200));
      expect(updated.totalBytes, equals(250));
      expect(updated.txBytes, equals(50));
      expect(updated.packageName, equals('com.test'));
    });

    test('equality and hashCode contract', () {
      const item1 = AppNetworkUsage(
        uid: 101,
        packageName: 'com.app',
        appName: 'App',
        rxBytes: 100,
        txBytes: 50,
        wifiRxBytes: 80,
        wifiTxBytes: 40,
        mobileRxBytes: 20,
        mobileTxBytes: 10,
        totalBytes: 150,
        isSystemApp: false,
      );

      const item2 = AppNetworkUsage(
        uid: 101,
        packageName: 'com.app',
        appName: 'App',
        rxBytes: 100,
        txBytes: 50,
        wifiRxBytes: 80,
        wifiTxBytes: 40,
        mobileRxBytes: 20,
        mobileTxBytes: 10,
        totalBytes: 150,
        isSystemApp: false,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
    });
  });
}
