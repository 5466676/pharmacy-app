// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isThisDeviceMeta = const VerificationMeta('isThisDevice');
  @override
  late final GeneratedColumn<bool> isThisDevice = GeneratedColumn<bool>(
    'is_this_device',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_this_device" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isThisDevice, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_this_device')) {
      context.handle(
        _isThisDeviceMeta,
        isThisDevice.isAcceptableOrUnknown(data['is_this_device']!, _isThisDeviceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isThisDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_this_device'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final String id;
  final String name;
  final bool isThisDevice;
  final DateTime createdAt;
  const DeviceRow({
    required this.id,
    required this.name,
    required this.isThisDevice,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_this_device'] = Variable<bool>(isThisDevice);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      isThisDevice: Value(isThisDevice),
      createdAt: Value(createdAt),
    );
  }

  factory DeviceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isThisDevice: serializer.fromJson<bool>(json['isThisDevice']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isThisDevice': serializer.toJson<bool>(isThisDevice),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DeviceRow copyWith({String? id, String? name, bool? isThisDevice, DateTime? createdAt}) =>
      DeviceRow(
        id: id ?? this.id,
        name: name ?? this.name,
        isThisDevice: isThisDevice ?? this.isThisDevice,
        createdAt: createdAt ?? this.createdAt,
      );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isThisDevice: data.isThisDevice.present ? data.isThisDevice.value : this.isThisDevice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isThisDevice: $isThisDevice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isThisDevice, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isThisDevice == this.isThisDevice &&
          other.createdAt == this.createdAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isThisDevice;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isThisDevice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    this.isThisDevice = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<DeviceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isThisDevice,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isThisDevice != null) 'is_this_device': isThisDevice,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isThisDevice,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isThisDevice: isThisDevice ?? this.isThisDevice,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isThisDevice.present) {
      map['is_this_device'] = Variable<bool>(isThisDevice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isThisDevice: $isThisDevice, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees with TableInfo<$EmployeesTable, EmployeeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta('pinSalt');
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, role, pinHash, pinSalt, active, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta, pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('pin_salt')) {
      context.handle(_pinSaltMeta, pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta));
    } else if (isInserting) {
      context.missing(_pinSaltMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta, active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class EmployeeRow extends DataClass implements Insertable<EmployeeRow> {
  final String id;
  final String name;

  /// `owner` or `employee`.
  final String role;
  final String pinHash;
  final String pinSalt;
  final bool active;
  final DateTime updatedAt;
  const EmployeeRow({
    required this.id,
    required this.name,
    required this.role,
    required this.pinHash,
    required this.pinSalt,
    required this.active,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['pin_hash'] = Variable<String>(pinHash);
    map['pin_salt'] = Variable<String>(pinSalt);
    map['active'] = Variable<bool>(active);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      pinHash: Value(pinHash),
      pinSalt: Value(pinSalt),
      active: Value(active),
      updatedAt: Value(updatedAt),
    );
  }

  factory EmployeeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      pinSalt: serializer.fromJson<String>(json['pinSalt']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'pinHash': serializer.toJson<String>(pinHash),
      'pinSalt': serializer.toJson<String>(pinSalt),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EmployeeRow copyWith({
    String? id,
    String? name,
    String? role,
    String? pinHash,
    String? pinSalt,
    bool? active,
    DateTime? updatedAt,
  }) => EmployeeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    pinHash: pinHash ?? this.pinHash,
    pinSalt: pinSalt ?? this.pinSalt,
    active: active ?? this.active,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EmployeeRow copyWithCompanion(EmployeesCompanion data) {
    return EmployeeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, role, pinHash, pinSalt, active, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt);
}

class EmployeesCompanion extends UpdateCompanion<EmployeeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> role;
  final Value<String> pinHash;
  final Value<String> pinSalt;
  final Value<bool> active;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String id,
    required String name,
    required String role,
    required String pinHash,
    required String pinSalt,
    this.active = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       role = Value(role),
       pinHash = Value(pinHash),
       pinSalt = Value(pinSalt),
       updatedAt = Value(updatedAt);
  static Insertable<EmployeeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<bool>? active,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? role,
    Value<String>? pinHash,
    Value<String>? pinSalt,
    Value<bool>? active,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
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
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeNameMeta = const VerificationMeta('tradeName');
  @override
  late final GeneratedColumn<String> tradeName = GeneratedColumn<String>(
    'trade_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicNameMeta = const VerificationMeta('arabicName');
  @override
  late final GeneratedColumn<String> arabicName = GeneratedColumn<String>(
    'arabic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeIngredientMeta = const VerificationMeta('activeIngredient');
  @override
  late final GeneratedColumn<String> activeIngredient = GeneratedColumn<String>(
    'active_ingredient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta('strength');
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfMeta = const VerificationMeta('shelf');
  @override
  late final GeneratedColumn<String> shelf = GeneratedColumn<String>(
    'shelf',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta('priceMinor');
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prescriptionOnlyMeta = const VerificationMeta('prescriptionOnly');
  @override
  late final GeneratedColumn<bool> prescriptionOnly = GeneratedColumn<bool>(
    'prescription_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("prescription_only" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
    'low_stock_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _unitsPerPackMeta = const VerificationMeta('unitsPerPack');
  @override
  late final GeneratedColumn<int> unitsPerPack = GeneratedColumn<int>(
    'units_per_pack',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _stripPriceMinorMeta = const VerificationMeta('stripPriceMinor');
  @override
  late final GeneratedColumn<int> stripPriceMinor = GeneratedColumn<int>(
    'strip_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta('updatedByDevice');
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tradeName,
    arabicName,
    activeIngredient,
    strength,
    form,
    manufacturer,
    shelf,
    priceMinor,
    prescriptionOnly,
    lowStockThreshold,
    unitsPerPack,
    stripPriceMinor,
    active,
    createdAt,
    updatedAt,
    updatedByDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trade_name')) {
      context.handle(
        _tradeNameMeta,
        tradeName.isAcceptableOrUnknown(data['trade_name']!, _tradeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeNameMeta);
    }
    if (data.containsKey('arabic_name')) {
      context.handle(
        _arabicNameMeta,
        arabicName.isAcceptableOrUnknown(data['arabic_name']!, _arabicNameMeta),
      );
    }
    if (data.containsKey('active_ingredient')) {
      context.handle(
        _activeIngredientMeta,
        activeIngredient.isAcceptableOrUnknown(data['active_ingredient']!, _activeIngredientMeta),
      );
    } else if (isInserting) {
      context.missing(_activeIngredientMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('form')) {
      context.handle(_formMeta, form.isAcceptableOrUnknown(data['form']!, _formMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(data['manufacturer']!, _manufacturerMeta),
      );
    }
    if (data.containsKey('shelf')) {
      context.handle(_shelfMeta, shelf.isAcceptableOrUnknown(data['shelf']!, _shelfMeta));
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMinorMeta);
    }
    if (data.containsKey('prescription_only')) {
      context.handle(
        _prescriptionOnlyMeta,
        prescriptionOnly.isAcceptableOrUnknown(data['prescription_only']!, _prescriptionOnlyMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('units_per_pack')) {
      context.handle(
        _unitsPerPackMeta,
        unitsPerPack.isAcceptableOrUnknown(data['units_per_pack']!, _unitsPerPackMeta),
      );
    }
    if (data.containsKey('strip_price_minor')) {
      context.handle(
        _stripPriceMinorMeta,
        stripPriceMinor.isAcceptableOrUnknown(data['strip_price_minor']!, _stripPriceMinorMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta, active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(data['updated_by_device']!, _updatedByDeviceMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tradeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_name'],
      )!,
      arabicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_name'],
      ),
      activeIngredient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_ingredient'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      form: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}form']),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      shelf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf'],
      ),
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      prescriptionOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prescription_only'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold'],
      )!,
      unitsPerPack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_pack'],
      )!,
      stripPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strip_price_minor'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;

  /// Latin brand/trade name, e.g. "Amoxil 500 mg".
  final String tradeName;
  final String? arabicName;

  /// Used to suggest alternatives when out of stock.
  final String activeIngredient;
  final String? strength;
  final String? form;
  final String? manufacturer;
  final String? shelf;
  final int priceMinor;
  final bool prescriptionOnly;
  final int lowStockThreshold;

  /// Strips per box. 1 = sold as whole boxes only. Stock is counted in strips.
  final int unitsPerPack;

  /// Price of one strip when [unitsPerPack] > 1.
  final int? stripPriceMinor;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedByDevice;
  const ProductRow({
    required this.id,
    required this.tradeName,
    this.arabicName,
    required this.activeIngredient,
    this.strength,
    this.form,
    this.manufacturer,
    this.shelf,
    required this.priceMinor,
    required this.prescriptionOnly,
    required this.lowStockThreshold,
    required this.unitsPerPack,
    this.stripPriceMinor,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedByDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trade_name'] = Variable<String>(tradeName);
    if (!nullToAbsent || arabicName != null) {
      map['arabic_name'] = Variable<String>(arabicName);
    }
    map['active_ingredient'] = Variable<String>(activeIngredient);
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || form != null) {
      map['form'] = Variable<String>(form);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || shelf != null) {
      map['shelf'] = Variable<String>(shelf);
    }
    map['price_minor'] = Variable<int>(priceMinor);
    map['prescription_only'] = Variable<bool>(prescriptionOnly);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['units_per_pack'] = Variable<int>(unitsPerPack);
    if (!nullToAbsent || stripPriceMinor != null) {
      map['strip_price_minor'] = Variable<int>(stripPriceMinor);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['updated_by_device'] = Variable<String>(updatedByDevice);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      tradeName: Value(tradeName),
      arabicName: arabicName == null && nullToAbsent ? const Value.absent() : Value(arabicName),
      activeIngredient: Value(activeIngredient),
      strength: strength == null && nullToAbsent ? const Value.absent() : Value(strength),
      form: form == null && nullToAbsent ? const Value.absent() : Value(form),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      shelf: shelf == null && nullToAbsent ? const Value.absent() : Value(shelf),
      priceMinor: Value(priceMinor),
      prescriptionOnly: Value(prescriptionOnly),
      lowStockThreshold: Value(lowStockThreshold),
      unitsPerPack: Value(unitsPerPack),
      stripPriceMinor: stripPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(stripPriceMinor),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      updatedByDevice: Value(updatedByDevice),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      tradeName: serializer.fromJson<String>(json['tradeName']),
      arabicName: serializer.fromJson<String?>(json['arabicName']),
      activeIngredient: serializer.fromJson<String>(json['activeIngredient']),
      strength: serializer.fromJson<String?>(json['strength']),
      form: serializer.fromJson<String?>(json['form']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      shelf: serializer.fromJson<String?>(json['shelf']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      prescriptionOnly: serializer.fromJson<bool>(json['prescriptionOnly']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      unitsPerPack: serializer.fromJson<int>(json['unitsPerPack']),
      stripPriceMinor: serializer.fromJson<int?>(json['stripPriceMinor']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedByDevice: serializer.fromJson<String>(json['updatedByDevice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tradeName': serializer.toJson<String>(tradeName),
      'arabicName': serializer.toJson<String?>(arabicName),
      'activeIngredient': serializer.toJson<String>(activeIngredient),
      'strength': serializer.toJson<String?>(strength),
      'form': serializer.toJson<String?>(form),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'shelf': serializer.toJson<String?>(shelf),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'prescriptionOnly': serializer.toJson<bool>(prescriptionOnly),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'unitsPerPack': serializer.toJson<int>(unitsPerPack),
      'stripPriceMinor': serializer.toJson<int?>(stripPriceMinor),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedByDevice': serializer.toJson<String>(updatedByDevice),
    };
  }

  ProductRow copyWith({
    String? id,
    String? tradeName,
    Value<String?> arabicName = const Value.absent(),
    String? activeIngredient,
    Value<String?> strength = const Value.absent(),
    Value<String?> form = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> shelf = const Value.absent(),
    int? priceMinor,
    bool? prescriptionOnly,
    int? lowStockThreshold,
    int? unitsPerPack,
    Value<int?> stripPriceMinor = const Value.absent(),
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedByDevice,
  }) => ProductRow(
    id: id ?? this.id,
    tradeName: tradeName ?? this.tradeName,
    arabicName: arabicName.present ? arabicName.value : this.arabicName,
    activeIngredient: activeIngredient ?? this.activeIngredient,
    strength: strength.present ? strength.value : this.strength,
    form: form.present ? form.value : this.form,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    shelf: shelf.present ? shelf.value : this.shelf,
    priceMinor: priceMinor ?? this.priceMinor,
    prescriptionOnly: prescriptionOnly ?? this.prescriptionOnly,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    unitsPerPack: unitsPerPack ?? this.unitsPerPack,
    stripPriceMinor: stripPriceMinor.present ? stripPriceMinor.value : this.stripPriceMinor,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedByDevice: updatedByDevice ?? this.updatedByDevice,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      tradeName: data.tradeName.present ? data.tradeName.value : this.tradeName,
      arabicName: data.arabicName.present ? data.arabicName.value : this.arabicName,
      activeIngredient: data.activeIngredient.present
          ? data.activeIngredient.value
          : this.activeIngredient,
      strength: data.strength.present ? data.strength.value : this.strength,
      form: data.form.present ? data.form.value : this.form,
      manufacturer: data.manufacturer.present ? data.manufacturer.value : this.manufacturer,
      shelf: data.shelf.present ? data.shelf.value : this.shelf,
      priceMinor: data.priceMinor.present ? data.priceMinor.value : this.priceMinor,
      prescriptionOnly: data.prescriptionOnly.present
          ? data.prescriptionOnly.value
          : this.prescriptionOnly,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      unitsPerPack: data.unitsPerPack.present ? data.unitsPerPack.value : this.unitsPerPack,
      stripPriceMinor: data.stripPriceMinor.present
          ? data.stripPriceMinor.value
          : this.stripPriceMinor,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('tradeName: $tradeName, ')
          ..write('arabicName: $arabicName, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('strength: $strength, ')
          ..write('form: $form, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('shelf: $shelf, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('prescriptionOnly: $prescriptionOnly, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('stripPriceMinor: $stripPriceMinor, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByDevice: $updatedByDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tradeName,
    arabicName,
    activeIngredient,
    strength,
    form,
    manufacturer,
    shelf,
    priceMinor,
    prescriptionOnly,
    lowStockThreshold,
    unitsPerPack,
    stripPriceMinor,
    active,
    createdAt,
    updatedAt,
    updatedByDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.tradeName == this.tradeName &&
          other.arabicName == this.arabicName &&
          other.activeIngredient == this.activeIngredient &&
          other.strength == this.strength &&
          other.form == this.form &&
          other.manufacturer == this.manufacturer &&
          other.shelf == this.shelf &&
          other.priceMinor == this.priceMinor &&
          other.prescriptionOnly == this.prescriptionOnly &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.unitsPerPack == this.unitsPerPack &&
          other.stripPriceMinor == this.stripPriceMinor &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.updatedByDevice == this.updatedByDevice);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> tradeName;
  final Value<String?> arabicName;
  final Value<String> activeIngredient;
  final Value<String?> strength;
  final Value<String?> form;
  final Value<String?> manufacturer;
  final Value<String?> shelf;
  final Value<int> priceMinor;
  final Value<bool> prescriptionOnly;
  final Value<int> lowStockThreshold;
  final Value<int> unitsPerPack;
  final Value<int?> stripPriceMinor;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> updatedByDevice;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.tradeName = const Value.absent(),
    this.arabicName = const Value.absent(),
    this.activeIngredient = const Value.absent(),
    this.strength = const Value.absent(),
    this.form = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.shelf = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.prescriptionOnly = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.unitsPerPack = const Value.absent(),
    this.stripPriceMinor = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String tradeName,
    this.arabicName = const Value.absent(),
    required String activeIngredient,
    this.strength = const Value.absent(),
    this.form = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.shelf = const Value.absent(),
    required int priceMinor,
    this.prescriptionOnly = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.unitsPerPack = const Value.absent(),
    this.stripPriceMinor = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required String updatedByDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tradeName = Value(tradeName),
       activeIngredient = Value(activeIngredient),
       priceMinor = Value(priceMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       updatedByDevice = Value(updatedByDevice);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? tradeName,
    Expression<String>? arabicName,
    Expression<String>? activeIngredient,
    Expression<String>? strength,
    Expression<String>? form,
    Expression<String>? manufacturer,
    Expression<String>? shelf,
    Expression<int>? priceMinor,
    Expression<bool>? prescriptionOnly,
    Expression<int>? lowStockThreshold,
    Expression<int>? unitsPerPack,
    Expression<int>? stripPriceMinor,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedByDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tradeName != null) 'trade_name': tradeName,
      if (arabicName != null) 'arabic_name': arabicName,
      if (activeIngredient != null) 'active_ingredient': activeIngredient,
      if (strength != null) 'strength': strength,
      if (form != null) 'form': form,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (shelf != null) 'shelf': shelf,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (prescriptionOnly != null) 'prescription_only': prescriptionOnly,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (unitsPerPack != null) 'units_per_pack': unitsPerPack,
      if (stripPriceMinor != null) 'strip_price_minor': stripPriceMinor,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? tradeName,
    Value<String?>? arabicName,
    Value<String>? activeIngredient,
    Value<String?>? strength,
    Value<String?>? form,
    Value<String?>? manufacturer,
    Value<String?>? shelf,
    Value<int>? priceMinor,
    Value<bool>? prescriptionOnly,
    Value<int>? lowStockThreshold,
    Value<int>? unitsPerPack,
    Value<int?>? stripPriceMinor,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? updatedByDevice,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      tradeName: tradeName ?? this.tradeName,
      arabicName: arabicName ?? this.arabicName,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      manufacturer: manufacturer ?? this.manufacturer,
      shelf: shelf ?? this.shelf,
      priceMinor: priceMinor ?? this.priceMinor,
      prescriptionOnly: prescriptionOnly ?? this.prescriptionOnly,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
      stripPriceMinor: stripPriceMinor ?? this.stripPriceMinor,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tradeName.present) {
      map['trade_name'] = Variable<String>(tradeName.value);
    }
    if (arabicName.present) {
      map['arabic_name'] = Variable<String>(arabicName.value);
    }
    if (activeIngredient.present) {
      map['active_ingredient'] = Variable<String>(activeIngredient.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (shelf.present) {
      map['shelf'] = Variable<String>(shelf.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (prescriptionOnly.present) {
      map['prescription_only'] = Variable<bool>(prescriptionOnly.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (unitsPerPack.present) {
      map['units_per_pack'] = Variable<int>(unitsPerPack.value);
    }
    if (stripPriceMinor.present) {
      map['strip_price_minor'] = Variable<int>(stripPriceMinor.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('tradeName: $tradeName, ')
          ..write('arabicName: $arabicName, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('strength: $strength, ')
          ..write('form: $form, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('shelf: $shelf, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('prescriptionOnly: $prescriptionOnly, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('stripPriceMinor: $stripPriceMinor, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductBarcodesTable extends ProductBarcodes
    with TableInfo<$ProductBarcodesTable, ProductBarcodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductBarcodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeMeta = const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES products (id)'),
  );
  @override
  List<GeneratedColumn> get $columns => [barcode, productId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_barcodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductBarcodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta, barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcode};
  @override
  ProductBarcodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductBarcodeRow(
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
    );
  }

  @override
  $ProductBarcodesTable createAlias(String alias) {
    return $ProductBarcodesTable(attachedDatabase, alias);
  }
}

class ProductBarcodeRow extends DataClass implements Insertable<ProductBarcodeRow> {
  final String barcode;
  final String productId;
  const ProductBarcodeRow({required this.barcode, required this.productId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode'] = Variable<String>(barcode);
    map['product_id'] = Variable<String>(productId);
    return map;
  }

  ProductBarcodesCompanion toCompanion(bool nullToAbsent) {
    return ProductBarcodesCompanion(barcode: Value(barcode), productId: Value(productId));
  }

  factory ProductBarcodeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductBarcodeRow(
      barcode: serializer.fromJson<String>(json['barcode']),
      productId: serializer.fromJson<String>(json['productId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcode': serializer.toJson<String>(barcode),
      'productId': serializer.toJson<String>(productId),
    };
  }

  ProductBarcodeRow copyWith({String? barcode, String? productId}) =>
      ProductBarcodeRow(barcode: barcode ?? this.barcode, productId: productId ?? this.productId);
  ProductBarcodeRow copyWithCompanion(ProductBarcodesCompanion data) {
    return ProductBarcodeRow(
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productId: data.productId.present ? data.productId.value : this.productId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductBarcodeRow(')
          ..write('barcode: $barcode, ')
          ..write('productId: $productId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(barcode, productId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductBarcodeRow &&
          other.barcode == this.barcode &&
          other.productId == this.productId);
}

class ProductBarcodesCompanion extends UpdateCompanion<ProductBarcodeRow> {
  final Value<String> barcode;
  final Value<String> productId;
  final Value<int> rowid;
  const ProductBarcodesCompanion({
    this.barcode = const Value.absent(),
    this.productId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductBarcodesCompanion.insert({
    required String barcode,
    required String productId,
    this.rowid = const Value.absent(),
  }) : barcode = Value(barcode),
       productId = Value(productId);
  static Insertable<ProductBarcodeRow> custom({
    Expression<String>? barcode,
    Expression<String>? productId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcode != null) 'barcode': barcode,
      if (productId != null) 'product_id': productId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductBarcodesCompanion copyWith({
    Value<String>? barcode,
    Value<String>? productId,
    Value<int>? rowid,
  }) {
    return ProductBarcodesCompanion(
      barcode: barcode ?? this.barcode,
      productId: productId ?? this.productId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductBarcodesCompanion(')
          ..write('barcode: $barcode, ')
          ..write('productId: $productId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(_phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomerRow({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomerRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomerRow copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockEventsTable extends StockEvents with TableInfo<$StockEventsTable, StockEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryMeta = const VerificationMeta('expiry');
  @override
  late final GeneratedColumn<DateTime> expiry = GeneratedColumn<DateTime>(
    'expiry',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta('unitCostMinor');
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    productId,
    batchId,
    quantity,
    expiry,
    unitCostMinor,
    saleId,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta, batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('expiry')) {
      context.handle(_expiryMeta, expiry.isAcceptableOrUnknown(data['expiry']!, _expiryMeta));
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(data['unit_cost_minor']!, _unitCostMinorMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta, saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      expiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry'],
      ),
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      ),
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $StockEventsTable createAlias(String alias) {
    return $StockEventsTable(attachedDatabase, alias);
  }
}

class StockEventRow extends DataClass implements Insertable<StockEventRow> {
  final String id;

  /// `received` | `sold` | `returned` | `adjusted` | `expired_removed`.
  final String type;
  final String productId;
  final String batchId;
  final int quantity;
  final DateTime? expiry;
  final int? unitCostMinor;
  final String? saleId;
  final String? note;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const StockEventRow({
    required this.id,
    required this.type,
    required this.productId,
    required this.batchId,
    required this.quantity,
    this.expiry,
    this.unitCostMinor,
    this.saleId,
    this.note,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['product_id'] = Variable<String>(productId);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || expiry != null) {
      map['expiry'] = Variable<DateTime>(expiry);
    }
    if (!nullToAbsent || unitCostMinor != null) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    }
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  StockEventsCompanion toCompanion(bool nullToAbsent) {
    return StockEventsCompanion(
      id: Value(id),
      type: Value(type),
      productId: Value(productId),
      batchId: Value(batchId),
      quantity: Value(quantity),
      expiry: expiry == null && nullToAbsent ? const Value.absent() : Value(expiry),
      unitCostMinor: unitCostMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCostMinor),
      saleId: saleId == null && nullToAbsent ? const Value.absent() : Value(saleId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory StockEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      productId: serializer.fromJson<String>(json['productId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      expiry: serializer.fromJson<DateTime?>(json['expiry']),
      unitCostMinor: serializer.fromJson<int?>(json['unitCostMinor']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      note: serializer.fromJson<String?>(json['note']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'productId': serializer.toJson<String>(productId),
      'batchId': serializer.toJson<String>(batchId),
      'quantity': serializer.toJson<int>(quantity),
      'expiry': serializer.toJson<DateTime?>(expiry),
      'unitCostMinor': serializer.toJson<int?>(unitCostMinor),
      'saleId': serializer.toJson<String?>(saleId),
      'note': serializer.toJson<String?>(note),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  StockEventRow copyWith({
    String? id,
    String? type,
    String? productId,
    String? batchId,
    int? quantity,
    Value<DateTime?> expiry = const Value.absent(),
    Value<int?> unitCostMinor = const Value.absent(),
    Value<String?> saleId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => StockEventRow(
    id: id ?? this.id,
    type: type ?? this.type,
    productId: productId ?? this.productId,
    batchId: batchId ?? this.batchId,
    quantity: quantity ?? this.quantity,
    expiry: expiry.present ? expiry.value : this.expiry,
    unitCostMinor: unitCostMinor.present ? unitCostMinor.value : this.unitCostMinor,
    saleId: saleId.present ? saleId.value : this.saleId,
    note: note.present ? note.value : this.note,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  StockEventRow copyWithCompanion(StockEventsCompanion data) {
    return StockEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      productId: data.productId.present ? data.productId.value : this.productId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      expiry: data.expiry.present ? data.expiry.value : this.expiry,
      unitCostMinor: data.unitCostMinor.present ? data.unitCostMinor.value : this.unitCostMinor,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      note: data.note.present ? data.note.value : this.note,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('expiry: $expiry, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    productId,
    batchId,
    quantity,
    expiry,
    unitCostMinor,
    saleId,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.productId == this.productId &&
          other.batchId == this.batchId &&
          other.quantity == this.quantity &&
          other.expiry == this.expiry &&
          other.unitCostMinor == this.unitCostMinor &&
          other.saleId == this.saleId &&
          other.note == this.note &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class StockEventsCompanion extends UpdateCompanion<StockEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> productId;
  final Value<String> batchId;
  final Value<int> quantity;
  final Value<DateTime?> expiry;
  final Value<int?> unitCostMinor;
  final Value<String?> saleId;
  final Value<String?> note;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const StockEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.productId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.expiry = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockEventsCompanion.insert({
    required String id,
    required String type,
    required String productId,
    required String batchId,
    required int quantity,
    this.expiry = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       productId = Value(productId),
       batchId = Value(batchId),
       quantity = Value(quantity),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<StockEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? productId,
    Expression<String>? batchId,
    Expression<int>? quantity,
    Expression<DateTime>? expiry,
    Expression<int>? unitCostMinor,
    Expression<String>? saleId,
    Expression<String>? note,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (productId != null) 'product_id': productId,
      if (batchId != null) 'batch_id': batchId,
      if (quantity != null) 'quantity': quantity,
      if (expiry != null) 'expiry': expiry,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (saleId != null) 'sale_id': saleId,
      if (note != null) 'note': note,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? productId,
    Value<String>? batchId,
    Value<int>? quantity,
    Value<DateTime?>? expiry,
    Value<int?>? unitCostMinor,
    Value<String?>? saleId,
    Value<String?>? note,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return StockEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      productId: productId ?? this.productId,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      expiry: expiry ?? this.expiry,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      saleId: saleId ?? this.saleId,
      note: note ?? this.note,
      deviceId: deviceId ?? this.deviceId,
      employeeId: employeeId ?? this.employeeId,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (expiry.present) {
      map['expiry'] = Variable<DateTime>(expiry.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('productId: $productId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('expiry: $expiry, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMeta = const VerificationMeta('payment');
  @override
  late final GeneratedColumn<String> payment = GeneratedColumn<String>(
    'payment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMinorMeta = const VerificationMeta('subtotalMinor');
  @override
  late final GeneratedColumn<int> subtotalMinor = GeneratedColumn<int>(
    'subtotal_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMinorMeta = const VerificationMeta('discountMinor');
  @override
  late final GeneratedColumn<int> discountMinor = GeneratedColumn<int>(
    'discount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta('totalMinor');
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    payment,
    currencyCode,
    subtotalMinor,
    discountMinor,
    totalMinor,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<SaleRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('payment')) {
      context.handle(_paymentMeta, payment.isAcceptableOrUnknown(data['payment']!, _paymentMeta));
    } else if (isInserting) {
      context.missing(_paymentMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(data['currency_code']!, _currencyCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('subtotal_minor')) {
      context.handle(
        _subtotalMinorMeta,
        subtotalMinor.isAcceptableOrUnknown(data['subtotal_minor']!, _subtotalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMinorMeta);
    }
    if (data.containsKey('discount_minor')) {
      context.handle(
        _discountMinorMeta,
        discountMinor.isAcceptableOrUnknown(data['discount_minor']!, _discountMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_discountMinorMeta);
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      payment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      subtotalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_minor'],
      )!,
      discountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_minor'],
      )!,
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String id;
  final String? customerId;

  /// `cash` | `debt`.
  final String payment;
  final String currencyCode;
  final int subtotalMinor;
  final int discountMinor;
  final int totalMinor;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const SaleRow({
    required this.id,
    this.customerId,
    required this.payment,
    required this.currencyCode,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.totalMinor,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['payment'] = Variable<String>(payment);
    map['currency_code'] = Variable<String>(currencyCode);
    map['subtotal_minor'] = Variable<int>(subtotalMinor);
    map['discount_minor'] = Variable<int>(discountMinor);
    map['total_minor'] = Variable<int>(totalMinor);
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent ? const Value.absent() : Value(customerId),
      payment: Value(payment),
      currencyCode: Value(currencyCode),
      subtotalMinor: Value(subtotalMinor),
      discountMinor: Value(discountMinor),
      totalMinor: Value(totalMinor),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory SaleRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      payment: serializer.fromJson<String>(json['payment']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      subtotalMinor: serializer.fromJson<int>(json['subtotalMinor']),
      discountMinor: serializer.fromJson<int>(json['discountMinor']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'payment': serializer.toJson<String>(payment),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'subtotalMinor': serializer.toJson<int>(subtotalMinor),
      'discountMinor': serializer.toJson<int>(discountMinor),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SaleRow copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    String? payment,
    String? currencyCode,
    int? subtotalMinor,
    int? discountMinor,
    int? totalMinor,
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SaleRow(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    payment: payment ?? this.payment,
    currencyCode: currencyCode ?? this.currencyCode,
    subtotalMinor: subtotalMinor ?? this.subtotalMinor,
    discountMinor: discountMinor ?? this.discountMinor,
    totalMinor: totalMinor ?? this.totalMinor,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present ? data.customerId.value : this.customerId,
      payment: data.payment.present ? data.payment.value : this.payment,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      subtotalMinor: data.subtotalMinor.present ? data.subtotalMinor.value : this.subtotalMinor,
      discountMinor: data.discountMinor.present ? data.discountMinor.value : this.discountMinor,
      totalMinor: data.totalMinor.present ? data.totalMinor.value : this.totalMinor,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('payment: $payment, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('subtotalMinor: $subtotalMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    payment,
    currencyCode,
    subtotalMinor,
    discountMinor,
    totalMinor,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.payment == this.payment &&
          other.currencyCode == this.currencyCode &&
          other.subtotalMinor == this.subtotalMinor &&
          other.discountMinor == this.discountMinor &&
          other.totalMinor == this.totalMinor &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String> payment;
  final Value<String> currencyCode;
  final Value<int> subtotalMinor;
  final Value<int> discountMinor;
  final Value<int> totalMinor;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.payment = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.subtotalMinor = const Value.absent(),
    this.discountMinor = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required String payment,
    required String currencyCode,
    required int subtotalMinor,
    required int discountMinor,
    required int totalMinor,
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payment = Value(payment),
       currencyCode = Value(currencyCode),
       subtotalMinor = Value(subtotalMinor),
       discountMinor = Value(discountMinor),
       totalMinor = Value(totalMinor),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<SaleRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? payment,
    Expression<String>? currencyCode,
    Expression<int>? subtotalMinor,
    Expression<int>? discountMinor,
    Expression<int>? totalMinor,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (payment != null) 'payment': payment,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (subtotalMinor != null) 'subtotal_minor': subtotalMinor,
      if (discountMinor != null) 'discount_minor': discountMinor,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<String>? payment,
    Value<String>? currencyCode,
    Value<int>? subtotalMinor,
    Value<int>? discountMinor,
    Value<int>? totalMinor,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      payment: payment ?? this.payment,
      currencyCode: currencyCode ?? this.currencyCode,
      subtotalMinor: subtotalMinor ?? this.subtotalMinor,
      discountMinor: discountMinor ?? this.discountMinor,
      totalMinor: totalMinor ?? this.totalMinor,
      deviceId: deviceId ?? this.deviceId,
      employeeId: employeeId ?? this.employeeId,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (payment.present) {
      map['payment'] = Variable<String>(payment.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (subtotalMinor.present) {
      map['subtotal_minor'] = Variable<int>(subtotalMinor.value);
    }
    if (discountMinor.present) {
      map['discount_minor'] = Variable<int>(discountMinor.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('payment: $payment, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('subtotalMinor: $subtotalMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTable extends SaleLines with TableInfo<$SaleLinesTable, SaleLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES sales (id)'),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta('unitPriceMinor');
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piecesPerUnitMeta = const VerificationMeta('piecesPerUnit');
  @override
  late final GeneratedColumn<int> piecesPerUnit = GeneratedColumn<int>(
    'pieces_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    quantity,
    unitPriceMinor,
    piecesPerUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta, saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(data['unit_price_minor']!, _unitPriceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('pieces_per_unit')) {
      context.handle(
        _piecesPerUnitMeta,
        piecesPerUnit.isAcceptableOrUnknown(data['pieces_per_unit']!, _piecesPerUnitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLineRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      piecesPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_unit'],
      )!,
    );
  }

  @override
  $SaleLinesTable createAlias(String alias) {
    return $SaleLinesTable(attachedDatabase, alias);
  }
}

class SaleLineRow extends DataClass implements Insertable<SaleLineRow> {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final int unitPriceMinor;

  /// Stock pieces per selling unit: box of 3 strips = 3, strip = 1.
  final int piecesPerUnit;
  const SaleLineRow({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
    required this.piecesPerUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['pieces_per_unit'] = Variable<int>(piecesPerUnit);
    return map;
  }

  SaleLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPriceMinor: Value(unitPriceMinor),
      piecesPerUnit: Value(piecesPerUnit),
    );
  }

  factory SaleLineRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLineRow(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      piecesPerUnit: serializer.fromJson<int>(json['piecesPerUnit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'piecesPerUnit': serializer.toJson<int>(piecesPerUnit),
    };
  }

  SaleLineRow copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    int? unitPriceMinor,
    int? piecesPerUnit,
  }) => SaleLineRow(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
  );
  SaleLineRow copyWithCompanion(SaleLinesCompanion data) {
    return SaleLineRow(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceMinor: data.unitPriceMinor.present ? data.unitPriceMinor.value : this.unitPriceMinor,
      piecesPerUnit: data.piecesPerUnit.present ? data.piecesPerUnit.value : this.piecesPerUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLineRow(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('piecesPerUnit: $piecesPerUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, saleId, productId, quantity, unitPriceMinor, piecesPerUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLineRow &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.piecesPerUnit == this.piecesPerUnit);
}

class SaleLinesCompanion extends UpdateCompanion<SaleLineRow> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> unitPriceMinor;
  final Value<int> piecesPerUnit;
  final Value<int> rowid;
  const SaleLinesCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.piecesPerUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    required String id,
    required String saleId,
    required String productId,
    required int quantity,
    required int unitPriceMinor,
    this.piecesPerUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPriceMinor = Value(unitPriceMinor);
  static Insertable<SaleLineRow> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? unitPriceMinor,
    Expression<int>? piecesPerUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (piecesPerUnit != null) 'pieces_per_unit': piecesPerUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? unitPriceMinor,
    Value<int>? piecesPerUnit,
    Value<int>? rowid,
  }) {
    return SaleLinesCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (piecesPerUnit.present) {
      map['pieces_per_unit'] = Variable<int>(piecesPerUnit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('piecesPerUnit: $piecesPerUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtEventsTable extends DebtEvents with TableInfo<$DebtEventsTable, DebtEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    customerId,
    amountMinor,
    currencyCode,
    saleId,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(data['currency_code']!, _currencyCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta, saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $DebtEventsTable createAlias(String alias) {
    return $DebtEventsTable(attachedDatabase, alias);
  }
}

class DebtEventRow extends DataClass implements Insertable<DebtEventRow> {
  final String id;

  /// `debt_added` | `payment_received`.
  final String type;
  final String customerId;
  final int amountMinor;
  final String currencyCode;
  final String? saleId;
  final String? note;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const DebtEventRow({
    required this.id,
    required this.type,
    required this.customerId,
    required this.amountMinor,
    required this.currencyCode,
    this.saleId,
    this.note,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['customer_id'] = Variable<String>(customerId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  DebtEventsCompanion toCompanion(bool nullToAbsent) {
    return DebtEventsCompanion(
      id: Value(id),
      type: Value(type),
      customerId: Value(customerId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      saleId: saleId == null && nullToAbsent ? const Value.absent() : Value(saleId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory DebtEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      customerId: serializer.fromJson<String>(json['customerId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      note: serializer.fromJson<String?>(json['note']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'customerId': serializer.toJson<String>(customerId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'saleId': serializer.toJson<String?>(saleId),
      'note': serializer.toJson<String?>(note),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  DebtEventRow copyWith({
    String? id,
    String? type,
    String? customerId,
    int? amountMinor,
    String? currencyCode,
    Value<String?> saleId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => DebtEventRow(
    id: id ?? this.id,
    type: type ?? this.type,
    customerId: customerId ?? this.customerId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    saleId: saleId.present ? saleId.value : this.saleId,
    note: note.present ? note.value : this.note,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  DebtEventRow copyWithCompanion(DebtEventsCompanion data) {
    return DebtEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      customerId: data.customerId.present ? data.customerId.value : this.customerId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      note: data.note.present ? data.note.value : this.note,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    customerId,
    amountMinor,
    currencyCode,
    saleId,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.customerId == this.customerId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.saleId == this.saleId &&
          other.note == this.note &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class DebtEventsCompanion extends UpdateCompanion<DebtEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> customerId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> saleId;
  final Value<String?> note;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const DebtEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.customerId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtEventsCompanion.insert({
    required String id,
    required String type,
    required String customerId,
    required int amountMinor,
    required String currencyCode,
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       customerId = Value(customerId),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<DebtEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? customerId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? saleId,
    Expression<String>? note,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (customerId != null) 'customer_id': customerId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (saleId != null) 'sale_id': saleId,
      if (note != null) 'note': note,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? customerId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String?>? saleId,
    Value<String?>? note,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return DebtEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      saleId: saleId ?? this.saleId,
      note: note ?? this.note,
      deviceId: deviceId ?? this.deviceId,
      employeeId: employeeId ?? this.employeeId,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('customerId: $customerId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReturnsTable extends Returns with TableInfo<$ReturnsTable, ReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundMeta = const VerificationMeta('refund');
  @override
  late final GeneratedColumn<String> refund = GeneratedColumn<String>(
    'refund',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta('totalMinor');
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    customerId,
    refund,
    currencyCode,
    totalMinor,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta, saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('refund')) {
      context.handle(_refundMeta, refund.isAcceptableOrUnknown(data['refund']!, _refundMeta));
    } else if (isInserting) {
      context.missing(_refundMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(data['currency_code']!, _currencyCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReturnRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      refund: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ReturnsTable createAlias(String alias) {
    return $ReturnsTable(attachedDatabase, alias);
  }
}

class ReturnRow extends DataClass implements Insertable<ReturnRow> {
  final String id;

  /// Set when returning against a past sale; null for a free-form return.
  final String? saleId;
  final String? customerId;

  /// `cash` | `debt_credit`.
  final String refund;
  final String currencyCode;
  final int totalMinor;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const ReturnRow({
    required this.id,
    this.saleId,
    this.customerId,
    required this.refund,
    required this.currencyCode,
    required this.totalMinor,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['refund'] = Variable<String>(refund);
    map['currency_code'] = Variable<String>(currencyCode);
    map['total_minor'] = Variable<int>(totalMinor);
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ReturnsCompanion toCompanion(bool nullToAbsent) {
    return ReturnsCompanion(
      id: Value(id),
      saleId: saleId == null && nullToAbsent ? const Value.absent() : Value(saleId),
      customerId: customerId == null && nullToAbsent ? const Value.absent() : Value(customerId),
      refund: Value(refund),
      currencyCode: Value(currencyCode),
      totalMinor: Value(totalMinor),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory ReturnRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReturnRow(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      refund: serializer.fromJson<String>(json['refund']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String?>(saleId),
      'customerId': serializer.toJson<String?>(customerId),
      'refund': serializer.toJson<String>(refund),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ReturnRow copyWith({
    String? id,
    Value<String?> saleId = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? refund,
    String? currencyCode,
    int? totalMinor,
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ReturnRow(
    id: id ?? this.id,
    saleId: saleId.present ? saleId.value : this.saleId,
    customerId: customerId.present ? customerId.value : this.customerId,
    refund: refund ?? this.refund,
    currencyCode: currencyCode ?? this.currencyCode,
    totalMinor: totalMinor ?? this.totalMinor,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ReturnRow copyWithCompanion(ReturnsCompanion data) {
    return ReturnRow(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      customerId: data.customerId.present ? data.customerId.value : this.customerId,
      refund: data.refund.present ? data.refund.value : this.refund,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      totalMinor: data.totalMinor.present ? data.totalMinor.value : this.totalMinor,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReturnRow(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('refund: $refund, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    customerId,
    refund,
    currencyCode,
    totalMinor,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReturnRow &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.customerId == this.customerId &&
          other.refund == this.refund &&
          other.currencyCode == this.currencyCode &&
          other.totalMinor == this.totalMinor &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class ReturnsCompanion extends UpdateCompanion<ReturnRow> {
  final Value<String> id;
  final Value<String?> saleId;
  final Value<String?> customerId;
  final Value<String> refund;
  final Value<String> currencyCode;
  final Value<int> totalMinor;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ReturnsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.refund = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReturnsCompanion.insert({
    required String id,
    this.saleId = const Value.absent(),
    this.customerId = const Value.absent(),
    required String refund,
    required String currencyCode,
    required int totalMinor,
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       refund = Value(refund),
       currencyCode = Value(currencyCode),
       totalMinor = Value(totalMinor),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<ReturnRow> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? customerId,
    Expression<String>? refund,
    Expression<String>? currencyCode,
    Expression<int>? totalMinor,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (customerId != null) 'customer_id': customerId,
      if (refund != null) 'refund': refund,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReturnsCompanion copyWith({
    Value<String>? id,
    Value<String?>? saleId,
    Value<String?>? customerId,
    Value<String>? refund,
    Value<String>? currencyCode,
    Value<int>? totalMinor,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ReturnsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      refund: refund ?? this.refund,
      currencyCode: currencyCode ?? this.currencyCode,
      totalMinor: totalMinor ?? this.totalMinor,
      deviceId: deviceId ?? this.deviceId,
      employeeId: employeeId ?? this.employeeId,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (refund.present) {
      map['refund'] = Variable<String>(refund.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReturnsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('refund: $refund, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReturnLinesTable extends ReturnLines with TableInfo<$ReturnLinesTable, ReturnLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReturnLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta('returnId');
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES returns (id)'),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta('unitPriceMinor');
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piecesPerUnitMeta = const VerificationMeta('piecesPerUnit');
  @override
  late final GeneratedColumn<int> piecesPerUnit = GeneratedColumn<int>(
    'pieces_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleLineIdMeta = const VerificationMeta('saleLineId');
  @override
  late final GeneratedColumn<String> saleLineId = GeneratedColumn<String>(
    'sale_line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    returnId,
    productId,
    quantity,
    unitPriceMinor,
    piecesPerUnit,
    saleLineId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'return_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReturnLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_returnIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(data['unit_price_minor']!, _unitPriceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('pieces_per_unit')) {
      context.handle(
        _piecesPerUnitMeta,
        piecesPerUnit.isAcceptableOrUnknown(data['pieces_per_unit']!, _piecesPerUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_piecesPerUnitMeta);
    }
    if (data.containsKey('sale_line_id')) {
      context.handle(
        _saleLineIdMeta,
        saleLineId.isAcceptableOrUnknown(data['sale_line_id']!, _saleLineIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReturnLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReturnLineRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      piecesPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_unit'],
      )!,
      saleLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_line_id'],
      ),
    );
  }

  @override
  $ReturnLinesTable createAlias(String alias) {
    return $ReturnLinesTable(attachedDatabase, alias);
  }
}

class ReturnLineRow extends DataClass implements Insertable<ReturnLineRow> {
  final String id;
  final String returnId;
  final String productId;
  final int quantity;
  final int unitPriceMinor;
  final int piecesPerUnit;
  final String? saleLineId;
  const ReturnLineRow({
    required this.id,
    required this.returnId,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
    required this.piecesPerUnit,
    this.saleLineId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['return_id'] = Variable<String>(returnId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['pieces_per_unit'] = Variable<int>(piecesPerUnit);
    if (!nullToAbsent || saleLineId != null) {
      map['sale_line_id'] = Variable<String>(saleLineId);
    }
    return map;
  }

  ReturnLinesCompanion toCompanion(bool nullToAbsent) {
    return ReturnLinesCompanion(
      id: Value(id),
      returnId: Value(returnId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPriceMinor: Value(unitPriceMinor),
      piecesPerUnit: Value(piecesPerUnit),
      saleLineId: saleLineId == null && nullToAbsent ? const Value.absent() : Value(saleLineId),
    );
  }

  factory ReturnLineRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReturnLineRow(
      id: serializer.fromJson<String>(json['id']),
      returnId: serializer.fromJson<String>(json['returnId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      piecesPerUnit: serializer.fromJson<int>(json['piecesPerUnit']),
      saleLineId: serializer.fromJson<String?>(json['saleLineId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'returnId': serializer.toJson<String>(returnId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'piecesPerUnit': serializer.toJson<int>(piecesPerUnit),
      'saleLineId': serializer.toJson<String?>(saleLineId),
    };
  }

  ReturnLineRow copyWith({
    String? id,
    String? returnId,
    String? productId,
    int? quantity,
    int? unitPriceMinor,
    int? piecesPerUnit,
    Value<String?> saleLineId = const Value.absent(),
  }) => ReturnLineRow(
    id: id ?? this.id,
    returnId: returnId ?? this.returnId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
    saleLineId: saleLineId.present ? saleLineId.value : this.saleLineId,
  );
  ReturnLineRow copyWithCompanion(ReturnLinesCompanion data) {
    return ReturnLineRow(
      id: data.id.present ? data.id.value : this.id,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceMinor: data.unitPriceMinor.present ? data.unitPriceMinor.value : this.unitPriceMinor,
      piecesPerUnit: data.piecesPerUnit.present ? data.piecesPerUnit.value : this.piecesPerUnit,
      saleLineId: data.saleLineId.present ? data.saleLineId.value : this.saleLineId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReturnLineRow(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('piecesPerUnit: $piecesPerUnit, ')
          ..write('saleLineId: $saleLineId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, returnId, productId, quantity, unitPriceMinor, piecesPerUnit, saleLineId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReturnLineRow &&
          other.id == this.id &&
          other.returnId == this.returnId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.piecesPerUnit == this.piecesPerUnit &&
          other.saleLineId == this.saleLineId);
}

class ReturnLinesCompanion extends UpdateCompanion<ReturnLineRow> {
  final Value<String> id;
  final Value<String> returnId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> unitPriceMinor;
  final Value<int> piecesPerUnit;
  final Value<String?> saleLineId;
  final Value<int> rowid;
  const ReturnLinesCompanion({
    this.id = const Value.absent(),
    this.returnId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.piecesPerUnit = const Value.absent(),
    this.saleLineId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReturnLinesCompanion.insert({
    required String id,
    required String returnId,
    required String productId,
    required int quantity,
    required int unitPriceMinor,
    required int piecesPerUnit,
    this.saleLineId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       returnId = Value(returnId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPriceMinor = Value(unitPriceMinor),
       piecesPerUnit = Value(piecesPerUnit);
  static Insertable<ReturnLineRow> custom({
    Expression<String>? id,
    Expression<String>? returnId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? unitPriceMinor,
    Expression<int>? piecesPerUnit,
    Expression<String>? saleLineId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnId != null) 'return_id': returnId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (piecesPerUnit != null) 'pieces_per_unit': piecesPerUnit,
      if (saleLineId != null) 'sale_line_id': saleLineId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReturnLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? returnId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? unitPriceMinor,
    Value<int>? piecesPerUnit,
    Value<String?>? saleLineId,
    Value<int>? rowid,
  }) {
    return ReturnLinesCompanion(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
      saleLineId: saleLineId ?? this.saleLineId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (piecesPerUnit.present) {
      map['pieces_per_unit'] = Variable<int>(piecesPerUnit.value);
    }
    if (saleLineId.present) {
      map['sale_line_id'] = Variable<String>(saleLineId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReturnLinesCompanion(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('piecesPerUnit: $piecesPerUnit, ')
          ..write('saleLineId: $saleLineId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductBarcodesTable productBarcodes = $ProductBarcodesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $StockEventsTable stockEvents = $StockEventsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final $DebtEventsTable debtEvents = $DebtEventsTable(this);
  late final $ReturnsTable returns = $ReturnsTable(this);
  late final $ReturnLinesTable returnLines = $ReturnLinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    settings,
    employees,
    products,
    productBarcodes,
    customers,
    stockEvents,
    sales,
    saleLines,
    debtEvents,
    returns,
    returnLines,
  ];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String name,
  Value<bool> isThisDevice,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isThisDevice,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isThisDevice =>
      $composableBuilder(column: $table.isThisDevice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isThisDevice =>
      $composableBuilder(column: $table.isThisDevice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isThisDevice =>
      $composableBuilder(column: $table.isThisDevice, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          DeviceRow,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (DeviceRow, BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow>),
          DeviceRow,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isThisDevice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                isThisDevice: isThisDevice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isThisDevice = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                isThisDevice: isThisDevice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, DeviceRow>(table),
                  BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      DeviceRow,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (DeviceRow, BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow>),
      DeviceRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$EmployeesTableCreateCompanionBuilder = EmployeesCompanion Function({
  required String id,
  required String name,
  required String role,
  required String pinHash,
  required String pinSalt,
  Value<bool> active,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> role,
  Value<String> pinHash,
  Value<String> pinSalt,
  Value<bool> active,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EmployeesTableFilterComposer extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EmployeesTableOrderingComposer extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EmployeesTableAnnotationComposer extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          EmployeeRow,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (EmployeeRow, BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeRow>),
          EmployeeRow,
          PrefetchHooks Function()
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> pinSalt = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                name: name,
                role: role,
                pinHash: pinHash,
                pinSalt: pinSalt,
                active: active,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String role,
                required String pinHash,
                required String pinSalt,
                Value<bool> active = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                name: name,
                role: role,
                pinHash: pinHash,
                pinSalt: pinSalt,
                active: active,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmployeesTable, EmployeeRow>(table),
                  BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      EmployeeRow,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (EmployeeRow, BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeRow>),
      EmployeeRow,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String tradeName,
  Value<String?> arabicName,
  required String activeIngredient,
  Value<String?> strength,
  Value<String?> form,
  Value<String?> manufacturer,
  Value<String?> shelf,
  required int priceMinor,
  Value<bool> prescriptionOnly,
  Value<int> lowStockThreshold,
  Value<int> unitsPerPack,
  Value<int?> stripPriceMinor,
  Value<bool> active,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String updatedByDevice,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> tradeName,
  Value<String?> arabicName,
  Value<String> activeIngredient,
  Value<String?> strength,
  Value<String?> form,
  Value<String?> manufacturer,
  Value<String?> shelf,
  Value<int> priceMinor,
  Value<bool> prescriptionOnly,
  Value<int> lowStockThreshold,
  Value<int> unitsPerPack,
  Value<int?> stripPriceMinor,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> updatedByDevice,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductBarcodesTable, List<ProductBarcodeRow>>
  _productBarcodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productBarcodes,
    aliasName: 'products__id__product_barcodes__product_id',
  );

  $$ProductBarcodesTableProcessedTableManager get productBarcodesRefs {
    final manager = $$ProductBarcodesTableTableManager(
      $_db,
      $_db.productBarcodes,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productBarcodesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get arabicName =>
      $composableBuilder(column: $table.arabicName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer =>
      $composableBuilder(column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shelf =>
      $composableBuilder(column: $table.shelf, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceMinor =>
      $composableBuilder(column: $table.priceMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get prescriptionOnly => $composableBuilder(
    column: $table.prescriptionOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsPerPack =>
      $composableBuilder(column: $table.unitsPerPack, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stripPriceMinor => $composableBuilder(
    column: $table.stripPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productBarcodesRefs(
    Expression<bool> Function($$ProductBarcodesTableFilterComposer f) f,
  ) {
    final $$ProductBarcodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productBarcodes,
      getReferencedColumn: (t) => t.productId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProductBarcodesTableFilterComposer(
            $db: $db,
            $table: $db.productBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get arabicName =>
      $composableBuilder(column: $table.arabicName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer =>
      $composableBuilder(column: $table.manufacturer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shelf =>
      $composableBuilder(column: $table.shelf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceMinor =>
      $composableBuilder(column: $table.priceMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get prescriptionOnly => $composableBuilder(
    column: $table.prescriptionOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerPack =>
      $composableBuilder(column: $table.unitsPerPack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stripPriceMinor => $composableBuilder(
    column: $table.stripPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => column);

  GeneratedColumn<String> get arabicName =>
      $composableBuilder(column: $table.arabicName, builder: (column) => column);

  GeneratedColumn<String> get activeIngredient =>
      $composableBuilder(column: $table.activeIngredient, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get manufacturer =>
      $composableBuilder(column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get shelf =>
      $composableBuilder(column: $table.shelf, builder: (column) => column);

  GeneratedColumn<int> get priceMinor =>
      $composableBuilder(column: $table.priceMinor, builder: (column) => column);

  GeneratedColumn<bool> get prescriptionOnly =>
      $composableBuilder(column: $table.prescriptionOnly, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold =>
      $composableBuilder(column: $table.lowStockThreshold, builder: (column) => column);

  GeneratedColumn<int> get unitsPerPack =>
      $composableBuilder(column: $table.unitsPerPack, builder: (column) => column);

  GeneratedColumn<int> get stripPriceMinor =>
      $composableBuilder(column: $table.stripPriceMinor, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedByDevice =>
      $composableBuilder(column: $table.updatedByDevice, builder: (column) => column);

  Expression<T> productBarcodesRefs<T extends Object>(
    Expression<T> Function($$ProductBarcodesTableAnnotationComposer a) f,
  ) {
    final $$ProductBarcodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productBarcodes,
      getReferencedColumn: (t) => t.productId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProductBarcodesTableAnnotationComposer(
            $db: $db,
            $table: $db.productBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({bool productBarcodesRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tradeName = const Value.absent(),
                Value<String?> arabicName = const Value.absent(),
                Value<String> activeIngredient = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> form = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> shelf = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<bool> prescriptionOnly = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<int> unitsPerPack = const Value.absent(),
                Value<int?> stripPriceMinor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedByDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                tradeName: tradeName,
                arabicName: arabicName,
                activeIngredient: activeIngredient,
                strength: strength,
                form: form,
                manufacturer: manufacturer,
                shelf: shelf,
                priceMinor: priceMinor,
                prescriptionOnly: prescriptionOnly,
                lowStockThreshold: lowStockThreshold,
                unitsPerPack: unitsPerPack,
                stripPriceMinor: stripPriceMinor,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedByDevice: updatedByDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tradeName,
                Value<String?> arabicName = const Value.absent(),
                required String activeIngredient,
                Value<String?> strength = const Value.absent(),
                Value<String?> form = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> shelf = const Value.absent(),
                required int priceMinor,
                Value<bool> prescriptionOnly = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<int> unitsPerPack = const Value.absent(),
                Value<int?> stripPriceMinor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required String updatedByDevice,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                tradeName: tradeName,
                arabicName: arabicName,
                activeIngredient: activeIngredient,
                strength: strength,
                form: form,
                manufacturer: manufacturer,
                shelf: shelf,
                priceMinor: priceMinor,
                prescriptionOnly: prescriptionOnly,
                lowStockThreshold: lowStockThreshold,
                unitsPerPack: unitsPerPack,
                stripPriceMinor: stripPriceMinor,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedByDevice: updatedByDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productBarcodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productBarcodesRefs) db.productBarcodes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productBarcodesRefs)
                    await $_getPrefetchedData<ProductRow, $ProductsTable, ProductBarcodeRow>(
                      currentTable: table,
                      referencedTable: $$ProductsTableReferences._productBarcodesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProductsTableReferences(db, table, p0).productBarcodesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.productId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({bool productBarcodesRefs})
    >;
typedef $$ProductBarcodesTableCreateCompanionBuilder = ProductBarcodesCompanion Function({
  required String barcode,
  required String productId,
  Value<int> rowid,
});
typedef $$ProductBarcodesTableUpdateCompanionBuilder = ProductBarcodesCompanion Function({
  Value<String> barcode,
  Value<String> productId,
  Value<int> rowid,
});

final class $$ProductBarcodesTableReferences
    extends BaseReferences<_$AppDatabase, $ProductBarcodesTable, ProductBarcodeRow> {
  $$ProductBarcodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('product_barcodes__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProductBarcodesTableFilterComposer extends Composer<_$AppDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductBarcodesTable,
          ProductBarcodeRow,
          $$ProductBarcodesTableFilterComposer,
          $$ProductBarcodesTableOrderingComposer,
          $$ProductBarcodesTableAnnotationComposer,
          $$ProductBarcodesTableCreateCompanionBuilder,
          $$ProductBarcodesTableUpdateCompanionBuilder,
          (ProductBarcodeRow, $$ProductBarcodesTableReferences),
          ProductBarcodeRow,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductBarcodesTableTableManager(_$AppDatabase db, $ProductBarcodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductBarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductBarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductBarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> barcode = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ProductBarcodesCompanion(barcode: barcode, productId: productId, rowid: rowid),
          createCompanionCallback:
              ({
                required String barcode,
                required String productId,
                Value<int> rowid = const Value.absent(),
              }) => ProductBarcodesCompanion.insert(
                barcode: barcode,
                productId: productId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductBarcodesTable, ProductBarcodeRow>(table),
                  $$ProductBarcodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$ProductBarcodesTableReferences._productIdTable(db),
                        referencedColumn: $$ProductBarcodesTableReferences._productIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProductBarcodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductBarcodesTable,
      ProductBarcodeRow,
      $$ProductBarcodesTableFilterComposer,
      $$ProductBarcodesTableOrderingComposer,
      $$ProductBarcodesTableAnnotationComposer,
      $$ProductBarcodesTableCreateCompanionBuilder,
      $$ProductBarcodesTableUpdateCompanionBuilder,
      (ProductBarcodeRow, $$ProductBarcodesTableReferences),
      ProductBarcodeRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
          CustomerRow,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerRow>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
      CustomerRow,
      PrefetchHooks Function()
    >;
typedef $$StockEventsTableCreateCompanionBuilder = StockEventsCompanion Function({
  required String id,
  required String type,
  required String productId,
  required String batchId,
  required int quantity,
  Value<DateTime?> expiry,
  Value<int?> unitCostMinor,
  Value<String?> saleId,
  Value<String?> note,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$StockEventsTableUpdateCompanionBuilder = StockEventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> productId,
  Value<String> batchId,
  Value<int> quantity,
  Value<DateTime?> expiry,
  Value<int?> unitCostMinor,
  Value<String?> saleId,
  Value<String?> note,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$StockEventsTableFilterComposer extends Composer<_$AppDatabase, $StockEventsTable> {
  $$StockEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCostMinor =>
      $composableBuilder(column: $table.unitCostMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$StockEventsTableOrderingComposer extends Composer<_$AppDatabase, $StockEventsTable> {
  $$StockEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$StockEventsTableAnnotationComposer extends Composer<_$AppDatabase, $StockEventsTable> {
  $$StockEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => column);

  GeneratedColumn<int> get unitCostMinor =>
      $composableBuilder(column: $table.unitCostMinor, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$StockEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockEventsTable,
          StockEventRow,
          $$StockEventsTableFilterComposer,
          $$StockEventsTableOrderingComposer,
          $$StockEventsTableAnnotationComposer,
          $$StockEventsTableCreateCompanionBuilder,
          $$StockEventsTableUpdateCompanionBuilder,
          (StockEventRow, BaseReferences<_$AppDatabase, $StockEventsTable, StockEventRow>),
          StockEventRow,
          PrefetchHooks Function()
        > {
  $$StockEventsTableTableManager(_$AppDatabase db, $StockEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StockEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StockEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime?> expiry = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockEventsCompanion(
                id: id,
                type: type,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                expiry: expiry,
                unitCostMinor: unitCostMinor,
                saleId: saleId,
                note: note,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String productId,
                required String batchId,
                required int quantity,
                Value<DateTime?> expiry = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockEventsCompanion.insert(
                id: id,
                type: type,
                productId: productId,
                batchId: batchId,
                quantity: quantity,
                expiry: expiry,
                unitCostMinor: unitCostMinor,
                saleId: saleId,
                note: note,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockEventsTable, StockEventRow>(table),
                  BaseReferences<_$AppDatabase, $StockEventsTable, StockEventRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockEventsTable,
      StockEventRow,
      $$StockEventsTableFilterComposer,
      $$StockEventsTableOrderingComposer,
      $$StockEventsTableAnnotationComposer,
      $$StockEventsTableCreateCompanionBuilder,
      $$StockEventsTableUpdateCompanionBuilder,
      (StockEventRow, BaseReferences<_$AppDatabase, $StockEventsTable, StockEventRow>),
      StockEventRow,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  Value<String?> customerId,
  required String payment,
  required String currencyCode,
  required int subtotalMinor,
  required int discountMinor,
  required int totalMinor,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<String?> customerId,
  Value<String> payment,
  Value<String> currencyCode,
  Value<int> subtotalMinor,
  Value<int> discountMinor,
  Value<int> totalMinor,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$SalesTableReferences extends BaseReferences<_$AppDatabase, $SalesTable, SaleRow> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleLinesTable, List<SaleLineRow>> _saleLinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.saleLines, aliasName: 'sales__id__sale_lines__sale_id');

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotalMinor =>
      $composableBuilder(column: $table.subtotalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountMinor =>
      $composableBuilder(column: $table.discountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> saleLinesRefs(Expression<bool> Function($$SaleLinesTableFilterComposer f) f) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotalMinor => $composableBuilder(
    column: $table.subtotalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<int> get subtotalMinor =>
      $composableBuilder(column: $table.subtotalMinor, builder: (column) => column);

  GeneratedColumn<int> get discountMinor =>
      $composableBuilder(column: $table.discountMinor, builder: (column) => column);

  GeneratedColumn<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleRow,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleRow, $$SalesTableReferences),
          SaleRow,
          PrefetchHooks Function({bool saleLinesRefs})
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> payment = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> subtotalMinor = const Value.absent(),
                Value<int> discountMinor = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                customerId: customerId,
                payment: payment,
                currencyCode: currencyCode,
                subtotalMinor: subtotalMinor,
                discountMinor: discountMinor,
                totalMinor: totalMinor,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                required String payment,
                required String currencyCode,
                required int subtotalMinor,
                required int discountMinor,
                required int totalMinor,
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                customerId: customerId,
                payment: payment,
                currencyCode: currencyCode,
                subtotalMinor: subtotalMinor,
                discountMinor: discountMinor,
                totalMinor: totalMinor,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, SaleRow>(table),
                  $$SalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleLinesRefs) db.saleLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleLinesRefs)
                    await $_getPrefetchedData<SaleRow, $SalesTable, SaleLineRow>(
                      currentTable: table,
                      referencedTable: $$SalesTableReferences._saleLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTableReferences(db, table, p0).saleLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleRow,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleRow, $$SalesTableReferences),
      SaleRow,
      PrefetchHooks Function({bool saleLinesRefs})
    >;
typedef $$SaleLinesTableCreateCompanionBuilder = SaleLinesCompanion Function({
  required String id,
  required String saleId,
  required String productId,
  required int quantity,
  required int unitPriceMinor,
  Value<int> piecesPerUnit,
  Value<int> rowid,
});
typedef $$SaleLinesTableUpdateCompanionBuilder = SaleLinesCompanion Function({
  Value<String> id,
  Value<String> saleId,
  Value<String> productId,
  Value<int> quantity,
  Value<int> unitPriceMinor,
  Value<int> piecesPerUnit,
  Value<int> rowid,
});

final class $$SaleLinesTableReferences
    extends BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLineRow> {
  $$SaleLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('sale_lines__sale_id__sales__id');

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SaleLinesTableFilterComposer extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => ColumnFilters(column));

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableOrderingComposer extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piecesPerUnit => $composableBuilder(
    column: $table.piecesPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableAnnotationComposer extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => column);

  GeneratedColumn<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleLinesTable,
          SaleLineRow,
          $$SaleLinesTableFilterComposer,
          $$SaleLinesTableOrderingComposer,
          $$SaleLinesTableAnnotationComposer,
          $$SaleLinesTableCreateCompanionBuilder,
          $$SaleLinesTableUpdateCompanionBuilder,
          (SaleLineRow, $$SaleLinesTableReferences),
          SaleLineRow,
          PrefetchHooks Function({bool saleId})
        > {
  $$SaleLinesTableTableManager(_$AppDatabase db, $SaleLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> piecesPerUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                piecesPerUnit: piecesPerUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String productId,
                required int quantity,
                required int unitPriceMinor,
                Value<int> piecesPerUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                piecesPerUnit: piecesPerUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleLinesTable, SaleLineRow>(table),
                  $$SaleLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.saleId,
                        referencedTable: $$SaleLinesTableReferences._saleIdTable(db),
                        referencedColumn: $$SaleLinesTableReferences._saleIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleLinesTable,
      SaleLineRow,
      $$SaleLinesTableFilterComposer,
      $$SaleLinesTableOrderingComposer,
      $$SaleLinesTableAnnotationComposer,
      $$SaleLinesTableCreateCompanionBuilder,
      $$SaleLinesTableUpdateCompanionBuilder,
      (SaleLineRow, $$SaleLinesTableReferences),
      SaleLineRow,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$DebtEventsTableCreateCompanionBuilder = DebtEventsCompanion Function({
  required String id,
  required String type,
  required String customerId,
  required int amountMinor,
  required String currencyCode,
  Value<String?> saleId,
  Value<String?> note,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$DebtEventsTableUpdateCompanionBuilder = DebtEventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> customerId,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<String?> saleId,
  Value<String?> note,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$DebtEventsTableFilterComposer extends Composer<_$AppDatabase, $DebtEventsTable> {
  $$DebtEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$DebtEventsTableOrderingComposer extends Composer<_$AppDatabase, $DebtEventsTable> {
  $$DebtEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$DebtEventsTableAnnotationComposer extends Composer<_$AppDatabase, $DebtEventsTable> {
  $$DebtEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$DebtEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtEventsTable,
          DebtEventRow,
          $$DebtEventsTableFilterComposer,
          $$DebtEventsTableOrderingComposer,
          $$DebtEventsTableAnnotationComposer,
          $$DebtEventsTableCreateCompanionBuilder,
          $$DebtEventsTableUpdateCompanionBuilder,
          (DebtEventRow, BaseReferences<_$AppDatabase, $DebtEventsTable, DebtEventRow>),
          DebtEventRow,
          PrefetchHooks Function()
        > {
  $$DebtEventsTableTableManager(_$AppDatabase db, $DebtEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DebtEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DebtEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtEventsCompanion(
                id: id,
                type: type,
                customerId: customerId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                saleId: saleId,
                note: note,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String customerId,
                required int amountMinor,
                required String currencyCode,
                Value<String?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtEventsCompanion.insert(
                id: id,
                type: type,
                customerId: customerId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                saleId: saleId,
                note: note,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebtEventsTable, DebtEventRow>(table),
                  BaseReferences<_$AppDatabase, $DebtEventsTable, DebtEventRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtEventsTable,
      DebtEventRow,
      $$DebtEventsTableFilterComposer,
      $$DebtEventsTableOrderingComposer,
      $$DebtEventsTableAnnotationComposer,
      $$DebtEventsTableCreateCompanionBuilder,
      $$DebtEventsTableUpdateCompanionBuilder,
      (DebtEventRow, BaseReferences<_$AppDatabase, $DebtEventsTable, DebtEventRow>),
      DebtEventRow,
      PrefetchHooks Function()
    >;
typedef $$ReturnsTableCreateCompanionBuilder = ReturnsCompanion Function({
  required String id,
  Value<String?> saleId,
  Value<String?> customerId,
  required String refund,
  required String currencyCode,
  required int totalMinor,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$ReturnsTableUpdateCompanionBuilder = ReturnsCompanion Function({
  Value<String> id,
  Value<String?> saleId,
  Value<String?> customerId,
  Value<String> refund,
  Value<String> currencyCode,
  Value<int> totalMinor,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$ReturnsTableReferences
    extends BaseReferences<_$AppDatabase, $ReturnsTable, ReturnRow> {
  $$ReturnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReturnLinesTable, List<ReturnLineRow>> _returnLinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.returnLines,
    aliasName: 'returns__id__return_lines__return_id',
  );

  $$ReturnLinesTableProcessedTableManager get returnLinesRefs {
    final manager = $$ReturnLinesTableTableManager(
      $_db,
      $_db.returnLines,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_returnLinesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ReturnsTableFilterComposer extends Composer<_$AppDatabase, $ReturnsTable> {
  $$ReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refund =>
      $composableBuilder(column: $table.refund, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> returnLinesRefs(
    Expression<bool> Function($$ReturnLinesTableFilterComposer f) f,
  ) {
    final $$ReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.returnLines,
      getReferencedColumn: (t) => t.returnId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.returnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReturnsTableOrderingComposer extends Composer<_$AppDatabase, $ReturnsTable> {
  $$ReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refund =>
      $composableBuilder(column: $table.refund, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReturnsTableAnnotationComposer extends Composer<_$AppDatabase, $ReturnsTable> {
  $$ReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get customerId =>
      $composableBuilder(column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get refund =>
      $composableBuilder(column: $table.refund, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> returnLinesRefs<T extends Object>(
    Expression<T> Function($$ReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$ReturnLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.returnLines,
      getReferencedColumn: (t) => t.returnId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ReturnLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.returnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReturnsTable,
          ReturnRow,
          $$ReturnsTableFilterComposer,
          $$ReturnsTableOrderingComposer,
          $$ReturnsTableAnnotationComposer,
          $$ReturnsTableCreateCompanionBuilder,
          $$ReturnsTableUpdateCompanionBuilder,
          (ReturnRow, $$ReturnsTableReferences),
          ReturnRow,
          PrefetchHooks Function({bool returnLinesRefs})
        > {
  $$ReturnsTableTableManager(_$AppDatabase db, $ReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> refund = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnsCompanion(
                id: id,
                saleId: saleId,
                customerId: customerId,
                refund: refund,
                currencyCode: currencyCode,
                totalMinor: totalMinor,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> saleId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String refund,
                required String currencyCode,
                required int totalMinor,
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnsCompanion.insert(
                id: id,
                saleId: saleId,
                customerId: customerId,
                refund: refund,
                currencyCode: currencyCode,
                totalMinor: totalMinor,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReturnsTable, ReturnRow>(table),
                  $$ReturnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({returnLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (returnLinesRefs) db.returnLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (returnLinesRefs)
                    await $_getPrefetchedData<ReturnRow, $ReturnsTable, ReturnLineRow>(
                      currentTable: table,
                      referencedTable: $$ReturnsTableReferences._returnLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReturnsTableReferences(db, table, p0).returnLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.returnId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReturnsTable,
      ReturnRow,
      $$ReturnsTableFilterComposer,
      $$ReturnsTableOrderingComposer,
      $$ReturnsTableAnnotationComposer,
      $$ReturnsTableCreateCompanionBuilder,
      $$ReturnsTableUpdateCompanionBuilder,
      (ReturnRow, $$ReturnsTableReferences),
      ReturnRow,
      PrefetchHooks Function({bool returnLinesRefs})
    >;
typedef $$ReturnLinesTableCreateCompanionBuilder = ReturnLinesCompanion Function({
  required String id,
  required String returnId,
  required String productId,
  required int quantity,
  required int unitPriceMinor,
  required int piecesPerUnit,
  Value<String?> saleLineId,
  Value<int> rowid,
});
typedef $$ReturnLinesTableUpdateCompanionBuilder = ReturnLinesCompanion Function({
  Value<String> id,
  Value<String> returnId,
  Value<String> productId,
  Value<int> quantity,
  Value<int> unitPriceMinor,
  Value<int> piecesPerUnit,
  Value<String?> saleLineId,
  Value<int> rowid,
});

final class $$ReturnLinesTableReferences
    extends BaseReferences<_$AppDatabase, $ReturnLinesTable, ReturnLineRow> {
  $$ReturnLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReturnsTable _returnIdTable(_$AppDatabase db) =>
      db.returns.createAlias('return_lines__return_id__returns__id');

  $$ReturnsTableProcessedTableManager get returnId {
    final $_column = $_itemColumn<String>('return_id')!;

    final manager = $$ReturnsTableTableManager(
      $_db,
      $_db.returns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReturnLinesTableFilterComposer extends Composer<_$AppDatabase, $ReturnLinesTable> {
  $$ReturnLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleLineId =>
      $composableBuilder(column: $table.saleLineId, builder: (column) => ColumnFilters(column));

  $$ReturnsTableFilterComposer get returnId {
    final $$ReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returns,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ReturnsTableFilterComposer(
            $db: $db,
            $table: $db.returns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReturnLinesTableOrderingComposer extends Composer<_$AppDatabase, $ReturnLinesTable> {
  $$ReturnLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piecesPerUnit => $composableBuilder(
    column: $table.piecesPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleLineId =>
      $composableBuilder(column: $table.saleLineId, builder: (column) => ColumnOrderings(column));

  $$ReturnsTableOrderingComposer get returnId {
    final $$ReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returns,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.returns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReturnLinesTableAnnotationComposer extends Composer<_$AppDatabase, $ReturnLinesTable> {
  $$ReturnLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => column);

  GeneratedColumn<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => column);

  GeneratedColumn<String> get saleLineId =>
      $composableBuilder(column: $table.saleLineId, builder: (column) => column);

  $$ReturnsTableAnnotationComposer get returnId {
    final $$ReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returns,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.returns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReturnLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReturnLinesTable,
          ReturnLineRow,
          $$ReturnLinesTableFilterComposer,
          $$ReturnLinesTableOrderingComposer,
          $$ReturnLinesTableAnnotationComposer,
          $$ReturnLinesTableCreateCompanionBuilder,
          $$ReturnLinesTableUpdateCompanionBuilder,
          (ReturnLineRow, $$ReturnLinesTableReferences),
          ReturnLineRow,
          PrefetchHooks Function({bool returnId})
        > {
  $$ReturnLinesTableTableManager(_$AppDatabase db, $ReturnLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ReturnLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ReturnLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReturnLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> returnId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> piecesPerUnit = const Value.absent(),
                Value<String?> saleLineId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnLinesCompanion(
                id: id,
                returnId: returnId,
                productId: productId,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                piecesPerUnit: piecesPerUnit,
                saleLineId: saleLineId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String returnId,
                required String productId,
                required int quantity,
                required int unitPriceMinor,
                required int piecesPerUnit,
                Value<String?> saleLineId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnLinesCompanion.insert(
                id: id,
                returnId: returnId,
                productId: productId,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                piecesPerUnit: piecesPerUnit,
                saleLineId: saleLineId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReturnLinesTable, ReturnLineRow>(table),
                  $$ReturnLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({returnId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (returnId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.returnId,
                        referencedTable: $$ReturnLinesTableReferences._returnIdTable(db),
                        referencedColumn: $$ReturnLinesTableReferences._returnIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReturnLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReturnLinesTable,
      ReturnLineRow,
      $$ReturnLinesTableFilterComposer,
      $$ReturnLinesTableOrderingComposer,
      $$ReturnLinesTableAnnotationComposer,
      $$ReturnLinesTableCreateCompanionBuilder,
      $$ReturnLinesTableUpdateCompanionBuilder,
      (ReturnLineRow, $$ReturnLinesTableReferences),
      ReturnLineRow,
      PrefetchHooks Function({bool returnId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices => $$DevicesTableTableManager(_db, _db.devices);
  $$SettingsTableTableManager get settings => $$SettingsTableTableManager(_db, _db.settings);
  $$EmployeesTableTableManager get employees => $$EmployeesTableTableManager(_db, _db.employees);
  $$ProductsTableTableManager get products => $$ProductsTableTableManager(_db, _db.products);
  $$ProductBarcodesTableTableManager get productBarcodes =>
      $$ProductBarcodesTableTableManager(_db, _db.productBarcodes);
  $$CustomersTableTableManager get customers => $$CustomersTableTableManager(_db, _db.customers);
  $$StockEventsTableTableManager get stockEvents =>
      $$StockEventsTableTableManager(_db, _db.stockEvents);
  $$SalesTableTableManager get sales => $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines => $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$DebtEventsTableTableManager get debtEvents =>
      $$DebtEventsTableTableManager(_db, _db.debtEvents);
  $$ReturnsTableTableManager get returns => $$ReturnsTableTableManager(_db, _db.returns);
  $$ReturnLinesTableTableManager get returnLines =>
      $$ReturnLinesTableTableManager(_db, _db.returnLines);
}
