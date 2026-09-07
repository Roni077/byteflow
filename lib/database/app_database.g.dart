// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsageSnapshotsTable extends UsageSnapshots
    with TableInfo<$UsageSnapshotsTable, UsageSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadBytesMeta = const VerificationMeta(
    'downloadBytes',
  );
  @override
  late final GeneratedColumn<int> downloadBytes = GeneratedColumn<int>(
    'download_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadBytesMeta = const VerificationMeta(
    'uploadBytes',
  );
  @override
  late final GeneratedColumn<int> uploadBytes = GeneratedColumn<int>(
    'upload_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wifiBytesMeta = const VerificationMeta(
    'wifiBytes',
  );
  @override
  late final GeneratedColumn<int> wifiBytes = GeneratedColumn<int>(
    'wifi_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileBytesMeta = const VerificationMeta(
    'mobileBytes',
  );
  @override
  late final GeneratedColumn<int> mobileBytes = GeneratedColumn<int>(
    'mobile_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    downloadBytes,
    uploadBytes,
    wifiBytes,
    mobileBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('download_bytes')) {
      context.handle(
        _downloadBytesMeta,
        downloadBytes.isAcceptableOrUnknown(
          data['download_bytes']!,
          _downloadBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadBytesMeta);
    }
    if (data.containsKey('upload_bytes')) {
      context.handle(
        _uploadBytesMeta,
        uploadBytes.isAcceptableOrUnknown(
          data['upload_bytes']!,
          _uploadBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uploadBytesMeta);
    }
    if (data.containsKey('wifi_bytes')) {
      context.handle(
        _wifiBytesMeta,
        wifiBytes.isAcceptableOrUnknown(data['wifi_bytes']!, _wifiBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_wifiBytesMeta);
    }
    if (data.containsKey('mobile_bytes')) {
      context.handle(
        _mobileBytesMeta,
        mobileBytes.isAcceptableOrUnknown(
          data['mobile_bytes']!,
          _mobileBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mobileBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      downloadBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_bytes'],
      )!,
      uploadBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}upload_bytes'],
      )!,
      wifiBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wifi_bytes'],
      )!,
      mobileBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mobile_bytes'],
      )!,
    );
  }

  @override
  $UsageSnapshotsTable createAlias(String alias) {
    return $UsageSnapshotsTable(attachedDatabase, alias);
  }
}

class UsageSnapshot extends DataClass implements Insertable<UsageSnapshot> {
  /// Unique auto-incrementing identifier.
  final int id;

  /// The timestamp when the snapshot was finalized and written.
  final DateTime timestamp;

  /// Downloaded / received volume in bytes during this snapshot interval.
  final int downloadBytes;

  /// Uploaded / transmitted volume in bytes during this snapshot interval.
  final int uploadBytes;

  /// Wi-Fi transfer volume in bytes during this snapshot interval.
  final int wifiBytes;

