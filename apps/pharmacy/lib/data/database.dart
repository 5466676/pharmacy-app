import 'package:doaya_core/doaya_core.dart' show toLatinDigits;
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

  /// Strips per box. 1 = sold as whole boxes only. Stock is counted in strips.
  IntColumn get unitsPerPack => integer().withDefault(const Constant(1))();

  /// Price of one strip when [unitsPerPack] > 1.
  IntColumn get stripPriceMinor => integer().nullable()();
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

  /// Purchase / supplier return / stocktake that caused it. v5.
  TextColumn get refId => text().nullable()();

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

  /// Cash handed over by the customer (cash sales, optional). v3.
  IntColumn get tenderedMinor => integer().nullable()();

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

  /// Stock pieces per selling unit: box of 3 strips = 3, strip = 1.
  IntColumn get piecesPerUnit => integer().withDefault(const Constant(1))();

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

@DataClassName('ReturnRow')
class Returns extends Table {
  TextColumn get id => text()();

  /// Set when returning against a past sale; null for a free-form return.
  TextColumn get saleId => text().nullable()();
  TextColumn get customerId => text().nullable()();

  /// `cash` | `debt_credit`.
  TextColumn get refund => text()();
  TextColumn get currencyCode => text()();
  IntColumn get totalMinor => integer()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReturnLineRow')
class ReturnLines extends Table {
  TextColumn get id => text()();
  TextColumn get returnId => text().references(Returns, #id)();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get piecesPerUnit => integer()();
  TextColumn get saleLineId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cash-drawer shifts: opened / cash_in / cash_out / closed. v3.
@DataClassName('TillEventRow')
class TillEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();

  /// Id of the shift's `opened` event.
  TextColumn get shiftId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── v5: suppliers, purchases, expenses, stocktakes, purchase orders ─────────

@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get repName => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get creditLimitMinor => integer().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseRow')
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text()();
  TextColumn get supplierInvoiceNo => text().nullable()();

  /// `cash` | `credit`.
  TextColumn get payment => text()();

  /// `drawer` | `outside` (cash only).
  TextColumn get paidFrom => text().nullable()();
  TextColumn get currencyCode => text()();
  IntColumn get grossMinor => integer()();
  IntColumn get lineDiscountsMinor => integer()();
  IntColumn get invoiceDiscountMinor => integer()();
  IntColumn get transportMinor => integer()();
  IntColumn get totalMinor => integer()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseLineRow')
class PurchaseLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get bonus => integer()();
  IntColumn get piecesPerUnit => integer()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get discountBasisPoints => integer()();

  /// True cost of the line after all discounts and its transport share.
  IntColumn get costMinor => integer()();

  /// Batch opened by this line (its `received` event id).
  TextColumn get batchId => text()();
  DateTimeColumn get expiry => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SupplierDebtEventRow')
class SupplierDebtEvents extends Table {
  TextColumn get id => text()();

  /// `purchase_on_credit` | `payment_made` | `return_credited`.
  TextColumn get type => text()();
  TextColumn get supplierId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get refId => text().nullable()();
  TextColumn get note => text().nullable()();

  /// For `payment_made`: `drawer` | `outside`.
  TextColumn get paidFrom => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SupplierReturnRow')
class SupplierReturns extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text()();
  IntColumn get totalMinor => integer()();
  BoolColumn get refundedInCash => boolean()();
  TextColumn get note => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExpenseEventRow')
class ExpenseEvents extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();

  /// `drawer` | `outside`.
  TextColumn get paidFrom => text()();
  TextColumn get note => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stocktake session header (mutable: it gets closed/applied).
@DataClassName('StocktakeRow')
class Stocktakes extends Table {
  TextColumn get id => text()();
  TextColumn get scope => text().nullable()();
  TextColumn get startedBy => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StocktakeCountRow')
class StocktakeCounts extends Table {
  TextColumn get id => text()();
  TextColumn get stocktakeId => text().references(Stocktakes, #id)();
  TextColumn get productId => text()();
  IntColumn get countedPieces => integer()();
  IntColumn get systemPiecesAtCount => integer()();
  TextColumn get deviceId => text()();
  TextColumn get employeeId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Purchase order draft to a supplier (mutable until received).
@DataClassName('PurchaseOrderRow')
class PurchaseOrders extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text()();

  /// `draft` | `sent` | `received`.
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseOrderLineRow')
class PurchaseOrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(PurchaseOrders, #id)();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Append-only tables are guarded by triggers created in _createLedgerGuards,
// _guardReturns, _guardTill and _guardAccounting.

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
    Returns,
    ReturnLines,
    TillEvents,
    Suppliers,
    Purchases,
    PurchaseLines,
    SupplierDebtEvents,
    SupplierReturns,
    ExpenseEvents,
    Stocktakes,
    StocktakeCounts,
    PurchaseOrders,
    PurchaseOrderLines,
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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createLedgerGuards();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2: strips (partial packs) and returns.
        await m.addColumn(products, products.unitsPerPack);
        await m.addColumn(products, products.stripPriceMinor);
        await m.addColumn(saleLines, saleLines.piecesPerUnit);
        await m.createTable(returns);
        await m.createTable(returnLines);
        await _guardReturns();
        await customStatement('CREATE INDEX return_lines_sale_line ON return_lines (sale_line_id)');
      }
      if (from < 3) {
        // v3: amount received at the counter, and cash-drawer shifts.
        await m.addColumn(sales, sales.tenderedMinor);
        await m.createTable(tillEvents);
        await _guardTill();
        await customStatement('CREATE INDEX till_events_shift ON till_events (shift_id)');
        // Re-create the sales guard so the new column is frozen too.
        await customStatement('DROP TRIGGER IF EXISTS sales_no_update');
        await customStatement('''
          CREATE TRIGGER sales_no_update BEFORE UPDATE ON sales
          WHEN NOT (${_sameColumnsExceptSynced('sales')})
          BEGIN SELECT RAISE(ABORT, 'append-only: sales'); END;
        ''');
      }
      if (from < 4) await _latinDigitsInMasterData();
      if (from < 5) {
        // v5: accounting (suppliers, purchases, expenses, stocktakes, orders).
        await m.addColumn(stockEvents, stockEvents.refId);
        for (final TableInfo<Table, dynamic> t in [
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
        ]) {
          await m.createTable(t);
        }
        // Re-create the stock_events guard so ref_id is frozen too.
        await customStatement('DROP TRIGGER IF EXISTS stock_events_no_update');
        await _guardUpdate('stock_events');
        await _guardAccounting();
        for (final s in _accountingIndexes) {
          await customStatement(s);
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// v4: every number in English digits (owner's decision). Converts
  /// Arabic-Indic digits already typed into names, phones and settings.
  /// Only mutable master data; ledgers never contain free text digits.
  Future<void> _latinDigitsInMasterData() async {
    String? fix(String? v) => v == null ? null : toLatinDigits(v);
    for (final p in await select(products).get()) {
      await (update(products)..where((t) => t.id.equals(p.id))).write(
        ProductsCompanion(
          tradeName: Value(fix(p.tradeName)!),
          arabicName: Value(fix(p.arabicName)),
          strength: Value(fix(p.strength)),
          form: Value(fix(p.form)),
          manufacturer: Value(fix(p.manufacturer)),
          shelf: Value(fix(p.shelf)),
        ),
      );
    }
    for (final c in await select(customers).get()) {
      await (update(customers)..where((t) => t.id.equals(c.id))).write(
        CustomersCompanion(
          name: Value(fix(c.name)!),
          phone: Value(fix(c.phone)),
          notes: Value(fix(c.notes)),
        ),
      );
    }
    for (final e in await select(employees).get()) {
      await (update(
        employees,
      )..where((t) => t.id.equals(e.id))).write(EmployeesCompanion(name: Value(fix(e.name)!)));
    }
    for (final d in await select(devices).get()) {
      await (update(
        devices,
      )..where((t) => t.id.equals(d.id))).write(DevicesCompanion(name: Value(fix(d.name)!)));
    }
    for (final st in await select(settings).get()) {
      await (update(
        settings,
      )..where((t) => t.key.equals(st.key))).write(SettingsCompanion(value: Value(fix(st.value)!)));
    }
  }

  Future<void> _createLedgerGuards() async {
    for (final t in const ['stock_events', 'sales', 'sale_lines', 'debt_events']) {
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
    await _guardReturns();
    await _guardTill();
    await _guardAccounting();
  }

  static const _accountingIndexes = [
    'CREATE INDEX purchases_supplier ON purchases (supplier_id)',
    'CREATE INDEX purchases_occurred ON purchases (occurred_at)',
    'CREATE INDEX purchase_lines_purchase ON purchase_lines (purchase_id)',
    'CREATE INDEX purchase_lines_product ON purchase_lines (product_id)',
    'CREATE INDEX purchase_lines_batch ON purchase_lines (batch_id)',
    'CREATE INDEX supplier_debt_events_supplier ON supplier_debt_events (supplier_id)',
    'CREATE INDEX expense_events_occurred ON expense_events (occurred_at)',
    'CREATE INDEX stocktake_counts_session ON stocktake_counts (stocktake_id)',
    'CREATE INDEX stock_events_ref ON stock_events (ref_id)',
  ];

  Future<void> _guardUpdate(String table) => customStatement('''
    CREATE TRIGGER ${table}_no_update BEFORE UPDATE ON $table
    WHEN NOT (${_sameColumnsExceptSynced(table)})
    BEGIN SELECT RAISE(ABORT, 'append-only: $table'); END;
  ''');

  /// v5 append-only tables: no DELETE; UPDATE only of `synced_at` (headers
  /// and events) or never (line tables).
  Future<void> _guardAccounting() async {
    for (final t in const [
      'purchases',
      'purchase_lines',
      'supplier_debt_events',
      'supplier_returns',
      'expense_events',
      'stocktake_counts',
    ]) {
      await customStatement('''
        CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t
        BEGIN SELECT RAISE(ABORT, 'append-only: $t'); END;
      ''');
    }
    for (final t in const [
      'purchases',
      'supplier_debt_events',
      'supplier_returns',
      'expense_events',
      'stocktake_counts',
    ]) {
      await _guardUpdate(t);
    }
    await customStatement('''
      CREATE TRIGGER purchase_lines_no_update BEFORE UPDATE ON purchase_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: purchase_lines'); END;
    ''');
  }

  Future<void> _guardTill() async {
    await customStatement('''
      CREATE TRIGGER till_events_no_delete BEFORE DELETE ON till_events
      BEGIN SELECT RAISE(ABORT, 'append-only: till_events'); END;
    ''');
    await customStatement('''
      CREATE TRIGGER till_events_no_update BEFORE UPDATE ON till_events
      WHEN NOT (${_sameColumnsExceptSynced('till_events')})
      BEGIN SELECT RAISE(ABORT, 'append-only: till_events'); END;
    ''');
  }

  Future<void> _guardReturns() async {
    for (final t in ['returns', 'return_lines']) {
      await customStatement('''
        CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t
        BEGIN SELECT RAISE(ABORT, 'append-only: $t'); END;
      ''');
    }
    await customStatement('''
      CREATE TRIGGER returns_no_update BEFORE UPDATE ON returns
      WHEN NOT (${_sameColumnsExceptSynced('returns')})
      BEGIN SELECT RAISE(ABORT, 'append-only: returns'); END;
    ''');
    await customStatement('''
      CREATE TRIGGER return_lines_no_update BEFORE UPDATE ON return_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: return_lines'); END;
    ''');
  }

  String _sameColumnsExceptSynced(String table) {
    final cols = switch (table) {
      'stock_events' => [
        'id', 'type', 'product_id', 'batch_id', 'quantity', 'expiry', 'unit_cost_minor', //
        'sale_id', 'note', 'device_id', 'employee_id', 'occurred_at', 'ref_id',
      ],
      'sales' => [
        'id', 'customer_id', 'payment', 'currency_code', 'subtotal_minor', 'discount_minor', //
        'total_minor', 'device_id', 'employee_id', 'occurred_at', 'tendered_minor',
      ],
      'debt_events' => [
        'id', 'type', 'customer_id', 'amount_minor', 'currency_code', 'sale_id', 'note', //
        'device_id', 'employee_id', 'occurred_at',
      ],
      'returns' => [
        'id', 'sale_id', 'customer_id', 'refund', 'currency_code', 'total_minor', //
        'device_id', 'employee_id', 'occurred_at',
      ],
      'till_events' => [
        'id', 'type', 'shift_id', 'amount_minor', 'note', 'device_id', 'employee_id', //
        'occurred_at',
      ],
      'purchases' => [
        'id', 'supplier_id', 'supplier_invoice_no', 'payment', 'paid_from', 'currency_code', //
        'gross_minor', 'line_discounts_minor', 'invoice_discount_minor', 'transport_minor',
        'total_minor', 'device_id', 'employee_id', 'occurred_at',
      ],
      'supplier_debt_events' => [
        'id', 'type', 'supplier_id', 'amount_minor', 'currency_code', 'ref_id', 'note', //
        'paid_from', 'device_id', 'employee_id', 'occurred_at',
      ],
      'supplier_returns' => [
        'id', 'supplier_id', 'total_minor', 'refunded_in_cash', 'note', 'device_id', //
        'employee_id', 'occurred_at',
      ],
      'expense_events' => [
        'id', 'category', 'amount_minor', 'currency_code', 'paid_from', 'note', 'device_id', //
        'employee_id', 'occurred_at',
      ],
      'stocktake_counts' => [
        'id', 'stocktake_id', 'product_id', 'counted_pieces', 'system_pieces_at_count', //
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
      'CREATE INDEX return_lines_sale_line ON return_lines (sale_line_id)',
      'CREATE INDEX till_events_shift ON till_events (shift_id)',
      ..._accountingIndexes,
    ]) {
      await customStatement(s);
    }
  }
}
