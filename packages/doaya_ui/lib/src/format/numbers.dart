/// Number formatting. Owner's decision (2026-09-25): every number is shown
/// with English (Western) digits, e.g. 1,234.50 — in Arabic text too.
library;

/// Arabic letter mark + minus: keeps the sign on the correct side in RTL text.
const _rtlSafeMinus = '؜-';

/// Formats [value] with English digits, "," thousands separator and "."
/// decimal separator.
///
/// ```dart
/// formatNumber(1234567)            // 1,234,567
/// formatNumber(12.5, decimals: 2)  // 12.50
/// ```
String formatNumber(num value, {int decimals = 0, bool grouping = true}) {
  assert(decimals >= 0);
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final dot = fixed.indexOf('.');
  final intPart = dot == -1 ? fixed : fixed.substring(0, dot);
  final fracPart = dot == -1 ? '' : fixed.substring(dot + 1);
  final isZero = double.parse(fixed) == 0;

  final buffer = StringBuffer();
  if (negative && !isZero) buffer.write(_rtlSafeMinus);
  buffer.write(grouping ? _group(intPart) : intPart);
  if (fracPart.isNotEmpty) buffer.write('.$fracPart');
  return buffer.toString();
}

String _group(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}
