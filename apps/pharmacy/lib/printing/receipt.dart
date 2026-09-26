import 'dart:typed_data';

import 'package:doaya_core/doaya_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../ui/format.dart';

class ReceiptLine {
  const ReceiptLine({required this.name, required this.quantity, required this.unitPriceMinor});

  final String name;
  final int quantity;
  final int unitPriceMinor;

  int get totalMinor => quantity * unitPriceMinor;
}

/// The words on a receipt (from the ARB file, so the printer says what the
/// screen says).
class ReceiptLabels {
  const ReceiptLabels({
    required this.saleNo,
    required this.cashier,
    required this.customer,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.payment,
    required this.tendered,
    required this.change,
    required this.thanks,
  });

  final String saleNo;
  final String cashier;
  final String customer;
  final String subtotal;
  final String discount;
  final String total;
  final String payment;
  final String tendered;
  final String change;
  final String thanks;
}

/// A sale as the customer takes it home.
class Receipt {
  const Receipt({
    required this.pharmacyName,
    required this.saleId,
    required this.at,
    required this.cashier,
    required this.lines,
    required this.currency,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.paymentLabel,
    this.customer,
    this.tenderedMinor,
  });

  final String pharmacyName;
  final String saleId;
  final DateTime at;
  final String cashier;
  final String? customer;
  final List<ReceiptLine> lines;
  final Currency currency;
  final int subtotalMinor;
  final int discountMinor;
  final String paymentLabel;
  final int? tenderedMinor;

  int get totalMinor => subtotalMinor - discountMinor;
  int? get changeMinor => tenderedMinor == null ? null : tenderedMinor! - totalMinor;

  /// The last 6 characters of the sale id: enough to find it again.
  String get shortId => saleId.length <= 6 ? saleId : saleId.substring(saleId.length - 6);

  /// Label, value rows under the lines (English digits, the app's money).
  List<(String, String)> totals(ReceiptLabels t) => [
    if (discountMinor > 0) ...[
      (t.subtotal, formatMoney(subtotalMinor, currency)),
      (t.discount, formatMoney(discountMinor, currency)),
    ],
    (t.total, formatMoney(totalMinor, currency)),
    (t.payment, paymentLabel),
    if (tenderedMinor != null) (t.tendered, formatMoney(tenderedMinor!, currency)),
    if (changeMinor case final c? when c > 0) (t.change, formatMoney(c, currency)),
  ];
}

String _two(int n) => n.toString().padLeft(2, '0');

/// An 80 mm roll receipt, right to left, the app's own fonts (no download).
Future<Uint8List> receiptPdf(
  Receipt r,
  ReceiptLabels t, {
  required pw.Font regular,
  required pw.Font bold,
}) {
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  const small = pw.TextStyle(fontSize: 8);
  const normal = pw.TextStyle(fontSize: 9);
  const strong = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
  final local = r.at.toLocal();
  pw.Widget row(String a, String b, {pw.TextStyle? style}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(a, style: style ?? normal),
      pw.Text(b, style: style ?? normal),
    ],
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(6 * PdfPageFormat.mm),
      textDirection: pw.TextDirection.rtl,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(child: pw.Text(r.pharmacyName, style: strong)),
          pw.SizedBox(height: 4),
          row(
            '${t.saleNo}: ${r.shortId}',
            '${local.day}/${local.month}/${local.year} ${_two(local.hour)}:${_two(local.minute)}',
            style: small,
          ),
          row('${t.cashier}: ${r.cashier}', '', style: small),
          if (r.customer != null) row('${t.customer}: ${r.customer}', '', style: small),
          pw.Divider(thickness: 0.5),
          for (final line in r.lines) ...[
            pw.Text(line.name, style: normal, textDirection: pw.TextDirection.ltr),
            row(
              '${formatQty(line.quantity)} × ${formatMoney(line.unitPriceMinor, r.currency)}',
              formatMoney(line.totalMinor, r.currency),
              style: small,
            ),
            pw.SizedBox(height: 3),
          ],
          pw.Divider(thickness: 0.5),
          for (final (label, value) in r.totals(t))
            row(label, value, style: label == t.total ? strong : normal),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Text(t.thanks, style: small)),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Opens the system print dialog (any printer, the receipt one included).
Future<void> printReceipt(Receipt r, ReceiptLabels t) async {
  Future<pw.Font> font(String name) async =>
      pw.Font.ttf(await rootBundle.load('packages/doaya_ui/assets/fonts/$name.ttf'));
  final bytes = await receiptPdf(
    r,
    t,
    regular: await font('ReadexPro-Regular'),
    bold: await font('ReadexPro-SemiBold'),
  );
  await Printing.layoutPdf(
    name: 'receipt-${r.shortId}',
    format: PdfPageFormat.roll80,
    onLayout: (_) async => bytes,
  );
}
