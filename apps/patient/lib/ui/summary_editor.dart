import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

/// Summary fields that are lists (the rest are short texts).
const _listFields = {'symptoms', 'denied_red_flags'};

String summaryLabel(AppLocalizations l, String field) => switch (field) {
  'symptoms' => l.sumSymptoms,
  'duration' => l.sumDuration,
  'age' => l.sumAge,
  'sex' => l.sumSex,
  'pregnancy' => l.sumPregnancy,
  'allergies' => l.sumAllergies,
  'medications' => l.sumMedications,
  'conditions' => l.sumConditions,
  'denied_red_flags' => l.sumDenied,
  _ => l.sumNotes,
};

String _text(Object? v) => switch (v) {
  final List<Object?> list => list.whereType<String>().join('، '),
  final String s => s,
  _ => '',
};

/// The assistant's summary, for the patient to check before it's sent.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.summary,
    required this.busy,
    required this.onEdit,
    required this.onSend,
  });

  final Map<String, Object?> summary;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.cardLarge),
      padding: EdgeInsets.all(DoayaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassSurface(
            tone: SurfaceTone.accentSoft,
            shadow: false,
            borderRadius: BorderRadius.circular(DoayaRadii.tile),
            padding: EdgeInsets.all(DoayaSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.summaryTitle,
                  style: DoayaTypography.label.copyWith(color: DoayaColors.accent),
                ),
                SizedBox(height: DoayaSpacing.xs),
                for (final f in summaryFields)
                  if (_text(summary[f]) case final v when v.isNotEmpty)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${summaryLabel(l, f)}: ',
                            style: DoayaTypography.bodySmall,
                          ),
                          TextSpan(text: v),
                        ],
                      ),
                      style: secondary,
                    ),
              ],
            ),
          ),
          SizedBox(height: DoayaSpacing.ml),
          Text(l.summaryHelp, style: secondary),
          SizedBox(height: DoayaSpacing.ml),
          Row(
            children: [
              Expanded(
                child: SagePillButton(
                  label: l.sendToPharmacy,
                  icon: DoayaIcons.send,
                  expand: true,
                  size: PillSize.medium,
                  onPressed: busy ? null : onSend,
                ),
              ),
              SizedBox(width: DoayaSpacing.sm),
              GlassPillButton(
                label: l.edit,
                icon: DoayaIcons.edit,
                size: PillSize.medium,
                onPressed: busy ? null : onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Edits the summary; returns it in the server's shape, or null if cancelled.
Future<Map<String, Object?>?> showSummaryEditor(
  BuildContext context,
  Map<String, Object?> summary,
) => showDoayaDialog<Map<String, Object?>>(
  context: context,
  title: AppLocalizations.of(context).summaryTitle,
  content: _SummaryEditor(summary),
);

class _SummaryEditor extends StatefulWidget {
  const _SummaryEditor(this.summary);

  final Map<String, Object?> summary;

  @override
  State<_SummaryEditor> createState() => _SummaryEditorState();
}

class _SummaryEditorState extends State<_SummaryEditor> {
  final _form = GlobalKey<FormState>();
  late final _fields = {
    for (final f in summaryFields) f: TextEditingController(text: _text(widget.summary[f])),
  };

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, Object?> _result() => {
    for (final MapEntry(key: f, value: c) in _fields.entries)
      f: _listFields.contains(f)
          ? [
              for (final s in c.text.split(RegExp('[,،]')))
                if (s.trim().isNotEmpty) s.trim(),
            ]
          : (c.text.trim().isEmpty ? null : c.text.trim()),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final f in summaryFields) ...[
            GlassTextField(
              label: summaryLabel(l, f),
              hint: _listFields.contains(f) ? l.listHint : null,
              controller: _fields[f],
              maxLines: f == 'notes' ? 3 : 1,
              validator: f == 'symptoms'
                  ? (v) => (v ?? '').trim().isEmpty ? l.required : null
                  : null,
            ),
            SizedBox(height: DoayaSpacing.ml),
          ],
          SizedBox(height: DoayaSpacing.sm),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: DoayaSpacing.m,
            children: [
              GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
              SagePillButton(
                label: l.save,
                onPressed: () {
                  if (_form.currentState!.validate()) Navigator.pop(context, _result());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
