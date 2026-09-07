/// Data access object for key-value settings storage.
library;

import 'package:drift/drift.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/database/tables/user_settings.dart';

part 'settings_dao.g.dart';

/// DAO managing [UserSettings] key-value operations.
@DriftAccessor(tables: [UserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  /// Creates a [SettingsDao] associated with the provided [db].
  SettingsDao(super.db);

  /// Retrieves the value for [key], or [defaultValue] if not found.
  Future<String?> getSetting(String key, {String? defaultValue}) async {
    final record = await (select(userSettings)..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return record?.value ?? defaultValue;
  }

  /// Sets or updates the preference [key] to [value].
  Future<void> setSetting(String key, String value) {
    return into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Streams the value of [key] as updates occur.
  Stream<String?> watchSetting(String key) {
    return (select(userSettings)..where((tbl) => tbl.key.equals(key)))
        .watchSingleOrNull()
        .map((record) => record?.value);
  }

  /// Retrieves all key-value entries as a [Map].
  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(userSettings).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Removes a setting by its [key].
  Future<int> removeSetting(String key) {
    return (delete(userSettings)..where((tbl) => tbl.key.equals(key))).go();
  }
}
