import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';

/// "٤٥٫٥٠ ل.س" — fraction only when non-zero. Symbol comes from settings.
String formatMoney(int minor, Currency c) {
  final m = Money(minor, c);
  final digits = formatArabicNumber(m.majorValue, decimals: m.hasFraction ? c.decimals : 0);
  return '$digits ${c.symbol}';
}

/// Plain amount for input fields, Latin digits (keyboards type Latin).
String moneyInput(int minor, Currency c) {
  final m = Money(minor, c);
  return m.hasFraction ? m.majorValue.toStringAsFixed(c.decimals) : '${minor ~/ c.minorPerMajor}';
}

String formatQty(int n) => formatArabicNumber(n);

/// Signed change ("+٦" / "−١") that keeps its sign on the correct side in RTL.
String formatSignedQty(int n) => n > 0 ? '\u061C+${formatArabicNumber(n)}' : formatArabicNumber(n);

/// Signed money change, same RTL-safe sign.
String formatSignedMoney(int minor, Currency c) =>
    minor >= 0 ? '\u061C+${formatMoney(minor, c)}' : '\u061C-${formatMoney(-minor, c)}';

/// d/m/yyyy in Arabic-Indic digits.
String formatDate(DateTime d) {
  final l = d.toLocal();
  return toArabicDigits('${l.day}/${l.month}/${l.year}');
}

/// HH:mm in Arabic-Indic digits.
String formatTime(DateTime d) {
  final l = d.toLocal();
  return toArabicDigits(
    '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}',
  );
}

/// Two-letter initials: "أبو أحمد" → "أ.أ".
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.characters.first;
  return '${parts.first.characters.first}.${parts[1].characters.first}';
}

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
