import 'dart:convert';
import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/printing/receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart' show TtfParser;
import 'package:pdf/widgets.dart' as pw;

const labels = ReceiptLabels(
  saleNo: 'فاتورة',
  cashier: 'البائع',
  customer: 'الزبون',
  subtotal: 'المجموع',
  discount: 'الحسم',
  total: 'الإجمالي',
  payment: 'الدفع',
  tendered: 'المدفوع',
  change: 'الباقي',
  thanks: 'سلامتك',
);

Receipt sale({int discount = 0, int? tendered}) => Receipt(
  pharmacyName: 'صيدلية الشفاء',
  saleId: '0192f3aa-7c1d-7e11-9a3b-5f2e4c1d9a01',
  at: DateTime(2026, 9, 26, 18, 5),
  cashier: 'رنا',
  customer: 'مازن',
  lines: const [
    ReceiptLine(name: 'Amoxil 500 mg', quantity: 2, unitPriceMinor: 450000),
    ReceiptLine(name: 'Panadol', quantity: 1, unitPriceMinor: 250000),
  ],
  currency: Currency.syp,
  subtotalMinor: 1150000,
  discountMinor: discount,
  paymentLabel: 'نقدي',
  tenderedMinor: tendered,
);

pw.Font font(String name) => pw.Font.ttf(
  File('../../packages/doaya_ui/assets/fonts/$name.ttf').readAsBytesSync().buffer.asByteData(),
);

void main() {
  test('what the receipt says: totals, change, English digits', () {
    expect(sale().totals(labels), [('الإجمالي', '11,500 ل.س'), ('الدفع', 'نقدي')]);
    expect(sale(discount: 50000, tendered: 1200000).totals(labels), [
      ('المجموع', '11,500 ل.س'),
      ('الحسم', '500 ل.س'),
      ('الإجمالي', '11,000 ل.س'),
      ('الدفع', 'نقدي'),
      ('المدفوع', '12,000 ل.س'),
      ('الباقي', '1,000 ل.س'),
    ]);
    expect(sale().shortId, '1d9a01');
  });

  test('an 80 mm PDF with the app\'s own Arabic fonts', () async {
    final bytes = await receiptPdf(
      sale(discount: 50000, tendered: 1200000),
      labels,
      regular: font(receiptFont),
      bold: font(receiptFont),
    );
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  test('the receipt font has the Arabic shapes the PDF prints with', () {
    final ttf = TtfParser(
      File('../../packages/doaya_ui/assets/fonts/$receiptFont.ttf')
          .readAsBytesSync()
          .buffer
          .asByteData(),
    );
    // Presentation Forms-B (initial, medial, final letters).
    final missing = [
      for (var cp = 0xFE80; cp <= 0xFEFB; cp++)
        if (!ttf.charToGlyphIndexMap.containsKey(cp)) cp.toRadixString(16),
    ];
    expect(missing, isEmpty);
  });
}
