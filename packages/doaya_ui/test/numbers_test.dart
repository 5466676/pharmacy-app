import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatNumber (English digits)', () {
    test('zero and small numbers', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(7), '7');
      expect(formatNumber(999), '999');
    });
    test('groups thousands with ","', () {
      expect(formatNumber(1000), '1,000');
      expect(formatNumber(1234567), '1,234,567');
      expect(formatNumber(1234567, grouping: false), '1234567');
    });
    test('decimals use "." and round', () {
      expect(formatNumber(12.5, decimals: 2), '12.50');
      expect(formatNumber(2.345, decimals: 1), '2.3');
      expect(formatNumber(1234.5, decimals: 1), '1,234.5');
      expect(formatNumber(12.6), '13');
    });
    test('negative numbers keep the sign on the right side in RTL', () {
      expect(formatNumber(-1500), '؜-1,500');
      expect(formatNumber(-0.001, decimals: 2), '0.00');
    });
    test('no Arabic-Indic digit is ever produced', () {
      for (final n in [0, 5, 1234567, -42]) {
        expect(RegExp('[\u0660-\u0669]').hasMatch(formatNumber(n, decimals: 2)), isFalse);
      }
    });
  });

  test('toLatinDigits converts Arabic-Indic and Persian digits', () {
    expect(toLatinDigits('0123456789'), '0123456789');
    expect(toLatinDigits('۱۲'), '12');
    expect(toLatinDigits('باقي 3'), 'باقي 3');
  });
}
