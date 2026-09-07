/// Central Drift database definition for ByteFlow.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:byteflow/database/daos/plans_dao.dart';
import 'package:byteflow/database/daos/settings_dao.dart';
import 'package:byteflow/database/daos/usage_dao.dart';
import 'package:byteflow/database/tables/data_plans_table.dart';
import 'package:byteflow/database/tables/usage_snapshots.dart';
import 'package:byteflow/database/tables/user_settings.dart';

part 'app_database.g.dart';

/// The central application database managing SQLite persistence.
@DriftDatabase(
  tables: [UsageSnapshots, DataPlans, UserSettings],
  daos: [UsageDao, DataPlansDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] using an optional [executor].
  ///
  /// Defaults to the persistent background SQLite database file.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'byteflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
