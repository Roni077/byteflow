/// Configuration model for Android background network speed monitoring.
library;

/// Immutable configuration holding settings and status for [NetworkSpeedService].
class ForegroundServiceConfig {
  /// Creates a [ForegroundServiceConfig] instance.
  const ForegroundServiceConfig({
    this.isServiceRunning = false,
    this.showStatusBarSpeed = true,
    this.speedDisplayMode = 'combined',
    this.startOnBoot = false,
    this.pollingIntervalMs = 1000,
    this.showPersistentNotification = true,
  });

  /// Whether the background foreground monitoring service is currently active.
  final bool isServiceRunning;

  /// Whether the dynamic status bar speed icon is rendered.
  final bool showStatusBarSpeed;

  /// Mode of speed displayed: `'combined'`, `'download'`, or `'upload'`.
  final String speedDisplayMode;

  /// Whether the service automatically starts after device reboot.
  final bool startOnBoot;

  /// Polling interval for background speed sampling in milliseconds.
  final int pollingIntervalMs;

  /// Whether the persistent notification is shown in the notification tray.
  final bool showPersistentNotification;

  /// Creates a copy of this config with the given fields replaced.
  ForegroundServiceConfig copyWith({
    bool? isServiceRunning,
    bool? showStatusBarSpeed,
    String? speedDisplayMode,
    bool? startOnBoot,
    int? pollingIntervalMs,
    bool? showPersistentNotification,
  }) {
    return ForegroundServiceConfig(
      isServiceRunning: isServiceRunning ?? this.isServiceRunning,
      showStatusBarSpeed: showStatusBarSpeed ?? this.showStatusBarSpeed,
      speedDisplayMode: speedDisplayMode ?? this.speedDisplayMode,
      startOnBoot: startOnBoot ?? this.startOnBoot,
      pollingIntervalMs: pollingIntervalMs ?? this.pollingIntervalMs,
      showPersistentNotification:
          showPersistentNotification ?? this.showPersistentNotification,
    );
  }

  /// Creates a [ForegroundServiceConfig] from a map received from platform channel.
  factory ForegroundServiceConfig.fromMap(Map<dynamic, dynamic> map) {
    return ForegroundServiceConfig(
      isServiceRunning: map['isRunning'] as bool? ?? false,
      showStatusBarSpeed: map['showStatusBarSpeed'] as bool? ?? true,
      speedDisplayMode: map['speedDisplayMode'] as String? ?? 'combined',
      startOnBoot: map['startOnBoot'] as bool? ?? false,
      pollingIntervalMs: (map['pollingIntervalMs'] as num?)?.toInt() ?? 1000,
      showPersistentNotification:
          map['showPersistentNotification'] as bool? ?? true,
    );
  }

  /// Converts this configuration to a platform-serializable map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isRunning': isServiceRunning,
      'showStatusBarSpeed': showStatusBarSpeed,
      'speedDisplayMode': speedDisplayMode,
      'startOnBoot': startOnBoot,
      'pollingIntervalMs': pollingIntervalMs,
      'showPersistentNotification': showPersistentNotification,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForegroundServiceConfig &&
        other.isServiceRunning == isServiceRunning &&
        other.showStatusBarSpeed == showStatusBarSpeed &&
        other.speedDisplayMode == speedDisplayMode &&
        other.startOnBoot == startOnBoot &&
        other.pollingIntervalMs == pollingIntervalMs &&
        other.showPersistentNotification == showPersistentNotification;
  }

  @override
  int get hashCode => Object.hash(
        isServiceRunning,
        showStatusBarSpeed,
        speedDisplayMode,
        startOnBoot,
        pollingIntervalMs,
        showPersistentNotification,
      );
}
