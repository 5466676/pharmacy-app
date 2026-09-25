import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/people_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// First run on a new machine: pharmacy name, device name, owner + PIN.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<FormState>();
  final _pharmacy = TextEditingController();
  final _device = TextEditingController();
  final _owner = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    for (final c in [_pharmacy, _device, _owner, _pin, _pin2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final people = ref.read(peopleProvider);
    final (device, owner) = await people.setUp(
      deviceName: _device.text,
      ownerName: _owner.text,
      ownerPin: _pin.text,
      pharmacyName: _pharmacy.text,
    );
    ref.read(sessionProvider.notifier).signIn(device, owner);
    ref.invalidate(thisDeviceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String? requiredField(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    final pinFormatters = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DoayaSpacing.huge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DoayaSizes.formWidth),
            child: GlassSurface(
              tone: SurfaceTone.strong,
              blur: true,
              borderRadius: BorderRadius.circular(DoayaRadii.splashCard),
              padding: const EdgeInsets.all(DoayaSpacing.giant),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: DoayaLogo(size: DoayaSizes.logoLarge)),
                    const SizedBox(height: DoayaSpacing.ml),
                    Text(l.setupTitle, style: DoayaTypography.title, textAlign: TextAlign.center),
                    const SizedBox(height: DoayaSpacing.sm),
                    Text(
                      l.setupSubtitle,
                      textAlign: TextAlign.center,
                      style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                    ),
                    const SizedBox(height: DoayaSpacing.huge),
                    GlassTextField(
                      label: l.pharmacyNameLabel,
                      controller: _pharmacy,
                      validator: requiredField,
                      autofocus: true,
                    ),
                    const SizedBox(height: DoayaSpacing.l),
                    GlassTextField(
                      label: l.deviceNameLabel,
                      hint: l.deviceNameHint,
                      controller: _device,
                      validator: requiredField,
                    ),
                    const SizedBox(height: DoayaSpacing.l),
                    GlassTextField(
                      label: l.ownerNameLabel,
                      controller: _owner,
                      validator: requiredField,
                    ),
                    const SizedBox(height: DoayaSpacing.l),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GlassTextField(
                            label: l.pinLabel,
                            controller: _pin,
                            obscureText: true,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            inputFormatters: pinFormatters,
                            validator: (v) =>
                                PeopleRepository.isValidPin(v ?? '') ? null : l.pinInvalid,
                          ),
                        ),
                        const SizedBox(width: DoayaSpacing.ml),
                        Expanded(
                          child: GlassTextField(
                            label: l.pinConfirmLabel,
                            controller: _pin2,
                            obscureText: true,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            inputFormatters: pinFormatters,
                            validator: (v) => v == _pin.text ? null : l.pinMismatch,
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DoayaSpacing.huge),
                    SagePillButton(
                      label: l.startButton,
                      icon: DoayaIcons.forward,
                      iconLayout: PillIconLayout.spread,
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
