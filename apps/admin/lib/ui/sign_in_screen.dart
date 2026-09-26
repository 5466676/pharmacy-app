import 'package:doaya_core/doaya_core.dart' show toLatinDigits;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _busy) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .login(toLatinDigits(_phone.text.trim()), _password.text);
    } on Object catch (e) {
      if (mounted) setState(() => _error = errorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String? required(String? v) => (v ?? '').trim().isEmpty ? l.required : null;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DoayaSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DoayaSizes.dialogWidth),
            child: GlassSurface(
              padding: EdgeInsets.all(DoayaSpacing.xl),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: DoayaLogo(size: DoayaSizes.logoMedium)),
                    SizedBox(height: DoayaSpacing.m),
                    Text(l.signInTitle, textAlign: TextAlign.center, style: DoayaTypography.title),
                    SizedBox(height: DoayaSpacing.xs),
                    Text(
                      l.signInSubtitle,
                      textAlign: TextAlign.center,
                      style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                    ),
                    SizedBox(height: DoayaSpacing.l),
                    GlassTextField(
                      label: l.phone,
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      validator: required,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: DoayaSpacing.m),
                    GlassTextField(
                      label: l.password,
                      controller: _password,
                      obscureText: true,
                      validator: required,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: DoayaSpacing.m),
                      NoticeBanner(message: _error!, tone: StatusTone.danger),
                    ],
                    SizedBox(height: DoayaSpacing.l),
                    SagePillButton(
                      label: l.signIn,
                      icon: DoayaIcons.forward,
                      expand: true,
                      onPressed: _busy ? null : _submit,
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
