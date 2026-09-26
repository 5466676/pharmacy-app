import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'consultation_tile.dart';

/// Opens a new consultation and goes to its chat.
Future<void> startConsultation(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  try {
    final c = await ref.read(apiProvider).startConsultation();
    ref.invalidate(consultationsProvider);
    if (context.mounted) await context.push(Routes.chat(c.id));
  } on Object catch (e) {
    if (context.mounted) toast(context, errorText(l, e), error: true);
  }
}

/// From design/patient_home.html: the pharmacy, the "حاسس بشي؟" hero, the
/// last consultations and the emergency line. (The shelf comes in step 7.)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pharmacy = ref.watch(authProvider).patient?.pharmacy;
    final recent = ref.watch(consultationsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(consultationsProvider.future),
      child: PhoneBody(
        child: ListView(
          children: [
            const SizedBox(height: DoayaSpacing.l),
            Row(
              children: [
                Text(l.appName, style: DoayaTypography.title),
                const Spacer(),
                if (pharmacy != null)
                  Flexible(
                    child: GlassPillButton(
                      label: pharmacy.name,
                      icon: DoayaIcons.pharmacy,
                      size: PillSize.small,
                      onPressed: () => context.go(Routes.account),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DoayaSpacing.xl),
            const _Hero(),
            const SizedBox(height: DoayaSpacing.xl),
            NoticeBanner(message: l.safetyLine, icon: DoayaIcons.warning),
            const SizedBox(height: DoayaSpacing.xl),
            SectionHeader(
              title: l.recentConsultations,
              actionLabel: l.seeAll,
              onAction: () => context.go(Routes.consultations),
            ),
            const SizedBox(height: DoayaSpacing.sm),
            ...switch (recent) {
              AsyncData(:final value) when value.isEmpty => [
                Text(
                  l.noConsultations,
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
              AsyncData(:final value) => [
                for (final c in value.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: ConsultationTile(
                      consultation: c,
                      onTap: () => context.push(Routes.chat(c.id)),
                    ),
                  ),
              ],
              AsyncError(:final error) => [
                NoticeBanner(
                  message: errorText(l, error),
                  action: GlassPillButton(
                    label: l.retry,
                    size: PillSize.small,
                    onPressed: () => ref.invalidate(consultationsProvider),
                  ),
                ),
              ],
              _ => [const Center(child: CircularProgressIndicator())],
            },
            const SizedBox(height: DoayaSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _Hero extends ConsumerStatefulWidget {
  const _Hero();

  @override
  ConsumerState<_Hero> createState() => _HeroState();
}

class _HeroState extends ConsumerState<_Hero> {
  var _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    await startConsultation(context, ref);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassSurface(
      tone: SurfaceTone.strong,
      blur: true,
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding: const EdgeInsets.all(DoayaSpacing.huge),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.heroTitle, style: DoayaTypography.displayLarge.copyWith(height: 1.2)),
                const SizedBox(height: DoayaSpacing.m),
                Text(
                  l.heroSubtitle,
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
                const SizedBox(height: DoayaSpacing.l),
                SagePillButton(
                  label: l.startConsultation,
                  icon: DoayaIcons.chat,
                  size: PillSize.small,
                  onPressed: _busy ? null : _start,
                ),
              ],
            ),
          ),
          const DoayaLogo(size: DoayaSizes.logoHero),
        ],
      ),
    );
  }
}
