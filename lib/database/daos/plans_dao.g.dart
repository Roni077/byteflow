// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_dao.dart';

// ignore_for_file: type=lint
mixin _$DataPlansDaoMixin on DatabaseAccessor<AppDatabase> {
  $DataPlansTable get dataPlans => attachedDatabase.dataPlans;
  DataPlansDaoManager get managers => DataPlansDaoManager(this);
}

class DataPlansDaoManager {
  final _$DataPlansDaoMixin _db;
  DataPlansDaoManager(this._db);
  $$DataPlansTableTableManager get dataPlans =>
      $$DataPlansTableTableManager(_db.attachedDatabase, _db.dataPlans);
}
