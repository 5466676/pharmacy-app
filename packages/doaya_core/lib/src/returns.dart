import 'events.dart';
import 'ids.dart';
import 'ledger.dart';
import 'money.dart';

/// How the customer gets their money back.
enum RefundMethod {
  /// Cash out of the drawer (reduces the employee's cash to hand in).
  cash,

  /// Taken off what the customer owes (a `debt_credited` event).
  debtCredit;

  String get wire => switch (this) {
    cash => 'cash',
    debtCredit => 'debt_credit',
  };

  static RefundMethod fromWire(String s) =>
      values.firstWhere((m) => m.wire == s, orElse: () => throw FormatException('refund: $s'));
}

class ReturnItem {
  const ReturnItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.piecesPerUnit = 1,
    this.saleLineId,
  });

  final String productId;

  /// Selling units being returned (boxes or strips).
  final int quantity;

  /// Refund per selling unit.
  final Money unitPrice;
  final int piecesPerUnit;

  /// Set when returning against a line of a past sale.
  final String? saleLineId;

  int get pieces => quantity * piecesPerUnit;
  Money get total => unitPrice.times(quantity);
}

class ReturnLine {
  const ReturnLine({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPriceMinor,
    required this.piecesPerUnit,
    this.saleLineId,
  });

  final String id;
  final String productId;
  final int quantity;
  final int unitPriceMinor;
  final int piecesPerUnit;
  final String? saleLineId;
}

class CompletedReturn {
  const CompletedReturn({
    required this.meta,
    required this.currency,
    required this.refund,
    required this.lines,
    required this.totalMinor,
    required this.stockEvents,
    this.saleId,
    this.customerId,
    this.debtEvent,
  });

  final EventMeta meta;
  final Currency currency;
  final RefundMethod refund;
  final List<ReturnLine> lines;
  final int totalMinor;
  final List<StockEvent> stockEvents;
  final String? saleId;
  final String? customerId;
  final DebtEvent? debtEvent;

  String get id => meta.id;
}

enum ReturnError {
  empty,
  badQuantity,
  moreThanSold,
  creditNeedsCustomer,
  creditMoreThanDebt,
  unknownProduct,
}

class ReturnException implements Exception {
  const ReturnException(this.code, [this.detail]);
  final ReturnError code;
  final Object? detail;

  @override
  String toString() => 'ReturnException($code, $detail)';
}

/// Builds a return and its ledger events. Pure, like `buildSale`.
///
/// * From a sale ([saleId] set): each item must reference a `saleLineId`,
///   and at most [returnablePieces] of that line can come back. The stock goes
///   back into the batches the sale took it from ([soldFromBatches], pieces
///   per batch for that sale and product).
/// * Free-form ([saleId] null): stock goes back into the product's
///   latest-expiring batch that exists.
CompletedReturn buildReturn({
  required List<ReturnItem> items,
  required StockLedger stock,
  required Currency currency,
  required RefundMethod refund,
  required String deviceId,
  required String employeeId,
  required DateTime now,
  required UuidV7 ids,
  String? saleId,
  String? customerId,
  Map<String, int> returnablePieces = const {},
  Map<String, Map<String, int>> soldFromBatches = const {},
  int customerBalanceMinor = 0,
}) {
  if (items.isEmpty) throw const ReturnException(ReturnError.empty);
  if (refund == RefundMethod.debtCredit && customerId == null) {
    throw const ReturnException(ReturnError.creditNeedsCustomer);
  }

  final piecesByLine = <String, int>{};
  for (final i in items) {
    if (i.quantity <= 0 || i.piecesPerUnit <= 0 || i.unitPrice.isNegative) {
      throw ReturnException(ReturnError.badQuantity, i.productId);
    }
    if (saleId != null) {
      final lineId = i.saleLineId;
      if (lineId == null) throw ReturnException(ReturnError.moreThanSold, i.productId);
      final total = (piecesByLine[lineId] ?? 0) + i.pieces;
      if (total > (returnablePieces[lineId] ?? 0)) {
        throw ReturnException(ReturnError.moreThanSold, i.productId);
      }
      piecesByLine[lineId] = total;
    }
  }

  var total = Money.zero(currency);
  for (final i in items) {
    total += i.total;
  }
  if (refund == RefundMethod.debtCredit && total.minor > customerBalanceMinor) {
    throw const ReturnException(ReturnError.creditMoreThanDebt);
  }

  EventMeta meta() =>
      EventMeta(id: ids.generate(), deviceId: deviceId, employeeId: employeeId, occurredAt: now);
  final returnMeta = meta();

  final piecesByProduct = <String, int>{};
  for (final i in items) {
    piecesByProduct[i.productId] = (piecesByProduct[i.productId] ?? 0) + i.pieces;
  }

  final events = <StockEvent>[];
  for (final MapEntry(key: productId, value: pieces) in piecesByProduct.entries) {
    final targets = <(String, int)>[];
    if (saleId != null) {
      // Back into the batches it left from.
      var left = pieces;
      for (final MapEntry(key: batchId, value: sold)
          in (soldFromBatches[productId] ?? {}).entries) {
        if (left == 0) break;
        final put = sold < left ? sold : left;
        targets.add((batchId, put));
        left -= put;
      }
      if (left > 0 && targets.isNotEmpty) {
        final (b, q) = targets.removeLast();
        targets.add((b, q + left));
      } else if (left > 0) {
        throw ReturnException(ReturnError.unknownProduct, productId);
      }
    } else {
      final batches = stock.batchesOf(productId).toList();
      if (batches.isEmpty) throw ReturnException(ReturnError.unknownProduct, productId);
      batches.sort((a, b) {
        final ea = a.expiry, eb = b.expiry;
        if (ea == null && eb == null) {
          return (b.receivedAt ?? DateTime(0)).compareTo(a.receivedAt ?? DateTime(0));
        }
        if (ea == null) return -1; // no-expiry batches are safest to top up
        if (eb == null) return 1;
        return eb.compareTo(ea); // latest expiry first
      });
      targets.add((batches.first.batchId, pieces));
    }
    for (final (batchId, q) in targets) {
      events.add(
        StockEvent(
          meta: meta(),
          type: StockEventType.returned,
          productId: productId,
          batchId: batchId,
          quantity: q,
          saleId: saleId,
        ),
      );
    }
  }

  final lines = [
    for (final i in items)
      ReturnLine(
        id: ids.generate(),
        productId: i.productId,
        quantity: i.quantity,
        unitPriceMinor: i.unitPrice.minor,
        piecesPerUnit: i.piecesPerUnit,
        saleLineId: i.saleLineId,
      ),
  ];

  final debt = refund == RefundMethod.debtCredit && total.minor > 0
      ? DebtEvent(
          meta: meta(),
          type: DebtEventType.debtCredited,
          customerId: customerId!,
          amountMinor: total.minor,
          currencyCode: currency.code,
          saleId: saleId,
          note: returnMeta.id,
        )
      : null;

  return CompletedReturn(
    meta: returnMeta,
    currency: currency,
    refund: refund,
    lines: lines,
    totalMinor: total.minor,
    stockEvents: events,
    saleId: saleId,
    customerId: customerId,
    debtEvent: debt,
  );
}

/// Splits a piece count into (boxes, loose strips) for display.
(int packs, int loose) splitPieces(int pieces, int piecesPerPack) {
  if (piecesPerPack <= 1) return (pieces, 0);
  return (pieces ~/ piecesPerPack, pieces % piecesPerPack);
}
