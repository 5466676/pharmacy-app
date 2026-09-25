import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toArabicDigits', () {
    test('maps every Latin digit', () {
      expect(toArabicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
    });
    test('keeps non-digits', () {
      expect(toArabicDigits('9:41'), '٩:٤١');
      expect(toArabicDigits('باقي 3'), 'باقي ٣');
    });
    test('is idempotent', () {
      expect(toArabicDigits(toArabicDigits('42')), '٤٢');
    });
  });

  group('formatArabicNumber', () {
    test('zero and small numbers', () {
      expect(formatArabicNumber(0), '٠');
      expect(formatArabicNumber(7), '٧');
      expect(formatArabicNumber(999), '٩٩٩');
    });
    test('groups thousands with \u066C', () {
      expect(formatArabicNumber(1000), '١\u066C٠٠٠');
      expect(formatArabicNumber(1234567), '١\u066C٢٣٤\u066C٥٦٧');
    });
    test('grouping can be disabled', () {
      expect(formatArabicNumber(1234567, grouping: false), '١٢٣٤٥٦٧');
    });
    test('decimals use \u066B and round', () {
      expect(formatArabicNumber(12.5, decimals: 2), '١٢\u066B٥٠');
      expect(formatArabicNumber(2.345, decimals: 1), '٢\u066B٣');
      expect(formatArabicNumber(1234.5, decimals: 1), '١\u066C٢٣٤\u066B٥');
    });
    test('integers ignore fraction when decimals is 0', () {
      expect(formatArabicNumber(12.6), '١٣');
    });
    test('negative numbers carry an Arabic letter mark before the minus', () {
      expect(formatArabicNumber(-1500), '\u061C-١\u066C٥٠٠');
    });
    test('negative values that round to zero have no sign', () {
      expect(formatArabicNumber(-0.001, decimals: 2), '٠\u066B٠٠');
    });
  });
}
