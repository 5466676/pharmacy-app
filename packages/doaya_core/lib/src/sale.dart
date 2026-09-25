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
  const CartLine({required this.productId, required this.quantity, required this.unitPrice});

  final String productId;
  final int quantity;
  final Money unitPrice;

  Money get total => unitPrice.times(quantity);
}

/// Line of a completed sale.
class SaleLine {
  const SaleLine({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
  });

  final String id;
  final String productId;
  final int quantity;
  final int unitPriceMinor;
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

  // Merge duplicate product lines so allocation sees the full quantity.
  final merged = <String, CartLine>{};
  for (final l in cart) {
    if (l.quantity <= 0) throw SaleException(SaleError.badQuantity, l.productId);
    final prev = merged[l.productId];
    merged[l.productId] = prev == null
        ? l
        : CartLine(
            productId: l.productId,
            quantity: prev.quantity + l.quantity,
            unitPrice: prev.unitPrice,
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
  final lines = <SaleLine>[];
  final events = <StockEvent>[];
  for (final l in merged.values) {
    final List<Allocation> allocations;
    try {
      allocations = stock.allocate(l.productId, l.quantity);
    } on InsufficientStock catch (e) {
      throw SaleException(SaleError.insufficientStock, e);
    }
    lines.add(
      SaleLine(
        id: ids.generate(),
        productId: l.productId,
        quantity: l.quantity,
        unitPriceMinor: l.unitPrice.minor,
      ),
    );
    for (final a in allocations) {
      events.add(
        StockEvent(
          meta: meta(),
          type: StockEventType.sold,
          productId: l.productId,
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