  /// Mobile cellular transfer volume in bytes during this snapshot interval.
  final int mobileBytes;
  const UsageSnapshot({
    required this.id,
    required this.timestamp,
    required this.downloadBytes,
    required this.uploadBytes,
    required this.wifiBytes,
    required this.mobileBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['download_bytes'] = Variable<int>(downloadBytes);
    map['upload_bytes'] = Variable<int>(uploadBytes);
    map['wifi_bytes'] = Variable<int>(wifiBytes);
    map['mobile_bytes'] = Variable<int>(mobileBytes);
    return map;
  }

  UsageSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return UsageSnapshotsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      downloadBytes: Value(downloadBytes),
      uploadBytes: Value(uploadBytes),
      wifiBytes: Value(wifiBytes),
      mobileBytes: Value(mobileBytes),
    );
  }

  factory UsageSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageSnapshot(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      downloadBytes: serializer.fromJson<int>(json['downloadBytes']),
      uploadBytes: serializer.fromJson<int>(json['uploadBytes']),
      wifiBytes: serializer.fromJson<int>(json['wifiBytes']),
      mobileBytes: serializer.fromJson<int>(json['mobileBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'downloadBytes': serializer.toJson<int>(downloadBytes),
      'uploadBytes': serializer.toJson<int>(uploadBytes),
      'wifiBytes': serializer.toJson<int>(wifiBytes),
      'mobileBytes': serializer.toJson<int>(mobileBytes),
    };
  }

  UsageSnapshot copyWith({
    int? id,
    DateTime? timestamp,
    int? downloadBytes,
    int? uploadBytes,
    int? wifiBytes,
    int? mobileBytes,
  }) => UsageSnapshot(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    downloadBytes: downloadBytes ?? this.downloadBytes,
    uploadBytes: uploadBytes ?? this.uploadBytes,
    wifiBytes: wifiBytes ?? this.wifiBytes,
    mobileBytes: mobileBytes ?? this.mobileBytes,
  );
  UsageSnapshot copyWithCompanion(UsageSnapshotsCompanion data) {
    return UsageSnapshot(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      downloadBytes: data.downloadBytes.present
          ? data.downloadBytes.value
          : this.downloadBytes,
      uploadBytes: data.uploadBytes.present
          ? data.uploadBytes.value
          : this.uploadBytes,
      wifiBytes: data.wifiBytes.present ? data.wifiBytes.value : this.wifiBytes,
      mobileBytes: data.mobileBytes.present
          ? data.mobileBytes.value
          : this.mobileBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageSnapshot(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('downloadBytes: $downloadBytes, ')
          ..write('uploadBytes: $uploadBytes, ')
          ..write('wifiBytes: $wifiBytes, ')
          ..write('mobileBytes: $mobileBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    downloadBytes,
    uploadBytes,
    wifiBytes,
    mobileBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageSnapshot &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.downloadBytes == this.downloadBytes &&
          other.uploadBytes == this.uploadBytes &&
          other.wifiBytes == this.wifiBytes &&
          other.mobileBytes == this.mobileBytes);
}

class UsageSnapshotsCompanion extends UpdateCompanion<UsageSnapshot> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<int> downloadBytes;
  final Value<int> uploadBytes;
  final Value<int> wifiBytes;
  final Value<int> mobileBytes;
  const UsageSnapshotsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.downloadBytes = const Value.absent(),
    this.uploadBytes = const Value.absent(),
    this.wifiBytes = const Value.absent(),
    this.mobileBytes = const Value.absent(),
  });
  UsageSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required int downloadBytes,
    required int uploadBytes,
    required int wifiBytes,
    required int mobileBytes,
  }) : timestamp = Value(timestamp),
       downloadBytes = Value(downloadBytes),
       uploadBytes = Value(uploadBytes),
       wifiBytes = Value(wifiBytes),
       mobileBytes = Value(mobileBytes);
  static Insertable<UsageSnapshot> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? downloadBytes,
    Expression<int>? uploadBytes,
    Expression<int>? wifiBytes,
    Expression<int>? mobileBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (downloadBytes != null) 'download_bytes': downloadBytes,
      if (uploadBytes != null) 'upload_bytes': uploadBytes,
      if (wifiBytes != null) 'wifi_bytes': wifiBytes,
      if (mobileBytes != null) 'mobile_bytes': mobileBytes,
    });
  }

  UsageSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<int>? downloadBytes,
    Value<int>? uploadBytes,
    Value<int>? wifiBytes,
    Value<int>? mobileBytes,
  }) {
    return UsageSnapshotsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      wifiBytes: wifiBytes ?? this.wifiBytes,
      mobileBytes: mobileBytes ?? this.mobileBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (downloadBytes.present) {
      map['download_bytes'] = Variable<int>(downloadBytes.value);
    }
    if (uploadBytes.present) {
      map['upload_bytes'] = Variable<int>(uploadBytes.value);
    }
    if (wifiBytes.present) {
      map['wifi_bytes'] = Variable<int>(wifiBytes.value);
    }
    if (mobileBytes.present) {
      map['mobile_bytes'] = Variable<int>(mobileBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('downloadBytes: $downloadBytes, ')
          ..write('uploadBytes: $uploadBytes, ')
          ..write('wifiBytes: $wifiBytes, ')
          ..write('mobileBytes: $mobileBytes')
          ..write(')'))
        .toString();
  }
}

