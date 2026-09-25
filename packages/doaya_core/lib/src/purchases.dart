import 'events.dart';
import 'ids.dart';
import 'ledger.dart';
import 'money.dart';

// ─── Suppliers ledger ────────────────────────────────────────────────────────

enum SupplierDebtEventType {
  /// Goods bought on credit: the pharmacy owes more.
  purchaseOnCredit,

  /// The pharmacy paid the supplier.
  paymentMade,

  /// Goods returned to the supplier and credited to the account.
  returnCredited;

  String get wire => switch (this) {
    purchaseOnCredit => 'purchase_on_credit',
    paymentMade => 'payment_made',
    returnCredited => 'return_credited',
  };

  static SupplierDebtEventType fromWire(String s) =>
      values.firstWhere((t) => t.wire == s, orElse: () => throw FormatException('supplier: $s'));
}

class SupplierDebtEvent {
  SupplierDebtEvent({
    required this.meta,
    required this.type,
    required this.supplierId,
    required this.amountMinor,
    required this.currencyCode,
    this.refId,
    this.note,
  }) {
    if (amountMinor <= 0) throw ArgumentError('amount must be > 0');
  }

  final EventMeta meta;
  final SupplierDebtEventType type;
  final String supplierId;
  final int amountMinor;
  final String currencyCode;

  /// Purchase invoice / supplier return this came from.
  final String? refId;
  final String? note;

  String get id => meta.id;

  /// Effect on what the pharmacy owes the supplier.
  int get signedMinor =>
      type == SupplierDebtEventType.purchaseOnCredit ? amountMinor : -amountMinor;
}

/// An unpaid (part of a) credit purchase, for debt ageing.
class OpenSupplierDebt {
  const OpenSupplierDebt({required this.since, required this.remainingMinor, this.refId});
  final DateTime since;
  final int remainingMinor;
  final String? refId;

  int ageInDays(DateTime now) => now.difference(since).inDays;
}

/// What the pharmacy owes each supplier. Idempotent like the other ledgers.
class SupplierLedger {
  SupplierLedger([Iterable<SupplierDebtEvent> events = const []]) {
    events.forEach(apply);
  }

  final _seen = <String>{};
  final _events = <String, List<SupplierDebtEvent>>{};

  bool apply(SupplierDebtEvent e) {
    if (!_seen.add(e.id)) return false;
    _events.putIfAbsent(e.supplierId, () => []).add(e);
    return true;
  }

  int balance(String supplierId) =>
      (_events[supplierId] ?? const []).fold(0, (s, e) => s + e.signedMinor);

  int get totalOwed => _events.keys.map(balance).where((b) => b > 0).fold(0, (a, b) => a + b);

  /// How many suppliers we owe money to.
  int get owedCount => _events.keys.where((id) => balance(id) > 0).length;

