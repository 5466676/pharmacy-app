/// Text normalisation shared by every layer.
library;

/// Converts Arabic-Indic (٠–٩) and Persian (۰–۹) digits to English digits.
/// All numbers in Doaya are stored and shown with English digits (owner's
/// decision), whatever keyboard they were typed on.
String toLatinDigits(String input) {
  final out = StringBuffer();
  for (final r in input.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      out.writeCharCode(0x30 + r - 0x0660);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      out.writeCharCode(0x30 + r - 0x06F0);
    } else {
      out.writeCharCode(r);
    }
  }
  return out.toString();
}

/// Trims and converts digits to English; null/blank → null.
String? cleanText(String? s) {
  if (s == null) return null;
  final t = toLatinDigits(s.trim());
  return t.isEmpty ? null : t;
}
