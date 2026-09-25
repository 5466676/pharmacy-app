import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/reports.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const syp = Currency.syp;

  group('periodRange', () {
    // 2026-09-25 is a Friday.
    final fri = DateTime(2026, 9, 25, 15, 30);

    test('today is [midnight, next midnight)', () {
      expect(periodRange(ReportPeriod.today, fri), (DateTime(2026, 9, 25), DateTime(2026, 9, 26)));
    });

    test('the week starts on Saturday', () {
      expect(periodRange(ReportPeriod.week, fri).$1, DateTime(2026, 9, 19));
      final sat = DateTime(2026, 9, 26, 8);
      expect(periodRange(ReportPeriod.week, sat).$1, DateTime(2026, 9, 26));
    });

    test('month starts on the 1st', () {
      expect(periodRange(ReportPeriod.month, fri).$1, DateTime(2026, 9));
    });
  });

  test('per-employee account from real sales, lines and payments', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    var now = DateTime(2026, 9, 25, 10);
    final ledger = LedgerRepository(db, clock: () => now);
    final people = PeopleRepository(db, clock: () => now);
    final catalog = CatalogRepository(db, clock: () => now);

    final (device, owner) = await people.setUp(
      deviceName: 'لابتوب',
      ownerName: 'سامر',
      ownerPin: '1234',
    );
    final rana = await people.addEmployee(name: 'رنا', pin: '1111');
    final amox = await catalog.create(
      const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
      deviceId: device.id,
    );
    final para = await catalog.create(
      const ProductDraft(tradeName: 'Panadol', activeIngredient: 'paracetamol', priceMinor: 1800),
      deviceId: device.id,
    );
    final ownerS = Session(deviceId: device.id, employeeId: owner.id);
    final ranaS = Session(deviceId: device.id, employeeId: rana.id);
    await ledger.receive(ownerS, productId: amox.id, quantity: 20);
    await ledger.receive(ownerS, productId: para.id, quantity: 20);
    final customer = await people.addCustomer(name: 'أبو أحمد');

    CartLine line(ProductRow p, int q) =>
        CartLine(productId: p.id, quantity: q, unitPrice: Money(p.priceMinor, syp));

    // Rana: one cash sale (2 amox + 1 para), one debt sale (1 amox), collects a payment.
    await ledger.sell(
      ranaS,
      cart: [line(amox, 2), line(para, 1)],
      currency: syp,
      payment: PaymentType.cash,
    );
    await ledger.sell(
      ranaS,
      cart: [line(amox, 1)],
      currency: syp,
      payment: PaymentType.debt,
      customerId: customer.id,
    );
    await ledger.recordPayment(ranaS, customerId: customer.id, amount: const Money(2000, syp));
    // Owner: one cash sale.
    await ledger.sell(ownerS, cart: [line(para, 3)], currency: syp, payment: PaymentType.cash);
    // Yesterday's sale by Rana is outside "today".
    now = DateTime(2026, 9, 24, 18);
    await ledger.sell(ranaS, cart: [line(para, 1)], currency: syp, payment: PaymentType.cash);
    now = DateTime(2026, 9, 25, 12);

    final (from, to) = periodRange(ReportPeriod.today, now);
    final summaries = summarizeByEmployee(
      sales: await ledger.watchSalesBetween(from, to).first,
      lines: await ledger.watchLinesBetween(from, to).first,
      payments: await ledger.watchPaymentsBetween(from, to).first,
    );

    expect(summaries.map((s) => s.employeeId), [rana.id, owner.id]);
    final r = summaries.first;
    expect(r.salesCount, 2);
    expect(r.cashSalesMinor, 2 * 4500 + 1800);
    expect(r.debtSalesMinor, 4500);
    expect(r.paymentsCollectedMinor, 2000);
    expect(r.cashToHandInMinor, 2 * 4500 + 1800 + 2000);
    expect(r.unitsSold, 4);
    expect((r.topProducts().first.key, r.topProducts().first.value), (amox.id, 3));
    final o = summaries.last;
    expect((o.salesCount, o.cashSalesMinor, o.unitsSold), (1, 3 * 1800, 3));
  });
}
