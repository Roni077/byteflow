/// Immutable model representing user preferences.
library;

import 'package:flutter/material.dart';
import 'package:byteflow/core/utils/formatters.dart';

/// Display style options for data usage summaries.
enum UsageDisplayStyle {
  /// Mobile cellular and Wi-Fi traffic breakdown (matching History screen).
  mobileAndWifi('Mobile & Wi-Fi'),

  /// Download and upload traffic breakdown.
  downloadAndUpload('Download & Upload'),

  /// Comprehensive breakdown showing both network types and directions.
  both('Both (All Metrics)');

  const UsageDisplayStyle(this.label);

  /// User-friendly display label.
  final String label;

  /// Parses a string into a [UsageDisplayStyle], defaulting to [UsageDisplayStyle.mobileAndWifi].
  static UsageDisplayStyle fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'downloadandupload' || 'download_and_upload' || 'rx_tx' =>
        UsageDisplayStyle.downloadAndUpload,
      'both' || 'all' || 'detailed' => UsageDisplayStyle.both,
      _ => UsageDisplayStyle.mobileAndWifi,
    };
  }
}

/// Immutable model holding persisted user configuration.
@immutable
class UserPreferences {
  /// Creates a [UserPreferences] instance.
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.speedUnit = SpeedUnit.auto,
    this.dataUnit = DataUnit.auto,
    this.usageDisplayStyle = UsageDisplayStyle.mobileAndWifi,
    this.pollingIntervalMs = 1000,
    this.showPersistentNotification = true,
  });

  /// The active display theme mode.
  final ThemeMode themeMode;

  /// Preferred unit for speed formatting.
  final SpeedUnit speedUnit;

  /// Preferred unit for cumulative data volume formatting.
  final DataUnit dataUnit;

  /// Preferred display style for dashboard data usage breakdown.
  final UsageDisplayStyle usageDisplayStyle;

  /// Real-time throughput polling interval in milliseconds.
  final int pollingIntervalMs;

  /// Whether the foreground service displays an ongoing notification.
  final bool showPersistentNotification;

  /// Creates a copy of this object with the given fields replaced.
  UserPreferences copyWith({
    ThemeMode? themeMode,
    SpeedUnit? speedUnit,
    DataUnit? dataUnit,
    UsageDisplayStyle? usageDisplayStyle,
    int? pollingIntervalMs,
    bool? showPersistentNotification,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      speedUnit: speedUnit ?? this.speedUnit,
      dataUnit: dataUnit ?? this.dataUnit,
      usageDisplayStyle: usageDisplayStyle ?? this.usageDisplayStyle,
      pollingIntervalMs: pollingIntervalMs ?? this.pollingIntervalMs,
      showPersistentNotification:
          showPersistentNotification ?? this.showPersistentNotification,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          speedUnit == other.speedUnit &&
          dataUnit == other.dataUnit &&
          usageDisplayStyle == other.usageDisplayStyle &&
          pollingIntervalMs == other.pollingIntervalMs &&
          showPersistentNotification == other.showPersistentNotification;

  @override
  int get hashCode => Object.hash(
        themeMode,
        speedUnit,
        dataUnit,
        usageDisplayStyle,
        pollingIntervalMs,
        showPersistentNotification,
      );
}
