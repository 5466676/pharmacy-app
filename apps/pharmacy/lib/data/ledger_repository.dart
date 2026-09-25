import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';

/// Who is acting, on which machine. Stamped on every event.
class Session {
  const Session({required this.deviceId, required this.employeeId});

  final String deviceId;
  final String employeeId;
}

/// Reads and appends ledger events. Never updates or deletes them (the DB
/// triggers would refuse anyway).
class LedgerRepository {
  LedgerRepository(this._db, {UuidV7? ids, DateTime Function()? clock})
    : _ids = ids ?? UuidV7(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final UuidV7 _ids;
  final DateTime Function() _clock;

  UuidV7 get ids => _ids;
  DateTime now() => _clock();

  EventMeta _meta(Session s) => EventMeta(
    id: _ids.generate(),
    deviceId: s.deviceId,
    employeeId: s.employeeId,
    occurredAt: _clock(),
  );

  // ─── Stock ────────────────────────────────────────────────────────────────

  Future<StockLedger> loadStock() async =>
      StockLedger((await _db.select(_db.stockEvents).get()).map(stockFromRow));

  Stream<StockLedger> watchStock() =>
      _db.select(_db.stockEvents).watch().map((rows) => StockLedger(rows.map(stockFromRow)));

  /// Every stock movement of one product, newest first.
  Stream<List<StockEvent>> watchProductEvents(String productId) =>
      (_db.select(_db.stockEvents)
            ..where((t) => t.productId.equals(productId))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt), (t) => OrderingTerm.desc(t.id)]))
          .watch()
          .map((rows) => rows.map(stockFromRow).toList());

  /// Inserts events, ignoring ids that already exist (idempotent sync).
  /// Returns how many were new.
  Future<int> insertStockEvents(Iterable<StockEvent> events) async {
    return _db.transaction(() async {
      final list = events.toList();
      final existing = await _existingIds(
        _db.stockEvents,
        _db.stockEvents.id,
        list.map((e) => e.id),
      );
      final fresh = {
        for (final e in list)
          if (!existing.contains(e.id)) e.id: e,
      }.values;
      await _db.batch((b) => b.insertAll(_db.stockEvents, fresh.map(stockToRow)));
      return fresh.length;
    });
  }

  Future<StockEvent> receive(
    Session s, {
    required String productId,
    required int quantity,
    DateTime? expiry,
    int? unitCostMinor,
    String? note,
  }) async {
    final m = _meta(s);
    final e = StockEvent(
      meta: m,
      type: StockEventType.received,
      productId: productId,
      batchId: m.id,
      quantity: quantity,
      expiry: expiry,
      unitCostMinor: unitCostMinor,
      note: note,
    );
    await insertStockEvents([e]);
    return e;
  }

  /// Manual correction of [delta] units after a count. Negative deltas are
  /// taken FEFO from existing batches; positive ones go to the newest batch.
  Future<List<StockEvent>> adjust(
    Session s, {
    required String productId,
    required int delta,
    String? note,
  }) async {
    if (delta == 0) return const [];
    final stock = await loadStock();
    final List<(String, int)> parts;
    if (delta < 0) {
      parts = [for (final a in stock.allocate(productId, -delta)) (a.batchId, -a.quantity)];
    } else {
      final batches = stock.batchesOf(productId).toList()
        ..sort((a, b) => (b.receivedAt ?? DateTime(0)).compareTo(a.receivedAt ?? DateTime(0)));
      if (batches.isEmpty) {
        // Nothing received yet: open a batch instead of adjusting into nothing.
        return [await receive(s, productId: productId, quantity: delta, note: note)];
      }
      parts = [(batches.first.batchId, delta)];
    }
    final events = [
      for (final (batch, qty) in parts)
        StockEvent(
          meta: _meta(s),
          type: StockEventType.adjusted,
          productId: productId,
          batchId: batch,
          quantity: qty,
          note: note,
        ),
    ];
    await insertStockEvents(events);
    return events;
  }

  /// Removes everything left in [batchId] as expired.
  Future<StockEvent?> removeExpired(Session s, {required String batchId}) async {
    final stock = await loadStock();
    final batch = stock.batch(batchId);
    if (batch == null || batch.quantity <= 0) return null;
    final e = StockEvent(
      meta: _meta(s),
      type: StockEventType.expiredRemoved,
      productId: batch.productId,
      batchId: batchId,
      quantity: -batch.quantity,
    );
    await insertStockEvents([e]);
    return e;
  }

  /// Ids among [ids] already stored in [table]. Idempotent sync relies on it.
  Future<Set<String>> _existingIds<T extends Table, R>(
    TableInfo<T, R> table,
    GeneratedColumn<String> idColumn,
    Iterable<String> ids,
  ) async {
    final all = ids.toSet();
    if (all.isEmpty) return {};
    final found = <String>{};
    // SQLite limits bound variables; query in chunks.
    final list = all.toList();
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(i, i + 500 > list.length ? list.length : i + 500);
      final q = _db.selectOnly(table)
        ..addColumns([idColumn])
        ..where(idColumn.isIn(chunk));
      found.addAll((await q.get()).map((r) => r.read(idColumn)!));
    }
    return found;
  }

  // ─── Sales ────────────────────────────────────────────────────────────────

  /// Validates and stores a sale in ONE transaction: header, lines, sold
  /// events and (for debt) the debt event. Stock is re-read inside the
  /// transaction so two counters can't oversell the same units.
  Future<CompletedSale> sell(
    Session s, {
    required List<CartLine> cart,
    required Currency currency,
    required PaymentType payment,
    String? customerId,
    int discountMinor = 0,
  }) {
    return _db.transaction(() async {
      final sale = buildSale(
        cart: cart,
        stock: await loadStock(),
        currency: currency,
        payment: payment,
        customerId: customerId,
        discountMinor: discountMinor,
        deviceId: s.deviceId,
        employeeId: s.employeeId,
        now: _clock(),
        ids: _ids,
      );
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              id: sale.id,
              customerId: Value(sale.customerId),
              payment: sale.payment.wire,
              currencyCode: sale.currency.code,
              subtotalMinor: sale.subtotalMinor,
              discountMinor: sale.discountMinor,
              totalMinor: sale.totalMinor,
              deviceId: sale.meta.deviceId,
              employeeId: sale.meta.employeeId,
              occurredAt: sale.meta.occurredAt,
            ),
          );
      for (final l in sale.lines) {
        await _db
            .into(_db.saleLines)
            .insert(
              SaleLinesCompanion.insert(
                id: l.id,
                saleId: sale.id,
                productId: l.productId,
                quantity: l.quantity,
                unitPriceMinor: l.unitPriceMinor,
              ),
            );
      }
      await insertStockEvents(sale.stockEvents);
      if (sale.debtEvent != null) await insertDebtEvents([sale.debtEvent!]);
      return sale;
    });
  }

  Stream<List<SaleRow>> watchRecentSales({int limit = 20}) =>
      (_db.select(_db.sales)
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
            ..limit(limit))
          .watch();

  Stream<List<SaleRow>> watchSalesSince(DateTime since) =>
      (_db.select(_db.sales)..where((t) => t.occurredAt.isBiggerOrEqualValue(since))).watch();

  Future<List<SaleLineRow>> linesOf(String saleId) =>
      (_db.select(_db.saleLines)..where((t) => t.saleId.equals(saleId))).get();

  // ─── Debts ────────────────────────────────────────────────────────────────

  Future<DebtLedger> loadDebts() async =>
      DebtLedger((await _db.select(_db.debtEvents).get()).map(debtFromRow));

  Stream<DebtLedger> watchDebts() =>
      _db.select(_db.debtEvents).watch().map((rows) => DebtLedger(rows.map(debtFromRow)));

  Stream<List<DebtEventRow>> watchDebtHistory(String customerId) =>
      (_db.select(_db.debtEvents)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Future<int> insertDebtEvents(Iterable<DebtEvent> events) async {
    return _db.transaction(() async {
      final list = events.toList();
      final existing = await _existingIds(_db.debtEvents, _db.debtEvents.id, list.map((e) => e.id));
      final fresh = {
        for (final e in list)
          if (!existing.contains(e.id)) e.id: e,
      }.values;
      await _db.batch((b) => b.insertAll(_db.debtEvents, fresh.map(debtToRow)));
      return fresh.length;
    });
  }

  Future<DebtEvent> recordPayment(
    Session s, {
    required String customerId,
    required Money amount,
    String? note,
  }) async {
    final e = DebtEvent(
      meta: _meta(s),
      type: DebtEventType.paymentReceived,
      customerId: customerId,
      amountMinor: amount.minor,
      currencyCode: amount.currency.code,
      note: note,
    );
    await insertDebtEvents([e]);
    return e;
  }
}

