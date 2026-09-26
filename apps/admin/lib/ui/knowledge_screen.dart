import 'dart:async';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

class KnowledgeScreen extends ConsumerWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        PageHeader(
          title: l.knowledgeTitle,
          subtitle: l.knowledgeSubtitle,
          trailing: SagePillButton(
            label: l.addNote,
            icon: DoayaIcons.add,
            size: PillSize.medium,
            onPressed: () => editNote(context, ref),
          ),
        ),
        const _TryIt(),
        SizedBox(height: DoayaSpacing.m),
        AsyncView(
          value: ref.watch(notesProvider),
          retry: () => ref.invalidate(notesProvider),
          data: (notes) => notes.isEmpty
              ? Panel(child: EmptyHint(l.notesEmpty))
              : Column(
                  children: [
                    for (final n in notes) ...[_NoteCard(n), SizedBox(height: DoayaSpacing.sm)],
                  ],
                ),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard(this.n);
  final KnowledgeNote n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Panel(
      title: n.title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(n.enabled ? l.noteEnabled : l.noteDisabled, style: DoayaTypography.caption),
          Switch(
            value: n.enabled,
            onChanged: (v) async {
              try {
                await ref.read(apiProvider).updateNote(n.id, enabled: v);
                ref.invalidate(notesProvider);
              } on Object catch (e) {
                if (context.mounted) toast(context, errorText(l, e), error: true);
              }
            },
          ),
          RoundIconButton(
            icon: DoayaIcons.edit,
            tooltip: l.save,
            onPressed: () => editNote(context, ref, note: n),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(n.text, style: DoayaTypography.body),
          SizedBox(height: DoayaSpacing.sm),
          Wrap(
            spacing: DoayaSpacing.xs,
            runSpacing: DoayaSpacing.xs,
            children: [for (final t in n.tags) StatusChip(label: t, tone: StatusTone.accent)],
          ),
        ],
      ),
    );
  }
}

/// «جرّب»: which notes the assistant would get for a patient's words.
class _TryIt extends ConsumerStatefulWidget {
  const _TryIt();

  @override
  ConsumerState<_TryIt> createState() => _TryItState();
}

class _TryItState extends ConsumerState<_TryIt> {
  Timer? _debounce;
  String? _result;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final l = AppLocalizations.of(context);
      if (text.trim().isEmpty) return setState(() => _result = null);
      try {
        final notes = await ref.read(apiProvider).matchNotes(text);
        if (!mounted) return;
        setState(
          () => _result = notes.isEmpty
              ? l.tryNothing
              : l.tryResult(notes.map((n) => n.title).join('، ')),
        );
      } on Object catch (e) {
        if (mounted) setState(() => _result = errorText(l, e));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Panel(
      title: l.tryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassTextField(label: l.tryHint, onChanged: _changed),
          if (_result != null) ...[
            SizedBox(height: DoayaSpacing.sm),
            Text(_result!, style: DoayaTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Adds a note (optionally from a review item) or edits one.
Future<void> editNote(
  BuildContext context,
  WidgetRef ref, {
  KnowledgeNote? note,
  int? sourceLogId,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _NoteDialog(note: note, sourceLogId: sourceLogId),
  );
  if (saved == true) ref.invalidate(notesProvider);
}

List<String> splitTags(String s) => [
  for (final t in s.split(RegExp('[,،\n]')))
    if (t.trim().isNotEmpty) t.trim(),
];

class _NoteDialog extends ConsumerStatefulWidget {
  const _NoteDialog({this.note, this.sourceLogId});
  final KnowledgeNote? note;
  final int? sourceLogId;

  @override
  ConsumerState<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends ConsumerState<_NoteDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.note?.title);
  late final _text = TextEditingController(text: widget.note?.text);
  late final _tags = TextEditingController(text: widget.note?.tags.join('، '));
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _busy) return;
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.note == null) {
        await api.addNote(
          title: _title.text.trim(),
          text: _text.text.trim(),
          tags: splitTags(_tags.text),
          sourceLogId: widget.sourceLogId,
        );
      } else {
        await api.updateNote(
          widget.note!.id,
          title: _title.text.trim(),
          text: _text.text.trim(),
          tags: splitTags(_tags.text),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(l, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.note == null ? l.addNote : widget.note!.title,
        style: DoayaTypography.lead,
      ),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                label: l.noteTitle,
                controller: _title,
                autofocus: true,
                validator: (v) => (v ?? '').trim().length < 2 ? l.required : null,
              ),
              SizedBox(height: DoayaSpacing.sm),
              GlassTextField(
                label: l.noteText,
                controller: _text,
                maxLines: 4,
                maxLength: 1000,
                validator: (v) => (v ?? '').trim().length < 5 ? l.required : null,
              ),
              GlassTextField(
                label: l.noteTags,
                hint: l.noteTagsHint,
                controller: _tags,
                validator: (v) => splitTags(v ?? '').isEmpty ? l.required : null,
              ),
              if (_error != null) ...[
                SizedBox(height: DoayaSpacing.m),
                NoticeBanner(message: _error!, tone: StatusTone.danger),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
        SagePillButton(label: l.save, size: PillSize.medium, onPressed: _busy ? null : _save),
      ],
    );
  }
}
