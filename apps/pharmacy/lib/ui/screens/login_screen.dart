import 'package:doaya_core/doaya_core.dart' show toLatinDigits;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../sync/sync_controller.dart';
import '../format.dart';

/// Whether this app run already tried the automatic sign-in (so "switch
/// user" on a phone still shows the list).
class _AutoSignInTried extends Notifier<bool> {
  @override
  bool build() => false;
  void mark() => state = true;
}

final _autoSignInTriedProvider = NotifierProvider<_AutoSignInTried, bool>(_AutoSignInTried.new);

/// Counter login: tap your name, type your 4-digit PIN (keyboard or keypad).
/// A device that joined with an employee's own account (their phone) signs
/// that employee in by itself.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  EmployeeRow? _selected;
  var _pin = '';
  var _error = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _tryAutoSignIn(ref.read(employeesProvider).value));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _tryAutoSignIn(List<EmployeeRow>? employees) async {
    if (employees == null || !mounted || ref.read(_autoSignInTriedProvider)) return;
    final id = await ref.read(syncStoreProvider)?.getState('auto_employee_id');
    if (!mounted) return;
    if (id == null) {
      ref.read(_autoSignInTriedProvider.notifier).mark();
      return;
    }
    // The account's employee may still be on its way (first download).
    final e = employees.where((x) => x.id == id && x.active).firstOrNull;
    if (e == null) return;
    ref.read(_autoSignInTriedProvider.notifier).mark();
    final device = await ref.read(thisDeviceProvider.future);
    if (device != null) ref.read(sessionProvider.notifier).signIn(device, e);
  }

  void _pick(EmployeeRow e) {
    setState(() {
      _selected = e;
      _pin = '';
      _error = false;
    });
    _focus.requestFocus();
  }

  Future<void> _type(String digit) async {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == 4) await _verify();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    final e = _selected!;
    final ok = await ref.read(peopleProvider).verifyPin(e.id, _pin);
    if (!mounted) return;
    if (ok == null) {
      setState(() {
        _pin = '';
        _error = true;
      });
      return;
    }
    final device = await ref.read(thisDeviceProvider.future);
    ref.read(sessionProvider.notifier).signIn(device!, ok);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent || _selected == null) return KeyEventResult.ignored;
    final ch = event.character == null ? null : toLatinDigits(event.character!);
    if (ch != null && RegExp(r'^[0-9]$').hasMatch(ch)) {
      _type(ch);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _selected = null);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final employees = ref.watch(employeesProvider).value ?? const [];
    ref.listen(employeesProvider, (_, next) => _tryAutoSignIn(next.value));

    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DoayaSpacing.huge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: DoayaSizes.formWidth),
              child: GlassSurface(
                tone: SurfaceTone.strong,
                blur: true,
                borderRadius: BorderRadius.circular(DoayaRadii.splashCard),
                padding: const EdgeInsets.all(DoayaSpacing.giant),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: DoayaWordmark(name: l.appName, textStyle: DoayaTypography.title),
                    ),
                    const SizedBox(height: DoayaSpacing.xxl),
                    if (_selected == null) ...[
                      Text(l.loginTitle, style: DoayaTypography.lead, textAlign: TextAlign.center),
                      const SizedBox(height: DoayaSpacing.xl),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: DoayaSpacing.ml,
                        runSpacing: DoayaSpacing.ml,
                        children: [
                          for (final e in employees)
                            _EmployeeTile(
                              name: e.name,
                              role: e.role == 'owner' ? l.owner : l.employee,
                              onTap: () => _pick(e),
                            ),
                        ],
                      ),
                    ] else
                      _PinPad(
                        title: l.loginEnterPin(_selected!.name),
                        length: _pin.length,
                        error: _error ? l.wrongPin : null,
                        onDigit: _type,
                        onBackspace: _backspace,
                        onBack: () => setState(() => _selected = null),
                        backLabel: l.changeEmployee,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.name, required this.role, required this.onTap});

  final String name;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DoayaSizes.employeeTile,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(DoayaRadii.card),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(DoayaSpacing.l),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: DoayaSizes.avatar / 2,
                    backgroundColor: DoayaColors.selectedTileFill,
                    child: Text(
                      initialsOf(name),
                      style: DoayaTypography.label.copyWith(color: DoayaColors.accent),
                    ),
                  ),
                  const SizedBox(height: DoayaSpacing.sm),
                  Text(name, style: DoayaTypography.label, textAlign: TextAlign.center),
                  Text(
                    role,
                    style: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({
    required this.title,
    required this.length,
    required this.onDigit,
    required this.onBackspace,
    required this.onBack,
    required this.backLabel,
    this.error,
  });

  final String title;
  final int length;
  final String? error;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback onTap, {String? semantics}) => Padding(
      padding: const EdgeInsets.all(DoayaSpacing.xs),
      child: SizedBox.square(
        dimension: DoayaSizes.pinKey,
        child: Semantics(
          button: true,
          label: semantics,
          child: GlassSurface(
            shadow: false,
            borderRadius: BorderRadius.circular(DoayaSizes.pinKey / 2),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
    Widget digit(int d) => key(Text('$d', style: DoayaTypography.titleSmall), () => onDigit('$d'));

    return Column(
      children: [
        Text(title, style: DoayaTypography.lead, textAlign: TextAlign.center),
        const SizedBox(height: DoayaSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: DoayaSpacing.s),
                width: DoayaSpacing.l,
                height: DoayaSpacing.l,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < length ? DoayaColors.accent : DoayaColors.transparent,
                  border: Border.all(color: DoayaColors.accent),
                ),
              ),
          ],
        ),
        SizedBox(
          height: DoayaSpacing.huge + DoayaSpacing.sm,
          child: Center(
            child: error == null
                ? null
                : Text(
                    error!,
                    style: DoayaTypography.caption.copyWith(color: DoayaColors.dangerText),
                  ),
          ),
        ),
        // Keypad is laid out LTR like every phone/ATM keypad.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              for (final row in const [
                [1, 2, 3],
                [4, 5, 6],
                [7, 8, 9],
              ])
                Row(mainAxisAlignment: MainAxisAlignment.center, children: row.map(digit).toList()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(dimension: DoayaSizes.pinKey + DoayaSpacing.sm),
                  digit(0),
                  key(const Icon(DoayaIcons.backspace, size: DoayaSizes.iconM), onBackspace),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.ml),
        TextButton(
          onPressed: onBack,
          child: Text(
            backLabel,
            style: DoayaTypography.caption.copyWith(color: DoayaColors.accent),
          ),
        ),
      ],
    );
  }
}
