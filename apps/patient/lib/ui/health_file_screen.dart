import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

const fileKinds = ['allergy', 'condition', 'medication', 'pregnancy', 'weight', 'note'];

String kindLabel(AppLocalizations l, String kind) => switch (kind) {
  'allergy' => l.kindAllergy,
  'condition' => l.kindCondition,
  'medication' => l.kindMedication,
  'pregnancy' => l.kindPregnancy,
  'weight' => l.kindWeight,
  _ => l.kindNote,
};

/// «ملفي الصحي».
class HealthFileScreen extends ConsumerWidget {
  const HealthFileScreen({super.key});

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() job) async {
    final l = AppLocalizations.of(context);
    try {
      await job();
    } on Object catch (e) {
      if (context.mounted) toast(context, errorText(l, e), error: true);
    }
    ref.invalidate(healthFileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    final file = ref.watch(healthFileProvider);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              ScreenHeader(
                title: l.fileTitle,
                onBack: () => context.canPop() ? context.pop() : context.go(Routes.account),
              ),
              switch (file) {
                AsyncData(value: null) => _NoFile(
                  onEnable: () => _run(context, ref, () => api.setFileConsent(true)),
                ),
                AsyncData(:final value?) => _File(value, run: (job) => _run(context, ref, job)),
                AsyncError(:final error) => Padding(
                  padding: EdgeInsets.all(DoayaSpacing.xl),
                  child: Column(
                    children: [
                      Text(errorText(l, error), textAlign: TextAlign.center),
                      SizedBox(height: DoayaSpacing.m),
                      GlassPillButton(
                        label: l.retry,
                        onPressed: () => ref.invalidate(healthFileProvider),
                      ),
                    ],
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
              SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoFile extends StatelessWidget {
  const _NoFile({required this.onEnable});
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassSurface(
      padding: EdgeInsets.all(DoayaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.fileNoConsent, style: DoayaTypography.body),
          SizedBox(height: DoayaSpacing.l),
          SagePillButton(label: l.fileEnable, expand: true, onPressed: onEnable),
        ],
      ),
    );
  }
}

class _File extends ConsumerWidget {
  const _File(this.f, {required this.run});
  final HealthFile f;
  final Future<void> Function(Future<void> Function() job) run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final mine = f.proposals.where((p) => p.forMe).toList();
    final theirs = f.proposals.where((p) => !p.forMe).toList();
    Widget section(String title) => Padding(
      padding: EdgeInsets.only(top: DoayaSpacing.xl, bottom: DoayaSpacing.sm),
      child: Text(title, style: DoayaTypography.lead),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.fileIntro, style: secondary),
        if (mine.isNotEmpty) ...[
          section(l.fileConfirmMine),
          for (final p in mine)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: NoticeBanner(
                tone: StatusTone.accent,
                message: '${kindLabel(l, p.kind)}: ${p.text}\n${l.fileProposalHelp}',
                action: Wrap(
                  spacing: DoayaSpacing.sm,
                  children: [
                    SagePillButton(
                      label: l.yes,
                      size: PillSize.small,
                      onPressed: () => run(() => api.decideProposal(p.id, accept: true)),
                    ),
                    GlassPillButton(
                      label: l.no,
                      onPressed: () => run(() => api.decideProposal(p.id, accept: false)),
                    ),
                  ],
                ),
              ),
            ),
        ],
        section(l.fileNow),
        if (f.facts.isEmpty) Text(l.fileEmpty, style: secondary),
        for (final fact in f.facts) _FactTile(fact, onEnd: () => run(() => api.endFact(fact.id))),
        if (theirs.isNotEmpty) ...[
          section(l.fileConfirmPharmacist),
          for (final p in theirs)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.xs),
              child: Text('${kindLabel(l, p.kind)}: ${p.text}', style: secondary),
            ),
        ],
        SizedBox(height: DoayaSpacing.m),
        GlassPillButton(
          label: l.addFact,
          icon: DoayaIcons.add,
          expand: true,
          onPressed: () async {
            final added = await showModalBottomSheet<(String, String)>(
              context: context,
              isScrollControlled: true,
              backgroundColor: DoayaColors.transparent,
              builder: (_) => const _AddFact(),
            );
            if (added != null) await run(() => api.addFact(added.$1, added.$2));
          },
        ),
        if (f.history.isNotEmpty) ...[
          section(l.fileHistory),
          for (final h in f.history)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: GlassSurface(
                padding: EdgeInsets.all(DoayaSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            h.symptoms.isEmpty ? (h.pharmacy ?? '') : h.symptoms.join('، '),
                            style: DoayaTypography.label,
                          ),
                        ),
                        if (h.urgent) StatusChip(label: l.urgentShort, tone: StatusTone.danger),
                        if (h.doctorAdvice)
                          StatusChip(label: l.doctorAdvisedShort, tone: StatusTone.warning),
                      ],
                    ),
                    Text([formatDate(h.sentAt), ?h.pharmacy].join('، '), style: secondary),
                    for (final m in h.medicines) LatinText(m, style: DoayaTypography.bodySmall),
                  ],
                ),
              ),
            ),
        ],
        if (f.pastFacts.isNotEmpty) ...[
          section(l.filePast),
          for (final fact in f.pastFacts) _FactTile(fact, past: true),
        ],
        SizedBox(height: DoayaSpacing.xl),
        GlassPillButton(
          label: l.fileExport,
          icon: DoayaIcons.share,
          expand: true,
          onPressed: () => run(() async {
            await Clipboard.setData(ClipboardData(text: await api.exportFile()));
            if (context.mounted) toast(context, l.fileExported);
          }),
        ),
        SizedBox(height: DoayaSpacing.sm),
        GlassPillButton(
          label: l.fileDelete,
          icon: DoayaIcons.delete,
          expand: true,
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(l.fileDeleteConfirm, style: DoayaTypography.body),
                actions: [
                  GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context, false)),
                  SagePillButton(
                    label: l.confirm,
                    size: PillSize.small,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
            if (ok != true) return;
            await run(api.deleteFile);
            if (context.mounted) toast(context, l.fileDeleted);
          },
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile(this.f, {this.onEnd, this.past = false});
  final HealthFact f;
  final VoidCallback? onEnd;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return Padding(
      padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
      child: GlassSurface(
        padding: EdgeInsets.all(DoayaSpacing.l),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kindLabel(l, f.kind), style: secondary),
                  Text(
                    f.text,
                    style: past
                        ? DoayaTypography.body.copyWith(color: DoayaColors.textSecondary)
                        : DoayaTypography.body,
                  ),
                  if (f.instructions != null)
                    Text(f.instructions!, style: DoayaTypography.bodySmall),
                  if (f.endsAt != null && !past)
                    Text(l.factUntil(formatDate(f.endsAt!)), style: secondary),
                ],
              ),
            ),
            StatusChip(
              label: f.confirmed ? l.factByPharmacist : l.factByMe,
              tone: f.confirmed ? StatusTone.success : StatusTone.neutral,
            ),
            if (onEnd != null)
              RoundIconButton(icon: DoayaIcons.close, tooltip: l.factEnd, onPressed: onEnd),
          ],
        ),
      ),
    );
  }
}

class _AddFact extends StatefulWidget {
  const _AddFact();

  @override
  State<_AddFact> createState() => _AddFactState();
}

class _AddFactState extends State<_AddFact> {
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: GlassSurface(
        padding: EdgeInsets.all(DoayaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.addFact, style: DoayaTypography.lead),
            SizedBox(height: DoayaSpacing.m),
            Wrap(
              spacing: DoayaSpacing.xs,
              runSpacing: DoayaSpacing.xs,
              children: [
                for (final k in fileKinds)
                  GlassPillButton(
                    label: kindLabel(l, k),
                    selected: k == _kind,
                    onPressed: () => setState(() => _kind = k),
                  ),
              ],
            ),
            SizedBox(height: DoayaSpacing.m),
            GlassTextField(label: l.factText, controller: _text, autofocus: true),
            SizedBox(height: DoayaSpacing.l),
            SagePillButton(
              label: l.save,
              expand: true,
              onPressed: () {
                final t = _text.text.trim();
                if (t.isNotEmpty) Navigator.pop(context, (_kind, t));
              },
            ),
          ],
        ),
      ),
    );
  }
}
