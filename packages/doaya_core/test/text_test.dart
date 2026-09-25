import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

void main() {
  test('toLatinDigits converts Arabic-Indic and Persian digits', () {
    expect(
      toLatinDigits('\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669'),
      '0123456789',
    );
    expect(toLatinDigits('\u06F1\u06F2'), '12');
    expect(toLatinDigits('أوميغا \u0663'), 'أوميغا 3');
  });

  test('cleanText trims, converts and nulls blanks', () {
    expect(cleanText('  \u0660\u0669\u0664\u0664  '), '0944');
    expect(cleanText('   '), isNull);
    expect(cleanText(null), isNull);
  });

  test('whatsappNumber: local, international and Arabic-keyboard numbers', () {
    expect(whatsappNumber('0944 123 456'), '963944123456');
    expect(whatsappNumber('٠٩٤٤١٢٣٤٥٦'), '963944123456');
    expect(whatsappNumber('944123456'), '963944123456');
    expect(whatsappNumber('+963 944-123-456'), '963944123456');
    expect(whatsappNumber('00963944123456'), '963944123456');
    expect(whatsappNumber('011 2223344'), '963112223344'); // Damascus landline
    expect(whatsappNumber('123'), isNull);
    expect(whatsappNumber(null), isNull);
  });
}
