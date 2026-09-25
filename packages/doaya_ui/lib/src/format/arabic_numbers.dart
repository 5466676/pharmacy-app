/// Arabic-Indic digit formatting. Every number shown to users goes through here.
library;

const _latinToArabic = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

/// Arabic decimal separator (U+066B).
const arabicDecimalSeparator = '\u066B';

/// Arabic thousands separator (U+066C).
const arabicGroupSeparator = '\u066C';

/// Arabic letter mark + minus: keeps the sign on the correct side in RTL text.
const _arabicMinus = '\u061C-';

/// Replaces Latin digits 0–9 with Arabic-Indic digits ٠–٩. Other characters
/// (e.g. `:` in a time) are left untouched.
String toArabicDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_latinToArabic[ch] ?? ch);
  }
  return out.toString();
}

/// Formats [value] with Arabic-Indic digits, Arabic group separator (\u066C) and
/// Arabic decimal separator (\u066B).
///
/// ```dart
/// formatArabicNumber(1234567)            // ١\u066C٢٣٤\u066C٥٦٧
/// formatArabicNumber(12.5, decimals: 2)  // ١٢\u066B٥٠
/// ```
String formatArabicNumber(num value, {int decimals = 0, bool grouping = true}) {
  assert(decimals >= 0);
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final dot = fixed.indexOf('.');
  final intPart = dot == -1 ? fixed : fixed.substring(0, dot);
  final fracPart = dot == -1 ? '' : fixed.substring(dot + 1);

  final grouped = grouping ? _group(intPart) : intPart;
  final isZero = double.parse(fixed) == 0;

  final buffer = StringBuffer();
  if (negative && !isZero) buffer.write(_arabicMinus);
  buffer.write(toArabicDigits(grouped));
  if (fracPart.isNotEmpty) {
    buffer
      ..write(arabicDecimalSeparator)
      ..write(toArabicDigits(fracPart));
  }
  return buffer.toString();
}

String _group(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(arabicGroupSeparator);
    out.write(digits[i]);
  }
  return out.toString();
}
