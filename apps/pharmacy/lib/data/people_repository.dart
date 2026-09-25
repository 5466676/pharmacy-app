import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';

enum EmployeeRole {
  owner,
  employee;

  static EmployeeRole fromWire(String s) => values.byName(s);
}

/// Device identity, employees (name + PIN), customers and settings.
class PeopleRepository {
  PeopleRepository(this._db, {UuidV7? ids, DateTime Function()? clock, Random? random})
    : _ids = ids ?? UuidV7(),
      _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();

  final AppDatabase _db;
  final UuidV7 _ids;
  final DateTime Function() _clock;
  final Random _random;

  // ─── Device ───────────────────────────────────────────────────────────────

  Future<DeviceRow?> thisDevice() =>
      (_db.select(_db.devices)..where((t) => t.isThisDevice.equals(true))).getSingleOrNull();

  Stream<List<DeviceRow>> watchDevices() => _db.select(_db.devices).watch();

  /// First-run setup: names this machine and creates the owner account.
  Future<(DeviceRow, EmployeeRow)> setUp({
    required String deviceName,
    required String ownerName,
    required String ownerPin,
    String? pharmacyName,
  }) {
    return _db.transaction(() async {
      if (await thisDevice() != null) throw StateError('already set up');
      final id = _ids.generate();
      await _db
          .into(_db.devices)
          .insert(
            DevicesCompanion.insert(
              id: id,
              name: cleanText(deviceName) ?? '',
              isThisDevice: const Value(true),
              createdAt: _clock(),
            ),
          );
      if (pharmacyName != null) {
        await setSetting(SettingKeys.pharmacyName, cleanText(pharmacyName) ?? '');
      }
      final owner = await addEmployee(name: ownerName, pin: ownerPin, role: EmployeeRole.owner);
      return ((await thisDevice())!, owner);
    });
  }

  // ─── Employees ────────────────────────────────────────────────────────────

  static final _pinPattern = RegExp(r'^\d{4}$');
  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  Future<EmployeeRow> addEmployee({
    required String name,
    required String pin,
    EmployeeRole role = EmployeeRole.employee,
  }) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN must be 4 digits');
    final id = _ids.generate();
    final salt = _newSalt();
    await _db
        .into(_db.employees)
        .insert(
          EmployeesCompanion.insert(
            id: id,
            name: cleanText(name) ?? '',
            role: role.name,
            pinHash: hashPin(pin, salt),
            pinSalt: salt,
            updatedAt: _clock(),
          ),
        );
    return (await (_db.select(_db.employees)..where((t) => t.id.equals(id))).getSingle());
  }

  Future<void> setActive(String employeeId, {required bool active}) =>
      (_db.update(_db.employees)..where((t) => t.id.equals(employeeId))).write(
        EmployeesCompanion(active: Value(active), updatedAt: Value(_clock())),
      );

  Future<void> changePin(String employeeId, String pin) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN must be 4 digits');
    final salt = _newSalt();
    await (_db.update(_db.employees)..where((t) => t.id.equals(employeeId))).write(
      EmployeesCompanion(
        pinHash: Value(hashPin(pin, salt)),
        pinSalt: Value(salt),
        updatedAt: Value(_clock()),
      ),
    );
  }

  Stream<List<EmployeeRow>> watchEmployees({bool activeOnly = true}) {
    final q = _db.select(_db.employees)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (activeOnly) q.where((t) => t.active.equals(true));
    return q.watch();
  }

  /// Returns the employee if [pin] matches, else null.
  Future<EmployeeRow?> verifyPin(String employeeId, String pin) async {
    final e = await (_db.select(
      _db.employees,
    )..where((t) => t.id.equals(employeeId) & t.active.equals(true))).getSingleOrNull();
    if (e == null) return null;
    return _constantTimeEquals(hashPin(pin, e.pinSalt), e.pinHash) ? e : null;
  }

  /// Iterated, salted SHA-256. A 4-digit PIN is a counter convenience, not
  /// strong security; this only avoids storing it in plain text.
  static String hashPin(String pin, String salt) {
    List<int> bytes = utf8.encode('$salt:$pin');
    for (var i = 0; i < 10000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64.encode(bytes);
  }

  String _newSalt() => base64.encode(List<int>.generate(16, (_) => _random.nextInt(256)));

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  // ─── Customers ────────────────────────────────────────────────────────────

  Future<CustomerRow> addCustomer({required String name, String? phone, String? notes}) async {
    final id = _ids.generate();
    final now = _clock();
    await _db
        .into(_db.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            name: cleanText(name) ?? '',
            phone: Value(cleanText(phone)),
            notes: Value(cleanText(notes)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await customer(id))!;
  }

  Future<CustomerRow?> customer(String id) =>
      (_db.select(_db.customers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<CustomerRow>> watchCustomers() =>
      (_db.select(_db.customers)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<List<CustomerRow>> searchCustomers(String q) {
    final pattern = '%${toLatinDigits(q.trim())}%';
    return (_db.select(_db.customers)
          ..where((t) => t.name.like(pattern) | t.phone.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(20))
        .get();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<String?> setting(String key) async =>
      (await (_db.select(_db.settings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: toLatinDigits(value)));

  Stream<Map<String, String>> watchSettings() =>
      _db.select(_db.settings).watch().map((rows) => {for (final r in rows) r.key: r.value});

  Future<Currency> currency() async => currencyFrom(
    await _db.select(_db.settings).get().then((rows) => {for (final r in rows) r.key: r.value}),
  );

  static Currency currencyFrom(Map<String, String> s) => Currency(
    code: s[SettingKeys.currencyCode] ?? Currency.syp.code,
    symbol: s[SettingKeys.currencySymbol] ?? Currency.syp.symbol,
    decimals: int.tryParse(s[SettingKeys.currencyDecimals] ?? '') ?? Currency.syp.decimals,
  );

  static int nearExpiryDaysFrom(Map<String, String> s) =>
      int.tryParse(s[SettingKeys.nearExpiryDays] ?? '') ?? SettingKeys.defaultNearExpiryDays;
}

abstract final class SettingKeys {
  static const pharmacyName = 'pharmacy_name';
  static const currencyCode = 'currency_code';
  static const currencySymbol = 'currency_symbol';
  static const currencyDecimals = 'currency_decimals';
  static const nearExpiryDays = 'near_expiry_days';
  static const defaultNearExpiryDays = 90;
}
