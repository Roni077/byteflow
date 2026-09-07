/// Service providing memory caching and retrieval for application icons.
library;

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/services/native_bridge.dart';

/// In-memory cache and retrieval service for application icons to avoid redundant IPC.
class AppIconService {
  /// Creates an [AppIconService] backed by the provided [NativeBridge].
  AppIconService({required this.nativeBridge});

  /// Interop bridge to native platform channels.
  final NativeBridge nativeBridge;
  final Map<String, Uint8List?> _iconCache = <String, Uint8List?>{};

  /// Retrieves the PNG icon byte array for the specified [packageName],
  /// caching the result in memory.
  Future<Uint8List?> getIcon(String packageName) async {
    if (_iconCache.containsKey(packageName)) {
      return _iconCache[packageName];
    }

    final bytes = await nativeBridge.getAppIcon(packageName);
    _iconCache[packageName] = bytes;
    return bytes;
  }

  /// Clears the in-memory icon cache.
  void clearCache() {
    _iconCache.clear();
  }
}

/// Provider exposing the singleton [AppIconService].
final appIconServiceProvider = Provider<AppIconService>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  return AppIconService(nativeBridge: bridge);
});

/// Family provider that loads and caches the icon bytes for a specific package name.
final appIconBytesProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) {
  final service = ref.watch(appIconServiceProvider);
  return service.getIcon(packageName);
});
