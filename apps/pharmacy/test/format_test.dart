import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/ui/format.dart';
import 'package:doaya_pharmacy/ui/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const syp = Currency.syp;

  test('money hides a zero fraction and shows a real one', () {
    expect(formatMoney(4500, syp), '٤٥ ل.س');
    expect(formatMoney(4550, syp), '٤٥٫٥٠ ل.س');
    expect(formatMoney(125000000, syp), '١٬٢٥٠٬٠٠٠ ل.س');
  });

  test('money input uses Latin digits for editing', () {
    expect(moneyInput(4500, syp), '45');
    expect(moneyInput(4550, syp), '45.50');
  });

  test('signed values carry an Arabic letter mark', () {
    expect(formatSignedQty(6), '؜+٦');
    expect(formatSignedQty(-1), '؜-١');
    expect(formatSignedMoney(-4500, syp), '؜-٤٥ ل.س');
  });

  test('dates parse in d/m/yyyy with Latin or Arabic digits', () {
    expect(parseDate('4/11/2026'), DateTime.utc(2026, 11, 4));
    expect(parseDate('٤/١١/٢٠٢٦'), DateTime.utc(2026, 11, 4));
    expect(parseDate('04-11-26'), DateTime.utc(2026, 11, 4));
    expect(parseDate('31/2/2026'), isNull);
    expect(parseDate(''), isNull);
    expect(parseDate('tomorrow'), isNull);
  });

  test('initials', () {
    expect(initialsOf('أبو أحمد'), 'أ.أ');
    expect(initialsOf('سامر'), 'س');
    expect(initialsOf('  '), '');
  });
}
