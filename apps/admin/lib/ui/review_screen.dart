import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'knowledge_screen.dart' show editNote;

String kindLabel(AppLocalizations l, String k) => switch (k) {
  'red_flag' => l.kindRedFlag,
  'guard_block' => l.kindGuardBlock,
  'correction' => l.kindCorrection,
  'patient_edit' => l.kindPatientEdit,
  'llm_down' => l.kindLlmDown,
  _ => k,
};

StatusTone kindTone(String k) => switch (k) {
  'red_flag' => StatusTone.danger,
  'guard_block' => StatusTone.warning,
  'correction' => StatusTone.accent,
  _ => StatusTone.neutral,
};

/// "رجل، 58 سنة، صيدلية النور": never a name or a phone.
String patientBrief(AppLocalizations l, ReviewItem r) => l.patientBrief(
  switch (r.sex) {
    'm' => l.sexM,
    'f' => l.sexF,
    _ => l.unknown,
  },
  r.age == null ? '—' : formatNumber(r.age!),
  r.pharmacy ?? '—',
);

/// The log entry's details worth reading, in words (the model's raw output
/// and ids are left out).
List<(String, String)> detailLines(AppLocalizations l, Json d) {
  final labels = {
    'category': l.detailCategory,
    'matched': l.detailMatched,
    'reason': l.detailReason,
    'original': l.detailOriginal,
    'correction': l.detailCorrection,
    'reply': l.detailReply,
    'by': l.detailBy,
    'error': l.detailError,
  };
  return [
    for (final e in labels.entries)
      if (d[e.key] is String && (d[e.key]! as String).isNotEmpty) (e.value, d[e.key]! as String),
  ];
}

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, this.selected});
  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final done = ref.watch(reviewDoneProvider);
    final list = AsyncView(
      value: ref.watch(reviewProvider),
      retry: () => ref.invalidate(reviewProvider),
      data: (items) => items.isEmpty
          ? EmptyHint(l.reviewEmpty)
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.xs),
              itemBuilder: (_, i) {
                final r = items[i];
                return GlassSurface(
                  tone: r.id == selected ? SurfaceTone.selected : SurfaceTone.normal,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DoayaRadii.card),
                    onTap: () => context.go(Routes.reviewItem(r.id)),
                    child: Padding(
                      padding: EdgeInsets.all(DoayaSpacing.m),
                      child: Row(
                        children: [
                          StatusChip(label: kindLabel(l, r.kind), tone: kindTone(r.kind)),
                          SizedBox(width: DoayaSpacing.sm),
                          Expanded(
                            child: Text(patientBrief(l, r), style: DoayaTypography.bodySmall),
                          ),
                          Text(
                            ago(l, r.at),
                            style: DoayaTypography.caption.copyWith(
                              color: DoayaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.reviewTitle,
          subtitle: l.reviewSubtitle,
          trailing: Wrap(
            spacing: DoayaSpacing.xs,
            children: [
              GlassPillButton(
                label: l.reviewWaitingTab,
                selected: !done,
                onPressed: () => ref.read(reviewDoneProvider.notifier).set(false),
              ),
              GlassPillButton(
                label: l.reviewDoneTab,
                selected: done,
                onPressed: () => ref.read(reviewDoneProvider.notifier).set(true),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final detail = selected == null
                  ? Panel(child: EmptyHint(l.pickItem))
                  : ReviewDetail(id: selected!);
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

class ReviewDetail extends ConsumerStatefulWidget {
  const ReviewDetail({super.key, required this.id});
  final int id;

  @override
  ConsumerState<ReviewDetail> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends ConsumerState<ReviewDetail> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(apiProvider).markReviewed(widget.id, note: _note.text.trim());
      ref
        ..invalidate(reviewProvider)
        ..invalidate(reviewItemProvider(widget.id))
        ..invalidate(overviewProvider);
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AsyncView(
      value: ref.watch(reviewItemProvider(widget.id)),
      retry: () => ref.invalidate(reviewItemProvider(widget.id)),
      data: (r) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Panel(
            title: l.detailTitle,
            trailing: StatusChip(label: kindLabel(l, r.kind), tone: kindTone(r.kind)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(patientBrief(l, r), style: DoayaTypography.label),
                Text(
                  formatDateTime(r.at),
                  style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                ),
                for (final (label, value) in detailLines(l, r.detail)) ...[
                  SizedBox(height: DoayaSpacing.xs),
                  Text('$label: $value', style: DoayaTypography.bodySmall),
                ],
                SizedBox(height: DoayaSpacing.m),
                for (final m in r.messages) _Message(m),
              ],
            ),
          ),
          SizedBox(height: DoayaSpacing.m),
          Panel(
            child: r.reviewed
                ? Text([l.reviewDoneTab, ?r.note].join(': '), style: DoayaTypography.bodySmall)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassTextField(label: l.reviewNote, controller: _note, maxLines: 3),
                      SizedBox(height: DoayaSpacing.m),
                      Wrap(
                        spacing: DoayaSpacing.sm,
                        runSpacing: DoayaSpacing.sm,
                        children: [
                          SagePillButton(
                            label: l.markReviewed,
                            icon: DoayaIcons.check,
                            size: PillSize.medium,
                            onPressed: _done,
                          ),
                          GlassPillButton(
                            label: l.toKnowledge,
                            icon: DoayaIcons.knowledge,
                            onPressed: () => editNote(context, ref, sourceLogId: r.id),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          SizedBox(height: DoayaSpacing.xl),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.m);
  final ReviewMessage m;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final who = switch (m.role) {
      'patient' => l.rolePatient,
      'assistant' => l.roleAssistant,
      'pharmacist' => m.author == null ? l.rolePharmacist : '${l.rolePharmacist}: ${m.author}',
      _ => l.roleSystem,
    };
    final mine = m.role == 'patient';
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: EdgeInsets.only(bottom: DoayaSpacing.sm),
        padding: EdgeInsets.all(DoayaSpacing.m),
        decoration: BoxDecoration(
          color: mine ? DoayaColors.subtleFill : DoayaColors.accentSoftFill,
          borderRadius: BorderRadius.circular(DoayaRadii.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(who, style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary)),
            Text(m.photo ? '[${l.photoMarker}]' : m.text, style: DoayaTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
