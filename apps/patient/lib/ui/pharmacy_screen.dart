import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

/// The pharmacy the patient's cases and orders go to: by the code on the
/// counter, or from the list of their city.
class ChoosePharmacyScreen extends ConsumerStatefulWidget {
  const ChoosePharmacyScreen({super.key});

  @override
  ConsumerState<ChoosePharmacyScreen> createState() => _ChoosePharmacyScreenState();
}

class _ChoosePharmacyScreenState extends ConsumerState<ChoosePharmacyScreen> {
  final _code = TextEditingController();
  late final _city = TextEditingController(text: ref.read(authProvider).patient?.city ?? '');
  List<PharmacyBrief>? _found;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _code.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _run(Future<List<PharmacyBrief>> Function() call) async {
    setState(() => _busy = true);
    try {
      final found = await call();
      if (mounted) setState(() => _found = found);
    } on Object catch (e) {
      if (mounted) toast(context, errorText(AppLocalizations.of(context), e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _search() => _run(() => ref.read(apiProvider).directory(city: _city.text.trim()));

  void _byCode() {
    if (_code.text.trim().isEmpty) return;
    _run(() async => [await ref.read(apiProvider).byCode(_code.text)]);
  }

  Future<void> _choose(PharmacyBrief p) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).choosePharmacy(p);
      ref.invalidate(consultationsProvider);
      if (mounted) context.canPop() ? context.pop() : context.go(Routes.home);
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(authProvider).patient?.pharmacy;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              ScreenHeader(
                title: l.choosePharmacyTitle,
                onBack: context.canPop() ? () => context.pop() : null,
              ),
              Text(l.choosePharmacyHelp, style: secondary),
              const SizedBox(height: DoayaSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GlassTextField(
                      label: l.pharmacyCodeLabel,
                      hint: l.pharmacyCodeHint,
                      controller: _code,
                      textDirection: TextDirection.ltr,
                      onSubmitted: (_) => _byCode(),
                    ),
                  ),
                  const SizedBox(width: DoayaSpacing.sm),
                  SagePillButton(
                    label: l.findByCode,
                    size: PillSize.medium,
                    onPressed: _busy ? null : _byCode,
                  ),
                ],
              ),
              const SizedBox(height: DoayaSpacing.xl),
              Text(l.orPickFromList, style: DoayaTypography.label),
              const SizedBox(height: DoayaSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GlassTextField(
                      label: l.cityLabel,
                      controller: _city,
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: DoayaSpacing.sm),
                  GlassPillButton(
                    label: l.findByCode,
                    icon: DoayaIcons.search,
                    size: PillSize.medium,
                    onPressed: _busy ? null : _search,
                  ),
                ],
              ),
              const SizedBox(height: DoayaSpacing.xl),
              if (_found == null && _busy)
                const Center(child: CircularProgressIndicator())
              else if (_found case final found? when found.isEmpty)
                Text(l.noPharmacies, style: secondary)
              else
                for (final p in _found ?? const <PharmacyBrief>[])
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: _PharmacyCard(
                      pharmacy: p,
                      current: p.id == current?.id,
                      onChoose: _busy ? null : () => _choose(p),
                    ),
                  ),
              const SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  const _PharmacyCard({required this.pharmacy, required this.current, required this.onChoose});

  final PharmacyBrief pharmacy;
  final bool current;
  final VoidCallback? onChoose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = pharmacy;
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return GlassSurface(
      tone: current ? SurfaceTone.selected : SurfaceTone.normal,
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      padding: const EdgeInsets.all(DoayaSpacing.l),
      child: Row(
        children: [
          const Icon(DoayaIcons.pharmacy, color: DoayaColors.accent, size: DoayaSizes.iconL),
          const SizedBox(width: DoayaSpacing.ml),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: DoayaTypography.label),
                Text([p.city, ?p.address].join('، '), style: secondary),
                if (p.hours != null) Text(l.pharmacyHours(p.hours!), style: secondary),
                if (p.phone != null) Text(ltrIsolate(p.phone!), style: secondary),
              ],
            ),
          ),
          const SizedBox(width: DoayaSpacing.sm),
          if (current)
            const Icon(DoayaIcons.check, color: DoayaColors.accent)
          else
            SagePillButton(label: l.chooseThis, size: PillSize.small, onPressed: onChoose),
        ],
      ),
    );
  }
}
