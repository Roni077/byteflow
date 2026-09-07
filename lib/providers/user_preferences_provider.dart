/// Riverpod provider managing persistent user settings and theme mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/user_preferences.dart';
import 'package:byteflow/providers/database_provider.dart';

/// Controller managing persistent user preferences using Drift SQLite.
class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  static const String _keyThemeMode = 'pref_theme_mode';
  static const String _keySpeedUnit = 'pref_speed_unit';
  static const String _keyDataUnit = 'pref_data_unit';
  static const String _keyUsageDisplayStyle = 'pref_usage_display_style';
  static const String _keyPollingInterval = 'pref_polling_interval_ms';
  static const String _keyPersistentNotif = 'pref_show_persistent_notif';

  @override
  Future<UserPreferences> build() async {
    return _loadPreferences();
  }

  Future<UserPreferences> _loadPreferences() async {
    final db = ref.watch(databaseProvider);
    final dao = db.settingsDao;

    final themeStr = await dao.getSetting(_keyThemeMode, defaultValue: 'system');
    final speedStr = await dao.getSetting(_keySpeedUnit, defaultValue: 'auto');
    final dataStr = await dao.getSetting(_keyDataUnit, defaultValue: 'auto');
    final usageStyleStr = await dao.getSetting(
      _keyUsageDisplayStyle,
      defaultValue: UsageDisplayStyle.mobileAndWifi.name,
    );
    final intervalStr = await dao.getSetting(_keyPollingInterval, defaultValue: '1000');
    final notifStr = await dao.getSetting(_keyPersistentNotif, defaultValue: 'true');

    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final speedUnit = SpeedUnit.fromString(speedStr);
    final dataUnit = DataUnit.fromString(dataStr);
    final usageDisplayStyle = UsageDisplayStyle.fromString(usageStyleStr);
    final pollingInterval = int.tryParse(intervalStr ?? '1000') ?? 1000;
    final showNotif = notifStr != 'false';

    return UserPreferences(
      themeMode: themeMode,
      speedUnit: speedUnit,
      dataUnit: dataUnit,
      usageDisplayStyle: usageDisplayStyle,
      pollingIntervalMs: pollingInterval,
      showPersistentNotification: showNotif,
    );
  }

  /// Sets the application theme mode and persists it to the database.
  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await dao.setSetting(_keyThemeMode, modeStr);
    state = AsyncValue.data(current.copyWith(themeMode: mode));
  }

  /// Sets the preferred speed unit and persists it to the database.
  Future<void> setSpeedUnit(SpeedUnit unit) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    await dao.setSetting(_keySpeedUnit, unit.name);
    state = AsyncValue.data(current.copyWith(speedUnit: unit));
  }

  /// Sets the preferred data volume unit and persists it to the database.
  Future<void> setDataUnit(DataUnit unit) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    await dao.setSetting(_keyDataUnit, unit.name);
    state = AsyncValue.data(current.copyWith(dataUnit: unit));
  }

  /// Sets the preferred usage display style and persists it to the database.
  Future<void> setUsageDisplayStyle(UsageDisplayStyle style) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    await dao.setSetting(_keyUsageDisplayStyle, style.name);
    state = AsyncValue.data(current.copyWith(usageDisplayStyle: style));
  }

  /// Sets the polling interval in milliseconds and persists it.
  Future<void> setPollingInterval(int intervalMs) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    await dao.setSetting(_keyPollingInterval, intervalMs.toString());
    state = AsyncValue.data(current.copyWith(pollingIntervalMs: intervalMs));
  }

  /// Toggles persistent speed notification visibility and persists it.
  Future<void> togglePersistentNotification(bool show) async {
    final current = state.value ?? const UserPreferences();
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;

    await dao.setSetting(_keyPersistentNotif, show.toString());
    state = AsyncValue.data(current.copyWith(showPersistentNotification: show));
  }
}

/// Exposes the active [UserPreferences] and configuration mutation methods.
final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);

/// Exposes the active [ThemeMode] for the root MaterialApp.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final prefsAsync = ref.watch(userPreferencesProvider);
  return prefsAsync.value?.themeMode ?? ThemeMode.system;
});
