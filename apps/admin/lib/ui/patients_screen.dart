import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

String factKind(AppLocalizations l, String k) => switch (k) {
  'allergy' => l.fkAllergy,
  'condition' => l.fkCondition,
  'medication' => l.fkMedication,
  'pregnancy' => l.fkPregnancy,
  'weight' => l.fkWeight,
  _ => l.fkNote,
};

/// «المرضى»: every patient by name or phone, and their file. The server
/// logs every opening (owner's decision: he sees everything, on record).
class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key, this.selected});
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSearchField(
          hint: l.searchPatients,
          onChanged: (q) => ref.read(patientQueryProvider.notifier).set(q),
        ),
        SizedBox(height: DoayaSpacing.m),
        Expanded(
          child: AsyncView(
            value: ref.watch(patientsProvider),
            retry: () => ref.invalidate(patientsProvider),
            data: (items) => items.isEmpty
                ? EmptyHint(l.noPatients)
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.xs),
                    itemBuilder: (_, i) {
                      final p = items[i];
                      return GlassSurface(
                        tone: p.id == selected ? SurfaceTone.selected : SurfaceTone.normal,
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(DoayaRadii.card),
                          onTap: () => context.go(Routes.patient(p.id)),
                          child: Padding(
                            padding: EdgeInsets.all(DoayaSpacing.m),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: DoayaTypography.label),
                                      Text(
                                        [
                                          p.phone,
                                          ?p.pharmacy,
                                          l.patientCases(formatNumber(p.cases)),
                                        ].join('، '),
                                        style: DoayaTypography.caption.copyWith(
                                          color: DoayaColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!p.hasFile) StatusChip(label: l.noFileYet),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l.navPatients, subtitle: l.patientsSubtitle),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final detail = selected == null
                  ? Panel(child: EmptyHint(l.pickPatient))
                  : _FileView(id: selected!);
              if (c.maxWidth < 900) {
                return selected == null ? list : SingleChildScrollView(child: detail);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: DoayaSizes.listPaneWidth + 60, child: list),
                  SizedBox(width: DoayaSpacing.l),
                  Expanded(child: SingleChildScrollView(child: detail)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FileView extends ConsumerWidget {
  const _FileView({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return AsyncView(
      value: ref.watch(patientFileProvider(id)),
      retry: () => ref.invalidate(patientFileProvider(id)),
      data: (f) {
        final p = f.patient;
        Widget fact(Json x, {bool past = false}) => Padding(
          padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xxs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${factKind(l, x['kind']! as String)}: ${x['text']}',
                  style: past
                      ? DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary)
                      : DoayaTypography.bodySmall,
                ),
              ),
              StatusChip(
                label: x['confirmed'] == true ? l.factConfirmed : l.factPatient,
                tone: x['confirmed'] == true ? StatusTone.success : StatusTone.neutral,
              ),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Panel(
              title: p.name,
              child: Text(
                [p.phone, if (p.age != null) formatNumber(p.age!), ?p.city].join('، '),
                style: secondary,
              ),
            ),
            SizedBox(height: DoayaSpacing.m),
            if (!f.consented)
              Panel(child: Text(l.fileNotAgreed, style: DoayaTypography.bodySmall))
            else ...[
              Panel(
                title: l.fileFacts,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (f.facts.isEmpty) Text(l.logEmpty, style: secondary),
                    for (final x in f.facts) fact(x),
                    if (f.proposals.isNotEmpty) ...[
                      SizedBox(height: DoayaSpacing.m),
                      Text(l.fileProposals, style: DoayaTypography.label),
                      for (final x in f.proposals)
                        Text(
                          '${factKind(l, x['kind']! as String)}: ${x['text']} '
                          '(${x['needs'] == 'pharmacist' ? l.needsPharmacist : l.needsPatient})',
                          style: secondary,
                        ),
                    ],
                    if (f.pastFacts.isNotEmpty) ...[
                      SizedBox(height: DoayaSpacing.m),
                      Text(l.filePastFacts, style: DoayaTypography.label),
                      for (final x in f.pastFacts) fact(x, past: true),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: DoayaSpacing.m),
            Panel(
              title: l.fileHistory,
              child: f.history.isEmpty
                  ? EmptyHint(l.logEmpty)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final h in f.history)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (((h['summary'] as Json?)?['symptoms'] as List?) ?? const [])
                                      .join('، '),
                                  style: DoayaTypography.label,
                                ),
                                Text(
                                  [
                                    formatDate(DateTime.parse(h['sent_at']! as String)),
                                    ?h['pharmacy'] as String?,
                                    for (final i
                                        in (((h['decision'] as Json?)?['items'] as List?) ??
                                            const []))
                                      (i as Json)['name']! as String,
                                  ].join('، '),
                                  style: secondary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            SizedBox(height: DoayaSpacing.m),
            Panel(
              title: l.fileOpened,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final o in f.opened)
                    Text(l.logBy(o.by, formatDateTime(o.at)), style: secondary),
                ],
              ),
            ),
            SizedBox(height: DoayaSpacing.xl),
          ],
        );
      },
    );
  }
}
