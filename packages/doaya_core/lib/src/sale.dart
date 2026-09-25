import 'events.dart';
import 'ids.dart';
import 'ledger.dart';
import 'money.dart';

enum PaymentType {
  cash,
  debt;

  String get wire => name;
  static PaymentType fromWire(String s) => values.byName(s);
}

class CartLine {
  const CartLine({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.piecesPerUnit = 1,
  });

  final String productId;

  /// Number of selling units (boxes, or strips).
  final int quantity;

  /// Price of ONE selling unit.
  final Money unitPrice;

  /// Stock pieces one selling unit takes: a box of 3 strips = 3, a strip = 1.
  /// Stock is always counted in the smallest piece.
  final int piecesPerUnit;

  int get pieces => quantity * piecesPerUnit;
  Money get total => unitPrice.times(quantity);
}

/// Line of a completed sale.
class SaleLine {
  const SaleLine({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
    this.piecesPerUnit = 1,
  });

  final String id;
  final String productId;
  final int quantity;
  final int unitPriceMinor;
  final int piecesPerUnit;

  int get pieces => quantity * piecesPerUnit;
}

/// Immutable sale header + everything it wrote to the ledgers.
class CompletedSale {
  const CompletedSale({
    required this.meta,
    required this.currency,
    required this.payment,
    required this.lines,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.stockEvents,
    this.customerId,
    this.debtEvent,
  });

  final EventMeta meta;
  final Currency currency;
  final PaymentType payment;
  final String? customerId;
  final List<SaleLine> lines;
  final int subtotalMinor;
  final int discountMinor;
  final List<StockEvent> stockEvents;
  final DebtEvent? debtEvent;

  String get id => meta.id;
  int get totalMinor => subtotalMinor - discountMinor;
}

class SaleException implements Exception {
  const SaleException(this.code, [this.detail]);

  /// Machine-readable reason, mapped to an ARB string by the UI.
  final SaleError code;
  final Object? detail;

  @override
  String toString() => 'SaleException($code, $detail)';
}

enum SaleError { emptyCart, badQuantity, debtNeedsCustomer, discountTooLarge, insufficientStock }

/// Turns a cart into a sale and its ledger events, allocating FEFO.
///
/// Pure: reads [stock], doesn't mutate it. The caller persists everything in
/// ONE transaction, then applies the events.
CompletedSale buildSale({
  required List<CartLine> cart,
  required StockLedger stock,
  required Currency currency,
  required PaymentType payment,
  required String deviceId,
  required String employeeId,
  required DateTime now,
  required UuidV7 ids,
  String? customerId,
  int discountMinor = 0,
}) {
  if (cart.isEmpty) throw const SaleException(SaleError.emptyCart);
  if (payment == PaymentType.debt && customerId == null) {
    throw const SaleException(SaleError.debtNeedsCustomer);
  }

  // Merge duplicate lines (same product AND same selling unit).
  final merged = <(String, int), CartLine>{};
  for (final l in cart) {
    if (l.quantity <= 0 || l.piecesPerUnit <= 0) {
      throw SaleException(SaleError.badQuantity, l.productId);
    }
    final key = (l.productId, l.piecesPerUnit);
    final prev = merged[key];
    merged[key] = prev == null
        ? l
        : CartLine(
            productId: l.productId,
            quantity: prev.quantity + l.quantity,
            unitPrice: prev.unitPrice,
            piecesPerUnit: l.piecesPerUnit,
          );
  }

  var subtotal = Money.zero(currency);
  for (final l in merged.values) {
    subtotal += l.total;
  }
  if (discountMinor < 0 || discountMinor > subtotal.minor) {
    throw const SaleException(SaleError.discountTooLarge);
  }

  EventMeta meta() =>
      EventMeta(id: ids.generate(), deviceId: deviceId, employeeId: employeeId, occurredAt: now);

  final saleMeta = meta();
  final lines = [
    for (final l in merged.values)
      SaleLine(
        id: ids.generate(),
        productId: l.productId,
        quantity: l.quantity,
        unitPriceMinor: l.unitPrice.minor,
        piecesPerUnit: l.piecesPerUnit,
      ),
  ];

  // Allocate ONCE per product (boxes + strips of the same product share batches).
  final piecesByProduct = <String, int>{};
  for (final l in merged.values) {
    piecesByProduct[l.productId] = (piecesByProduct[l.productId] ?? 0) + l.pieces;
  }
  final events = <StockEvent>[];
  for (final MapEntry(key: productId, value: pieces) in piecesByProduct.entries) {
    final List<Allocation> allocations;
    try {
      allocations = stock.allocate(productId, pieces);
    } on InsufficientStock catch (e) {
      throw SaleException(SaleError.insufficientStock, e);
    }
    for (final a in allocations) {
      events.add(
        StockEvent(
          meta: meta(),
          type: StockEventType.sold,
          productId: productId,
          batchId: a.batchId,
          quantity: -a.quantity,
          saleId: saleMeta.id,
        ),
      );
    }
  }

  final total = subtotal.minor - discountMinor;
  final debt = payment == PaymentType.debt && total > 0
      ? DebtEvent(
          meta: meta(),
          type: DebtEventType.debtAdded,
          customerId: customerId!,
          amountMinor: total,
          currencyCode: currency.code,
          saleId: saleMeta.id,
        )
      : null;

  return CompletedSale(
    meta: saleMeta,
    currency: currency,
    payment: payment,
    customerId: customerId,
    lines: lines,
    subtotalMinor: subtotal.minor,
    discountMinor: discountMinor,
    stockEvents: events,
    debtEvent: debt,
  );
}
