import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../central/central_api.dart';
import '../central/inbox_controller.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';
import 'screens/sync_screen.dart' show syncErrorText;
import 'widgets.dart';

const _kinds = ['allergy', 'condition', 'medication', 'pregnancy', 'weight', 'note'];

String fileKindLabel(AppLocalizations l, String kind) => switch (kind) {
  'allergy' => l.fileKindAllergy,
  'condition' => l.fileKindCondition,
  'medication' => l.fileKindMedication,
  'pregnancy' => l.fileKindPregnancy,
  'weight' => l.fileKindWeight,
  _ => l.fileKindNote,
};

final patientFileProvider = FutureProvider.autoDispose.family<PatientFile, String>(
  (ref, id) => ref.read(centralApiProvider)!.patientFile(id),
);

/// «ملف المريض» beside a case or an order: allergies first, what the chat
/// revealed for the pharmacist to confirm, and adding a fact. Shown only
/// when the patient agreed to a file.
class PatientFilePanel extends ConsumerWidget {
  const PatientFilePanel({super.key, required this.patient});

  final CasePatient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = patient.id;
    if (id == null || !patient.hasFile) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final async = ref.watch(patientFileProvider(id));
    return Panel(
      title: l.fileTitle,
      child: switch (async) {
        AsyncData(:final value) => _Body(id, value),
        AsyncError(:final error) => EmptyHint(syncErrorText(l, error)),
        _ => Center(child: CircularProgressIndicator(color: DoayaColors.accent)),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body(this.patientId, this.f);
  final String patientId;
  final PatientFile f;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(CentralApi) job,
  ) async {
    final l = AppLocalizations.of(context);
    try {
      await job(ref.read(centralApiProvider)!);
    } on Object catch (e) {
      if (context.mounted) toast(context, syncErrorText(l, e), error: true);
    }
    ref.invalidate(patientFileProvider(patientId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    if (f.limited) return Text(l.fileLimited, style: secondary);
    final allergies = f.facts.where((x) => x.kind == 'allergy').map((x) => x.text).toList();
    final mine = f.proposals.where((p) => p.forPharmacist).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (allergies.isNotEmpty) ...[
          NoticeBanner(
            tone: StatusTone.danger,
            icon: DoayaIcons.warning,
            message: l.fileAllergyAlert(allergies.join('، ')),
          ),
          SizedBox(height: DoayaSpacing.sm),
        ],
        if (f.facts.isEmpty) Text(l.fileNoFacts, style: secondary),
        for (final fact in f.facts)
          Padding(
            padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fileKindLabel(l, fact.kind)}: ${fact.text}',
                        style: DoayaTypography.bodySmall,
                      ),
                      if (fact.instructions != null || fact.endsAt != null)
                        Text(
                          [
                            ?fact.instructions,
                            if (fact.endsAt != null) l.fileUntil(formatDate(fact.endsAt!)),
                          ].join('، '),
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (!fact.confirmed) ...[
                  StatusChip(label: l.fileByPatient),
                  SizedBox(width: DoayaSpacing.xs),
                  GlassPillButton(
                    label: l.fileConfirm,
                    onPressed: () =>
                        _run(context, ref, (api) => api.confirmFact(patientId, fact.id)),
                  ),
                ],
                RoundIconButton(
                  icon: DoayaIcons.close,
                  tooltip: l.fileEnd,
                  size: DoayaSizes.buttonSmall,
                  onPressed: () => _run(context, ref, (api) => api.endFact(patientId, fact.id)),
                ),
              ],
            ),
          ),
        if (mine.isNotEmpty) ...[
          SizedBox(height: DoayaSpacing.m),
          Text(l.fileToConfirm, style: DoayaTypography.label),
          for (final p in mine)
            Padding(
              padding: EdgeInsets.only(top: DoayaSpacing.sm),
              child: NoticeBanner(
                tone: StatusTone.accent,
                message: '${fileKindLabel(l, p.kind)}: ${p.text}\n${l.fileProposalFrom}',
                action: Wrap(
                  spacing: DoayaSpacing.sm,
                  children: [
                    SagePillButton(
                      label: l.fileAccept,
                      size: PillSize.small,
                      onPressed: () => _run(
                        context,
                        ref,
                        (api) => api.decideProposal(patientId, p.id, accept: true),
                      ),
                    ),
                    GlassPillButton(
                      label: l.fileReject,
                      onPressed: () => _run(
                        context,
                        ref,
                        (api) => api.decideProposal(patientId, p.id, accept: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
        SizedBox(height: DoayaSpacing.m),
        Row(
          children: [
            Expanded(child: Text(l.filePastCases(formatNumber(f.pastCases)), style: secondary)),
            GlassPillButton(
              label: l.fileAdd,
              icon: DoayaIcons.add,
              onPressed: () async {
                final added = await _addFact(context);
                if (added != null && context.mounted) {
                  await _run(context, ref, (api) => api.addFact(patientId, added.$1, added.$2));
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

Future<(String, String)?> _addFact(BuildContext context) =>
    showDialog<(String, String)>(context: context, builder: (_) => const _AddFactDialog());

class _AddFactDialog extends StatefulWidget {
  const _AddFactDialog();

  @override
  State<_AddFactDialog> createState() => _AddFactDialogState();
}

class _AddFactDialogState extends State<_AddFactDialog> {
  String _kind = 'allergy';
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.fileAdd, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: DoayaSpacing.xs,
              runSpacing: DoayaSpacing.xs,
              children: [
                for (final k in _kinds)
                  GlassPillButton(
                    label: fileKindLabel(l, k),
                    selected: k == _kind,
                    onPressed: () => setState(() => _kind = k),
                  ),
              ],
            ),
            SizedBox(height: DoayaSpacing.m),
            GlassTextField(label: l.factText, controller: _text, autofocus: true),
          ],
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
        SagePillButton(
          label: l.save,
          size: PillSize.small,
          onPressed: () {
            final t = _text.text.trim();
            if (t.isNotEmpty) Navigator.pop(context, (_kind, t));
          },
        ),
      ],
    );
  }
}
