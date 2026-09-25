import 'database.dart';

/// What one employee did in a period: the owner's per-employee account.
class EmployeeSummary {
  EmployeeSummary(this.employeeId);

  final String employeeId;
  int salesCount = 0;
  int cashSalesMinor = 0;
  int debtSalesMinor = 0;
  int discountMinor = 0;

  /// Debt payments this employee took from customers (cash in hand).
  int paymentsCollectedMinor = 0;
  int unitsSold = 0;
  int returnsCount = 0;
  int cashRefundsMinor = 0;
  int creditRefundsMinor = 0;
  final Map<String, int> unitsByProduct = {};
  final List<SaleRow> sales = [];

  int get totalSalesMinor => cashSalesMinor + debtSalesMinor;

  /// Cash this employee should hand over:
  /// cash sales + debt payments taken − cash refunds paid out.
  int get cashToHandInMinor => cashSalesMinor + paymentsCollectedMinor - cashRefundsMinor;

  /// Top products by units, largest first.
  List<MapEntry<String, int>> topProducts([int n = 5]) =>
      (unitsByProduct.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .take(n)
          .toList();
}

/// Groups a period's sales, lines and payments by employee.
/// Sorted by total sales, largest first. Pure: easy to test.
List<EmployeeSummary> summarizeByEmployee({
  required List<SaleRow> sales,
  required List<SaleLineRow> lines,
  required List<DebtEventRow> payments,
  List<ReturnRow> returns = const [],
}) {
  final byId = <String, EmployeeSummary>{};
  EmployeeSummary of(String id) => byId.putIfAbsent(id, () => EmployeeSummary(id));
  final saleOwner = <String, String>{};

  for (final s in sales) {
    final e = of(s.employeeId);
    saleOwner[s.id] = s.employeeId;
    e.salesCount++;
    e.discountMinor += s.discountMinor;
    e.sales.add(s);
    if (s.payment == 'debt') {
      e.debtSalesMinor += s.totalMinor;
    } else {
      e.cashSalesMinor += s.totalMinor;
    }
  }
  for (final l in lines) {
    final owner = saleOwner[l.saleId];
    if (owner == null) continue;
    final e = of(owner);
    // Counted in selling units (a box and a strip each count as one).
    e.unitsSold += l.quantity;
    e.unitsByProduct[l.productId] = (e.unitsByProduct[l.productId] ?? 0) + l.quantity;
  }
  for (final p in payments) {
    of(p.employeeId).paymentsCollectedMinor += p.amountMinor;
  }
  for (final r in returns) {
    final e = of(r.employeeId);
    e.returnsCount++;
    if (r.refund == 'cash') {
      e.cashRefundsMinor += r.totalMinor;
    } else {
      e.creditRefundsMinor += r.totalMinor;
    }
  }
  for (final e in byId.values) {
    e.sales.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
  return byId.values.toList()..sort((a, b) => b.totalSalesMinor.compareTo(a.totalSalesMinor));
}

enum ReportPeriod { today, week, month }

/// `[from, to)` in local time. The week starts on Saturday (Syria).
(DateTime, DateTime) periodRange(ReportPeriod p, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return switch (p) {
    ReportPeriod.today => (today, today.add(const Duration(days: 1))),
    ReportPeriod.week => (
      today.subtract(Duration(days: (today.weekday - DateTime.saturday) % 7)),
      today.add(const Duration(days: 1)),
    ),
    ReportPeriod.month => (DateTime(now.year, now.month), today.add(const Duration(days: 1))),
  };
}