class $DataPlansTable extends DataPlans
    with TableInfo<$DataPlansTable, DataPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitBytesMeta = const VerificationMeta(
    'limitBytes',
  );
  @override
  late final GeneratedColumn<int> limitBytes = GeneratedColumn<int>(
    'limit_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleStartDateMeta = const VerificationMeta(
    'cycleStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> cycleStartDate =
      GeneratedColumn<DateTime>(
        'cycle_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cycleTypeMeta = const VerificationMeta(
    'cycleType',
  );
  @override
  late final GeneratedColumn<String> cycleType = GeneratedColumn<String>(
    'cycle_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _simSlotMeta = const VerificationMeta(
    'simSlot',
  );
  @override
  late final GeneratedColumn<int> simSlot = GeneratedColumn<int>(
    'sim_slot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warningPercentMeta = const VerificationMeta(
    'warningPercent',
  );
  @override
  late final GeneratedColumn<int> warningPercent = GeneratedColumn<int>(
    'warning_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(80),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    limitBytes,
    cycleStartDate,
    cycleType,
    simSlot,
    warningPercent,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('limit_bytes')) {
      context.handle(
        _limitBytesMeta,
        limitBytes.isAcceptableOrUnknown(data['limit_bytes']!, _limitBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_limitBytesMeta);
    }
    if (data.containsKey('cycle_start_date')) {
      context.handle(
        _cycleStartDateMeta,
        cycleStartDate.isAcceptableOrUnknown(
          data['cycle_start_date']!,
          _cycleStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleStartDateMeta);
    }
    if (data.containsKey('cycle_type')) {
      context.handle(
        _cycleTypeMeta,
        cycleType.isAcceptableOrUnknown(data['cycle_type']!, _cycleTypeMeta),
      );
    }
    if (data.containsKey('sim_slot')) {
      context.handle(
        _simSlotMeta,
        simSlot.isAcceptableOrUnknown(data['sim_slot']!, _simSlotMeta),
      );
    }
    if (data.containsKey('warning_percent')) {
      context.handle(
        _warningPercentMeta,
        warningPercent.isAcceptableOrUnknown(
          data['warning_percent']!,
          _warningPercentMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      limitBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_bytes'],
      )!,
      cycleStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cycle_start_date'],
      )!,
      cycleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_type'],
      )!,
      simSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sim_slot'],
      ),
      warningPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_percent'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DataPlansTable createAlias(String alias) {
    return $DataPlansTable(attachedDatabase, alias);
  }
}

class DataPlan extends DataClass implements Insertable<DataPlan> {
  /// Unique plan identifier.
  final int id;

  /// User-assigned label for the plan (e.g., 'Primary SIM - 100GB').
  final String name;

  /// Total data quota limit in bytes.
  final int limitBytes;

  /// Start date and time of the current billing cycle.
  final DateTime cycleStartDate;

  /// Cycle recurrence type: 'daily', 'weekly', or 'monthly'.
  final String cycleType;

  /// Associated SIM slot index (0, 1) or null for all / generic plans.
  final int? simSlot;

  /// Warning threshold percentage (e.g. 80 for 80%).
  final int warningPercent;

