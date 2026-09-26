import 'package:doaya_core/doaya_core.dart' show toLatinDigits, whatsappNumber;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

/// From design/patient_splash_and_logo.html: the logo, a promise, two ways in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              const Center(child: DoayaLogo(size: DoayaSizes.logoHero)),
              SizedBox(height: DoayaSpacing.l),
              Text(l.appName, textAlign: TextAlign.center, style: DoayaTypography.wordmark),
              SizedBox(height: DoayaSpacing.sm),
              Text(
                l.tagline,
                textAlign: TextAlign.center,
                style: DoayaTypography.bodyMedium.copyWith(color: DoayaColors.textSecondary),
              ),
              const Spacer(flex: 4),
              SagePillButton(
                label: l.createAccount,
                size: PillSize.large,
                expand: true,
                onPressed: () => context.push(Routes.signUp),
              ),
              SizedBox(height: DoayaSpacing.sm),
              GlassPillButton(
                label: l.haveAccount,
                size: PillSize.large,
                expand: true,
                onPressed: () => context.push(Routes.signIn),
              ),
              SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormPage extends StatelessWidget {
  const _FormPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              SizedBox(height: DoayaSpacing.l),
              Row(
                children: [
                  RoundIconButton(
                    icon: DoayaIcons.back,
                    tooltip: l.cancel,
                    onPressed: () => context.canPop() ? context.pop() : context.go(Routes.welcome),
                  ),
                  SizedBox(width: DoayaSpacing.sm),
                  Text(title, style: DoayaTypography.title),
                ],
              ),
              SizedBox(height: DoayaSpacing.xl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

String? _checkPhone(AppLocalizations l, String? v) =>
    whatsappNumber(v) == null ? l.invalidPhone : null;

String? _checkPassword(AppLocalizations l, String? v) =>
    (v ?? '').length < 6 ? l.passwordTooShort : null;

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _year = TextEditingController();
  final _city = TextEditingController();
  String? _sex;
  var _consent = false;
  var _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _password, _year, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            name: _name.text.trim(),
            phone: toLatinDigits(_phone.text),
            password: _password.text,
            birthYear: int.tryParse(toLatinDigits(_year.text)),
            sex: _sex,
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
            fileConsent: _consent,
          );
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final gap = SizedBox(height: DoayaSpacing.l);
    final thisYear = DateTime.now().year;
    return _FormPage(
      title: l.signUpTitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                label: l.nameLabel,
                controller: _name,
                validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
              ),
              gap,
              GlassTextField(
                label: l.phoneLabel,
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                validator: (v) => _checkPhone(l, v),
              ),
              gap,
              GlassTextField(
                label: l.passwordLabel,
                controller: _password,
                obscureText: true,
                validator: (v) => _checkPassword(l, v),
              ),
              gap,
              GlassTextField(
                label: '${l.birthYearLabel} (${l.optional})',
                controller: _year,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
                validator: (v) {
                  if ((v ?? '').isEmpty) return null;
                  final y = int.tryParse(toLatinDigits(v!));
                  return y == null || y < 1900 || y > thisYear ? l.invalidYear : null;
                },
              ),
              gap,
              Text(
                '${l.sexLabel} (${l.optional})',
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
              SizedBox(height: DoayaSpacing.s),
              Row(
                children: [
                  for (final (value, label) in [('m', l.male), ('f', l.female)]) ...[
                    Expanded(
                      child: GlassPillButton(
                        label: label,
                        expand: true,
                        selected: _sex == value,
                        onPressed: () => setState(() => _sex = _sex == value ? null : value),
                      ),
                    ),
                    if (value == 'm') SizedBox(width: DoayaSpacing.sm),
                  ],
                ],
              ),
              gap,
              GlassTextField(label: '${l.cityLabel} (${l.optional})', controller: _city),
              SizedBox(height: DoayaSpacing.sm),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: Text(l.fileConsent, style: DoayaTypography.bodySmall),
              ),
              Text(
                l.signUpHelp,
                style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
              ),
              SizedBox(height: DoayaSpacing.xl),
              BusyButton(label: l.createAccount, busy: _busy, onPressed: _submit),
              SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).login(toLatinDigits(_phone.text), _password.text);
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _FormPage(
      title: l.signInTitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                label: l.phoneLabel,
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                validator: (v) => _checkPhone(l, v),
              ),
              SizedBox(height: DoayaSpacing.l),
              GlassTextField(
                label: l.passwordLabel,
                controller: _password,
                obscureText: true,
                validator: (v) => _checkPassword(l, v),
                onSubmitted: (_) => _submit(),
              ),
              SizedBox(height: DoayaSpacing.xl),
              BusyButton(label: l.signIn, busy: _busy, onPressed: _submit),
            ],
          ),
        ),
      ],
    );
  }
}