// ─── Row mapping ─────────────────────────────────────────────────────────────

StockEvent stockFromRow(StockEventRow r) => StockEvent(
  meta: EventMeta(
    id: r.id,
    deviceId: r.deviceId,
    employeeId: r.employeeId,
    occurredAt: r.occurredAt,
  ),
  type: StockEventType.fromWire(r.type),
  productId: r.productId,
  batchId: r.batchId,
  quantity: r.quantity,
  expiry: r.expiry,
  unitCostMinor: r.unitCostMinor,
  saleId: r.saleId,
  note: r.note,
);

StockEventsCompanion stockToRow(StockEvent e) => StockEventsCompanion.insert(
  id: e.id,
  type: e.type.wire,
  productId: e.productId,
  batchId: e.batchId,
  quantity: e.quantity,
  expiry: Value(e.expiry),
  unitCostMinor: Value(e.unitCostMinor),
  saleId: Value(e.saleId),
  note: Value(e.note),
  deviceId: e.meta.deviceId,
  employeeId: e.meta.employeeId,
  occurredAt: e.meta.occurredAt,
);

DebtEvent debtFromRow(DebtEventRow r) => DebtEvent(
  meta: EventMeta(
    id: r.id,
    deviceId: r.deviceId,
    employeeId: r.employeeId,
    occurredAt: r.occurredAt,
  ),
  type: DebtEventType.fromWire(r.type),
  customerId: r.customerId,
  amountMinor: r.amountMinor,
  currencyCode: r.currencyCode,
  saleId: r.saleId,
  note: r.note,
);

DebtEventsCompanion debtToRow(DebtEvent e) => DebtEventsCompanion.insert(
  id: e.id,
  type: e.type.wire,
  customerId: e.customerId,
  amountMinor: e.amountMinor,
  currencyCode: e.currencyCode,
  saleId: Value(e.saleId),
  note: Value(e.note),
  deviceId: e.meta.deviceId,
  employeeId: e.meta.employeeId,
  occurredAt: e.meta.occurredAt,
);
