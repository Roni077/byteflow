import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/models/foreground_service_config.dart';
import 'package:byteflow/providers/foreground_service_provider.dart';
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
  });

  group('ForegroundServiceConfig', () {
    test('default constructor initializes with standard defaults', () {
      const config = ForegroundServiceConfig();
      expect(config.isServiceRunning, isFalse);
      expect(config.showStatusBarSpeed, isTrue);
      expect(config.speedDisplayMode, equals('combined'));
      expect(config.startOnBoot, isFalse);
      expect(config.pollingIntervalMs, equals(1000));
      expect(config.showPersistentNotification, isTrue);
    });

    test('copyWith properly updates specified fields', () {
      const config = ForegroundServiceConfig();
      final updated = config.copyWith(
        isServiceRunning: true,
        speedDisplayMode: 'download',
        pollingIntervalMs: 3000,
        showPersistentNotification: false,
      );
      expect(updated.isServiceRunning, isTrue);
      expect(updated.showStatusBarSpeed, isTrue);
      expect(updated.speedDisplayMode, equals('download'));
      expect(updated.startOnBoot, isFalse);
      expect(updated.pollingIntervalMs, equals(3000));
      expect(updated.showPersistentNotification, isFalse);
    });

    test('fromMap and toMap serialization consistency', () {
      final map = <String, dynamic>{
        'isRunning': true,
        'showStatusBarSpeed': false,
        'speedDisplayMode': 'upload',
        'startOnBoot': true,
        'pollingIntervalMs': 2000,
        'showPersistentNotification': false,
      };
      final config = ForegroundServiceConfig.fromMap(map);
      expect(config.isServiceRunning, isTrue);
      expect(config.showStatusBarSpeed, isFalse);
      expect(config.speedDisplayMode, equals('upload'));
      expect(config.startOnBoot, isTrue);
      expect(config.pollingIntervalMs, equals(2000));
      expect(config.showPersistentNotification, isFalse);

      final serialized = config.toMap();
      expect(serialized['isRunning'], isTrue);
      expect(serialized['showStatusBarSpeed'], isFalse);
      expect(serialized['speedDisplayMode'], equals('upload'));
      expect(serialized['startOnBoot'], isTrue);
      expect(serialized['pollingIntervalMs'], equals(2000));
      expect(serialized['showPersistentNotification'], isFalse);
    });
  });

  group('NativeBridge Foreground Service Methods', () {
    test('startForegroundService calls correct method with parameters', () async {
      MethodCall? recordedCall;
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodStartForegroundService) {
            recordedCall = call;
            return true;
          }
          return null;
        },
      );

      final bridge = NativeBridge();
      final result = await bridge.startForegroundService(
        showStatusBarSpeed: true,
        speedDisplayMode: 'combined',
        startOnBoot: true,
      );

      expect(result, isTrue);
      expect(recordedCall, isNotNull);
      expect(recordedCall!.arguments, equals(<String, dynamic>{
        'showStatusBarSpeed': true,
        'speedDisplayMode': 'combined',
        'startOnBoot': true,
        'pollingIntervalMs': 1000,
        'showPersistentNotification': true,
      }));
    });

    test('stopForegroundService calls stop method', () async {
      var stopped = false;
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodStopForegroundService) {
            stopped = true;
            return true;
          }
          return null;
        },
      );

      final bridge = NativeBridge();
      final result = await bridge.stopForegroundService();

      expect(result, isTrue);
      expect(stopped, isTrue);
    });

    test('isForegroundServiceRunning returns state from native platform', () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodIsForegroundServiceRunning) {
            return true;
          }
          return null;
        },
      );

      final bridge = NativeBridge();
      final isRunning = await bridge.isForegroundServiceRunning();

      expect(isRunning, isTrue);
    });

    test('updateServiceConfig calls update method with partial arguments', () async {
      MethodCall? recordedCall;
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodUpdateServiceConfig) {
            recordedCall = call;
            return true;
          }
          return null;
        },
      );

      final bridge = NativeBridge();
      final result = await bridge.updateServiceConfig(
        speedDisplayMode: 'upload',
      );

      expect(result, isTrue);
      expect(recordedCall, isNotNull);
      expect(recordedCall!.arguments, equals(<String, dynamic>{
        'speedDisplayMode': 'upload',
      }));
    });

    test('getServiceConfig parses configuration map', () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodGetServiceConfig) {
            return <String, dynamic>{
              'isRunning': true,
              'showStatusBarSpeed': true,
              'speedDisplayMode': 'combined',
              'startOnBoot': false,
            };
          }
          return null;
        },
      );

      final bridge = NativeBridge();
      final configMap = await bridge.getServiceConfig();

      expect(configMap['isRunning'], isTrue);
      expect(configMap['showStatusBarSpeed'], isTrue);
      expect(configMap['speedDisplayMode'], equals('combined'));
      expect(configMap['startOnBoot'], isFalse);
    });
  });

  group('ForegroundServiceNotifier', () {
    test('build loads configuration and running state', () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodGetServiceConfig) {
            return <String, dynamic>{
              'isRunning': false,
              'showStatusBarSpeed': true,
              'speedDisplayMode': 'combined',
              'startOnBoot': false,
            };
          }
          if (call.method == AppConstants.methodIsForegroundServiceRunning) {
            return false;
          }
          return null;
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(foregroundServiceProvider.future);
      expect(initial.isServiceRunning, isFalse);
      expect(initial.showStatusBarSpeed, isTrue);
      expect(initial.speedDisplayMode, equals('combined'));
      expect(initial.startOnBoot, isFalse);
    });

    test('toggleService updates state and invokes platform bridge', () async {
      var startInvoked = false;
      var stopInvoked = false;

      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodGetServiceConfig) {
            return <String, dynamic>{
              'isRunning': false,
              'showStatusBarSpeed': true,
              'speedDisplayMode': 'combined',
              'startOnBoot': false,
            };
          }
          if (call.method == AppConstants.methodIsForegroundServiceRunning) {
            return false;
          }
          if (call.method == AppConstants.methodStartForegroundService) {
            startInvoked = true;
            return true;
          }
          if (call.method == AppConstants.methodStopForegroundService) {
            stopInvoked = true;
            return true;
          }
          return null;
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(foregroundServiceProvider.future);
      final notifier = container.read(foregroundServiceProvider.notifier);

      final startSuccess = await notifier.toggleService(true);
      expect(startSuccess, isTrue);
      expect(startInvoked, isTrue);
      expect(container.read(foregroundServiceProvider).value?.isServiceRunning, isTrue);

      final stopSuccess = await notifier.toggleService(false);
      expect(stopSuccess, isTrue);
      expect(stopInvoked, isTrue);
      expect(container.read(foregroundServiceProvider).value?.isServiceRunning, isFalse);
    });

    test('configuration setters update state and call platform bridge', () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel(AppConstants.methodChannelName),
        (MethodCall call) async {
          if (call.method == AppConstants.methodGetServiceConfig) {
            return <String, dynamic>{
              'isRunning': true,
              'showStatusBarSpeed': true,
              'speedDisplayMode': 'combined',
              'startOnBoot': false,
            };
          }
          if (call.method == AppConstants.methodIsForegroundServiceRunning) {
            return true;
          }
          if (call.method == AppConstants.methodUpdateServiceConfig) {
            return true;
          }
          return null;
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(foregroundServiceProvider.future);
      final notifier = container.read(foregroundServiceProvider.notifier);

      await notifier.toggleStatusBarSpeed(false);
      expect(container.read(foregroundServiceProvider).value?.showStatusBarSpeed, isFalse);

      await notifier.setSpeedDisplayMode('download');
      expect(container.read(foregroundServiceProvider).value?.speedDisplayMode, equals('download'));

      await notifier.toggleStartOnBoot(true);
      expect(container.read(foregroundServiceProvider).value?.startOnBoot, isTrue);
    });
  });
}
