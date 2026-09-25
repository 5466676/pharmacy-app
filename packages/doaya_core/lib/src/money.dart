import 'text.dart';

/// A currency the pharmacy prices in. Code and symbol are user-editable
/// (the new Syrian pound's ISO code/symbol may change).
class Currency {
  const Currency({required this.code, required this.symbol, required this.decimals})
    : assert(decimals >= 0 && decimals <= 4);

  /// Default: the new Syrian pound (2026 redenomination, 2 decimals).
  static const syp = Currency(code: 'SYP', symbol: 'ل.س', decimals: 2);
  static const usd = Currency(code: 'USD', symbol: r'$', decimals: 2);

  final String code;
  final String symbol;
  final int decimals;

  int get minorPerMajor {
    var f = 1;
    for (var i = 0; i < decimals; i++) {
      f *= 10;
    }
    return f;
  }

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

/// An exact amount: integer minor units of one currency. Never a double.
class Money implements Comparable<Money> {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  /// Parses user input like `45`, `45.5`, `1,250.50` (English digits, ","
  /// thousands) — also accepts Arabic-keyboard input such as `٤٥٫٥` or
  /// `١٬٢٥٠`. Returns null for invalid input or too many decimals.
  static Money? tryParse(String input, Currency currency) {
    final s = toLatinDigits(input.trim())
        .replaceAll('\u066C', '') // Arabic thousands separator
        .replaceAll(',', '') // English thousands separator
        .replaceAll(' ', '')
        .replaceAll('\u066B', '.'); // Arabic decimal separator
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(s)) return null;
    final parts = s.split('.');
    final frac = parts.length > 1 ? parts[1] : '';
    if (frac.length > currency.decimals) return null;
    final major = int.parse(parts[0]);
    final minor = frac.isEmpty ? 0 : int.parse(frac.padRight(currency.decimals, '0'));
    return Money(major * currency.minorPerMajor + minor, currency);
  }

  final int minor;
  final Currency currency;

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;

  Money operator +(Money other) => Money(minor + _same(other).minor, currency);
  Money operator -(Money other) => Money(minor - _same(other).minor, currency);
  Money operator -() => Money(-minor, currency);
  Money times(int quantity) => Money(minor * quantity, currency);

  /// Major units as a number, for display only.
  num get majorValue => minor / currency.minorPerMajor;

  /// Whether the amount has a non-zero fractional part.
  bool get hasFraction => minor % currency.minorPerMajor != 0;

  Money _same(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return other;
  }

  @override
  int compareTo(Money other) => minor.compareTo(_same(other).minor);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => '$majorValue ${currency.code}';
}
