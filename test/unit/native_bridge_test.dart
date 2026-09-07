import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/services/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      null,
    );
    messenger.setMockStreamHandler(
      const EventChannel(AppConstants.speedEventChannelName),
      null,
    );
    messenger.setMockStreamHandler(
      const EventChannel(AppConstants.networkEventChannelName),
      null,
    );
  });

  test('NativeBridge getNetworkInfo invokes method and parses result', () async {
    messenger.setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall call) async {
        if (call.method == AppConstants.methodGetNetworkInfo) {
          return <String, dynamic>{
            'type': 'wifi',
            'isConnected': true,
            'isMetered': false,
            'ssid': 'ByteFlow_Test_WiFi',
          };
        }
        return null;
      },
    );

    final bridge = NativeBridge();
    final info = await bridge.getNetworkInfo();

    expect(info.type, equals(NetworkType.wifi));
    expect(info.isConnected, isTrue);
    expect(info.isMetered, isFalse);
    expect(info.ssid, equals('ByteFlow_Test_WiFi'));
  });

  test('NativeBridge getTrafficStats returns cumulative counters', () async {
    messenger.setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall call) async {
        if (call.method == AppConstants.methodGetTrafficStats) {
          return <String, dynamic>{
            'rxTotalBytes': 1234567,
            'txTotalBytes': 7654321,
            'timestamp': 1725500000000,
          };
        }
        return null;
      },
    );

    final bridge = NativeBridge();
    final stats = await bridge.getTrafficStats();

    expect(stats['rxTotalBytes'], equals(1234567));
    expect(stats['txTotalBytes'], equals(7654321));
  });

  test('NativeBridge speedStream emits transformed NetworkSpeed events', () async {
    final speedChannel = const EventChannel(AppConstants.speedEventChannelName);
    messenger.setMockStreamHandler(
      speedChannel,
      MockStreamHandler.inline(
        onListen: (args, events) {
          events.success(<String, dynamic>{
            'rxSpeed': 500000,
            'txSpeed': 250000,
            'totalSpeed': 750000,
            'timestamp': 1725500000000,
          });
        },
      ),
    );

    final bridge = NativeBridge();
    final speed = await bridge.speedStream.first;

    expect(speed.rxBytesPerSecond, equals(500000));
    expect(speed.txBytesPerSecond, equals(250000));
    expect(speed.totalBytesPerSecond, equals(750000));
  });

  test('NativeBridge networkInfoStream emits transformed NetworkInfo events', () async {
    final networkChannel =
        const EventChannel(AppConstants.networkEventChannelName);
    messenger.setMockStreamHandler(
      networkChannel,
      MockStreamHandler.inline(
        onListen: (args, events) {
          events.success(<String, dynamic>{
            'type': 'mobile',
            'isConnected': true,
            'isMetered': true,
            'ssid': null,
          });
        },
      ),
    );

    final bridge = NativeBridge();
    final info = await bridge.networkInfoStream.first;

    expect(info.type, equals(NetworkType.mobile));
    expect(info.isConnected, isTrue);
    expect(info.isMetered, isTrue);
  });
}
