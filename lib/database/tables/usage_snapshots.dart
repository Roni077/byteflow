/// Drift table definition for periodic traffic usage snapshots.
library;

import 'package:drift/drift.dart';

/// Table storing discrete periodic data transfer measurements.
///
/// Snapshots are batch-persisted periodically (every 15-30 minutes) or on app lifecycle pause,
/// storing cumulative byte transfer totals accumulated during that interval.
@TableIndex(name: 'usage_snapshots_timestamp_idx', columns: {#timestamp})
class UsageSnapshots extends Table {
  /// Unique auto-incrementing identifier.
  IntColumn get id => integer().autoIncrement()();

  /// The timestamp when the snapshot was finalized and written.
  DateTimeColumn get timestamp => dateTime()();

  /// Downloaded / received volume in bytes during this snapshot interval.
  IntColumn get downloadBytes => integer()();

  /// Uploaded / transmitted volume in bytes during this snapshot interval.
  IntColumn get uploadBytes => integer()();

  /// Wi-Fi transfer volume in bytes during this snapshot interval.
  IntColumn get wifiBytes => integer()();

  /// Mobile cellular transfer volume in bytes during this snapshot interval.
  IntColumn get mobileBytes => integer()();
}