  /// Whether this plan is actively tracked.
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;
  const DataPlan({
    required this.id,
    required this.name,
    required this.limitBytes,
    required this.cycleStartDate,
    required this.cycleType,
    this.simSlot,
    required this.warningPercent,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['limit_bytes'] = Variable<int>(limitBytes);
    map['cycle_start_date'] = Variable<DateTime>(cycleStartDate);
    map['cycle_type'] = Variable<String>(cycleType);
    if (!nullToAbsent || simSlot != null) {
      map['sim_slot'] = Variable<int>(simSlot);
    }
    map['warning_percent'] = Variable<int>(warningPercent);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DataPlansCompanion toCompanion(bool nullToAbsent) {
    return DataPlansCompanion(
      id: Value(id),
      name: Value(name),
      limitBytes: Value(limitBytes),
      cycleStartDate: Value(cycleStartDate),
      cycleType: Value(cycleType),
      simSlot: simSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(simSlot),
      warningPercent: Value(warningPercent),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory DataPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataPlan(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      limitBytes: serializer.fromJson<int>(json['limitBytes']),
      cycleStartDate: serializer.fromJson<DateTime>(json['cycleStartDate']),
      cycleType: serializer.fromJson<String>(json['cycleType']),
      simSlot: serializer.fromJson<int?>(json['simSlot']),
      warningPercent: serializer.fromJson<int>(json['warningPercent']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'limitBytes': serializer.toJson<int>(limitBytes),
      'cycleStartDate': serializer.toJson<DateTime>(cycleStartDate),
      'cycleType': serializer.toJson<String>(cycleType),
      'simSlot': serializer.toJson<int?>(simSlot),
      'warningPercent': serializer.toJson<int>(warningPercent),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DataPlan copyWith({
    int? id,
    String? name,
    int? limitBytes,
    DateTime? cycleStartDate,
    String? cycleType,
    Value<int?> simSlot = const Value.absent(),
    int? warningPercent,
    bool? isActive,
    DateTime? createdAt,
  }) => DataPlan(
    id: id ?? this.id,
    name: name ?? this.name,
    limitBytes: limitBytes ?? this.limitBytes,
    cycleStartDate: cycleStartDate ?? this.cycleStartDate,
    cycleType: cycleType ?? this.cycleType,
    simSlot: simSlot.present ? simSlot.value : this.simSlot,
    warningPercent: warningPercent ?? this.warningPercent,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  DataPlan copyWithCompanion(DataPlansCompanion data) {
    return DataPlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      limitBytes: data.limitBytes.present
          ? data.limitBytes.value
          : this.limitBytes,
      cycleStartDate: data.cycleStartDate.present
          ? data.cycleStartDate.value
          : this.cycleStartDate,
      cycleType: data.cycleType.present ? data.cycleType.value : this.cycleType,
      simSlot: data.simSlot.present ? data.simSlot.value : this.simSlot,
      warningPercent: data.warningPercent.present
          ? data.warningPercent.value
          : this.warningPercent,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataPlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('limitBytes: $limitBytes, ')
          ..write('cycleStartDate: $cycleStartDate, ')
          ..write('cycleType: $cycleType, ')
          ..write('simSlot: $simSlot, ')
          ..write('warningPercent: $warningPercent, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    limitBytes,
    cycleStartDate,
    cycleType,
    simSlot,
    warningPercent,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataPlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.limitBytes == this.limitBytes &&
          other.cycleStartDate == this.cycleStartDate &&
          other.cycleType == this.cycleType &&
          other.simSlot == this.simSlot &&
          other.warningPercent == this.warningPercent &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class DataPlansCompanion extends UpdateCompanion<DataPlan> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> limitBytes;
  final Value<DateTime> cycleStartDate;
  final Value<String> cycleType;
  final Value<int?> simSlot;
  final Value<int> warningPercent;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const DataPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.limitBytes = const Value.absent(),
    this.cycleStartDate = const Value.absent(),
    this.cycleType = const Value.absent(),
    this.simSlot = const Value.absent(),
    this.warningPercent = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DataPlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int limitBytes,
    required DateTime cycleStartDate,
    this.cycleType = const Value.absent(),
    this.simSlot = const Value.absent(),
    this.warningPercent = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       limitBytes = Value(limitBytes),
       cycleStartDate = Value(cycleStartDate);
  static Insertable<DataPlan> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? limitBytes,
    Expression<DateTime>? cycleStartDate,
    Expression<String>? cycleType,
    Expression<int>? simSlot,
    Expression<int>? warningPercent,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (limitBytes != null) 'limit_bytes': limitBytes,
      if (cycleStartDate != null) 'cycle_start_date': cycleStartDate,
      if (cycleType != null) 'cycle_type': cycleType,
      if (simSlot != null) 'sim_slot': simSlot,
      if (warningPercent != null) 'warning_percent': warningPercent,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DataPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? limitBytes,
    Value<DateTime>? cycleStartDate,
    Value<String>? cycleType,
    Value<int?>? simSlot,
    Value<int>? warningPercent,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return DataPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      limitBytes: limitBytes ?? this.limitBytes,
      cycleStartDate: cycleStartDate ?? this.cycleStartDate,
      cycleType: cycleType ?? this.cycleType,
      simSlot: simSlot ?? this.simSlot,
      warningPercent: warningPercent ?? this.warningPercent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (limitBytes.present) {
      map['limit_bytes'] = Variable<int>(limitBytes.value);
    }
    if (cycleStartDate.present) {
      map['cycle_start_date'] = Variable<DateTime>(cycleStartDate.value);
    }
    if (cycleType.present) {
      map['cycle_type'] = Variable<String>(cycleType.value);
    }
    if (simSlot.present) {
      map['sim_slot'] = Variable<int>(simSlot.value);
    }
    if (warningPercent.present) {
      map['warning_percent'] = Variable<int>(warningPercent.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('limitBytes: $limitBytes, ')
          ..write('cycleStartDate: $cycleStartDate, ')
          ..write('cycleType: $cycleType, ')
          ..write('simSlot: $simSlot, ')
          ..write('warningPercent: $warningPercent, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  /// Preference key name (unique primary key).
  final String key;

  /// Preference value serialized as a string.
  final String value;

  /// Timestamp when the setting was last updated.
  final DateTime updatedAt;
  const UserSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      UserSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsageSnapshotsTable usageSnapshots = $UsageSnapshotsTable(this);
  late final $DataPlansTable dataPlans = $DataPlansTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final Index usageSnapshotsTimestampIdx = Index(
    'usage_snapshots_timestamp_idx',
    'CREATE INDEX usage_snapshots_timestamp_idx ON usage_snapshots (timestamp)',
  );
  late final UsageDao usageDao = UsageDao(this as AppDatabase);
  late final DataPlansDao dataPlansDao = DataPlansDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usageSnapshots,
    dataPlans,
    userSettings,
    usageSnapshotsTimestampIdx,
  ];
}

typedef $$UsageSnapshotsTableCreateCompanionBuilder =
    UsageSnapshotsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required int downloadBytes,
      required int uploadBytes,
      required int wifiBytes,
      required int mobileBytes,
    });
typedef $$UsageSnapshotsTableUpdateCompanionBuilder =
    UsageSnapshotsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<int> downloadBytes,
      Value<int> uploadBytes,
      Value<int> wifiBytes,
      Value<int> mobileBytes,
    });

class $$UsageSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageSnapshotsTable> {
  $$UsageSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadBytes => $composableBuilder(
    column: $table.downloadBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadBytes => $composableBuilder(
    column: $table.uploadBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wifiBytes => $composableBuilder(
    column: $table.wifiBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mobileBytes => $composableBuilder(
    column: $table.mobileBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageSnapshotsTable> {
  $$UsageSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadBytes => $composableBuilder(
    column: $table.downloadBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadBytes => $composableBuilder(
    column: $table.uploadBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wifiBytes => $composableBuilder(
    column: $table.wifiBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mobileBytes => $composableBuilder(
    column: $table.mobileBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageSnapshotsTable> {
  $$UsageSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get downloadBytes => $composableBuilder(
    column: $table.downloadBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uploadBytes => $composableBuilder(
    column: $table.uploadBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wifiBytes =>
      $composableBuilder(column: $table.wifiBytes, builder: (column) => column);

  GeneratedColumn<int> get mobileBytes => $composableBuilder(
    column: $table.mobileBytes,
    builder: (column) => column,
  );
}

class $$UsageSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageSnapshotsTable,
          UsageSnapshot,
          $$UsageSnapshotsTableFilterComposer,
          $$UsageSnapshotsTableOrderingComposer,
          $$UsageSnapshotsTableAnnotationComposer,
          $$UsageSnapshotsTableCreateCompanionBuilder,
          $$UsageSnapshotsTableUpdateCompanionBuilder,
          (
            UsageSnapshot,
            BaseReferences<_$AppDatabase, $UsageSnapshotsTable, UsageSnapshot>,
          ),
          UsageSnapshot,
          PrefetchHooks Function()
        > {
  $$UsageSnapshotsTableTableManager(
    _$AppDatabase db,
    $UsageSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> downloadBytes = const Value.absent(),
                Value<int> uploadBytes = const Value.absent(),
                Value<int> wifiBytes = const Value.absent(),
                Value<int> mobileBytes = const Value.absent(),
              }) => UsageSnapshotsCompanion(
                id: id,
                timestamp: timestamp,
                downloadBytes: downloadBytes,
                uploadBytes: uploadBytes,
                wifiBytes: wifiBytes,
                mobileBytes: mobileBytes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required int downloadBytes,
                required int uploadBytes,
                required int wifiBytes,
                required int mobileBytes,
              }) => UsageSnapshotsCompanion.insert(
                id: id,
                timestamp: timestamp,
                downloadBytes: downloadBytes,
                uploadBytes: uploadBytes,
                wifiBytes: wifiBytes,
                mobileBytes: mobileBytes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsageSnapshotsTable, UsageSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UsageSnapshotsTable,
                    UsageSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageSnapshotsTable,
      UsageSnapshot,
      $$UsageSnapshotsTableFilterComposer,
      $$UsageSnapshotsTableOrderingComposer,
      $$UsageSnapshotsTableAnnotationComposer,
      $$UsageSnapshotsTableCreateCompanionBuilder,
      $$UsageSnapshotsTableUpdateCompanionBuilder,
      (
        UsageSnapshot,
        BaseReferences<_$AppDatabase, $UsageSnapshotsTable, UsageSnapshot>,
      ),
      UsageSnapshot,
      PrefetchHooks Function()
    >;
typedef $$DataPlansTableCreateCompanionBuilder =
    DataPlansCompanion Function({
      Value<int> id,
      required String name,
      required int limitBytes,
      required DateTime cycleStartDate,
      Value<String> cycleType,
      Value<int?> simSlot,
      Value<int> warningPercent,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$DataPlansTableUpdateCompanionBuilder =
    DataPlansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> limitBytes,
      Value<DateTime> cycleStartDate,
      Value<String> cycleType,
      Value<int?> simSlot,
      Value<int> warningPercent,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$DataPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DataPlansTable> {
  $$DataPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitBytes => $composableBuilder(
    column: $table.limitBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cycleStartDate => $composableBuilder(
    column: $table.cycleStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleType => $composableBuilder(
    column: $table.cycleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get simSlot => $composableBuilder(
    column: $table.simSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DataPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DataPlansTable> {
  $$DataPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitBytes => $composableBuilder(
    column: $table.limitBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cycleStartDate => $composableBuilder(
    column: $table.cycleStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleType => $composableBuilder(
    column: $table.cycleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get simSlot => $composableBuilder(
    column: $table.simSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DataPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataPlansTable> {
  $$DataPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get limitBytes => $composableBuilder(
    column: $table.limitBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cycleStartDate => $composableBuilder(
    column: $table.cycleStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycleType =>
      $composableBuilder(column: $table.cycleType, builder: (column) => column);

  GeneratedColumn<int> get simSlot =>
      $composableBuilder(column: $table.simSlot, builder: (column) => column);

  GeneratedColumn<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DataPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DataPlansTable,
          DataPlan,
          $$DataPlansTableFilterComposer,
          $$DataPlansTableOrderingComposer,
          $$DataPlansTableAnnotationComposer,
          $$DataPlansTableCreateCompanionBuilder,
          $$DataPlansTableUpdateCompanionBuilder,
          (DataPlan, BaseReferences<_$AppDatabase, $DataPlansTable, DataPlan>),
          DataPlan,
          PrefetchHooks Function()
        > {
  $$DataPlansTableTableManager(_$AppDatabase db, $DataPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> limitBytes = const Value.absent(),
                Value<DateTime> cycleStartDate = const Value.absent(),
                Value<String> cycleType = const Value.absent(),
                Value<int?> simSlot = const Value.absent(),
                Value<int> warningPercent = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DataPlansCompanion(
                id: id,
                name: name,
                limitBytes: limitBytes,
                cycleStartDate: cycleStartDate,
                cycleType: cycleType,
                simSlot: simSlot,
                warningPercent: warningPercent,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int limitBytes,
                required DateTime cycleStartDate,
                Value<String> cycleType = const Value.absent(),
                Value<int?> simSlot = const Value.absent(),
                Value<int> warningPercent = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DataPlansCompanion.insert(
                id: id,
                name: name,
                limitBytes: limitBytes,
                cycleStartDate: cycleStartDate,
                cycleType: cycleType,
                simSlot: simSlot,
                warningPercent: warningPercent,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DataPlansTable, DataPlan>(table),
                  BaseReferences<_$AppDatabase, $DataPlansTable, DataPlan>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DataPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DataPlansTable,
      DataPlan,
      $$DataPlansTableFilterComposer,
      $$DataPlansTableOrderingComposer,
      $$DataPlansTableAnnotationComposer,
      $$DataPlansTableCreateCompanionBuilder,
      $$DataPlansTableUpdateCompanionBuilder,
      (DataPlan, BaseReferences<_$AppDatabase, $DataPlansTable, DataPlan>),
      DataPlan,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTable, UserSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsTable,
                    UserSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsageSnapshotsTableTableManager get usageSnapshots =>
      $$UsageSnapshotsTableTableManager(_db, _db.usageSnapshots);
  $$DataPlansTableTableManager get dataPlans =>
      $$DataPlansTableTableManager(_db, _db.dataPlans);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}
