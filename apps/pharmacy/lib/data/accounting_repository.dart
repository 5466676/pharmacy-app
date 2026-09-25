import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';
import 'ledger_repository.dart';

/// Suppliers (المستودعات), purchase invoices, supplier returns, the supplier
/// ledger, batch costs, expenses and stocktakes.
class AccountingRepository {
  AccountingRepository(this._db, this._ledger, {UuidV7? ids, DateTime Function()? clock})
    : _ids = ids ?? UuidV7(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final LedgerRepository _ledger;
  final UuidV7 _ids;
  final DateTime Function() _clock;

  EventMeta _meta(Session s) => EventMeta(
    id: _ids.generate(),
    deviceId: s.deviceId,
    employeeId: s.employeeId,
    occurredAt: _clock().toUtc(),
  );

  // ─── Suppliers ────────────────────────────────────────────────────────────

  Future<SupplierRow> addSupplier({
    required String name,
    String? phone,
    String? repName,
    String? notes,
    int? creditLimitMinor,
  }) async {
    final id = _ids.generate();
    final now = _clock();
    await _db
        .into(_db.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: id,
            name: cleanText(name) ?? '',
            phone: Value(cleanText(phone)),
            repName: Value(cleanText(repName)),
            notes: Value(cleanText(notes)),
            creditLimitMinor: Value(creditLimitMinor),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await supplier(id))!;
  }

  Future<SupplierRow?> supplier(String id) =>
      (_db.select(_db.suppliers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<SupplierRow>> watchSuppliers() =>
      (_db.select(_db.suppliers)
            ..where((t) => t.active.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<SupplierLedger> loadSupplierLedger() async =>
      SupplierLedger((await _db.select(_db.supplierDebtEvents).get()).map(supplierDebtFromRow));

  Stream<SupplierLedger> watchSupplierLedger() => _db
      .select(_db.supplierDebtEvents)
      .watch()
      .map((rows) => SupplierLedger(rows.map(supplierDebtFromRow)));

  Future<void> _insertSupplierDebt(SupplierDebtEvent e, {PaidFrom? paidFrom}) => _db
      .into(_db.supplierDebtEvents)
      .insert(
        SupplierDebtEventsCompanion.insert(
          id: e.id,
          type: e.type.wire,
          supplierId: e.supplierId,
          amountMinor: e.amountMinor,
          currencyCode: e.currencyCode,
          refId: Value(e.refId),
          note: Value(e.note),
          paidFrom: Value(paidFrom?.wire),
          deviceId: e.meta.deviceId,
          employeeId: e.meta.employeeId,
          occurredAt: e.meta.occurredAt,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  /// The pharmacy pays a supplier.
  Future<SupplierDebtEvent> paySupplier(
    Session s, {
    required String supplierId,
    required Money amount,
    required PaidFrom paidFrom,
    String? note,
  }) async {
    final e = SupplierDebtEvent(
      meta: _meta(s),
      type: SupplierDebtEventType.paymentMade,
      supplierId: supplierId,
      amountMinor: amount.minor,
      currencyCode: amount.currency.code,
      note: cleanText(note),
    );
    await _insertSupplierDebt(e, paidFrom: paidFrom);
    return e;
  }

  // ─── Purchases ────────────────────────────────────────────────────────────

  /// Stores a purchase invoice in ONE transaction: header, lines, received
  /// batches, supplier debt (credit) and optional new sale prices.
  Future<CompletedPurchase> recordPurchase(
    Session s, {
    required String supplierId,
    required List<PurchaseItem> items,
    required Currency currency,
    required PurchasePayment payment,
    PaidFrom? paidFrom,
    int invoiceDiscountMinor = 0,
    int transportMinor = 0,
    String? supplierInvoiceNo,
    Map<String, int> newSalePrices = const {},
  }) {
    return _db.transaction(() async {
      final p = buildPurchase(
        items: items,
        supplierId: supplierId,
        currency: currency,
        payment: payment,
        paidFrom: paidFrom,
        invoiceDiscountMinor: invoiceDiscountMinor,
        transportMinor: transportMinor,
        supplierInvoiceNo: cleanText(supplierInvoiceNo),
        deviceId: s.deviceId,
        employeeId: s.employeeId,
        now: _clock().toUtc(),
        ids: _ids,
      );
      await _db
          .into(_db.purchases)
          .insert(
            PurchasesCompanion.insert(
              id: p.id,
              supplierId: supplierId,
              supplierInvoiceNo: Value(p.supplierInvoiceNo),
              payment: p.payment.wire,
              paidFrom: Value(p.paidFrom?.wire),
              currencyCode: currency.code,
              grossMinor: p.grossMinor,
              lineDiscountsMinor: p.lineDiscountsMinor,
              invoiceDiscountMinor: p.invoiceDiscountMinor,
              transportMinor: p.transportMinor,
              totalMinor: p.totalMinor,
              deviceId: s.deviceId,
              employeeId: s.employeeId,
              occurredAt: p.meta.occurredAt,
            ),
          );
      for (final l in p.lines) {
        await _db
            .into(_db.purchaseLines)
            .insert(
              PurchaseLinesCompanion.insert(
                id: l.id,
                purchaseId: p.id,
                productId: l.item.productId,
                quantity: l.item.quantity,
                bonus: l.item.bonus,
                piecesPerUnit: l.item.piecesPerUnit,
                unitPriceMinor: l.item.unitPriceMinor,
                discountBasisPoints: l.item.discountBasisPoints,
                costMinor: l.costMinor,
                batchId: l.batchId,
                expiry: Value(l.item.expiry),
              ),
            );
      }
      await _ledger.insertStockEvents(p.stockEvents);
      if (p.supplierDebtEvent != null) await _insertSupplierDebt(p.supplierDebtEvent!);
      for (final MapEntry(key: productId, value: price) in newSalePrices.entries) {
        await (_db.update(_db.products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(
            priceMinor: Value(price),
            updatedAt: Value(_clock()),
            updatedByDevice: Value(s.deviceId),
          ),
        );
      }
      return p;
    });
  }

  Stream<List<PurchaseRow>> watchPurchases({String? supplierId, int limit = 100}) {
    final q = _db.select(_db.purchases)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit);
    if (supplierId != null) q.where((t) => t.supplierId.equals(supplierId));
    return q.watch();
  }

  Future<List<PurchaseLineRow>> purchaseLines(String purchaseId) =>
      (_db.select(_db.purchaseLines)..where((t) => t.purchaseId.equals(purchaseId))).get();

  /// Latest purchase price per supplier for [productId] (newest first).
  Future<List<({String supplierId, int unitPriceMinor, int piecesPerUnit, DateTime at})>>
  priceHistory(String productId) async {
    final q =
        _db.select(_db.purchaseLines).join([
            innerJoin(_db.purchases, _db.purchases.id.equalsExp(_db.purchaseLines.purchaseId)),
          ])
          ..where(
            _db.purchaseLines.productId.equals(productId) &
                _db.purchaseLines.quantity.isBiggerThanValue(0),
          )
          ..orderBy([OrderingTerm.desc(_db.purchases.occurredAt)]);
    final seen = <String>{};
    final out = <({String supplierId, int unitPriceMinor, int piecesPerUnit, DateTime at})>[];
    for (final r in await q.get()) {
      final p = r.readTable(_db.purchases);
      final l = r.readTable(_db.purchaseLines);
      if (seen.add(p.supplierId)) {
        out.add((
          supplierId: p.supplierId,
          unitPriceMinor: l.unitPriceMinor,
          piecesPerUnit: l.piecesPerUnit,
          at: p.occurredAt,
        ));
      }
    }
    return out;
  }

  /// Batch costs from every purchase line.
  Future<CostBook> costBook() async => CostBook({
    for (final l in await _db.select(_db.purchaseLines).get())
      l.batchId: BatchCost(
        totalMinor: l.costMinor,
        pieces: (l.quantity + l.bonus) * l.piecesPerUnit,
      ),
  });

  Stream<CostBook> watchCostBook() => _db
      .select(_db.purchaseLines)
      .watch()
      .map(
        (rows) => CostBook({
          for (final l in rows)
            l.batchId: BatchCost(
              totalMinor: l.costMinor,
              pieces: (l.quantity + l.bonus) * l.piecesPerUnit,
            ),
        }),
      );

  // ─── Profit ───────────────────────────────────────────────────────────────

  /// Profit of `[from, to)`: sales (discount spread over their lines) minus
  /// customer refunds, and the cost of the pieces sold minus those returned.
  Future<ProfitReport> profitReport(DateTime from, DateTime to) async {
    final f = from.toUtc(), t = to.toUtc();
    final sales =
        await (_db.select(_db.sales)..where(
              (x) => x.occurredAt.isBiggerOrEqualValue(f) & x.occurredAt.isSmallerThanValue(t),
            ))
            .get();
    final saleLines =
        await (_db.select(_db.saleLines).join([
              innerJoin(_db.sales, _db.sales.id.equalsExp(_db.saleLines.saleId)),
            ])..where(
              _db.sales.occurredAt.isBiggerOrEqualValue(f) &
                  _db.sales.occurredAt.isSmallerThanValue(t),
            ))
            .get();
    final returnLines =
        await (_db.select(_db.returnLines).join([
              innerJoin(_db.returns, _db.returns.id.equalsExp(_db.returnLines.returnId)),
            ])..where(
              _db.returns.occurredAt.isBiggerOrEqualValue(f) &
                  _db.returns.occurredAt.isSmallerThanValue(t),
            ))
            .get();
    final events =
        await (_db.select(_db.stockEvents)..where(
              (x) =>
                  x.type.isIn([StockEventType.sold.wire, StockEventType.returned.wire]) &
                  x.occurredAt.isBiggerOrEqualValue(f) &
                  x.occurredAt.isSmallerThanValue(t),
            ))
            .get();

    final linesBySale = <String, List<SaleLineRow>>{};
    for (final r in saleLines) {
      final l = r.readTable(_db.saleLines);
      linesBySale.putIfAbsent(l.saleId, () => []).add(l);
    }
    final revenue = <RevenueItem>[];
    for (final s in sales) {
      final lines = linesBySale[s.id] ?? const <SaleLineRow>[];
      final gross = [for (final l in lines) l.quantity * l.unitPriceMinor];
      final discount = allocateProportionally(s.discountMinor, gross);
      for (var i = 0; i < lines.length; i++) {
        revenue.add(
          RevenueItem(
            productId: lines[i].productId,
            employeeId: s.employeeId,
            at: s.occurredAt,
            amountMinor: gross[i] - discount[i],
          ),
        );
      }
    }
    for (final r in returnLines) {
      final ret = r.readTable(_db.returns);
      final l = r.readTable(_db.returnLines);
      revenue.add(
        RevenueItem(
          productId: l.productId,
          employeeId: ret.employeeId,
          at: ret.occurredAt,
          amountMinor: -(l.quantity * l.unitPriceMinor),
        ),
      );
    }
    return buildProfitReport(
      revenue: revenue,
      stockEvents: events.map(stockFromRow),
      costs: await costBook(),
      dayOf: (at) {
        final l = at.toLocal();
        return DateTime(l.year, l.month, l.day);
      },
    );
  }

  // ─── Shortages & purchase orders ─────────────────────────────────────────

  /// Products to reorder (see [findShortages]); sales counted over the last
  /// [windowDays].
  Future<List<Shortage>> shortages({int windowDays = 30, int coverDays = 14}) async {
    final products = await (_db.select(_db.products)..where((t) => t.active.equals(true))).get();
    final stock = await _ledger.loadStock();
    final since = _clock().toUtc().subtract(Duration(days: windowDays));
    final moves =
        await (_db.select(_db.stockEvents)..where(
              (t) =>
                  t.type.isIn([StockEventType.sold.wire, StockEventType.returned.wire]) &
                  t.occurredAt.isBiggerOrEqualValue(since),
            ))
            .get();
    final sold = <String, int>{};
    for (final m in moves) {
      sold[m.productId] = (sold[m.productId] ?? 0) - m.quantity;
    }
    return findShortages(
      [
        for (final p in products)
          ShortageInput(
            productId: p.id,
            onHandPieces: stock.onHand(p.id),
            minimumPieces: p.lowStockThreshold * (p.unitsPerPack < 1 ? 1 : p.unitsPerPack),
            soldPiecesInWindow: sold[p.id] ?? 0,
            piecesPerPack: p.unitsPerPack,
          ),
      ],
      windowDays: windowDays,
      coverDays: coverDays,
    );
  }

  /// The latest purchase line of every product (who we bought it from last,
  /// at what price per unit).
  Future<Map<String, ({String supplierId, int unitPriceMinor, int piecesPerUnit})>>
  lastPurchases() async {
    final q =
        _db.select(_db.purchaseLines).join([
            innerJoin(_db.purchases, _db.purchases.id.equalsExp(_db.purchaseLines.purchaseId)),
          ])
          ..where(_db.purchaseLines.quantity.isBiggerThanValue(0))
          ..orderBy([OrderingTerm.desc(_db.purchases.occurredAt)]);
    final out = <String, ({String supplierId, int unitPriceMinor, int piecesPerUnit})>{};
    for (final r in await q.get()) {
      final l = r.readTable(_db.purchaseLines);
      out.putIfAbsent(
        l.productId,
        () => (
          supplierId: r.readTable(_db.purchases).supplierId,
          unitPriceMinor: l.unitPriceMinor,
          piecesPerUnit: l.piecesPerUnit,
        ),
      );
    }
    return out;
  }

  /// One draft order per supplier: supplierId → [(productId, boxes)].
  Future<List<String>> createOrders(Map<String, List<(String, int)>> bySupplier) {
    return _db.transaction(() async {
      final ids = <String>[];
      final now = _clock();
      for (final MapEntry(key: supplierId, value: lines) in bySupplier.entries) {
        final wanted = lines.where((x) => x.$2 > 0).toList();
        if (wanted.isEmpty) continue;
        final id = _ids.generate();
        await _db
            .into(_db.purchaseOrders)
            .insert(
              PurchaseOrdersCompanion.insert(
                id: id,
                supplierId: supplierId,
                status: 'draft',
                createdAt: now,
                updatedAt: now,
              ),
            );
        for (final (productId, qty) in wanted) {
          await _db
              .into(_db.purchaseOrderLines)
              .insert(
                PurchaseOrderLinesCompanion.insert(
                  id: _ids.generate(),
                  orderId: id,
                  productId: productId,
                  quantity: qty,
                ),
              );
        }
        ids.add(id);
      }
      return ids;
    });
  }

  Stream<List<PurchaseOrderRow>> watchOrders() =>
      (_db.select(_db.purchaseOrders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Stream<List<PurchaseOrderLineRow>> watchOrderLines() =>
      _db.select(_db.purchaseOrderLines).watch();

  Future<PurchaseOrderRow?> order(String id) =>
      (_db.select(_db.purchaseOrders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<PurchaseOrderLineRow>> orderLines(String orderId) =>
      (_db.select(_db.purchaseOrderLines)..where((t) => t.orderId.equals(orderId))).get();

  /// Changes a line's quantity; 0 removes it.
  Future<void> setOrderLineQuantity(String lineId, int quantity) async {
    final q = _db.purchaseOrderLines;
    if (quantity <= 0) {
      await (_db.delete(q)..where((t) => t.id.equals(lineId))).go();
    } else {
      await (_db.update(q)..where((t) => t.id.equals(lineId))).write(
        PurchaseOrderLinesCompanion(quantity: Value(quantity)),
      );
    }
  }

  /// `draft` → `sent` (copied to the supplier) → `received` (became an invoice).
  Future<void> setOrderStatus(String orderId, String status) =>
      (_db.update(_db.purchaseOrders)..where((t) => t.id.equals(orderId))).write(
        PurchaseOrdersCompanion(status: Value(status), updatedAt: Value(_clock())),
      );

  Future<void> deleteOrder(String orderId) => _db.transaction(() async {
    await (_db.delete(_db.purchaseOrderLines)..where((t) => t.orderId.equals(orderId))).go();
    await (_db.delete(_db.purchaseOrders)..where((t) => t.id.equals(orderId))).go();
  });

  // ─── Returns to supplier ──────────────────────────────────────────────────

  Future<CompletedSupplierReturn> returnToSupplier(
    Session s, {
    required String supplierId,
    required List<SupplierReturnItem> items,
    required Currency currency,
    required bool refundInCash,
    String? note,
  }) {
    return _db.transaction(() async {
      final r = buildSupplierReturn(
        items: items,
        supplierId: supplierId,
        stock: await _ledger.loadStock(),
        currency: currency,
        refundInCash: refundInCash,
        deviceId: s.deviceId,
        employeeId: s.employeeId,
        now: _clock().toUtc(),
        ids: _ids,
      );
      await _db
          .into(_db.supplierReturns)
          .insert(
            SupplierReturnsCompanion.insert(
              id: r.id,
              supplierId: supplierId,
              totalMinor: r.totalMinor,
              refundedInCash: refundInCash,
              note: Value(cleanText(note)),
              deviceId: s.deviceId,
              employeeId: s.employeeId,
              occurredAt: r.meta.occurredAt,
            ),
          );
      await _ledger.insertStockEvents(r.stockEvents);
      if (r.supplierDebtEvent != null) await _insertSupplierDebt(r.supplierDebtEvent!);
      return r;
    });
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────

  Future<ExpenseEvent> addExpense(
    Session s, {
    required String category,
    required Money amount,
    required PaidFrom paidFrom,
    String? note,
  }) async {
    final e = ExpenseEvent(
      meta: _meta(s),
      category: cleanText(category) ?? '',
      amountMinor: amount.minor,
      currencyCode: amount.currency.code,
      paidFrom: paidFrom,
      note: cleanText(note),
    );
    await _db
        .into(_db.expenseEvents)
        .insert(
          ExpenseEventsCompanion.insert(
            id: e.id,
            category: e.category,
            amountMinor: e.amountMinor,
            currencyCode: e.currencyCode,
            paidFrom: e.paidFrom.wire,
            note: Value(e.note),
            deviceId: s.deviceId,
            employeeId: s.employeeId,
            occurredAt: e.meta.occurredAt,
          ),
        );
    return e;
  }

  Stream<List<ExpenseEvent>> watchExpensesBetween(DateTime from, DateTime to) =>
      (_db.select(_db.expenseEvents)
            ..where(
              (t) =>
                  t.occurredAt.isBiggerOrEqualValue(from.toUtc()) &
                  t.occurredAt.isSmallerThanValue(to.toUtc()),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch()
          .map((rows) => rows.map(expenseFromRow).toList());

  // ─── Stocktakes ───────────────────────────────────────────────────────────

  Future<String> startStocktake(Session s, {String? scope}) async {
    final id = _ids.generate();
    await _db
        .into(_db.stocktakes)
        .insert(
          StocktakesCompanion.insert(
            id: id,
            scope: Value(cleanText(scope)),
            startedBy: s.employeeId,
            startedAt: _clock().toUtc(),
          ),
        );
    return id;
  }

  /// Records a count; the system quantity is taken NOW, so selling can go on.
  Future<StocktakeCount> count(
    Session s, {
    required String stocktakeId,
    required String productId,
    required int countedPieces,
  }) async {
    final system = (await _ledger.loadStock()).onHand(productId);
    final m = _meta(s);
    await _db
        .into(_db.stocktakeCounts)
        .insert(
          StocktakeCountsCompanion.insert(
            id: m.id,
            stocktakeId: stocktakeId,
            productId: productId,
            countedPieces: countedPieces,
            systemPiecesAtCount: system,
            deviceId: s.deviceId,
            employeeId: s.employeeId,
            occurredAt: m.occurredAt,
          ),
        );
    return StocktakeCount(
      productId: productId,
      countedPieces: countedPieces,
      systemPiecesAtCount: system,
    );
  }

  Stream<List<StocktakeCountRow>> watchCounts(String stocktakeId) =>
      (_db.select(_db.stocktakeCounts)
            ..where((t) => t.stocktakeId.equals(stocktakeId))
            ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
          .watch();

  Future<StocktakeRow?> openStocktake() =>
      (_db.select(_db.stocktakes)
            ..where((t) => t.appliedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Applies the session: one `adjusted` movement per counted difference.
  Future<Map<String, int>> applyStocktake(Session s, String stocktakeId) {
    return _db.transaction(() async {
      final rows =
          await (_db.select(
              _db.stocktakeCounts,
            )..where((t) => t.stocktakeId.equals(stocktakeId))).get()
            ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      final adjustments = stocktakeAdjustments([
        for (final r in rows)
          StocktakeCount(
            productId: r.productId,
            countedPieces: r.countedPieces,
            systemPiecesAtCount: r.systemPiecesAtCount,
          ),
      ]);
      for (final MapEntry(key: productId, value: delta) in adjustments.entries) {
        await _ledger.adjust(s, productId: productId, delta: delta, refId: stocktakeId);
      }
      await (_db.update(_db.stocktakes)..where((t) => t.id.equals(stocktakeId))).write(
        StocktakesCompanion(appliedAt: Value(_clock().toUtc())),
      );
      return adjustments;
    });
  }
}

SupplierDebtEvent supplierDebtFromRow(SupplierDebtEventRow r) => SupplierDebtEvent(
  meta: EventMeta(
    id: r.id,
    deviceId: r.deviceId,
    employeeId: r.employeeId,
    occurredAt: r.occurredAt,
  ),
  type: SupplierDebtEventType.fromWire(r.type),
  supplierId: r.supplierId,
  amountMinor: r.amountMinor,
  currencyCode: r.currencyCode,
  refId: r.refId,
  note: r.note,
);

ExpenseEvent expenseFromRow(ExpenseEventRow r) => ExpenseEvent(
  meta: EventMeta(
    id: r.id,
    deviceId: r.deviceId,
    employeeId: r.employeeId,
    occurredAt: r.occurredAt,
  ),
  category: r.category,
  amountMinor: r.amountMinor,
  currencyCode: r.currencyCode,
  paidFrom: PaidFrom.fromWire(r.paidFrom),
  note: r.note,
);
