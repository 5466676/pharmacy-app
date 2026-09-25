import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

void main() {
  const syp = Currency.syp;

  test('new Syrian pound defaults: 2 decimals', () {
    expect(syp.decimals, 2);
    expect(syp.minorPerMajor, 100);
  });

  test('arithmetic is exact', () {
    const a = Money(4550, syp); // 45.50
    expect((a + const Money(50, syp)).minor, 4600);
    expect(a.times(3).minor, 13650);
    expect((a - const Money(5000, syp)).isNegative, isTrue);
    expect(const Money(4500, syp).hasFraction, isFalse);
    expect(a.hasFraction, isTrue);
  });

  test('mixing currencies throws', () {
    expect(() => const Money(1, syp) + const Money(1, Currency.usd), throwsArgumentError);
  });

  test('parses Latin and Arabic input', () {
    expect(Money.tryParse('45', syp)!.minor, 4500);
    expect(Money.tryParse('45.5', syp)!.minor, 4550);
    expect(Money.tryParse('45,05', syp)!.minor, 4505);
    expect(Money.tryParse('٤٥٫٥', syp)!.minor, 4550);
    expect(Money.tryParse('١٬٢٥٠', syp)!.minor, 125000);
    expect(Money.tryParse(' 7 ', syp)!.minor, 700);
  });

  test('rejects bad input', () {
    expect(Money.tryParse('', syp), isNull);
    expect(Money.tryParse('abc', syp), isNull);
    expect(Money.tryParse('1.234', syp), isNull);
    expect(Money.tryParse('-5', syp), isNull);
    expect(Money.tryParse('1.2.3', syp), isNull);
  });

  test('zero-decimal currency', () {
    const c = Currency(code: 'XXX', symbol: 'x', decimals: 0);
    expect(Money.tryParse('12', c)!.minor, 12);
    expect(Money.tryParse('12.5', c), isNull);
  });
}
