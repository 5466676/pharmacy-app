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

/// A phone number in the international form WhatsApp links need (digits
/// only, country code first), or null when it doesn't look like one.
/// Local Syrian numbers get the 963 code: "0944 123 456" → "963944123456".
String? whatsappNumber(String? phone, {String countryCode = '963'}) {
  if (phone == null) return null;
  var d = toLatinDigits(phone).replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('0')) d = '$countryCode${d.substring(1)}';
  if (d.length == 9 && d.startsWith('9')) d = '$countryCode$d'; // 944123456
  return d.length >= 10 && d.length <= 15 ? d : null;
}
