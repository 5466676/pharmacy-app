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
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    refId,
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
    if (data.containsKey('ref_id')) {
      context.handle(_refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
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
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
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

  /// Purchase / supplier return / stocktake that caused it. v5.
  final String? refId;
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
    this.refId,
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
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
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
      refId: refId == null && nullToAbsent ? const Value.absent() : Value(refId),
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
      refId: serializer.fromJson<String?>(json['refId']),
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
      'refId': serializer.toJson<String?>(refId),
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
    Value<String?> refId = const Value.absent(),
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
    refId: refId.present ? refId.value : this.refId,
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
      refId: data.refId.present ? data.refId.value : this.refId,
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
          ..write('syncedAt: $syncedAt, ')
          ..write('refId: $refId')
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
    refId,
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
          other.syncedAt == this.syncedAt &&
          other.refId == this.refId);
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
  final Value<String?> refId;
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
    this.refId = const Value.absent(),
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
    this.refId = const Value.absent(),
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
    Expression<String>? refId,
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
      if (refId != null) 'ref_id': refId,
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
    Value<String?>? refId,
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
      refId: refId ?? this.refId,
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
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
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
          ..write('refId: $refId, ')
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
  static const VerificationMeta _tenderedMinorMeta = const VerificationMeta('tenderedMinor');
  @override
  late final GeneratedColumn<int> tenderedMinor = GeneratedColumn<int>(
    'tendered_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    tenderedMinor,
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
    if (data.containsKey('tendered_minor')) {
      context.handle(
        _tenderedMinorMeta,
        tenderedMinor.isAcceptableOrUnknown(data['tendered_minor']!, _tenderedMinorMeta),
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
      tenderedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tendered_minor'],
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

  /// Cash handed over by the customer (cash sales, optional). v3.
  final int? tenderedMinor;
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
    this.tenderedMinor,
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
    if (!nullToAbsent || tenderedMinor != null) {
      map['tendered_minor'] = Variable<int>(tenderedMinor);
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
      tenderedMinor: tenderedMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(tenderedMinor),
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
      tenderedMinor: serializer.fromJson<int?>(json['tenderedMinor']),
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
      'tenderedMinor': serializer.toJson<int?>(tenderedMinor),
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
    Value<int?> tenderedMinor = const Value.absent(),
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
    tenderedMinor: tenderedMinor.present ? tenderedMinor.value : this.tenderedMinor,
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
      tenderedMinor: data.tenderedMinor.present ? data.tenderedMinor.value : this.tenderedMinor,
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
          ..write('syncedAt: $syncedAt, ')
          ..write('tenderedMinor: $tenderedMinor')
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
    tenderedMinor,
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
          other.syncedAt == this.syncedAt &&
          other.tenderedMinor == this.tenderedMinor);
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
  final Value<int?> tenderedMinor;
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
    this.tenderedMinor = const Value.absent(),
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
    this.tenderedMinor = const Value.absent(),
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
    Expression<int>? tenderedMinor,
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
      if (tenderedMinor != null) 'tendered_minor': tenderedMinor,
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
    Value<int?>? tenderedMinor,
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
      tenderedMinor: tenderedMinor ?? this.tenderedMinor,
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
    if (tenderedMinor.present) {
      map['tendered_minor'] = Variable<int>(tenderedMinor.value);
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
          ..write('tenderedMinor: $tenderedMinor, ')
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

class $TillEventsTable extends TillEvents with TableInfo<$TillEventsTable, TillEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TillEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _shiftIdMeta = const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
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
    shiftId,
    amountMinor,
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
  static const String $name = 'till_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TillEventRow> instance, {
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
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta, shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
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
  TillEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TillEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
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
  $TillEventsTable createAlias(String alias) {
    return $TillEventsTable(attachedDatabase, alias);
  }
}

class TillEventRow extends DataClass implements Insertable<TillEventRow> {
  final String id;
  final String type;

  /// Id of the shift's `opened` event.
  final String shiftId;
  final int amountMinor;
  final String? note;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const TillEventRow({
    required this.id,
    required this.type,
    required this.shiftId,
    required this.amountMinor,
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
    map['shift_id'] = Variable<String>(shiftId);
    map['amount_minor'] = Variable<int>(amountMinor);
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

  TillEventsCompanion toCompanion(bool nullToAbsent) {
    return TillEventsCompanion(
      id: Value(id),
      type: Value(type),
      shiftId: Value(shiftId),
      amountMinor: Value(amountMinor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory TillEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TillEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
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
      'shiftId': serializer.toJson<String>(shiftId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'note': serializer.toJson<String?>(note),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  TillEventRow copyWith({
    String? id,
    String? type,
    String? shiftId,
    int? amountMinor,
    Value<String?> note = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => TillEventRow(
    id: id ?? this.id,
    type: type ?? this.type,
    shiftId: shiftId ?? this.shiftId,
    amountMinor: amountMinor ?? this.amountMinor,
    note: note.present ? note.value : this.note,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TillEventRow copyWithCompanion(TillEventsCompanion data) {
    return TillEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      note: data.note.present ? data.note.value : this.note,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TillEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('shiftId: $shiftId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('note: $note, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, shiftId, amountMinor, note, deviceId, employeeId, occurredAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TillEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.shiftId == this.shiftId &&
          other.amountMinor == this.amountMinor &&
          other.note == this.note &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class TillEventsCompanion extends UpdateCompanion<TillEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> shiftId;
  final Value<int> amountMinor;
  final Value<String?> note;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const TillEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.note = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TillEventsCompanion.insert({
    required String id,
    required String type,
    required String shiftId,
    required int amountMinor,
    this.note = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       shiftId = Value(shiftId),
       amountMinor = Value(amountMinor),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<TillEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? shiftId,
    Expression<int>? amountMinor,
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
      if (shiftId != null) 'shift_id': shiftId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (note != null) 'note': note,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TillEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? shiftId,
    Value<int>? amountMinor,
    Value<String?>? note,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TillEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      shiftId: shiftId ?? this.shiftId,
      amountMinor: amountMinor ?? this.amountMinor,
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
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
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
    return (StringBuffer('TillEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('shiftId: $shiftId, ')
          ..write('amountMinor: $amountMinor, ')
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

class $SuppliersTable extends Suppliers with TableInfo<$SuppliersTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _repNameMeta = const VerificationMeta('repName');
  @override
  late final GeneratedColumn<String> repName = GeneratedColumn<String>(
    'rep_name',
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
  static const VerificationMeta _creditLimitMinorMeta = const VerificationMeta('creditLimitMinor');
  @override
  late final GeneratedColumn<int> creditLimitMinor = GeneratedColumn<int>(
    'credit_limit_minor',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    repName,
    notes,
    creditLimitMinor,
    active,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRow> instance, {
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
    if (data.containsKey('rep_name')) {
      context.handle(_repNameMeta, repName.isAcceptableOrUnknown(data['rep_name']!, _repNameMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('credit_limit_minor')) {
      context.handle(
        _creditLimitMinorMeta,
        creditLimitMinor.isAcceptableOrUnknown(data['credit_limit_minor']!, _creditLimitMinorMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      repName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      creditLimitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_minor'],
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
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final String name;
  final String? phone;
  final String? repName;
  final String? notes;
  final int? creditLimitMinor;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SupplierRow({
    required this.id,
    required this.name,
    this.phone,
    this.repName,
    this.notes,
    this.creditLimitMinor,
    required this.active,
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
    if (!nullToAbsent || repName != null) {
      map['rep_name'] = Variable<String>(repName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || creditLimitMinor != null) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      repName: repName == null && nullToAbsent ? const Value.absent() : Value(repName),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      creditLimitMinor: creditLimitMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitMinor),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SupplierRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      repName: serializer.fromJson<String?>(json['repName']),
      notes: serializer.fromJson<String?>(json['notes']),
      creditLimitMinor: serializer.fromJson<int?>(json['creditLimitMinor']),
      active: serializer.fromJson<bool>(json['active']),
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
      'repName': serializer.toJson<String?>(repName),
      'notes': serializer.toJson<String?>(notes),
      'creditLimitMinor': serializer.toJson<int?>(creditLimitMinor),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SupplierRow copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> repName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> creditLimitMinor = const Value.absent(),
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SupplierRow(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    repName: repName.present ? repName.value : this.repName,
    notes: notes.present ? notes.value : this.notes,
    creditLimitMinor: creditLimitMinor.present ? creditLimitMinor.value : this.creditLimitMinor,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SupplierRow copyWithCompanion(SuppliersCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      repName: data.repName.present ? data.repName.value : this.repName,
      notes: data.notes.present ? data.notes.value : this.notes,
      creditLimitMinor: data.creditLimitMinor.present
          ? data.creditLimitMinor.value
          : this.creditLimitMinor,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('repName: $repName, ')
          ..write('notes: $notes, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, repName, notes, creditLimitMinor, active, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.repName == this.repName &&
          other.notes == this.notes &&
          other.creditLimitMinor == this.creditLimitMinor &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> repName;
  final Value<String?> notes;
  final Value<int?> creditLimitMinor;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.repName = const Value.absent(),
    this.notes = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.repName = const Value.absent(),
    this.notes = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SupplierRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? repName,
    Expression<String>? notes,
    Expression<int>? creditLimitMinor,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (repName != null) 'rep_name': repName,
      if (notes != null) 'notes': notes,
      if (creditLimitMinor != null) 'credit_limit_minor': creditLimitMinor,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? repName,
    Value<String?>? notes,
    Value<int?>? creditLimitMinor,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      repName: repName ?? this.repName,
      notes: notes ?? this.notes,
      creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
      active: active ?? this.active,
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
    if (repName.present) {
      map['rep_name'] = Variable<String>(repName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (creditLimitMinor.present) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('repName: $repName, ')
          ..write('notes: $notes, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases with TableInfo<$PurchasesTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierInvoiceNoMeta = const VerificationMeta(
    'supplierInvoiceNo',
  );
  @override
  late final GeneratedColumn<String> supplierInvoiceNo = GeneratedColumn<String>(
    'supplier_invoice_no',
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
  static const VerificationMeta _paidFromMeta = const VerificationMeta('paidFrom');
  @override
  late final GeneratedColumn<String> paidFrom = GeneratedColumn<String>(
    'paid_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _grossMinorMeta = const VerificationMeta('grossMinor');
  @override
  late final GeneratedColumn<int> grossMinor = GeneratedColumn<int>(
    'gross_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineDiscountsMinorMeta = const VerificationMeta(
    'lineDiscountsMinor',
  );
  @override
  late final GeneratedColumn<int> lineDiscountsMinor = GeneratedColumn<int>(
    'line_discounts_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceDiscountMinorMeta = const VerificationMeta(
    'invoiceDiscountMinor',
  );
  @override
  late final GeneratedColumn<int> invoiceDiscountMinor = GeneratedColumn<int>(
    'invoice_discount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transportMinorMeta = const VerificationMeta('transportMinor');
  @override
  late final GeneratedColumn<int> transportMinor = GeneratedColumn<int>(
    'transport_minor',
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
    supplierId,
    supplierInvoiceNo,
    payment,
    paidFrom,
    currencyCode,
    grossMinor,
    lineDiscountsMinor,
    invoiceDiscountMinor,
    transportMinor,
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
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('supplier_invoice_no')) {
      context.handle(
        _supplierInvoiceNoMeta,
        supplierInvoiceNo.isAcceptableOrUnknown(
          data['supplier_invoice_no']!,
          _supplierInvoiceNoMeta,
        ),
      );
    }
    if (data.containsKey('payment')) {
      context.handle(_paymentMeta, payment.isAcceptableOrUnknown(data['payment']!, _paymentMeta));
    } else if (isInserting) {
      context.missing(_paymentMeta);
    }
    if (data.containsKey('paid_from')) {
      context.handle(
        _paidFromMeta,
        paidFrom.isAcceptableOrUnknown(data['paid_from']!, _paidFromMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(data['currency_code']!, _currencyCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('gross_minor')) {
      context.handle(
        _grossMinorMeta,
        grossMinor.isAcceptableOrUnknown(data['gross_minor']!, _grossMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_grossMinorMeta);
    }
    if (data.containsKey('line_discounts_minor')) {
      context.handle(
        _lineDiscountsMinorMeta,
        lineDiscountsMinor.isAcceptableOrUnknown(
          data['line_discounts_minor']!,
          _lineDiscountsMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineDiscountsMinorMeta);
    }
    if (data.containsKey('invoice_discount_minor')) {
      context.handle(
        _invoiceDiscountMinorMeta,
        invoiceDiscountMinor.isAcceptableOrUnknown(
          data['invoice_discount_minor']!,
          _invoiceDiscountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDiscountMinorMeta);
    }
    if (data.containsKey('transport_minor')) {
      context.handle(
        _transportMinorMeta,
        transportMinor.isAcceptableOrUnknown(data['transport_minor']!, _transportMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_transportMinorMeta);
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
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      supplierInvoiceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_invoice_no'],
      ),
      payment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment'],
      )!,
      paidFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_from'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      grossMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_minor'],
      )!,
      lineDiscountsMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_discounts_minor'],
      )!,
      invoiceDiscountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_discount_minor'],
      )!,
      transportMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transport_minor'],
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
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  final String id;
  final String supplierId;
  final String? supplierInvoiceNo;

  /// `cash` | `credit`.
  final String payment;

  /// `drawer` | `outside` (cash only).
  final String? paidFrom;
  final String currencyCode;
  final int grossMinor;
  final int lineDiscountsMinor;
  final int invoiceDiscountMinor;
  final int transportMinor;
  final int totalMinor;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const PurchaseRow({
    required this.id,
    required this.supplierId,
    this.supplierInvoiceNo,
    required this.payment,
    this.paidFrom,
    required this.currencyCode,
    required this.grossMinor,
    required this.lineDiscountsMinor,
    required this.invoiceDiscountMinor,
    required this.transportMinor,
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
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || supplierInvoiceNo != null) {
      map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo);
    }
    map['payment'] = Variable<String>(payment);
    if (!nullToAbsent || paidFrom != null) {
      map['paid_from'] = Variable<String>(paidFrom);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['gross_minor'] = Variable<int>(grossMinor);
    map['line_discounts_minor'] = Variable<int>(lineDiscountsMinor);
    map['invoice_discount_minor'] = Variable<int>(invoiceDiscountMinor);
    map['transport_minor'] = Variable<int>(transportMinor);
    map['total_minor'] = Variable<int>(totalMinor);
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      supplierInvoiceNo: supplierInvoiceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierInvoiceNo),
      payment: Value(payment),
      paidFrom: paidFrom == null && nullToAbsent ? const Value.absent() : Value(paidFrom),
      currencyCode: Value(currencyCode),
      grossMinor: Value(grossMinor),
      lineDiscountsMinor: Value(lineDiscountsMinor),
      invoiceDiscountMinor: Value(invoiceDiscountMinor),
      transportMinor: Value(transportMinor),
      totalMinor: Value(totalMinor),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory PurchaseRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      supplierInvoiceNo: serializer.fromJson<String?>(json['supplierInvoiceNo']),
      payment: serializer.fromJson<String>(json['payment']),
      paidFrom: serializer.fromJson<String?>(json['paidFrom']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      grossMinor: serializer.fromJson<int>(json['grossMinor']),
      lineDiscountsMinor: serializer.fromJson<int>(json['lineDiscountsMinor']),
      invoiceDiscountMinor: serializer.fromJson<int>(json['invoiceDiscountMinor']),
      transportMinor: serializer.fromJson<int>(json['transportMinor']),
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
      'supplierId': serializer.toJson<String>(supplierId),
      'supplierInvoiceNo': serializer.toJson<String?>(supplierInvoiceNo),
      'payment': serializer.toJson<String>(payment),
      'paidFrom': serializer.toJson<String?>(paidFrom),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'grossMinor': serializer.toJson<int>(grossMinor),
      'lineDiscountsMinor': serializer.toJson<int>(lineDiscountsMinor),
      'invoiceDiscountMinor': serializer.toJson<int>(invoiceDiscountMinor),
      'transportMinor': serializer.toJson<int>(transportMinor),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  PurchaseRow copyWith({
    String? id,
    String? supplierId,
    Value<String?> supplierInvoiceNo = const Value.absent(),
    String? payment,
    Value<String?> paidFrom = const Value.absent(),
    String? currencyCode,
    int? grossMinor,
    int? lineDiscountsMinor,
    int? invoiceDiscountMinor,
    int? transportMinor,
    int? totalMinor,
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => PurchaseRow(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    supplierInvoiceNo: supplierInvoiceNo.present ? supplierInvoiceNo.value : this.supplierInvoiceNo,
    payment: payment ?? this.payment,
    paidFrom: paidFrom.present ? paidFrom.value : this.paidFrom,
    currencyCode: currencyCode ?? this.currencyCode,
    grossMinor: grossMinor ?? this.grossMinor,
    lineDiscountsMinor: lineDiscountsMinor ?? this.lineDiscountsMinor,
    invoiceDiscountMinor: invoiceDiscountMinor ?? this.invoiceDiscountMinor,
    transportMinor: transportMinor ?? this.transportMinor,
    totalMinor: totalMinor ?? this.totalMinor,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  PurchaseRow copyWithCompanion(PurchasesCompanion data) {
    return PurchaseRow(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present ? data.supplierId.value : this.supplierId,
      supplierInvoiceNo: data.supplierInvoiceNo.present
          ? data.supplierInvoiceNo.value
          : this.supplierInvoiceNo,
      payment: data.payment.present ? data.payment.value : this.payment,
      paidFrom: data.paidFrom.present ? data.paidFrom.value : this.paidFrom,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      grossMinor: data.grossMinor.present ? data.grossMinor.value : this.grossMinor,
      lineDiscountsMinor: data.lineDiscountsMinor.present
          ? data.lineDiscountsMinor.value
          : this.lineDiscountsMinor,
      invoiceDiscountMinor: data.invoiceDiscountMinor.present
          ? data.invoiceDiscountMinor.value
          : this.invoiceDiscountMinor,
      transportMinor: data.transportMinor.present ? data.transportMinor.value : this.transportMinor,
      totalMinor: data.totalMinor.present ? data.totalMinor.value : this.totalMinor,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('payment: $payment, ')
          ..write('paidFrom: $paidFrom, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('grossMinor: $grossMinor, ')
          ..write('lineDiscountsMinor: $lineDiscountsMinor, ')
          ..write('invoiceDiscountMinor: $invoiceDiscountMinor, ')
          ..write('transportMinor: $transportMinor, ')
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
    supplierId,
    supplierInvoiceNo,
    payment,
    paidFrom,
    currencyCode,
    grossMinor,
    lineDiscountsMinor,
    invoiceDiscountMinor,
    transportMinor,
    totalMinor,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.supplierInvoiceNo == this.supplierInvoiceNo &&
          other.payment == this.payment &&
          other.paidFrom == this.paidFrom &&
          other.currencyCode == this.currencyCode &&
          other.grossMinor == this.grossMinor &&
          other.lineDiscountsMinor == this.lineDiscountsMinor &&
          other.invoiceDiscountMinor == this.invoiceDiscountMinor &&
          other.transportMinor == this.transportMinor &&
          other.totalMinor == this.totalMinor &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class PurchasesCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> supplierInvoiceNo;
  final Value<String> payment;
  final Value<String?> paidFrom;
  final Value<String> currencyCode;
  final Value<int> grossMinor;
  final Value<int> lineDiscountsMinor;
  final Value<int> invoiceDiscountMinor;
  final Value<int> transportMinor;
  final Value<int> totalMinor;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierInvoiceNo = const Value.absent(),
    this.payment = const Value.absent(),
    this.paidFrom = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.grossMinor = const Value.absent(),
    this.lineDiscountsMinor = const Value.absent(),
    this.invoiceDiscountMinor = const Value.absent(),
    this.transportMinor = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String supplierId,
    this.supplierInvoiceNo = const Value.absent(),
    required String payment,
    this.paidFrom = const Value.absent(),
    required String currencyCode,
    required int grossMinor,
    required int lineDiscountsMinor,
    required int invoiceDiscountMinor,
    required int transportMinor,
    required int totalMinor,
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       payment = Value(payment),
       currencyCode = Value(currencyCode),
       grossMinor = Value(grossMinor),
       lineDiscountsMinor = Value(lineDiscountsMinor),
       invoiceDiscountMinor = Value(invoiceDiscountMinor),
       transportMinor = Value(transportMinor),
       totalMinor = Value(totalMinor),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<PurchaseRow> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? supplierInvoiceNo,
    Expression<String>? payment,
    Expression<String>? paidFrom,
    Expression<String>? currencyCode,
    Expression<int>? grossMinor,
    Expression<int>? lineDiscountsMinor,
    Expression<int>? invoiceDiscountMinor,
    Expression<int>? transportMinor,
    Expression<int>? totalMinor,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierInvoiceNo != null) 'supplier_invoice_no': supplierInvoiceNo,
      if (payment != null) 'payment': payment,
      if (paidFrom != null) 'paid_from': paidFrom,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (grossMinor != null) 'gross_minor': grossMinor,
      if (lineDiscountsMinor != null) 'line_discounts_minor': lineDiscountsMinor,
      if (invoiceDiscountMinor != null) 'invoice_discount_minor': invoiceDiscountMinor,
      if (transportMinor != null) 'transport_minor': transportMinor,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String?>? supplierInvoiceNo,
    Value<String>? payment,
    Value<String?>? paidFrom,
    Value<String>? currencyCode,
    Value<int>? grossMinor,
    Value<int>? lineDiscountsMinor,
    Value<int>? invoiceDiscountMinor,
    Value<int>? transportMinor,
    Value<int>? totalMinor,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
      payment: payment ?? this.payment,
      paidFrom: paidFrom ?? this.paidFrom,
      currencyCode: currencyCode ?? this.currencyCode,
      grossMinor: grossMinor ?? this.grossMinor,
      lineDiscountsMinor: lineDiscountsMinor ?? this.lineDiscountsMinor,
      invoiceDiscountMinor: invoiceDiscountMinor ?? this.invoiceDiscountMinor,
      transportMinor: transportMinor ?? this.transportMinor,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierInvoiceNo.present) {
      map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo.value);
    }
    if (payment.present) {
      map['payment'] = Variable<String>(payment.value);
    }
    if (paidFrom.present) {
      map['paid_from'] = Variable<String>(paidFrom.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (grossMinor.present) {
      map['gross_minor'] = Variable<int>(grossMinor.value);
    }
    if (lineDiscountsMinor.present) {
      map['line_discounts_minor'] = Variable<int>(lineDiscountsMinor.value);
    }
    if (invoiceDiscountMinor.present) {
      map['invoice_discount_minor'] = Variable<int>(invoiceDiscountMinor.value);
    }
    if (transportMinor.present) {
      map['transport_minor'] = Variable<int>(transportMinor.value);
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
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('payment: $payment, ')
          ..write('paidFrom: $paidFrom, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('grossMinor: $grossMinor, ')
          ..write('lineDiscountsMinor: $lineDiscountsMinor, ')
          ..write('invoiceDiscountMinor: $invoiceDiscountMinor, ')
          ..write('transportMinor: $transportMinor, ')
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

class $PurchaseLinesTable extends PurchaseLines
    with TableInfo<$PurchaseLinesTable, PurchaseLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES purchases (id)'),
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
  static const VerificationMeta _bonusMeta = const VerificationMeta('bonus');
  @override
  late final GeneratedColumn<int> bonus = GeneratedColumn<int>(
    'bonus',
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
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta('unitPriceMinor');
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountBasisPointsMeta = const VerificationMeta(
    'discountBasisPoints',
  );
  @override
  late final GeneratedColumn<int> discountBasisPoints = GeneratedColumn<int>(
    'discount_basis_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMinorMeta = const VerificationMeta('costMinor');
  @override
  late final GeneratedColumn<int> costMinor = GeneratedColumn<int>(
    'cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _expiryMeta = const VerificationMeta('expiry');
  @override
  late final GeneratedColumn<DateTime> expiry = GeneratedColumn<DateTime>(
    'expiry',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    productId,
    quantity,
    bonus,
    piecesPerUnit,
    unitPriceMinor,
    discountBasisPoints,
    costMinor,
    batchId,
    expiry,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
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
    if (data.containsKey('bonus')) {
      context.handle(_bonusMeta, bonus.isAcceptableOrUnknown(data['bonus']!, _bonusMeta));
    } else if (isInserting) {
      context.missing(_bonusMeta);
    }
    if (data.containsKey('pieces_per_unit')) {
      context.handle(
        _piecesPerUnitMeta,
        piecesPerUnit.isAcceptableOrUnknown(data['pieces_per_unit']!, _piecesPerUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_piecesPerUnitMeta);
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(data['unit_price_minor']!, _unitPriceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('discount_basis_points')) {
      context.handle(
        _discountBasisPointsMeta,
        discountBasisPoints.isAcceptableOrUnknown(
          data['discount_basis_points']!,
          _discountBasisPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountBasisPointsMeta);
    }
    if (data.containsKey('cost_minor')) {
      context.handle(
        _costMinorMeta,
        costMinor.isAcceptableOrUnknown(data['cost_minor']!, _costMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_costMinorMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta, batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('expiry')) {
      context.handle(_expiryMeta, expiry.isAcceptableOrUnknown(data['expiry']!, _expiryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseLineRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      bonus: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bonus'])!,
      piecesPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pieces_per_unit'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      discountBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_basis_points'],
      )!,
      costMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_minor'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      expiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry'],
      ),
    );
  }

  @override
  $PurchaseLinesTable createAlias(String alias) {
    return $PurchaseLinesTable(attachedDatabase, alias);
  }
}

class PurchaseLineRow extends DataClass implements Insertable<PurchaseLineRow> {
  final String id;
  final String purchaseId;
  final String productId;
  final int quantity;
  final int bonus;
  final int piecesPerUnit;
  final int unitPriceMinor;
  final int discountBasisPoints;

  /// True cost of the line after all discounts and its transport share.
  final int costMinor;

  /// Batch opened by this line (its `received` event id).
  final String batchId;
  final DateTime? expiry;
  const PurchaseLineRow({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.bonus,
    required this.piecesPerUnit,
    required this.unitPriceMinor,
    required this.discountBasisPoints,
    required this.costMinor,
    required this.batchId,
    this.expiry,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['bonus'] = Variable<int>(bonus);
    map['pieces_per_unit'] = Variable<int>(piecesPerUnit);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['discount_basis_points'] = Variable<int>(discountBasisPoints);
    map['cost_minor'] = Variable<int>(costMinor);
    map['batch_id'] = Variable<String>(batchId);
    if (!nullToAbsent || expiry != null) {
      map['expiry'] = Variable<DateTime>(expiry);
    }
    return map;
  }

  PurchaseLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseLinesCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productId: Value(productId),
      quantity: Value(quantity),
      bonus: Value(bonus),
      piecesPerUnit: Value(piecesPerUnit),
      unitPriceMinor: Value(unitPriceMinor),
      discountBasisPoints: Value(discountBasisPoints),
      costMinor: Value(costMinor),
      batchId: Value(batchId),
      expiry: expiry == null && nullToAbsent ? const Value.absent() : Value(expiry),
    );
  }

  factory PurchaseLineRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseLineRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      bonus: serializer.fromJson<int>(json['bonus']),
      piecesPerUnit: serializer.fromJson<int>(json['piecesPerUnit']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      discountBasisPoints: serializer.fromJson<int>(json['discountBasisPoints']),
      costMinor: serializer.fromJson<int>(json['costMinor']),
      batchId: serializer.fromJson<String>(json['batchId']),
      expiry: serializer.fromJson<DateTime?>(json['expiry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'bonus': serializer.toJson<int>(bonus),
      'piecesPerUnit': serializer.toJson<int>(piecesPerUnit),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'discountBasisPoints': serializer.toJson<int>(discountBasisPoints),
      'costMinor': serializer.toJson<int>(costMinor),
      'batchId': serializer.toJson<String>(batchId),
      'expiry': serializer.toJson<DateTime?>(expiry),
    };
  }

  PurchaseLineRow copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    int? quantity,
    int? bonus,
    int? piecesPerUnit,
    int? unitPriceMinor,
    int? discountBasisPoints,
    int? costMinor,
    String? batchId,
    Value<DateTime?> expiry = const Value.absent(),
  }) => PurchaseLineRow(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    bonus: bonus ?? this.bonus,
    piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    discountBasisPoints: discountBasisPoints ?? this.discountBasisPoints,
    costMinor: costMinor ?? this.costMinor,
    batchId: batchId ?? this.batchId,
    expiry: expiry.present ? expiry.value : this.expiry,
  );
  PurchaseLineRow copyWithCompanion(PurchaseLinesCompanion data) {
    return PurchaseLineRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      bonus: data.bonus.present ? data.bonus.value : this.bonus,
      piecesPerUnit: data.piecesPerUnit.present ? data.piecesPerUnit.value : this.piecesPerUnit,
      unitPriceMinor: data.unitPriceMinor.present ? data.unitPriceMinor.value : this.unitPriceMinor,
      discountBasisPoints: data.discountBasisPoints.present
          ? data.discountBasisPoints.value
          : this.discountBasisPoints,
      costMinor: data.costMinor.present ? data.costMinor.value : this.costMinor,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      expiry: data.expiry.present ? data.expiry.value : this.expiry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLineRow(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('bonus: $bonus, ')
          ..write('piecesPerUnit: $piecesPerUnit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('discountBasisPoints: $discountBasisPoints, ')
          ..write('costMinor: $costMinor, ')
          ..write('batchId: $batchId, ')
          ..write('expiry: $expiry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseId,
    productId,
    quantity,
    bonus,
    piecesPerUnit,
    unitPriceMinor,
    discountBasisPoints,
    costMinor,
    batchId,
    expiry,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseLineRow &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.bonus == this.bonus &&
          other.piecesPerUnit == this.piecesPerUnit &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.discountBasisPoints == this.discountBasisPoints &&
          other.costMinor == this.costMinor &&
          other.batchId == this.batchId &&
          other.expiry == this.expiry);
}

class PurchaseLinesCompanion extends UpdateCompanion<PurchaseLineRow> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> bonus;
  final Value<int> piecesPerUnit;
  final Value<int> unitPriceMinor;
  final Value<int> discountBasisPoints;
  final Value<int> costMinor;
  final Value<String> batchId;
  final Value<DateTime?> expiry;
  final Value<int> rowid;
  const PurchaseLinesCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.bonus = const Value.absent(),
    this.piecesPerUnit = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.discountBasisPoints = const Value.absent(),
    this.costMinor = const Value.absent(),
    this.batchId = const Value.absent(),
    this.expiry = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseLinesCompanion.insert({
    required String id,
    required String purchaseId,
    required String productId,
    required int quantity,
    required int bonus,
    required int piecesPerUnit,
    required int unitPriceMinor,
    required int discountBasisPoints,
    required int costMinor,
    required String batchId,
    this.expiry = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       productId = Value(productId),
       quantity = Value(quantity),
       bonus = Value(bonus),
       piecesPerUnit = Value(piecesPerUnit),
       unitPriceMinor = Value(unitPriceMinor),
       discountBasisPoints = Value(discountBasisPoints),
       costMinor = Value(costMinor),
       batchId = Value(batchId);
  static Insertable<PurchaseLineRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? bonus,
    Expression<int>? piecesPerUnit,
    Expression<int>? unitPriceMinor,
    Expression<int>? discountBasisPoints,
    Expression<int>? costMinor,
    Expression<String>? batchId,
    Expression<DateTime>? expiry,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (bonus != null) 'bonus': bonus,
      if (piecesPerUnit != null) 'pieces_per_unit': piecesPerUnit,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (discountBasisPoints != null) 'discount_basis_points': discountBasisPoints,
      if (costMinor != null) 'cost_minor': costMinor,
      if (batchId != null) 'batch_id': batchId,
      if (expiry != null) 'expiry': expiry,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? bonus,
    Value<int>? piecesPerUnit,
    Value<int>? unitPriceMinor,
    Value<int>? discountBasisPoints,
    Value<int>? costMinor,
    Value<String>? batchId,
    Value<DateTime?>? expiry,
    Value<int>? rowid,
  }) {
    return PurchaseLinesCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      bonus: bonus ?? this.bonus,
      piecesPerUnit: piecesPerUnit ?? this.piecesPerUnit,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      discountBasisPoints: discountBasisPoints ?? this.discountBasisPoints,
      costMinor: costMinor ?? this.costMinor,
      batchId: batchId ?? this.batchId,
      expiry: expiry ?? this.expiry,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (bonus.present) {
      map['bonus'] = Variable<int>(bonus.value);
    }
    if (piecesPerUnit.present) {
      map['pieces_per_unit'] = Variable<int>(piecesPerUnit.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (discountBasisPoints.present) {
      map['discount_basis_points'] = Variable<int>(discountBasisPoints.value);
    }
    if (costMinor.present) {
      map['cost_minor'] = Variable<int>(costMinor.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (expiry.present) {
      map['expiry'] = Variable<DateTime>(expiry.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLinesCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('bonus: $bonus, ')
          ..write('piecesPerUnit: $piecesPerUnit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('discountBasisPoints: $discountBasisPoints, ')
          ..write('costMinor: $costMinor, ')
          ..write('batchId: $batchId, ')
          ..write('expiry: $expiry, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierDebtEventsTable extends SupplierDebtEvents
    with TableInfo<$SupplierDebtEventsTable, SupplierDebtEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierDebtEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _supplierIdMeta = const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
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
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
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
  static const VerificationMeta _paidFromMeta = const VerificationMeta('paidFrom');
  @override
  late final GeneratedColumn<String> paidFrom = GeneratedColumn<String>(
    'paid_from',
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
    supplierId,
    amountMinor,
    currencyCode,
    refId,
    note,
    paidFrom,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_debt_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierDebtEventRow> instance, {
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
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
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
    if (data.containsKey('ref_id')) {
      context.handle(_refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('paid_from')) {
      context.handle(
        _paidFromMeta,
        paidFrom.isAcceptableOrUnknown(data['paid_from']!, _paidFromMeta),
      );
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
  SupplierDebtEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierDebtEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      paidFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_from'],
      ),
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
  $SupplierDebtEventsTable createAlias(String alias) {
    return $SupplierDebtEventsTable(attachedDatabase, alias);
  }
}

class SupplierDebtEventRow extends DataClass implements Insertable<SupplierDebtEventRow> {
  final String id;

  /// `purchase_on_credit` | `payment_made` | `return_credited`.
  final String type;
  final String supplierId;
  final int amountMinor;
  final String currencyCode;
  final String? refId;
  final String? note;

  /// For `payment_made`: `drawer` | `outside`.
  final String? paidFrom;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const SupplierDebtEventRow({
    required this.id,
    required this.type,
    required this.supplierId,
    required this.amountMinor,
    required this.currencyCode,
    this.refId,
    this.note,
    this.paidFrom,
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
    map['supplier_id'] = Variable<String>(supplierId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || paidFrom != null) {
      map['paid_from'] = Variable<String>(paidFrom);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SupplierDebtEventsCompanion toCompanion(bool nullToAbsent) {
    return SupplierDebtEventsCompanion(
      id: Value(id),
      type: Value(type),
      supplierId: Value(supplierId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      refId: refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paidFrom: paidFrom == null && nullToAbsent ? const Value.absent() : Value(paidFrom),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory SupplierDebtEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierDebtEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      refId: serializer.fromJson<String?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
      paidFrom: serializer.fromJson<String?>(json['paidFrom']),
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
      'supplierId': serializer.toJson<String>(supplierId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'refId': serializer.toJson<String?>(refId),
      'note': serializer.toJson<String?>(note),
      'paidFrom': serializer.toJson<String?>(paidFrom),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SupplierDebtEventRow copyWith({
    String? id,
    String? type,
    String? supplierId,
    int? amountMinor,
    String? currencyCode,
    Value<String?> refId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> paidFrom = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SupplierDebtEventRow(
    id: id ?? this.id,
    type: type ?? this.type,
    supplierId: supplierId ?? this.supplierId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    refId: refId.present ? refId.value : this.refId,
    note: note.present ? note.value : this.note,
    paidFrom: paidFrom.present ? paidFrom.value : this.paidFrom,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SupplierDebtEventRow copyWithCompanion(SupplierDebtEventsCompanion data) {
    return SupplierDebtEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      supplierId: data.supplierId.present ? data.supplierId.value : this.supplierId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
      paidFrom: data.paidFrom.present ? data.paidFrom.value : this.paidFrom,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDebtEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('supplierId: $supplierId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('paidFrom: $paidFrom, ')
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
    supplierId,
    amountMinor,
    currencyCode,
    refId,
    note,
    paidFrom,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierDebtEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.supplierId == this.supplierId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.refId == this.refId &&
          other.note == this.note &&
          other.paidFrom == this.paidFrom &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class SupplierDebtEventsCompanion extends UpdateCompanion<SupplierDebtEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> supplierId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String?> refId;
  final Value<String?> note;
  final Value<String?> paidFrom;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SupplierDebtEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.paidFrom = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierDebtEventsCompanion.insert({
    required String id,
    required String type,
    required String supplierId,
    required int amountMinor,
    required String currencyCode,
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.paidFrom = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       supplierId = Value(supplierId),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<SupplierDebtEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? supplierId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? refId,
    Expression<String>? note,
    Expression<String>? paidFrom,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (supplierId != null) 'supplier_id': supplierId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
      if (paidFrom != null) 'paid_from': paidFrom,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierDebtEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? supplierId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String?>? refId,
    Value<String?>? note,
    Value<String?>? paidFrom,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SupplierDebtEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      supplierId: supplierId ?? this.supplierId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      refId: refId ?? this.refId,
      note: note ?? this.note,
      paidFrom: paidFrom ?? this.paidFrom,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paidFrom.present) {
      map['paid_from'] = Variable<String>(paidFrom.value);
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
    return (StringBuffer('SupplierDebtEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('supplierId: $supplierId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('paidFrom: $paidFrom, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierReturnsTable extends SupplierReturns
    with TableInfo<$SupplierReturnsTable, SupplierReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
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
  static const VerificationMeta _refundedInCashMeta = const VerificationMeta('refundedInCash');
  @override
  late final GeneratedColumn<bool> refundedInCash = GeneratedColumn<bool>(
    'refunded_in_cash',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("refunded_in_cash" IN (0, 1))'),
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
    supplierId,
    totalMinor,
    refundedInCash,
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
  static const String $name = 'supplier_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('refunded_in_cash')) {
      context.handle(
        _refundedInCashMeta,
        refundedInCash.isAcceptableOrUnknown(data['refunded_in_cash']!, _refundedInCashMeta),
      );
    } else if (isInserting) {
      context.missing(_refundedInCashMeta);
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
  SupplierReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierReturnRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      refundedInCash: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}refunded_in_cash'],
      )!,
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
  $SupplierReturnsTable createAlias(String alias) {
    return $SupplierReturnsTable(attachedDatabase, alias);
  }
}

class SupplierReturnRow extends DataClass implements Insertable<SupplierReturnRow> {
  final String id;
  final String supplierId;
  final int totalMinor;
  final bool refundedInCash;
  final String? note;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const SupplierReturnRow({
    required this.id,
    required this.supplierId,
    required this.totalMinor,
    required this.refundedInCash,
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
    map['supplier_id'] = Variable<String>(supplierId);
    map['total_minor'] = Variable<int>(totalMinor);
    map['refunded_in_cash'] = Variable<bool>(refundedInCash);
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

  SupplierReturnsCompanion toCompanion(bool nullToAbsent) {
    return SupplierReturnsCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      totalMinor: Value(totalMinor),
      refundedInCash: Value(refundedInCash),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory SupplierReturnRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierReturnRow(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      refundedInCash: serializer.fromJson<bool>(json['refundedInCash']),
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
      'supplierId': serializer.toJson<String>(supplierId),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'refundedInCash': serializer.toJson<bool>(refundedInCash),
      'note': serializer.toJson<String?>(note),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SupplierReturnRow copyWith({
    String? id,
    String? supplierId,
    int? totalMinor,
    bool? refundedInCash,
    Value<String?> note = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SupplierReturnRow(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    totalMinor: totalMinor ?? this.totalMinor,
    refundedInCash: refundedInCash ?? this.refundedInCash,
    note: note.present ? note.value : this.note,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SupplierReturnRow copyWithCompanion(SupplierReturnsCompanion data) {
    return SupplierReturnRow(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present ? data.supplierId.value : this.supplierId,
      totalMinor: data.totalMinor.present ? data.totalMinor.value : this.totalMinor,
      refundedInCash: data.refundedInCash.present ? data.refundedInCash.value : this.refundedInCash,
      note: data.note.present ? data.note.value : this.note,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReturnRow(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('refundedInCash: $refundedInCash, ')
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
    supplierId,
    totalMinor,
    refundedInCash,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierReturnRow &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.totalMinor == this.totalMinor &&
          other.refundedInCash == this.refundedInCash &&
          other.note == this.note &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class SupplierReturnsCompanion extends UpdateCompanion<SupplierReturnRow> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<int> totalMinor;
  final Value<bool> refundedInCash;
  final Value<String?> note;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SupplierReturnsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.refundedInCash = const Value.absent(),
    this.note = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierReturnsCompanion.insert({
    required String id,
    required String supplierId,
    required int totalMinor,
    required bool refundedInCash,
    this.note = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       totalMinor = Value(totalMinor),
       refundedInCash = Value(refundedInCash),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<SupplierReturnRow> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<int>? totalMinor,
    Expression<bool>? refundedInCash,
    Expression<String>? note,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (refundedInCash != null) 'refunded_in_cash': refundedInCash,
      if (note != null) 'note': note,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierReturnsCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<int>? totalMinor,
    Value<bool>? refundedInCash,
    Value<String?>? note,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SupplierReturnsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      totalMinor: totalMinor ?? this.totalMinor,
      refundedInCash: refundedInCash ?? this.refundedInCash,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (refundedInCash.present) {
      map['refunded_in_cash'] = Variable<bool>(refundedInCash.value);
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
    return (StringBuffer('SupplierReturnsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('refundedInCash: $refundedInCash, ')
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

class $ExpenseEventsTable extends ExpenseEvents
    with TableInfo<$ExpenseEventsTable, ExpenseEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
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
  static const VerificationMeta _paidFromMeta = const VerificationMeta('paidFrom');
  @override
  late final GeneratedColumn<String> paidFrom = GeneratedColumn<String>(
    'paid_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    category,
    amountMinor,
    currencyCode,
    paidFrom,
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
  static const String $name = 'expense_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
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
    if (data.containsKey('paid_from')) {
      context.handle(
        _paidFromMeta,
        paidFrom.isAcceptableOrUnknown(data['paid_from']!, _paidFromMeta),
      );
    } else if (isInserting) {
      context.missing(_paidFromMeta);
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
  ExpenseEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseEventRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      paidFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_from'],
      )!,
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
  $ExpenseEventsTable createAlias(String alias) {
    return $ExpenseEventsTable(attachedDatabase, alias);
  }
}

class ExpenseEventRow extends DataClass implements Insertable<ExpenseEventRow> {
  final String id;
  final String category;
  final int amountMinor;
  final String currencyCode;

  /// `drawer` | `outside`.
  final String paidFrom;
  final String? note;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const ExpenseEventRow({
    required this.id,
    required this.category,
    required this.amountMinor,
    required this.currencyCode,
    required this.paidFrom,
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
    map['category'] = Variable<String>(category);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['paid_from'] = Variable<String>(paidFrom);
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

  ExpenseEventsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseEventsCompanion(
      id: Value(id),
      category: Value(category),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      paidFrom: Value(paidFrom),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory ExpenseEventRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseEventRow(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      paidFrom: serializer.fromJson<String>(json['paidFrom']),
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
      'category': serializer.toJson<String>(category),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'paidFrom': serializer.toJson<String>(paidFrom),
      'note': serializer.toJson<String?>(note),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ExpenseEventRow copyWith({
    String? id,
    String? category,
    int? amountMinor,
    String? currencyCode,
    String? paidFrom,
    Value<String?> note = const Value.absent(),
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ExpenseEventRow(
    id: id ?? this.id,
    category: category ?? this.category,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    paidFrom: paidFrom ?? this.paidFrom,
    note: note.present ? note.value : this.note,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ExpenseEventRow copyWithCompanion(ExpenseEventsCompanion data) {
    return ExpenseEventRow(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode: data.currencyCode.present ? data.currencyCode.value : this.currencyCode,
      paidFrom: data.paidFrom.present ? data.paidFrom.value : this.paidFrom,
      note: data.note.present ? data.note.value : this.note,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseEventRow(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('paidFrom: $paidFrom, ')
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
    category,
    amountMinor,
    currencyCode,
    paidFrom,
    note,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseEventRow &&
          other.id == this.id &&
          other.category == this.category &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.paidFrom == this.paidFrom &&
          other.note == this.note &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class ExpenseEventsCompanion extends UpdateCompanion<ExpenseEventRow> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> paidFrom;
  final Value<String?> note;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ExpenseEventsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.paidFrom = const Value.absent(),
    this.note = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseEventsCompanion.insert({
    required String id,
    required String category,
    required int amountMinor,
    required String currencyCode,
    required String paidFrom,
    this.note = const Value.absent(),
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       paidFrom = Value(paidFrom),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<ExpenseEventRow> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? paidFrom,
    Expression<String>? note,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (paidFrom != null) 'paid_from': paidFrom,
      if (note != null) 'note': note,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? paidFrom,
    Value<String?>? note,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ExpenseEventsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      paidFrom: paidFrom ?? this.paidFrom,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (paidFrom.present) {
      map['paid_from'] = Variable<String>(paidFrom.value);
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
    return (StringBuffer('ExpenseEventsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('paidFrom: $paidFrom, ')
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

class $StocktakesTable extends Stocktakes with TableInfo<$StocktakesTable, StocktakeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocktakesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedByMeta = const VerificationMeta('startedBy');
  @override
  late final GeneratedColumn<String> startedBy = GeneratedColumn<String>(
    'started_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta('appliedAt');
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scope, startedBy, startedAt, appliedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocktakes';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocktakeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(_scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    }
    if (data.containsKey('started_by')) {
      context.handle(
        _startedByMeta,
        startedBy.isAcceptableOrUnknown(data['started_by']!, _startedByMeta),
      );
    } else if (isInserting) {
      context.missing(_startedByMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StocktakeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocktakeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      ),
      startedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_by'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
    );
  }

  @override
  $StocktakesTable createAlias(String alias) {
    return $StocktakesTable(attachedDatabase, alias);
  }
}

class StocktakeRow extends DataClass implements Insertable<StocktakeRow> {
  final String id;
  final String? scope;
  final String startedBy;
  final DateTime startedAt;
  final DateTime? appliedAt;
  const StocktakeRow({
    required this.id,
    this.scope,
    required this.startedBy,
    required this.startedAt,
    this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || scope != null) {
      map['scope'] = Variable<String>(scope);
    }
    map['started_by'] = Variable<String>(startedBy);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    return map;
  }

  StocktakesCompanion toCompanion(bool nullToAbsent) {
    return StocktakesCompanion(
      id: Value(id),
      scope: scope == null && nullToAbsent ? const Value.absent() : Value(scope),
      startedBy: Value(startedBy),
      startedAt: Value(startedAt),
      appliedAt: appliedAt == null && nullToAbsent ? const Value.absent() : Value(appliedAt),
    );
  }

  factory StocktakeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocktakeRow(
      id: serializer.fromJson<String>(json['id']),
      scope: serializer.fromJson<String?>(json['scope']),
      startedBy: serializer.fromJson<String>(json['startedBy']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scope': serializer.toJson<String?>(scope),
      'startedBy': serializer.toJson<String>(startedBy),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
    };
  }

  StocktakeRow copyWith({
    String? id,
    Value<String?> scope = const Value.absent(),
    String? startedBy,
    DateTime? startedAt,
    Value<DateTime?> appliedAt = const Value.absent(),
  }) => StocktakeRow(
    id: id ?? this.id,
    scope: scope.present ? scope.value : this.scope,
    startedBy: startedBy ?? this.startedBy,
    startedAt: startedAt ?? this.startedAt,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
  );
  StocktakeRow copyWithCompanion(StocktakesCompanion data) {
    return StocktakeRow(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      startedBy: data.startedBy.present ? data.startedBy.value : this.startedBy,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocktakeRow(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('startedBy: $startedBy, ')
          ..write('startedAt: $startedAt, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scope, startedBy, startedAt, appliedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocktakeRow &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.startedBy == this.startedBy &&
          other.startedAt == this.startedAt &&
          other.appliedAt == this.appliedAt);
}

class StocktakesCompanion extends UpdateCompanion<StocktakeRow> {
  final Value<String> id;
  final Value<String?> scope;
  final Value<String> startedBy;
  final Value<DateTime> startedAt;
  final Value<DateTime?> appliedAt;
  final Value<int> rowid;
  const StocktakesCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.startedBy = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocktakesCompanion.insert({
    required String id,
    this.scope = const Value.absent(),
    required String startedBy,
    required DateTime startedAt,
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedBy = Value(startedBy),
       startedAt = Value(startedAt);
  static Insertable<StocktakeRow> custom({
    Expression<String>? id,
    Expression<String>? scope,
    Expression<String>? startedBy,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (startedBy != null) 'started_by': startedBy,
      if (startedAt != null) 'started_at': startedAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocktakesCompanion copyWith({
    Value<String>? id,
    Value<String?>? scope,
    Value<String>? startedBy,
    Value<DateTime>? startedAt,
    Value<DateTime?>? appliedAt,
    Value<int>? rowid,
  }) {
    return StocktakesCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      startedBy: startedBy ?? this.startedBy,
      startedAt: startedAt ?? this.startedAt,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (startedBy.present) {
      map['started_by'] = Variable<String>(startedBy.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocktakesCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('startedBy: $startedBy, ')
          ..write('startedAt: $startedAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocktakeCountsTable extends StocktakeCounts
    with TableInfo<$StocktakeCountsTable, StocktakeCountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocktakeCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stocktakeIdMeta = const VerificationMeta('stocktakeId');
  @override
  late final GeneratedColumn<String> stocktakeId = GeneratedColumn<String>(
    'stocktake_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES stocktakes (id)'),
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
  static const VerificationMeta _countedPiecesMeta = const VerificationMeta('countedPieces');
  @override
  late final GeneratedColumn<int> countedPieces = GeneratedColumn<int>(
    'counted_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemPiecesAtCountMeta = const VerificationMeta(
    'systemPiecesAtCount',
  );
  @override
  late final GeneratedColumn<int> systemPiecesAtCount = GeneratedColumn<int>(
    'system_pieces_at_count',
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
    stocktakeId,
    productId,
    countedPieces,
    systemPiecesAtCount,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocktake_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StocktakeCountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stocktake_id')) {
      context.handle(
        _stocktakeIdMeta,
        stocktakeId.isAcceptableOrUnknown(data['stocktake_id']!, _stocktakeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stocktakeIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('counted_pieces')) {
      context.handle(
        _countedPiecesMeta,
        countedPieces.isAcceptableOrUnknown(data['counted_pieces']!, _countedPiecesMeta),
      );
    } else if (isInserting) {
      context.missing(_countedPiecesMeta);
    }
    if (data.containsKey('system_pieces_at_count')) {
      context.handle(
        _systemPiecesAtCountMeta,
        systemPiecesAtCount.isAcceptableOrUnknown(
          data['system_pieces_at_count']!,
          _systemPiecesAtCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemPiecesAtCountMeta);
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
  StocktakeCountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StocktakeCountRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      stocktakeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stocktake_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      countedPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_pieces'],
      )!,
      systemPiecesAtCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}system_pieces_at_count'],
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
  $StocktakeCountsTable createAlias(String alias) {
    return $StocktakeCountsTable(attachedDatabase, alias);
  }
}

class StocktakeCountRow extends DataClass implements Insertable<StocktakeCountRow> {
  final String id;
  final String stocktakeId;
  final String productId;
  final int countedPieces;
  final int systemPiecesAtCount;
  final String deviceId;
  final String employeeId;
  final DateTime occurredAt;
  final DateTime? syncedAt;
  const StocktakeCountRow({
    required this.id,
    required this.stocktakeId,
    required this.productId,
    required this.countedPieces,
    required this.systemPiecesAtCount,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stocktake_id'] = Variable<String>(stocktakeId);
    map['product_id'] = Variable<String>(productId);
    map['counted_pieces'] = Variable<int>(countedPieces);
    map['system_pieces_at_count'] = Variable<int>(systemPiecesAtCount);
    map['device_id'] = Variable<String>(deviceId);
    map['employee_id'] = Variable<String>(employeeId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  StocktakeCountsCompanion toCompanion(bool nullToAbsent) {
    return StocktakeCountsCompanion(
      id: Value(id),
      stocktakeId: Value(stocktakeId),
      productId: Value(productId),
      countedPieces: Value(countedPieces),
      systemPiecesAtCount: Value(systemPiecesAtCount),
      deviceId: Value(deviceId),
      employeeId: Value(employeeId),
      occurredAt: Value(occurredAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory StocktakeCountRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StocktakeCountRow(
      id: serializer.fromJson<String>(json['id']),
      stocktakeId: serializer.fromJson<String>(json['stocktakeId']),
      productId: serializer.fromJson<String>(json['productId']),
      countedPieces: serializer.fromJson<int>(json['countedPieces']),
      systemPiecesAtCount: serializer.fromJson<int>(json['systemPiecesAtCount']),
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
      'stocktakeId': serializer.toJson<String>(stocktakeId),
      'productId': serializer.toJson<String>(productId),
      'countedPieces': serializer.toJson<int>(countedPieces),
      'systemPiecesAtCount': serializer.toJson<int>(systemPiecesAtCount),
      'deviceId': serializer.toJson<String>(deviceId),
      'employeeId': serializer.toJson<String>(employeeId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  StocktakeCountRow copyWith({
    String? id,
    String? stocktakeId,
    String? productId,
    int? countedPieces,
    int? systemPiecesAtCount,
    String? deviceId,
    String? employeeId,
    DateTime? occurredAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => StocktakeCountRow(
    id: id ?? this.id,
    stocktakeId: stocktakeId ?? this.stocktakeId,
    productId: productId ?? this.productId,
    countedPieces: countedPieces ?? this.countedPieces,
    systemPiecesAtCount: systemPiecesAtCount ?? this.systemPiecesAtCount,
    deviceId: deviceId ?? this.deviceId,
    employeeId: employeeId ?? this.employeeId,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  StocktakeCountRow copyWithCompanion(StocktakeCountsCompanion data) {
    return StocktakeCountRow(
      id: data.id.present ? data.id.value : this.id,
      stocktakeId: data.stocktakeId.present ? data.stocktakeId.value : this.stocktakeId,
      productId: data.productId.present ? data.productId.value : this.productId,
      countedPieces: data.countedPieces.present ? data.countedPieces.value : this.countedPieces,
      systemPiecesAtCount: data.systemPiecesAtCount.present
          ? data.systemPiecesAtCount.value
          : this.systemPiecesAtCount,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      employeeId: data.employeeId.present ? data.employeeId.value : this.employeeId,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StocktakeCountRow(')
          ..write('id: $id, ')
          ..write('stocktakeId: $stocktakeId, ')
          ..write('productId: $productId, ')
          ..write('countedPieces: $countedPieces, ')
          ..write('systemPiecesAtCount: $systemPiecesAtCount, ')
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
    stocktakeId,
    productId,
    countedPieces,
    systemPiecesAtCount,
    deviceId,
    employeeId,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StocktakeCountRow &&
          other.id == this.id &&
          other.stocktakeId == this.stocktakeId &&
          other.productId == this.productId &&
          other.countedPieces == this.countedPieces &&
          other.systemPiecesAtCount == this.systemPiecesAtCount &&
          other.deviceId == this.deviceId &&
          other.employeeId == this.employeeId &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class StocktakeCountsCompanion extends UpdateCompanion<StocktakeCountRow> {
  final Value<String> id;
  final Value<String> stocktakeId;
  final Value<String> productId;
  final Value<int> countedPieces;
  final Value<int> systemPiecesAtCount;
  final Value<String> deviceId;
  final Value<String> employeeId;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const StocktakeCountsCompanion({
    this.id = const Value.absent(),
    this.stocktakeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.countedPieces = const Value.absent(),
    this.systemPiecesAtCount = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocktakeCountsCompanion.insert({
    required String id,
    required String stocktakeId,
    required String productId,
    required int countedPieces,
    required int systemPiecesAtCount,
    required String deviceId,
    required String employeeId,
    required DateTime occurredAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stocktakeId = Value(stocktakeId),
       productId = Value(productId),
       countedPieces = Value(countedPieces),
       systemPiecesAtCount = Value(systemPiecesAtCount),
       deviceId = Value(deviceId),
       employeeId = Value(employeeId),
       occurredAt = Value(occurredAt);
  static Insertable<StocktakeCountRow> custom({
    Expression<String>? id,
    Expression<String>? stocktakeId,
    Expression<String>? productId,
    Expression<int>? countedPieces,
    Expression<int>? systemPiecesAtCount,
    Expression<String>? deviceId,
    Expression<String>? employeeId,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stocktakeId != null) 'stocktake_id': stocktakeId,
      if (productId != null) 'product_id': productId,
      if (countedPieces != null) 'counted_pieces': countedPieces,
      if (systemPiecesAtCount != null) 'system_pieces_at_count': systemPiecesAtCount,
      if (deviceId != null) 'device_id': deviceId,
      if (employeeId != null) 'employee_id': employeeId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocktakeCountsCompanion copyWith({
    Value<String>? id,
    Value<String>? stocktakeId,
    Value<String>? productId,
    Value<int>? countedPieces,
    Value<int>? systemPiecesAtCount,
    Value<String>? deviceId,
    Value<String>? employeeId,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return StocktakeCountsCompanion(
      id: id ?? this.id,
      stocktakeId: stocktakeId ?? this.stocktakeId,
      productId: productId ?? this.productId,
      countedPieces: countedPieces ?? this.countedPieces,
      systemPiecesAtCount: systemPiecesAtCount ?? this.systemPiecesAtCount,
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
    if (stocktakeId.present) {
      map['stocktake_id'] = Variable<String>(stocktakeId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (countedPieces.present) {
      map['counted_pieces'] = Variable<int>(countedPieces.value);
    }
    if (systemPiecesAtCount.present) {
      map['system_pieces_at_count'] = Variable<int>(systemPiecesAtCount.value);
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
    return (StringBuffer('StocktakeCountsCompanion(')
          ..write('id: $id, ')
          ..write('stocktakeId: $stocktakeId, ')
          ..write('productId: $productId, ')
          ..write('countedPieces: $countedPieces, ')
          ..write('systemPiecesAtCount: $systemPiecesAtCount, ')
          ..write('deviceId: $deviceId, ')
          ..write('employeeId: $employeeId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrdersTable extends PurchaseOrders
    with TableInfo<$PurchaseOrdersTable, PurchaseOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, supplierId, status, note, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
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
  PurchaseOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrderRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
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
  $PurchaseOrdersTable createAlias(String alias) {
    return $PurchaseOrdersTable(attachedDatabase, alias);
  }
}

class PurchaseOrderRow extends DataClass implements Insertable<PurchaseOrderRow> {
  final String id;
  final String supplierId;

  /// `draft` | `sent` | `received`.
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PurchaseOrderRow({
    required this.id,
    required this.supplierId,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PurchaseOrdersCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrdersCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PurchaseOrderRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrderRow(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PurchaseOrderRow copyWith({
    String? id,
    String? supplierId,
    String? status,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PurchaseOrderRow(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PurchaseOrderRow copyWithCompanion(PurchaseOrdersCompanion data) {
    return PurchaseOrderRow(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present ? data.supplierId.value : this.supplierId,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderRow(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supplierId, status, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrderRow &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PurchaseOrdersCompanion extends UpdateCompanion<PurchaseOrderRow> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String> status;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PurchaseOrdersCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrdersCompanion.insert({
    required String id,
    required String supplierId,
    required String status,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PurchaseOrderRow> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String>? status,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PurchaseOrdersCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      note: note ?? this.note,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('PurchaseOrdersCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseOrderLinesTable extends PurchaseOrderLines
    with TableInfo<$PurchaseOrderLinesTable, PurchaseOrderLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES purchase_orders (id)'),
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
  @override
  List<GeneratedColumn> get $columns => [id, orderId, productId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseOrderLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta, orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseOrderLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseOrderLineRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $PurchaseOrderLinesTable createAlias(String alias) {
    return $PurchaseOrderLinesTable(attachedDatabase, alias);
  }
}

class PurchaseOrderLineRow extends DataClass implements Insertable<PurchaseOrderLineRow> {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  const PurchaseOrderLineRow({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<String>(productId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  PurchaseOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseOrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
    );
  }

  factory PurchaseOrderLineRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseOrderLineRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<String>(productId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  PurchaseOrderLineRow copyWith({String? id, String? orderId, String? productId, int? quantity}) =>
      PurchaseOrderLineRow(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
      );
  PurchaseOrderLineRow copyWithCompanion(PurchaseOrderLinesCompanion data) {
    return PurchaseOrderLineRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderLineRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, productId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseOrderLineRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity);
}

class PurchaseOrderLinesCompanion extends UpdateCompanion<PurchaseOrderLineRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<int> quantity;
  final Value<int> rowid;
  const PurchaseOrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseOrderLinesCompanion.insert({
    required String id,
    required String orderId,
    required String productId,
    required int quantity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       productId = Value(productId),
       quantity = Value(quantity);
  static Insertable<PurchaseOrderLineRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseOrderLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? productId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return PurchaseOrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
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
  late final $TillEventsTable tillEvents = $TillEventsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseLinesTable purchaseLines = $PurchaseLinesTable(this);
  late final $SupplierDebtEventsTable supplierDebtEvents = $SupplierDebtEventsTable(this);
  late final $SupplierReturnsTable supplierReturns = $SupplierReturnsTable(this);
  late final $ExpenseEventsTable expenseEvents = $ExpenseEventsTable(this);
  late final $StocktakesTable stocktakes = $StocktakesTable(this);
  late final $StocktakeCountsTable stocktakeCounts = $StocktakeCountsTable(this);
  late final $PurchaseOrdersTable purchaseOrders = $PurchaseOrdersTable(this);
  late final $PurchaseOrderLinesTable purchaseOrderLines = $PurchaseOrderLinesTable(this);
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
    tillEvents,
    suppliers,
    purchases,
    purchaseLines,
    supplierDebtEvents,
    supplierReturns,
    expenseEvents,
    stocktakes,
    stocktakeCounts,
    purchaseOrders,
    purchaseOrderLines,
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
  Value<String?> refId,
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
  Value<String?> refId,
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

  ColumnFilters<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);
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
                Value<String?> refId = const Value.absent(),
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
                refId: refId,
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
                Value<String?> refId = const Value.absent(),
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
                refId: refId,
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
  Value<int?> tenderedMinor,
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
  Value<int?> tenderedMinor,
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

  ColumnFilters<int> get tenderedMinor =>
      $composableBuilder(column: $table.tenderedMinor, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<int> get tenderedMinor => $composableBuilder(
    column: $table.tenderedMinor,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get tenderedMinor =>
      $composableBuilder(column: $table.tenderedMinor, builder: (column) => column);

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
                Value<int?> tenderedMinor = const Value.absent(),
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
                tenderedMinor: tenderedMinor,
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
                Value<int?> tenderedMinor = const Value.absent(),
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
                tenderedMinor: tenderedMinor,
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
typedef $$TillEventsTableCreateCompanionBuilder = TillEventsCompanion Function({
  required String id,
  required String type,
  required String shiftId,
  required int amountMinor,
  Value<String?> note,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$TillEventsTableUpdateCompanionBuilder = TillEventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> shiftId,
  Value<int> amountMinor,
  Value<String?> note,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$TillEventsTableFilterComposer extends Composer<_$AppDatabase, $TillEventsTable> {
  $$TillEventsTableFilterComposer({
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

  ColumnFilters<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnFilters(column));

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

class $$TillEventsTableOrderingComposer extends Composer<_$AppDatabase, $TillEventsTable> {
  $$TillEventsTableOrderingComposer({
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

  ColumnOrderings<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

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

class $$TillEventsTableAnnotationComposer extends Composer<_$AppDatabase, $TillEventsTable> {
  $$TillEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => column);

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

class $$TillEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TillEventsTable,
          TillEventRow,
          $$TillEventsTableFilterComposer,
          $$TillEventsTableOrderingComposer,
          $$TillEventsTableAnnotationComposer,
          $$TillEventsTableCreateCompanionBuilder,
          $$TillEventsTableUpdateCompanionBuilder,
          (TillEventRow, BaseReferences<_$AppDatabase, $TillEventsTable, TillEventRow>),
          TillEventRow,
          PrefetchHooks Function()
        > {
  $$TillEventsTableTableManager(_$AppDatabase db, $TillEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TillEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TillEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TillEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TillEventsCompanion(
                id: id,
                type: type,
                shiftId: shiftId,
                amountMinor: amountMinor,
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
                required String shiftId,
                required int amountMinor,
                Value<String?> note = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TillEventsCompanion.insert(
                id: id,
                type: type,
                shiftId: shiftId,
                amountMinor: amountMinor,
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
                  e.readTable<$TillEventsTable, TillEventRow>(table),
                  BaseReferences<_$AppDatabase, $TillEventsTable, TillEventRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TillEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TillEventsTable,
      TillEventRow,
      $$TillEventsTableFilterComposer,
      $$TillEventsTableOrderingComposer,
      $$TillEventsTableAnnotationComposer,
      $$TillEventsTableCreateCompanionBuilder,
      $$TillEventsTableUpdateCompanionBuilder,
      (TillEventRow, BaseReferences<_$AppDatabase, $TillEventsTable, TillEventRow>),
      TillEventRow,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> repName,
  Value<String?> notes,
  Value<int?> creditLimitMinor,
  Value<bool> active,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> repName,
  Value<String?> notes,
  Value<int?> creditLimitMinor,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get repName =>
      $composableBuilder(column: $table.repName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get repName =>
      $composableBuilder(column: $table.repName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
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

  GeneratedColumn<String> get repName =>
      $composableBuilder(column: $table.repName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get creditLimitMinor =>
      $composableBuilder(column: $table.creditLimitMinor, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierRow,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (SupplierRow, BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>),
          SupplierRow,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> repName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                phone: phone,
                repName: repName,
                notes: notes,
                creditLimitMinor: creditLimitMinor,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> repName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                repName: repName,
                notes: notes,
                creditLimitMinor: creditLimitMinor,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, SupplierRow>(table),
                  BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierRow,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (SupplierRow, BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>),
      SupplierRow,
      PrefetchHooks Function()
    >;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String supplierId,
  Value<String?> supplierInvoiceNo,
  required String payment,
  Value<String?> paidFrom,
  required String currencyCode,
  required int grossMinor,
  required int lineDiscountsMinor,
  required int invoiceDiscountMinor,
  required int transportMinor,
  required int totalMinor,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> supplierId,
  Value<String?> supplierInvoiceNo,
  Value<String> payment,
  Value<String?> paidFrom,
  Value<String> currencyCode,
  Value<int> grossMinor,
  Value<int> lineDiscountsMinor,
  Value<int> invoiceDiscountMinor,
  Value<int> transportMinor,
  Value<int> totalMinor,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLineRow>> _purchaseLinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: 'purchases__id__purchase_lines__purchase_id',
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PurchasesTableFilterComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierInvoiceNo => $composableBuilder(
    column: $table.supplierInvoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grossMinor =>
      $composableBuilder(column: $table.grossMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineDiscountsMinor => $composableBuilder(
    column: $table.lineDiscountsMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invoiceDiscountMinor => $composableBuilder(
    column: $table.invoiceDiscountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transportMinor =>
      $composableBuilder(column: $table.transportMinor, builder: (column) => ColumnFilters(column));

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

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableOrderingComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierInvoiceNo => $composableBuilder(
    column: $table.supplierInvoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grossMinor =>
      $composableBuilder(column: $table.grossMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineDiscountsMinor => $composableBuilder(
    column: $table.lineDiscountsMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceDiscountMinor => $composableBuilder(
    column: $table.invoiceDiscountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transportMinor => $composableBuilder(
    column: $table.transportMinor,
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

class $$PurchasesTableAnnotationComposer extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get supplierInvoiceNo =>
      $composableBuilder(column: $table.supplierInvoiceNo, builder: (column) => column);

  GeneratedColumn<String> get payment =>
      $composableBuilder(column: $table.payment, builder: (column) => column);

  GeneratedColumn<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<int> get grossMinor =>
      $composableBuilder(column: $table.grossMinor, builder: (column) => column);

  GeneratedColumn<int> get lineDiscountsMinor =>
      $composableBuilder(column: $table.lineDiscountsMinor, builder: (column) => column);

  GeneratedColumn<int> get invoiceDiscountMinor =>
      $composableBuilder(column: $table.invoiceDiscountMinor, builder: (column) => column);

  GeneratedColumn<int> get transportMinor =>
      $composableBuilder(column: $table.transportMinor, builder: (column) => column);

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

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          PurchaseRow,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (PurchaseRow, $$PurchasesTableReferences),
          PurchaseRow,
          PrefetchHooks Function({bool purchaseLinesRefs})
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String?> supplierInvoiceNo = const Value.absent(),
                Value<String> payment = const Value.absent(),
                Value<String?> paidFrom = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> grossMinor = const Value.absent(),
                Value<int> lineDiscountsMinor = const Value.absent(),
                Value<int> invoiceDiscountMinor = const Value.absent(),
                Value<int> transportMinor = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                supplierId: supplierId,
                supplierInvoiceNo: supplierInvoiceNo,
                payment: payment,
                paidFrom: paidFrom,
                currencyCode: currencyCode,
                grossMinor: grossMinor,
                lineDiscountsMinor: lineDiscountsMinor,
                invoiceDiscountMinor: invoiceDiscountMinor,
                transportMinor: transportMinor,
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
                required String supplierId,
                Value<String?> supplierInvoiceNo = const Value.absent(),
                required String payment,
                Value<String?> paidFrom = const Value.absent(),
                required String currencyCode,
                required int grossMinor,
                required int lineDiscountsMinor,
                required int invoiceDiscountMinor,
                required int transportMinor,
                required int totalMinor,
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                supplierId: supplierId,
                supplierInvoiceNo: supplierInvoiceNo,
                payment: payment,
                paidFrom: paidFrom,
                currencyCode: currencyCode,
                grossMinor: grossMinor,
                lineDiscountsMinor: lineDiscountsMinor,
                invoiceDiscountMinor: invoiceDiscountMinor,
                transportMinor: transportMinor,
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
                  e.readTable<$PurchasesTable, PurchaseRow>(table),
                  $$PurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (purchaseLinesRefs) db.purchaseLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseLinesRefs)
                    await $_getPrefetchedData<PurchaseRow, $PurchasesTable, PurchaseLineRow>(
                      currentTable: table,
                      referencedTable: $$PurchasesTableReferences._purchaseLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PurchasesTableReferences(db, table, p0).purchaseLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.purchaseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      PurchaseRow,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (PurchaseRow, $$PurchasesTableReferences),
      PurchaseRow,
      PrefetchHooks Function({bool purchaseLinesRefs})
    >;
typedef $$PurchaseLinesTableCreateCompanionBuilder = PurchaseLinesCompanion Function({
  required String id,
  required String purchaseId,
  required String productId,
  required int quantity,
  required int bonus,
  required int piecesPerUnit,
  required int unitPriceMinor,
  required int discountBasisPoints,
  required int costMinor,
  required String batchId,
  Value<DateTime?> expiry,
  Value<int> rowid,
});
typedef $$PurchaseLinesTableUpdateCompanionBuilder = PurchaseLinesCompanion Function({
  Value<String> id,
  Value<String> purchaseId,
  Value<String> productId,
  Value<int> quantity,
  Value<int> bonus,
  Value<int> piecesPerUnit,
  Value<int> unitPriceMinor,
  Value<int> discountBasisPoints,
  Value<int> costMinor,
  Value<String> batchId,
  Value<DateTime?> expiry,
  Value<int> rowid,
});

final class $$PurchaseLinesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLineRow> {
  $$PurchaseLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchase_lines__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PurchaseLinesTableFilterComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableFilterComposer({
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

  ColumnFilters<int> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountBasisPoints => $composableBuilder(
    column: $table.discountBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costMinor =>
      $composableBuilder(column: $table.costMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => ColumnFilters(column));

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableOrderingComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableOrderingComposer({
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

  ColumnOrderings<int> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get piecesPerUnit => $composableBuilder(
    column: $table.piecesPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountBasisPoints => $composableBuilder(
    column: $table.discountBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costMinor =>
      $composableBuilder(column: $table.costMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => ColumnOrderings(column));

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableAnnotationComposer extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableAnnotationComposer({
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

  GeneratedColumn<int> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => column);

  GeneratedColumn<int> get piecesPerUnit =>
      $composableBuilder(column: $table.piecesPerUnit, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor =>
      $composableBuilder(column: $table.unitPriceMinor, builder: (column) => column);

  GeneratedColumn<int> get discountBasisPoints =>
      $composableBuilder(column: $table.discountBasisPoints, builder: (column) => column);

  GeneratedColumn<int> get costMinor =>
      $composableBuilder(column: $table.costMinor, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseLinesTable,
          PurchaseLineRow,
          $$PurchaseLinesTableFilterComposer,
          $$PurchaseLinesTableOrderingComposer,
          $$PurchaseLinesTableAnnotationComposer,
          $$PurchaseLinesTableCreateCompanionBuilder,
          $$PurchaseLinesTableUpdateCompanionBuilder,
          (PurchaseLineRow, $$PurchaseLinesTableReferences),
          PurchaseLineRow,
          PrefetchHooks Function({bool purchaseId})
        > {
  $$PurchaseLinesTableTableManager(_$AppDatabase db, $PurchaseLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PurchaseLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> bonus = const Value.absent(),
                Value<int> piecesPerUnit = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> discountBasisPoints = const Value.absent(),
                Value<int> costMinor = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<DateTime?> expiry = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion(
                id: id,
                purchaseId: purchaseId,
                productId: productId,
                quantity: quantity,
                bonus: bonus,
                piecesPerUnit: piecesPerUnit,
                unitPriceMinor: unitPriceMinor,
                discountBasisPoints: discountBasisPoints,
                costMinor: costMinor,
                batchId: batchId,
                expiry: expiry,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String productId,
                required int quantity,
                required int bonus,
                required int piecesPerUnit,
                required int unitPriceMinor,
                required int discountBasisPoints,
                required int costMinor,
                required String batchId,
                Value<DateTime?> expiry = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                productId: productId,
                quantity: quantity,
                bonus: bonus,
                piecesPerUnit: piecesPerUnit,
                unitPriceMinor: unitPriceMinor,
                discountBasisPoints: discountBasisPoints,
                costMinor: costMinor,
                batchId: batchId,
                expiry: expiry,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseLinesTable, PurchaseLineRow>(table),
                  $$PurchaseLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
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
                    if (purchaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.purchaseId,
                        referencedTable: $$PurchaseLinesTableReferences._purchaseIdTable(db),
                        referencedColumn: $$PurchaseLinesTableReferences._purchaseIdTable(db).id,
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

typedef $$PurchaseLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseLinesTable,
      PurchaseLineRow,
      $$PurchaseLinesTableFilterComposer,
      $$PurchaseLinesTableOrderingComposer,
      $$PurchaseLinesTableAnnotationComposer,
      $$PurchaseLinesTableCreateCompanionBuilder,
      $$PurchaseLinesTableUpdateCompanionBuilder,
      (PurchaseLineRow, $$PurchaseLinesTableReferences),
      PurchaseLineRow,
      PrefetchHooks Function({bool purchaseId})
    >;
typedef $$SupplierDebtEventsTableCreateCompanionBuilder = SupplierDebtEventsCompanion Function({
  required String id,
  required String type,
  required String supplierId,
  required int amountMinor,
  required String currencyCode,
  Value<String?> refId,
  Value<String?> note,
  Value<String?> paidFrom,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SupplierDebtEventsTableUpdateCompanionBuilder = SupplierDebtEventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> supplierId,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<String?> refId,
  Value<String?> note,
  Value<String?> paidFrom,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$SupplierDebtEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierDebtEventsTable> {
  $$SupplierDebtEventsTableFilterComposer({
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

  ColumnFilters<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$SupplierDebtEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierDebtEventsTable> {
  $$SupplierDebtEventsTableOrderingComposer({
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

  ColumnOrderings<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$SupplierDebtEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierDebtEventsTable> {
  $$SupplierDebtEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SupplierDebtEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierDebtEventsTable,
          SupplierDebtEventRow,
          $$SupplierDebtEventsTableFilterComposer,
          $$SupplierDebtEventsTableOrderingComposer,
          $$SupplierDebtEventsTableAnnotationComposer,
          $$SupplierDebtEventsTableCreateCompanionBuilder,
          $$SupplierDebtEventsTableUpdateCompanionBuilder,
          (
            SupplierDebtEventRow,
            BaseReferences<_$AppDatabase, $SupplierDebtEventsTable, SupplierDebtEventRow>,
          ),
          SupplierDebtEventRow,
          PrefetchHooks Function()
        > {
  $$SupplierDebtEventsTableTableManager(_$AppDatabase db, $SupplierDebtEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierDebtEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierDebtEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierDebtEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paidFrom = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierDebtEventsCompanion(
                id: id,
                type: type,
                supplierId: supplierId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                refId: refId,
                note: note,
                paidFrom: paidFrom,
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
                required String supplierId,
                required int amountMinor,
                required String currencyCode,
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paidFrom = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierDebtEventsCompanion.insert(
                id: id,
                type: type,
                supplierId: supplierId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                refId: refId,
                note: note,
                paidFrom: paidFrom,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierDebtEventsTable, SupplierDebtEventRow>(table),
                  BaseReferences<_$AppDatabase, $SupplierDebtEventsTable, SupplierDebtEventRow>(
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

typedef $$SupplierDebtEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierDebtEventsTable,
      SupplierDebtEventRow,
      $$SupplierDebtEventsTableFilterComposer,
      $$SupplierDebtEventsTableOrderingComposer,
      $$SupplierDebtEventsTableAnnotationComposer,
      $$SupplierDebtEventsTableCreateCompanionBuilder,
      $$SupplierDebtEventsTableUpdateCompanionBuilder,
      (
        SupplierDebtEventRow,
        BaseReferences<_$AppDatabase, $SupplierDebtEventsTable, SupplierDebtEventRow>,
      ),
      SupplierDebtEventRow,
      PrefetchHooks Function()
    >;
typedef $$SupplierReturnsTableCreateCompanionBuilder = SupplierReturnsCompanion Function({
  required String id,
  required String supplierId,
  required int totalMinor,
  required bool refundedInCash,
  Value<String?> note,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SupplierReturnsTableUpdateCompanionBuilder = SupplierReturnsCompanion Function({
  Value<String> id,
  Value<String> supplierId,
  Value<int> totalMinor,
  Value<bool> refundedInCash,
  Value<String?> note,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$SupplierReturnsTableFilterComposer extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get refundedInCash =>
      $composableBuilder(column: $table.refundedInCash, builder: (column) => ColumnFilters(column));

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

class $$SupplierReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get refundedInCash => $composableBuilder(
    column: $table.refundedInCash,
    builder: (column) => ColumnOrderings(column),
  );

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

class $$SupplierReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<int> get totalMinor =>
      $composableBuilder(column: $table.totalMinor, builder: (column) => column);

  GeneratedColumn<bool> get refundedInCash =>
      $composableBuilder(column: $table.refundedInCash, builder: (column) => column);

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

class $$SupplierReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierReturnsTable,
          SupplierReturnRow,
          $$SupplierReturnsTableFilterComposer,
          $$SupplierReturnsTableOrderingComposer,
          $$SupplierReturnsTableAnnotationComposer,
          $$SupplierReturnsTableCreateCompanionBuilder,
          $$SupplierReturnsTableUpdateCompanionBuilder,
          (
            SupplierReturnRow,
            BaseReferences<_$AppDatabase, $SupplierReturnsTable, SupplierReturnRow>,
          ),
          SupplierReturnRow,
          PrefetchHooks Function()
        > {
  $$SupplierReturnsTableTableManager(_$AppDatabase db, $SupplierReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<bool> refundedInCash = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnsCompanion(
                id: id,
                supplierId: supplierId,
                totalMinor: totalMinor,
                refundedInCash: refundedInCash,
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
                required String supplierId,
                required int totalMinor,
                required bool refundedInCash,
                Value<String?> note = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnsCompanion.insert(
                id: id,
                supplierId: supplierId,
                totalMinor: totalMinor,
                refundedInCash: refundedInCash,
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
                  e.readTable<$SupplierReturnsTable, SupplierReturnRow>(table),
                  BaseReferences<_$AppDatabase, $SupplierReturnsTable, SupplierReturnRow>(
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

typedef $$SupplierReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierReturnsTable,
      SupplierReturnRow,
      $$SupplierReturnsTableFilterComposer,
      $$SupplierReturnsTableOrderingComposer,
      $$SupplierReturnsTableAnnotationComposer,
      $$SupplierReturnsTableCreateCompanionBuilder,
      $$SupplierReturnsTableUpdateCompanionBuilder,
      (SupplierReturnRow, BaseReferences<_$AppDatabase, $SupplierReturnsTable, SupplierReturnRow>),
      SupplierReturnRow,
      PrefetchHooks Function()
    >;
typedef $$ExpenseEventsTableCreateCompanionBuilder = ExpenseEventsCompanion Function({
  required String id,
  required String category,
  required int amountMinor,
  required String currencyCode,
  required String paidFrom,
  Value<String?> note,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$ExpenseEventsTableUpdateCompanionBuilder = ExpenseEventsCompanion Function({
  Value<String> id,
  Value<String> category,
  Value<int> amountMinor,
  Value<String> currencyCode,
  Value<String> paidFrom,
  Value<String?> note,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$ExpenseEventsTableFilterComposer extends Composer<_$AppDatabase, $ExpenseEventsTable> {
  $$ExpenseEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnFilters(column));

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

class $$ExpenseEventsTableOrderingComposer extends Composer<_$AppDatabase, $ExpenseEventsTable> {
  $$ExpenseEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => ColumnOrderings(column));

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

class $$ExpenseEventsTableAnnotationComposer extends Composer<_$AppDatabase, $ExpenseEventsTable> {
  $$ExpenseEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountMinor =>
      $composableBuilder(column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currencyCode =>
      $composableBuilder(column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get paidFrom =>
      $composableBuilder(column: $table.paidFrom, builder: (column) => column);

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

class $$ExpenseEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseEventsTable,
          ExpenseEventRow,
          $$ExpenseEventsTableFilterComposer,
          $$ExpenseEventsTableOrderingComposer,
          $$ExpenseEventsTableAnnotationComposer,
          $$ExpenseEventsTableCreateCompanionBuilder,
          $$ExpenseEventsTableUpdateCompanionBuilder,
          (ExpenseEventRow, BaseReferences<_$AppDatabase, $ExpenseEventsTable, ExpenseEventRow>),
          ExpenseEventRow,
          PrefetchHooks Function()
        > {
  $$ExpenseEventsTableTableManager(_$AppDatabase db, $ExpenseEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExpenseEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> paidFrom = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseEventsCompanion(
                id: id,
                category: category,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                paidFrom: paidFrom,
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
                required String category,
                required int amountMinor,
                required String currencyCode,
                required String paidFrom,
                Value<String?> note = const Value.absent(),
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseEventsCompanion.insert(
                id: id,
                category: category,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                paidFrom: paidFrom,
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
                  e.readTable<$ExpenseEventsTable, ExpenseEventRow>(table),
                  BaseReferences<_$AppDatabase, $ExpenseEventsTable, ExpenseEventRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseEventsTable,
      ExpenseEventRow,
      $$ExpenseEventsTableFilterComposer,
      $$ExpenseEventsTableOrderingComposer,
      $$ExpenseEventsTableAnnotationComposer,
      $$ExpenseEventsTableCreateCompanionBuilder,
      $$ExpenseEventsTableUpdateCompanionBuilder,
      (ExpenseEventRow, BaseReferences<_$AppDatabase, $ExpenseEventsTable, ExpenseEventRow>),
      ExpenseEventRow,
      PrefetchHooks Function()
    >;
typedef $$StocktakesTableCreateCompanionBuilder = StocktakesCompanion Function({
  required String id,
  Value<String?> scope,
  required String startedBy,
  required DateTime startedAt,
  Value<DateTime?> appliedAt,
  Value<int> rowid,
});
typedef $$StocktakesTableUpdateCompanionBuilder = StocktakesCompanion Function({
  Value<String> id,
  Value<String?> scope,
  Value<String> startedBy,
  Value<DateTime> startedAt,
  Value<DateTime?> appliedAt,
  Value<int> rowid,
});

final class $$StocktakesTableReferences
    extends BaseReferences<_$AppDatabase, $StocktakesTable, StocktakeRow> {
  $$StocktakesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StocktakeCountsTable, List<StocktakeCountRow>>
  _stocktakeCountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stocktakeCounts,
    aliasName: 'stocktakes__id__stocktake_counts__stocktake_id',
  );

  $$StocktakeCountsTableProcessedTableManager get stocktakeCountsRefs {
    final manager = $$StocktakeCountsTableTableManager(
      $_db,
      $_db.stocktakeCounts,
    ).filter((f) => f.stocktakeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stocktakeCountsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StocktakesTableFilterComposer extends Composer<_$AppDatabase, $StocktakesTable> {
  $$StocktakesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedBy =>
      $composableBuilder(column: $table.startedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> stocktakeCountsRefs(
    Expression<bool> Function($$StocktakeCountsTableFilterComposer f) f,
  ) {
    final $$StocktakeCountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stocktakeCounts,
      getReferencedColumn: (t) => t.stocktakeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$StocktakeCountsTableFilterComposer(
            $db: $db,
            $table: $db.stocktakeCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StocktakesTableOrderingComposer extends Composer<_$AppDatabase, $StocktakesTable> {
  $$StocktakesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedBy =>
      $composableBuilder(column: $table.startedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => ColumnOrderings(column));
}

class $$StocktakesTableAnnotationComposer extends Composer<_$AppDatabase, $StocktakesTable> {
  $$StocktakesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get startedBy =>
      $composableBuilder(column: $table.startedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  Expression<T> stocktakeCountsRefs<T extends Object>(
    Expression<T> Function($$StocktakeCountsTableAnnotationComposer a) f,
  ) {
    final $$StocktakeCountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stocktakeCounts,
      getReferencedColumn: (t) => t.stocktakeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$StocktakeCountsTableAnnotationComposer(
            $db: $db,
            $table: $db.stocktakeCounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StocktakesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocktakesTable,
          StocktakeRow,
          $$StocktakesTableFilterComposer,
          $$StocktakesTableOrderingComposer,
          $$StocktakesTableAnnotationComposer,
          $$StocktakesTableCreateCompanionBuilder,
          $$StocktakesTableUpdateCompanionBuilder,
          (StocktakeRow, $$StocktakesTableReferences),
          StocktakeRow,
          PrefetchHooks Function({bool stocktakeCountsRefs})
        > {
  $$StocktakesTableTableManager(_$AppDatabase db, $StocktakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StocktakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StocktakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocktakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> scope = const Value.absent(),
                Value<String> startedBy = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocktakesCompanion(
                id: id,
                scope: scope,
                startedBy: startedBy,
                startedAt: startedAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> scope = const Value.absent(),
                required String startedBy,
                required DateTime startedAt,
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocktakesCompanion.insert(
                id: id,
                scope: scope,
                startedBy: startedBy,
                startedAt: startedAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StocktakesTable, StocktakeRow>(table),
                  $$StocktakesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stocktakeCountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stocktakeCountsRefs) db.stocktakeCounts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stocktakeCountsRefs)
                    await $_getPrefetchedData<StocktakeRow, $StocktakesTable, StocktakeCountRow>(
                      currentTable: table,
                      referencedTable: $$StocktakesTableReferences._stocktakeCountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StocktakesTableReferences(db, table, p0).stocktakeCountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stocktakeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StocktakesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocktakesTable,
      StocktakeRow,
      $$StocktakesTableFilterComposer,
      $$StocktakesTableOrderingComposer,
      $$StocktakesTableAnnotationComposer,
      $$StocktakesTableCreateCompanionBuilder,
      $$StocktakesTableUpdateCompanionBuilder,
      (StocktakeRow, $$StocktakesTableReferences),
      StocktakeRow,
      PrefetchHooks Function({bool stocktakeCountsRefs})
    >;
typedef $$StocktakeCountsTableCreateCompanionBuilder = StocktakeCountsCompanion Function({
  required String id,
  required String stocktakeId,
  required String productId,
  required int countedPieces,
  required int systemPiecesAtCount,
  required String deviceId,
  required String employeeId,
  required DateTime occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$StocktakeCountsTableUpdateCompanionBuilder = StocktakeCountsCompanion Function({
  Value<String> id,
  Value<String> stocktakeId,
  Value<String> productId,
  Value<int> countedPieces,
  Value<int> systemPiecesAtCount,
  Value<String> deviceId,
  Value<String> employeeId,
  Value<DateTime> occurredAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$StocktakeCountsTableReferences
    extends BaseReferences<_$AppDatabase, $StocktakeCountsTable, StocktakeCountRow> {
  $$StocktakeCountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StocktakesTable _stocktakeIdTable(_$AppDatabase db) =>
      db.stocktakes.createAlias('stocktake_counts__stocktake_id__stocktakes__id');

  $$StocktakesTableProcessedTableManager get stocktakeId {
    final $_column = $_itemColumn<String>('stocktake_id')!;

    final manager = $$StocktakesTableTableManager(
      $_db,
      $_db.stocktakes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stocktakeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StocktakeCountsTableFilterComposer extends Composer<_$AppDatabase, $StocktakeCountsTable> {
  $$StocktakeCountsTableFilterComposer({
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

  ColumnFilters<int> get countedPieces =>
      $composableBuilder(column: $table.countedPieces, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get systemPiecesAtCount => $composableBuilder(
    column: $table.systemPiecesAtCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  $$StocktakesTableFilterComposer get stocktakeId {
    final $$StocktakesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocktakeId,
      referencedTable: $db.stocktakes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$StocktakesTableFilterComposer(
            $db: $db,
            $table: $db.stocktakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocktakeCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $StocktakeCountsTable> {
  $$StocktakeCountsTableOrderingComposer({
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

  ColumnOrderings<int> get countedPieces => $composableBuilder(
    column: $table.countedPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systemPiecesAtCount => $composableBuilder(
    column: $table.systemPiecesAtCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  $$StocktakesTableOrderingComposer get stocktakeId {
    final $$StocktakesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocktakeId,
      referencedTable: $db.stocktakes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$StocktakesTableOrderingComposer(
            $db: $db,
            $table: $db.stocktakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocktakeCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocktakeCountsTable> {
  $$StocktakeCountsTableAnnotationComposer({
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

  GeneratedColumn<int> get countedPieces =>
      $composableBuilder(column: $table.countedPieces, builder: (column) => column);

  GeneratedColumn<int> get systemPiecesAtCount =>
      $composableBuilder(column: $table.systemPiecesAtCount, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get employeeId =>
      $composableBuilder(column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$StocktakesTableAnnotationComposer get stocktakeId {
    final $$StocktakesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stocktakeId,
      referencedTable: $db.stocktakes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$StocktakesTableAnnotationComposer(
            $db: $db,
            $table: $db.stocktakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocktakeCountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocktakeCountsTable,
          StocktakeCountRow,
          $$StocktakeCountsTableFilterComposer,
          $$StocktakeCountsTableOrderingComposer,
          $$StocktakeCountsTableAnnotationComposer,
          $$StocktakeCountsTableCreateCompanionBuilder,
          $$StocktakeCountsTableUpdateCompanionBuilder,
          (StocktakeCountRow, $$StocktakeCountsTableReferences),
          StocktakeCountRow,
          PrefetchHooks Function({bool stocktakeId})
        > {
  $$StocktakeCountsTableTableManager(_$AppDatabase db, $StocktakeCountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocktakeCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocktakeCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocktakeCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stocktakeId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> countedPieces = const Value.absent(),
                Value<int> systemPiecesAtCount = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocktakeCountsCompanion(
                id: id,
                stocktakeId: stocktakeId,
                productId: productId,
                countedPieces: countedPieces,
                systemPiecesAtCount: systemPiecesAtCount,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stocktakeId,
                required String productId,
                required int countedPieces,
                required int systemPiecesAtCount,
                required String deviceId,
                required String employeeId,
                required DateTime occurredAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocktakeCountsCompanion.insert(
                id: id,
                stocktakeId: stocktakeId,
                productId: productId,
                countedPieces: countedPieces,
                systemPiecesAtCount: systemPiecesAtCount,
                deviceId: deviceId,
                employeeId: employeeId,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StocktakeCountsTable, StocktakeCountRow>(table),
                  $$StocktakeCountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stocktakeId = false}) {
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
                    if (stocktakeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.stocktakeId,
                        referencedTable: $$StocktakeCountsTableReferences._stocktakeIdTable(db),
                        referencedColumn: $$StocktakeCountsTableReferences._stocktakeIdTable(db).id,
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

typedef $$StocktakeCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocktakeCountsTable,
      StocktakeCountRow,
      $$StocktakeCountsTableFilterComposer,
      $$StocktakeCountsTableOrderingComposer,
      $$StocktakeCountsTableAnnotationComposer,
      $$StocktakeCountsTableCreateCompanionBuilder,
      $$StocktakeCountsTableUpdateCompanionBuilder,
      (StocktakeCountRow, $$StocktakeCountsTableReferences),
      StocktakeCountRow,
      PrefetchHooks Function({bool stocktakeId})
    >;
typedef $$PurchaseOrdersTableCreateCompanionBuilder = PurchaseOrdersCompanion Function({
  required String id,
  required String supplierId,
  required String status,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PurchaseOrdersTableUpdateCompanionBuilder = PurchaseOrdersCompanion Function({
  Value<String> id,
  Value<String> supplierId,
  Value<String> status,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PurchaseOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseOrdersTable, PurchaseOrderRow> {
  $$PurchaseOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseOrderLinesTable, List<PurchaseOrderLineRow>>
  _purchaseOrderLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseOrderLines,
    aliasName: 'purchase_orders__id__purchase_order_lines__order_id',
  );

  $$PurchaseOrderLinesTableProcessedTableManager get purchaseOrderLinesRefs {
    final manager = $$PurchaseOrderLinesTableTableManager(
      $_db,
      $_db.purchaseOrderLines,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseOrderLinesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PurchaseOrdersTableFilterComposer extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> purchaseOrderLinesRefs(
    Expression<bool> Function($$PurchaseOrderLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseOrderLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrderLines,
      getReferencedColumn: (t) => t.orderId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseOrderLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseOrdersTableOrderingComposer extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrdersTable> {
  $$PurchaseOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supplierId =>
      $composableBuilder(column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> purchaseOrderLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseOrderLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseOrderLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseOrderLines,
      getReferencedColumn: (t) => t.orderId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseOrderLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseOrderLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrdersTable,
          PurchaseOrderRow,
          $$PurchaseOrdersTableFilterComposer,
          $$PurchaseOrdersTableOrderingComposer,
          $$PurchaseOrdersTableAnnotationComposer,
          $$PurchaseOrdersTableCreateCompanionBuilder,
          $$PurchaseOrdersTableUpdateCompanionBuilder,
          (PurchaseOrderRow, $$PurchaseOrdersTableReferences),
          PurchaseOrderRow,
          PrefetchHooks Function({bool purchaseOrderLinesRefs})
        > {
  $$PurchaseOrdersTableTableManager(_$AppDatabase db, $PurchaseOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion(
                id: id,
                supplierId: supplierId,
                status: status,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                required String status,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrdersCompanion.insert(
                id: id,
                supplierId: supplierId,
                status: status,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseOrdersTable, PurchaseOrderRow>(table),
                  $$PurchaseOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseOrderLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (purchaseOrderLinesRefs) db.purchaseOrderLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseOrderLinesRefs)
                    await $_getPrefetchedData<
                      PurchaseOrderRow,
                      $PurchaseOrdersTable,
                      PurchaseOrderLineRow
                    >(
                      currentTable: table,
                      referencedTable: $$PurchaseOrdersTableReferences._purchaseOrderLinesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$PurchaseOrdersTableReferences(db, table, p0).purchaseOrderLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.orderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PurchaseOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrdersTable,
      PurchaseOrderRow,
      $$PurchaseOrdersTableFilterComposer,
      $$PurchaseOrdersTableOrderingComposer,
      $$PurchaseOrdersTableAnnotationComposer,
      $$PurchaseOrdersTableCreateCompanionBuilder,
      $$PurchaseOrdersTableUpdateCompanionBuilder,
      (PurchaseOrderRow, $$PurchaseOrdersTableReferences),
      PurchaseOrderRow,
      PrefetchHooks Function({bool purchaseOrderLinesRefs})
    >;
typedef $$PurchaseOrderLinesTableCreateCompanionBuilder = PurchaseOrderLinesCompanion Function({
  required String id,
  required String orderId,
  required String productId,
  required int quantity,
  Value<int> rowid,
});
typedef $$PurchaseOrderLinesTableUpdateCompanionBuilder = PurchaseOrderLinesCompanion Function({
  Value<String> id,
  Value<String> orderId,
  Value<String> productId,
  Value<int> quantity,
  Value<int> rowid,
});

final class $$PurchaseOrderLinesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseOrderLinesTable, PurchaseOrderLineRow> {
  $$PurchaseOrderLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PurchaseOrdersTable _orderIdTable(_$AppDatabase db) =>
      db.purchaseOrders.createAlias('purchase_order_lines__order_id__purchase_orders__id');

  $$PurchaseOrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$PurchaseOrdersTableTableManager(
      $_db,
      $_db.purchaseOrders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PurchaseOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableFilterComposer({
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

  $$PurchaseOrdersTableFilterComposer get orderId {
    final $$PurchaseOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseOrdersTableFilterComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableOrderingComposer({
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

  $$PurchaseOrdersTableOrderingComposer get orderId {
    final $$PurchaseOrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseOrdersTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseOrderLinesTable> {
  $$PurchaseOrderLinesTableAnnotationComposer({
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

  $$PurchaseOrdersTableAnnotationComposer get orderId {
    final $$PurchaseOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.purchaseOrders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PurchaseOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseOrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseOrderLinesTable,
          PurchaseOrderLineRow,
          $$PurchaseOrderLinesTableFilterComposer,
          $$PurchaseOrderLinesTableOrderingComposer,
          $$PurchaseOrderLinesTableAnnotationComposer,
          $$PurchaseOrderLinesTableCreateCompanionBuilder,
          $$PurchaseOrderLinesTableUpdateCompanionBuilder,
          (PurchaseOrderLineRow, $$PurchaseOrderLinesTableReferences),
          PurchaseOrderLineRow,
          PrefetchHooks Function({bool orderId})
        > {
  $$PurchaseOrderLinesTableTableManager(_$AppDatabase db, $PurchaseOrderLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseOrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderLinesCompanion(
                id: id,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String productId,
                required int quantity,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseOrderLinesCompanion.insert(
                id: id,
                orderId: orderId,
                productId: productId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseOrderLinesTable, PurchaseOrderLineRow>(table),
                  $$PurchaseOrderLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
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
                    if (orderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.orderId,
                        referencedTable: $$PurchaseOrderLinesTableReferences._orderIdTable(db),
                        referencedColumn: $$PurchaseOrderLinesTableReferences._orderIdTable(db).id,
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

typedef $$PurchaseOrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseOrderLinesTable,
      PurchaseOrderLineRow,
      $$PurchaseOrderLinesTableFilterComposer,
      $$PurchaseOrderLinesTableOrderingComposer,
      $$PurchaseOrderLinesTableAnnotationComposer,
      $$PurchaseOrderLinesTableCreateCompanionBuilder,
      $$PurchaseOrderLinesTableUpdateCompanionBuilder,
      (PurchaseOrderLineRow, $$PurchaseOrderLinesTableReferences),
      PurchaseOrderLineRow,
      PrefetchHooks Function({bool orderId})
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
  $$TillEventsTableTableManager get tillEvents =>
      $$TillEventsTableTableManager(_db, _db.tillEvents);
  $$SuppliersTableTableManager get suppliers => $$SuppliersTableTableManager(_db, _db.suppliers);
  $$PurchasesTableTableManager get purchases => $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseLinesTableTableManager get purchaseLines =>
      $$PurchaseLinesTableTableManager(_db, _db.purchaseLines);
  $$SupplierDebtEventsTableTableManager get supplierDebtEvents =>
      $$SupplierDebtEventsTableTableManager(_db, _db.supplierDebtEvents);
  $$SupplierReturnsTableTableManager get supplierReturns =>
      $$SupplierReturnsTableTableManager(_db, _db.supplierReturns);
  $$ExpenseEventsTableTableManager get expenseEvents =>
      $$ExpenseEventsTableTableManager(_db, _db.expenseEvents);
  $$StocktakesTableTableManager get stocktakes =>
      $$StocktakesTableTableManager(_db, _db.stocktakes);
  $$StocktakeCountsTableTableManager get stocktakeCounts =>
      $$StocktakeCountsTableTableManager(_db, _db.stocktakeCounts);
  $$PurchaseOrdersTableTableManager get purchaseOrders =>
      $$PurchaseOrdersTableTableManager(_db, _db.purchaseOrders);
  $$PurchaseOrderLinesTableTableManager get purchaseOrderLines =>
      $$PurchaseOrderLinesTableTableManager(_db, _db.purchaseOrderLines);
}
