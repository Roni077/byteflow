/// Data access object for querying and persisting network usage snapshots.
library;

import 'package:drift/drift.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/database/tables/usage_snapshots.dart';

part 'usage_dao.g.dart';

/// Aggregated usage statistics container for arbitrary time windows.
class UsageAggregate {
  /// Downloaded / received volume in bytes.
  final int downloadBytes;

  /// Uploaded / transmitted volume in bytes.
  final int uploadBytes;

  /// Wi-Fi volume in bytes.
  final int wifiBytes;

  /// Mobile cellular volume in bytes.
  final int mobileBytes;

  /// Creates an immutable [UsageAggregate] summary.
  const UsageAggregate({
    required this.downloadBytes,
    required this.uploadBytes,
    required this.wifiBytes,
    required this.mobileBytes,
  });

  /// Zero baseline aggregate.
  const UsageAggregate.zero()
      : downloadBytes = 0,
        uploadBytes = 0,
        wifiBytes = 0,
        mobileBytes = 0;

  /// Combined total bytes (download + upload).
  int get totalBytes => downloadBytes + uploadBytes;
}

/// DAO managing time-series [UsageSnapshots] operations.
@DriftAccessor(tables: [UsageSnapshots])
class UsageDao extends DatabaseAccessor<AppDatabase> with _$UsageDaoMixin {
  /// Creates a [UsageDao] associated with the provided [db].
  UsageDao(super.db);

  /// Inserts a discrete usage snapshot.
  Future<int> insertSnapshot(UsageSnapshotsCompanion snapshot) {
    return into(usageSnapshots).insert(snapshot);
  }

  /// Inserts a batch of usage snapshots in a single database transaction.
  Future<void> insertBatch(List<UsageSnapshotsCompanion> snapshots) {
    return batch((b) {
      b.insertAll(usageSnapshots, snapshots);
    });
  }

  /// Retrieves all snapshots within the range `[start, end]`, ordered chronologically.
  Future<List<UsageSnapshot>> getSnapshotsBetween(DateTime start, DateTime end) {
    return (select(usageSnapshots)
          ..where(
            (tbl) =>
                tbl.timestamp.isBiggerOrEqualValue(start) &
                tbl.timestamp.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .get();
  }

  /// Streams snapshots within the range `[start, end]`, updating on any modification.
  Stream<List<UsageSnapshot>> watchSnapshotsBetween(
    DateTime start,
    DateTime end,
  ) {
    return (select(usageSnapshots)
          ..where(
            (tbl) =>
                tbl.timestamp.isBiggerOrEqualValue(start) &
                tbl.timestamp.isSmallerOrEqualValue(end),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .watch();
  }

  /// Calculates aggregated totals for the specified time range.
  Future<UsageAggregate> getAggregateBetween(DateTime start, DateTime end) async {
    final downloadSum = usageSnapshots.downloadBytes.sum();
    final uploadSum = usageSnapshots.uploadBytes.sum();
    final wifiSum = usageSnapshots.wifiBytes.sum();
    final mobileSum = usageSnapshots.mobileBytes.sum();

    final query = selectOnly(usageSnapshots)
      ..addColumns([downloadSum, uploadSum, wifiSum, mobileSum])
      ..where(
        usageSnapshots.timestamp.isBiggerOrEqualValue(start) &
            usageSnapshots.timestamp.isSmallerOrEqualValue(end),
      );

    final row = await query.getSingleOrNull();
    if (row == null) {
      return const UsageAggregate.zero();
    }

    return UsageAggregate(
      downloadBytes: row.read(downloadSum) ?? 0,
      uploadBytes: row.read(uploadSum) ?? 0,
      wifiBytes: row.read(wifiSum) ?? 0,
      mobileBytes: row.read(mobileSum) ?? 0,
    );
  }

  /// Deletes snapshots created prior to the [threshold] date to prune storage.
  Future<int> deleteOlderThan(DateTime threshold) {
    return (delete(usageSnapshots)
          ..where((tbl) => tbl.timestamp.isSmallerThanValue(threshold)))
        .go();
  }

  /// Deletes all recorded snapshots (for diagnostics / reset).
  Future<int> clearAllSnapshots() {
    return delete(usageSnapshots).go();
  }
}