  /// Statement lines, oldest first, with the running balance.
  List<(SupplierDebtEvent, int)> statement(String supplierId) {
    final list = [...?_events[supplierId]]
      ..sort((a, b) {
        final c = a.meta.occurredAt.compareTo(b.meta.occurredAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    var running = 0;
    return [for (final e in list) (e, running += e.signedMinor)];
  }

  /// Unpaid credit purchases, oldest first: payments and credits settle the
  /// oldest purchases first (FIFO), which is how suppliers count debt age.
  List<OpenSupplierDebt> openDebts(String supplierId) {
    final lines = statement(supplierId);
    final open = <({DateTime since, int remaining, String? refId})>[];
    var credit = 0;
    for (final (e, _) in lines) {
      if (e.type == SupplierDebtEventType.purchaseOnCredit) {
        open.add((since: e.meta.occurredAt, remaining: e.amountMinor, refId: e.refId));
      } else {
        credit += e.amountMinor;
      }
    }
    final out = <OpenSupplierDebt>[];
    for (final o in open) {
      final used = credit < o.remaining ? credit : o.remaining;
      credit -= used;
      final left = o.remaining - used;
      if (left > 0) out.add(OpenSupplierDebt(since: o.since, remainingMinor: left, refId: o.refId));
    }
    return out;
  }
}

// ─── Purchase invoices ───────────────────────────────────────────────────────

enum PurchasePayment {
  /// Paid now (from the drawer or from outside it).
  cash,

  /// On the supplier's account.
  credit;

  String get wire => name;
  static PurchasePayment fromWire(String s) => values.byName(s);
}

/// Where cash for a purchase / expense came from.
enum PaidFrom {
  /// Out of the cash drawer: lowers the shift's expected cash.
  drawer,

  /// From outside the drawer (the owner).
  outside;

  String get wire => name;
  static PaidFrom fromWire(String s) => values.byName(s);
}

class PurchaseItem {
  const PurchaseItem({
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
    this.bonus = 0,
    this.piecesPerUnit = 1,
    this.discountBasisPoints = 0,
    this.expiry,
  });

  final String productId;

  /// Paid units (boxes, or strips when bought split).
  final int quantity;

  /// Free units (بونص / هدية) on top of [quantity].
  final int bonus;

  /// Supplier price for ONE paid unit, before discounts.
  final int unitPriceMinor;

  /// Stock pieces per unit (strips per box when the product is split).
  final int piecesPerUnit;

  /// Line discount in basis points (500 = 5%).
  final int discountBasisPoints;
  final DateTime? expiry;

  int get grossMinor => quantity * unitPriceMinor;
  int get lineDiscountMinor => (grossMinor * discountBasisPoints / 10000).round();
  int get netMinor => grossMinor - lineDiscountMinor;
  int get pieces => (quantity + bonus) * piecesPerUnit;
}

class PurchaseLine {
  const PurchaseLine({
    required this.id,
    required this.item,
    required this.costMinor,
    required this.batchId,
  });

  final String id;
  final PurchaseItem item;

  /// What this line really cost, after line + invoice discount and its share
  /// of transport. Sums exactly to the invoice total.
  final int costMinor;

  /// The batch this line opened (id of its `received` event).
  final String batchId;
}

class CompletedPurchase {
  const CompletedPurchase({
    required this.meta,
    required this.supplierId,
    required this.currency,
    required this.payment,
    required this.lines,
    required this.grossMinor,
    required this.lineDiscountsMinor,
    required this.invoiceDiscountMinor,
    required this.transportMinor,
    required this.stockEvents,
    this.paidFrom,
    this.supplierInvoiceNo,
    this.supplierDebtEvent,
  });

  final EventMeta meta;
  final String supplierId;
  final Currency currency;
  final PurchasePayment payment;
  final PaidFrom? paidFrom;
  final String? supplierInvoiceNo;
  final List<PurchaseLine> lines;
  final int grossMinor;
  final int lineDiscountsMinor;
  final int invoiceDiscountMinor;
  final int transportMinor;
  final List<StockEvent> stockEvents;
  final SupplierDebtEvent? supplierDebtEvent;

  String get id => meta.id;
  int get totalMinor => grossMinor - lineDiscountsMinor - invoiceDiscountMinor + transportMinor;
}

enum PurchaseError { empty, badLine, discountTooLarge, cashNeedsSource }

class PurchaseException implements Exception {
  const PurchaseException(this.code, [this.detail]);
  final PurchaseError code;
  final Object? detail;

  @override
  String toString() => 'PurchaseException($code, $detail)';
}

/// Splits [amount] across [weights] proportionally so the parts sum to
/// exactly [amount] (largest remainder). Used for invoice discount and
/// transport.
List<int> allocateProportionally(int amount, List<int> weights) {
  final total = weights.fold(0, (a, b) => a + b);
  if (amount == 0 || weights.isEmpty) return List.filled(weights.length, 0);
  if (total == 0) {
    // No weights: spread evenly.
    final base = amount ~/ weights.length;
    final out = List.filled(weights.length, base);
    for (var i = 0; i < amount - base * weights.length; i++) {
      out[i]++;
    }
    return out;
  }
  final exact = [for (final w in weights) amount * w / total];
  final out = [for (final x in exact) x.floor()];
  var left = amount - out.fold(0, (a, b) => a + b);
  final order = List.generate(weights.length, (i) => i)
    ..sort((a, b) => (exact[b] - out[b]).compareTo(exact[a] - out[a]));
  for (final i in order) {
    if (left == 0) break;
    out[i]++;
    left--;
  }
  return out;
}

/// Builds a purchase invoice: one `received` batch per line (quantity +
/// bonus, with its true cost), and for credit purchases a supplier debt event.
CompletedPurchase buildPurchase({
  required List<PurchaseItem> items,
  required String supplierId,
  required Currency currency,
  required PurchasePayment payment,
  required String deviceId,
  required String employeeId,
  required DateTime now,
  required UuidV7 ids,
  PaidFrom? paidFrom,
  int invoiceDiscountMinor = 0,
  int transportMinor = 0,
  String? supplierInvoiceNo,
}) {
  if (items.isEmpty) throw const PurchaseException(PurchaseError.empty);
  for (final i in items) {
    if (i.quantity < 0 ||
        i.bonus < 0 ||
        i.quantity + i.bonus <= 0 ||
        i.piecesPerUnit <= 0 ||
        i.unitPriceMinor < 0 ||
        i.discountBasisPoints < 0 ||
        i.discountBasisPoints > 10000) {
      throw PurchaseException(PurchaseError.badLine, i.productId);
    }
  }
  if (payment == PurchasePayment.cash && paidFrom == null) {
    throw const PurchaseException(PurchaseError.cashNeedsSource);
  }
  final nets = [for (final i in items) i.netMinor];
  final netTotal = nets.fold(0, (a, b) => a + b);
  if (invoiceDiscountMinor < 0 || transportMinor < 0 || invoiceDiscountMinor > netTotal) {
    throw const PurchaseException(PurchaseError.discountTooLarge);
  }

  final discountShares = allocateProportionally(invoiceDiscountMinor, nets);
  final transportShares = allocateProportionally(transportMinor, nets);

  EventMeta meta() =>
      EventMeta(id: ids.generate(), deviceId: deviceId, employeeId: employeeId, occurredAt: now);
  final purchaseMeta = meta();

  final lines = <PurchaseLine>[];
  final events = <StockEvent>[];
  for (var k = 0; k < items.length; k++) {
    final item = items[k];
    final cost = nets[k] - discountShares[k] + transportShares[k];
    final m = meta();
    events.add(
      StockEvent(
        meta: m,
        type: StockEventType.received,
        productId: item.productId,
        batchId: m.id,
        quantity: item.pieces,
        expiry: item.expiry,
        unitCostMinor: (cost / item.pieces).round(),
        refId: purchaseMeta.id,
      ),
    );
    lines.add(PurchaseLine(id: ids.generate(), item: item, costMinor: cost, batchId: m.id));
  }

  final gross = items.fold(0, (s, i) => s + i.grossMinor);
  final lineDiscounts = items.fold(0, (s, i) => s + i.lineDiscountMinor);
  final total = gross - lineDiscounts - invoiceDiscountMinor + transportMinor;

  return CompletedPurchase(
    meta: purchaseMeta,
    supplierId: supplierId,
    currency: currency,
    payment: payment,
    paidFrom: payment == PurchasePayment.cash ? paidFrom : null,
    supplierInvoiceNo: supplierInvoiceNo,
    lines: lines,
    grossMinor: gross,
    lineDiscountsMinor: lineDiscounts,
    invoiceDiscountMinor: invoiceDiscountMinor,
    transportMinor: transportMinor,
    stockEvents: events,
    supplierDebtEvent: payment == PurchasePayment.credit && total > 0
        ? SupplierDebtEvent(
            meta: meta(),
            type: SupplierDebtEventType.purchaseOnCredit,
            supplierId: supplierId,
            amountMinor: total,
            currencyCode: currency.code,
            refId: purchaseMeta.id,
          )
        : null,
  );
}

// ─── Returns to supplier ─────────────────────────────────────────────────────

class SupplierReturnItem {
  const SupplierReturnItem({
    required this.productId,
    required this.pieces,
    required this.creditMinor,
    this.batchId,
  });

  final String productId;

  /// Pieces sent back.
  final int pieces;

  /// Value the supplier gives back for them.
  final int creditMinor;

  /// A specific batch (e.g. the expired one); null = earliest expiry first.
  final String? batchId;
}

class CompletedSupplierReturn {
  const CompletedSupplierReturn({
    required this.meta,
    required this.supplierId,
    required this.totalMinor,
    required this.stockEvents,
    required this.refundedInCash,
    this.supplierDebtEvent,
  });

  final EventMeta meta;
  final String supplierId;
  final int totalMinor;
  final List<StockEvent> stockEvents;

  /// True when the supplier paid cash back instead of crediting the account.
  final bool refundedInCash;
  final SupplierDebtEvent? supplierDebtEvent;

  String get id => meta.id;
}

CompletedSupplierReturn buildSupplierReturn({
  required List<SupplierReturnItem> items,
  required String supplierId,
  required StockLedger stock,
  required Currency currency,
  required bool refundInCash,
  required String deviceId,
  required String employeeId,
  required DateTime now,
  required UuidV7 ids,
}) {
  if (items.isEmpty) throw const PurchaseException(PurchaseError.empty);
  EventMeta meta() =>
      EventMeta(id: ids.generate(), deviceId: deviceId, employeeId: employeeId, occurredAt: now);
  final returnMeta = meta();
  final events = <StockEvent>[];
  for (final i in items) {
    if (i.pieces <= 0 || i.creditMinor < 0) {
      throw PurchaseException(PurchaseError.badLine, i.productId);
    }
    final List<Allocation> parts;
    if (i.batchId != null) {
      final b = stock.batch(i.batchId!);
      if (b == null || b.productId != i.productId || b.quantity < i.pieces) {
        throw InsufficientStock(i.productId, i.pieces, b?.quantity ?? 0);
      }
      parts = [Allocation(i.batchId!, i.pieces)];
    } else {
      parts = stock.allocate(i.productId, i.pieces);
    }
    for (final a in parts) {
      events.add(
        StockEvent(
          meta: meta(),
          type: StockEventType.returnedToSupplier,
          productId: i.productId,
          batchId: a.batchId,
          quantity: -a.quantity,
          refId: returnMeta.id,
        ),
      );
    }
  }
  final total = items.fold(0, (s, i) => s + i.creditMinor);
  return CompletedSupplierReturn(
    meta: returnMeta,
    supplierId: supplierId,
    totalMinor: total,
    stockEvents: events,
    refundedInCash: refundInCash,
    supplierDebtEvent: !refundInCash && total > 0
        ? SupplierDebtEvent(
            meta: meta(),
            type: SupplierDebtEventType.returnCredited,
            supplierId: supplierId,
            amountMinor: total,
            currencyCode: currency.code,
            refId: returnMeta.id,
          )
        : null,
  );
}
