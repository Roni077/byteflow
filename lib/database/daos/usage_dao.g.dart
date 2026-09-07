// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_dao.dart';

// ignore_for_file: type=lint
mixin _$UsageDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsageSnapshotsTable get usageSnapshots => attachedDatabase.usageSnapshots;
  UsageDaoManager get managers => UsageDaoManager(this);
}

class UsageDaoManager {
  final _$UsageDaoMixin _db;
  UsageDaoManager(this._db);
  $$UsageSnapshotsTableTableManager get usageSnapshots =>
      $$UsageSnapshotsTableTableManager(
        _db.attachedDatabase,
        _db.usageSnapshots,
      );
}
