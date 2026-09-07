/// Application-level network monitoring service coordinating platform data feeds.
library;

import 'dart:async';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/models/network_speed.dart';
import 'package:byteflow/services/native_bridge.dart';

/// Coordinates real-time speed monitoring and network state updates.
class NetworkService {
  /// Creates a [NetworkService] backed by the provided [nativeBridge].
  NetworkService({NativeBridge? nativeBridge})
      : _bridge = nativeBridge ?? NativeBridge() {
    _initStreams();
  }

  final NativeBridge _bridge;

  NetworkSpeed _currentSpeed = NetworkSpeed.zero();
  NetworkInfo _currentNetworkInfo = NetworkInfo.disconnected();

  StreamSubscription<NetworkSpeed>? _speedSubscription;
  StreamSubscription<NetworkInfo>? _networkSubscription;

  final StreamController<NetworkSpeed> _speedController =
      StreamController<NetworkSpeed>.broadcast();
  final StreamController<NetworkInfo> _networkController =
      StreamController<NetworkInfo>.broadcast();

  void _initStreams() {
    _speedSubscription = _bridge.speedStream.listen(
      (speed) {
        _currentSpeed = speed;
        _speedController.add(speed);
      },
      onError: (Object error) {
        _currentSpeed = NetworkSpeed.zero();
        _speedController.add(_currentSpeed);
      },
    );

    _networkSubscription = _bridge.networkInfoStream.listen(
      (info) {
        _currentNetworkInfo = info;
        _networkController.add(info);
      },
      onError: (Object error) {
        _currentNetworkInfo = NetworkInfo.disconnected();
        _networkController.add(_currentNetworkInfo);
      },
    );

    // Initial snapshot fetch
    unawaited(refreshNetworkInfo());
  }

  /// The most recently received speed sample.
  NetworkSpeed get currentSpeed => _currentSpeed;

  /// The most recently received network connectivity description.
  NetworkInfo get currentNetworkInfo => _currentNetworkInfo;

  /// Stream of real-time speed updates.
  Stream<NetworkSpeed> get speedStream => _speedController.stream;

  /// Stream of network transport and status updates.
  Stream<NetworkInfo> get networkInfoStream => _networkController.stream;

  /// Refreshes and returns the current active network state.
  Future<NetworkInfo> refreshNetworkInfo() async {
    final info = await _bridge.getNetworkInfo();
    _currentNetworkInfo = info;
    _networkController.add(info);
    return info;
  }

  /// Returns cumulative total traffic counter values.
  Future<Map<String, int>> getCumulativeStats() {
    return _bridge.getTrafficStats();
  }

  /// Disposes active subscriptions and controllers.
  void dispose() {
    _speedSubscription?.cancel();
    _networkSubscription?.cancel();
    _speedController.close();
    _networkController.close();
  }
}
