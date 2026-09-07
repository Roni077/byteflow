/// Drift table definition for key-value user preferences.
library;

import 'package:drift/drift.dart';

/// Table storing key-value pairs for persistent application preferences.
class UserSettings extends Table {
  /// Preference key name (unique primary key).
  TextColumn get key => text()();

  /// Preference value serialized as a string.
  TextColumn get value => text()();

  /// Timestamp when the setting was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
