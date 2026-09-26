import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A const leaf: the case a normal rebuild would skip.
class _Swatch extends StatelessWidget {
  const _Swatch();

  @override
  Widget build(BuildContext context) => DoayaLookScope.textScaled(
    context,
    Builder(
      builder: (context) => ColoredBox(
        key: const Key('swatch'),
        color: DoayaColors.accent,
        child: Text('${MediaQuery.textScalerOf(context).scale(10)}'),
      ),
    ),
  );
}

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => HostState();
}

class HostState extends State<_Host> {
  DoayaLook look = const DoayaLook();
  var taps = 0;

  @override
  Widget build(BuildContext context) => DoayaLookScope(
    look: look,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(onTap: () => taps++, child: const _Swatch()),
    ),
  );
}

void main() {
  tearDown(() => DoayaAppearance.apply(const DoayaLook()));

  testWidgets('a new look repaints everything, const parts and state kept', (tester) async {
    await tester.pumpWidget(const _Host());
    Color swatch() => tester.widget<ColoredBox>(find.byKey(const Key('swatch'))).color;
    expect(swatch(), DoayaPalette.classic.accent);
    expect(find.text('10.0'), findsOneWidget);

    final host = tester.state<HostState>(find.byType(_Host));
    host.taps = 3;
    // ignore: invalid_use_of_protected_member
    host.setState(() => host.look = const DoayaLook(palette: 'navy', mode: DoayaMode.light, textScale: 1.3));
    await tester.pumpAndSettle();

    final navyDay = DoayaPalette.of(const DoayaLook(palette: 'navy', mode: DoayaMode.light));
    expect(swatch(), navyDay.accent);
    expect(DoayaColors.bgMid, navyDay.bgMid);
    expect(find.text('13.0'), findsOneWidget);
    expect(host.taps, 3); // state survived
  });
}
