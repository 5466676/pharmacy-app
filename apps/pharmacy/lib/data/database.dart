import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// ─── Master data (mutable; last-writer-wins by updatedAt when synced) ───────

/// Machines this pharmacy uses. Exactly one row has `isThisDevice`.
@DataClassName('DeviceRow')
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isThisDevice => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Simple key/value settings (currency, thresholds, pharmacy name).
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('EmployeeRow')
class Employees extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// `owner` or `employee`.
  TextColumn get role => text()();
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();

  /// Latin brand/trade name, e.g. "Amoxil 500 mg".
  TextColumn get tradeName => text()();
  TextColumn get arabicName => text().nullable()();

  /// Used to suggest alternatives when out of stock.
  TextColumn get activeIngredient => text()();
  TextColumn get strength => text().nullable()();
  TextColumn get form => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get shelf => text().nullable()();
  IntColumn get priceMinor => integer()();
  BoolColumn get prescriptionOnly => boolean().withDefault(const Constant(false))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get updatedByDevice => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductBarcodeRow')
class ProductBarcodes extends Table {
  TextColumn get barcode => text()();
  TextColumn get productId => text().references(Products, #id)();

  @override
  Set<Column> get primaryKey => {barcode};
}

@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Append-only ledgers (triggers forbid UPDATE except syncedAt, and DELETE) ─

@DataClassName('StockEventRow')
class StockEvents extends Table {
  TextColumn get id => text()();

  /// `received` | `sold` | `returned` | `adjusted` | `expired_removed`.
  TextColumn get type => text()();
  TextColumn get productId => text()();
  TextColumn get batchId => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get expiry => dateTime().nullable()();
  IntColumn get unitCostMinor => integer().nullable()();
  TextColumn get saleId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleRow')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().nullable()();

  /// `cash` | `debt`.
  TextColumn get payment => text()();
  TextColumn get currencyCode => text()();
  IntColumn get subtotalMinor => integer()();
  IntColumn get discountMinor => integer()();
  IntColumn get totalMinor => integer()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleLineRow')
class SaleLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceMinor => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DebtEventRow')
class DebtEvents extends Table {
  TextColumn get id => text()();

  /// `debt_added` | `payment_received`.
  TextColumn get type => text()();
  TextColumn get customerId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get saleId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

const _appendOnlyTables = ['stock_events', 'sales', 'sale_lines', 'debt_events'];

@DriftDatabase(
  tables: [
    Devices,
    Settings,
    Employees,
    Products,
    ProductBarcodes,
    Customers,
    StockEvents,
    Sales,
    SaleLines,
    DebtEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-disk database in the app's private support directory (NOT the
  /// user's Documents folder, which Windows often syncs to OneDrive).
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'doaya_pharmacy',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createLedgerGuards();
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createLedgerGuards() async {
    for (final t in _appendOnlyTables) {
      await customStatement('''
        CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t
        BEGIN SELECT RAISE(ABORT, 'append-only: $t'); END;
      ''');
    }
    // Events may only gain a syncedAt stamp; every other column is frozen.
    for (final t in ['stock_events', 'sales', 'debt_events']) {
      await customStatement('''
        CREATE TRIGGER ${t}_no_update BEFORE UPDATE ON $t
        WHEN NOT (${_sameColumnsExceptSynced(t)})
        BEGIN SELECT RAISE(ABORT, 'append-only: $t'); END;
      ''');
    }
    await customStatement('''
      CREATE TRIGGER sale_lines_no_update BEFORE UPDATE ON sale_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: sale_lines'); END;
    ''');
  }

  String _sameColumnsExceptSynced(String table) {
    final cols = switch (table) {
      'stock_events' => [
        'id', 'type', 'product_id', 'batch_id', 'quantity', 'expiry', 'unit_cost_minor', //
        'sale_id', 'note', 'device_id', 'employee_id', 'occurred_at',
      ],
      'sales' => [
        'id', 'customer_id', 'payment', 'currency_code', 'subtotal_minor', 'discount_minor', //
        'total_minor', 'device_id', 'employee_id', 'occurred_at',
      ],
      'debt_events' => [
        'id', 'type', 'customer_id', 'amount_minor', 'currency_code', 'sale_id', 'note', //
        'device_id', 'employee_id', 'occurred_at',
      ],
      _ => throw ArgumentError(table),
    };
    return cols.map((c) => 'OLD.$c IS NEW.$c').join(' AND ');
  }

  Future<void> _createIndexes() async {
    for (final s in [
      'CREATE INDEX stock_events_product ON stock_events (product_id)',
      'CREATE INDEX stock_events_unsynced ON stock_events (synced_at) WHERE synced_at IS NULL',
      'CREATE INDEX debt_events_customer ON debt_events (customer_id)',
      'CREATE INDEX sales_occurred ON sales (occurred_at)',
      'CREATE INDEX sale_lines_sale ON sale_lines (sale_id)',
      'CREATE INDEX products_ingredient ON products (active_ingredient)',
      'CREATE INDEX product_barcodes_product ON product_barcodes (product_id)',
    ]) {
      await customStatement(s);
    }
  }
}
