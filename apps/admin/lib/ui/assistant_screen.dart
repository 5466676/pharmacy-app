import 'package:doaya_core/doaya_core.dart' show toLatinDigits;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

enum AssistantTab { state, prompts, examples, sandbox }

String labelName(AppLocalizations l, String label) => switch (label) {
  'emergency' => l.labelEmergency,
  'doctor' => l.labelDoctor,
  _ => l.labelNormal,
};

StatusTone labelTone(String label) => switch (label) {
  'emergency' => StatusTone.danger,
  'doctor' => StatusTone.warning,
  _ => StatusTone.neutral,
};

String kindName(AppLocalizations l, String kind) => switch (kind) {
  'assistant' => l.kindAssistant,
  'summary' => l.kindSummary,
  _ => l.kindClassifier,
};

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, this.tab = AssistantTab.state});
  final AssistantTab tab;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  late var _tab = widget.tab;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final names = {
      AssistantTab.state: l.tabState,
      AssistantTab.prompts: l.tabPrompts,
      AssistantTab.examples: l.tabExamples,
      AssistantTab.sandbox: l.tabSandbox,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l.asTitle, subtitle: l.asSubtitle),
        Wrap(
          spacing: DoayaSpacing.xs,
          children: [
            for (final t in AssistantTab.values)
              GlassPillButton(
                label: names[t]!,
                selected: t == _tab,
                onPressed: () => setState(() => _tab = t),
              ),
          ],
        ),
        SizedBox(height: DoayaSpacing.m),
        Expanded(
          child: switch (_tab) {
            AssistantTab.state => const _StateTab(),
            AssistantTab.prompts => const _PromptsTab(),
            AssistantTab.examples => const _ExamplesTab(),
            AssistantTab.sandbox => const _SandboxTab(),
          },
        ),
      ],
    );
  }
}

// ─── State and model ────────────────────────────────────────────────────────

class _StateTab extends ConsumerWidget {
  const _StateTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        AsyncView(
          value: ref.watch(assistantStatsProvider(24)),
          retry: () => ref.invalidate(assistantStatsProvider(24)),
          data: (s) {
            String ms(int? v) => v == null ? '—' : l.msValue(formatNumber(v));
            final cards = [
              StatCard(
                icon: DoayaIcons.chat,
                label: l.stReplies,
                value: formatNumber(s.replies),
                caption: l.last24h,
              ),
              StatCard(
                icon: DoayaIcons.clock,
                label: l.stMedian,
                value: ms(s.medianMs),
                caption: l.stSlowest(ms(s.slowestMs)),
              ),
              StatCard(
                icon: DoayaIcons.offline,
                label: l.stDown,
                value: formatNumber(s.down),
                caption: s.lastDownAt == null ? l.never : l.lastDown(ago(l, s.lastDownAt)),
                tone: s.down > 0 ? StatusTone.warning : StatusTone.accent,
              ),
              StatCard(
                icon: DoayaIcons.warning,
                label: l.stFlags,
                value: formatNumber(s.redFlagsRules + s.redFlagsModel),
                caption: l.stFlagsCaption(
                  formatNumber(s.redFlagsRules),
                  formatNumber(s.redFlagsModel),
                ),
              ),
              StatCard(
                icon: DoayaIcons.person,
                label: l.stDoctor,
                value: formatNumber(s.doctorAdvice),
              ),
              StatCard(
                icon: DoayaIcons.lock,
                label: l.stGuard,
                value: formatNumber(s.guardBlocks),
                tone: s.guardBlocks > 0 ? StatusTone.warning : StatusTone.accent,
              ),
            ];
            return LayoutBuilder(
              builder: (context, c) {
                final columns = c.maxWidth > 1100 ? 6 : (c.maxWidth > 700 ? 3 : 2);
                final gap = DoayaSpacing.m;
                final w = (c.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [for (final k in cards) SizedBox(width: w, child: k)],
                );
              },
            );
          },
        ),
        SizedBox(height: DoayaSpacing.m),
        AsyncView(
          value: ref.watch(assistantProvider),
          retry: () => ref.invalidate(assistantProvider),
          data: (m) => Panel(
            title: l.modelTitle,
            trailing: SagePillButton(
              label: l.changeModel,
              icon: DoayaIcons.swap,
              size: PillSize.medium,
              onPressed: () => showDialog<void>(context: context, builder: (_) => _ModelDialog(m)),
            ),
            child: Wrap(
              spacing: DoayaSpacing.sm,
              runSpacing: DoayaSpacing.sm,
              children: [
                Fact(label: l.chooseServer, value: providerName(l, m.provider)),
                Fact(label: l.serverUrl, value: m.baseUrl, ltr: true),
                Fact(label: l.chooseModel, value: m.model, ltr: true),
                Fact(label: l.apiKey, value: m.hasKey ? l.modelKeySet : l.modelNoKey),
                Fact(
                  label: l.modelTitle,
                  value: m.source == 'panel' ? l.modelSourcePanel : l.modelSourceSettings,
                ),
                if (m.updatedBy != null && m.updatedAt != null)
                  Fact(
                    label: l.logTitle,
                    value: l.logBy(m.updatedBy!, formatDateTime(m.updatedAt!)),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

String providerName(AppLocalizations l, String p) => switch (p) {
  'lm_studio' => l.providerLmStudio,
  'ollama' => l.providerOllama,
  _ => l.providerHosted,
};

class _ModelDialog extends ConsumerStatefulWidget {
  const _ModelDialog(this.current);
  final AssistantModel current;

  @override
  ConsumerState<_ModelDialog> createState() => _ModelDialogState();
}

class _ModelDialogState extends ConsumerState<_ModelDialog> {
  late String _provider = widget.current.provider;
  late final _url = TextEditingController(text: widget.current.baseUrl);
  final _key = TextEditingController();
  late final _model = TextEditingController(text: widget.current.model);
  late final _timeout = TextEditingController(text: '${widget.current.timeout}');
  List<String>? _models;
  bool _removeKey = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_url, _key, _model, _timeout]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _keyToSend => _removeKey ? '' : (_key.text.trim().isEmpty ? null : _key.text.trim());

  Future<void> _run(Future<void> Function() job) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
    } on Object catch (e) {
      _error = errorText(l, e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _fetch() => _run(() async {
    _models = await ref
        .read(apiProvider)
        .listModels(_provider, _url.text.trim(), apiKey: _keyToSend);
    if (_models!.isNotEmpty && !_models!.contains(_model.text.trim())) {
      _model.text = _models!.first;
    }
  });

  Future<void> _save() => _run(() async {
    final l = AppLocalizations.of(context);
    final m = await ref
        .read(apiProvider)
        .setModel(
          provider: _provider,
          baseUrl: _url.text.trim(),
          model: _model.text.trim(),
          apiKey: _keyToSend,
          timeoutSeconds: int.tryParse(toLatinDigits(_timeout.text.trim())) ?? 60,
        );
    ref
      ..invalidate(assistantProvider)
      ..invalidate(settingsProvider);
    if (mounted) {
      Navigator.pop(context);
      toast(context, l.switched(l.msValue(formatNumber(m.ms ?? 0))));
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final presets = widget.current.providers;
    return AlertDialog(
      title: Text(l.changeModel, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.formWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.chooseServer, style: DoayaTypography.label),
              SizedBox(height: DoayaSpacing.sm),
              Wrap(
                spacing: DoayaSpacing.xs,
                children: [
                  for (final p in ['lm_studio', 'ollama', 'hosted'])
                    GlassPillButton(
                      label: providerName(l, p),
                      selected: p == _provider,
                      onPressed: () => setState(() {
                        _provider = p;
                        _models = null;
                        if ((presets[p] ?? '').isNotEmpty) _url.text = presets[p]!;
                      }),
                    ),
                ],
              ),
              SizedBox(height: DoayaSpacing.m),
              GlassTextField(
                label: l.serverUrl,
                controller: _url,
                textDirection: TextDirection.ltr,
              ),
              SizedBox(height: DoayaSpacing.sm),
              GlassTextField(
                label: l.apiKey,
                hint: widget.current.hasKey ? l.apiKeyKeep : null,
                controller: _key,
                obscureText: true,
                textDirection: TextDirection.ltr,
              ),
              if (widget.current.hasKey)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _removeKey,
                  title: Text(l.removeKey, style: DoayaTypography.bodySmall),
                  onChanged: (v) => setState(() => _removeKey = v ?? false),
                ),
              SizedBox(height: DoayaSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GlassPillButton(
                  label: l.fetchModels,
                  icon: DoayaIcons.refresh,
                  onPressed: _busy ? null : _fetch,
                ),
              ),
              if (_models != null) ...[
                SizedBox(height: DoayaSpacing.sm),
                if (_models!.isEmpty)
                  Text(l.noModels, style: DoayaTypography.bodySmall)
                else
                  Wrap(
                    spacing: DoayaSpacing.xs,
                    runSpacing: DoayaSpacing.xs,
                    children: [
                      for (final m in _models!)
                        GlassPillButton(
                          label: m,
                          selected: m == _model.text.trim(),
                          onPressed: () => setState(() => _model.text = m),
                        ),
                    ],
                  ),
              ],
              SizedBox(height: DoayaSpacing.m),
              GlassTextField(
                label: l.modelNameManual,
                controller: _model,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: DoayaSpacing.sm),
              GlassTextField(
                label: l.timeoutSeconds,
                controller: _timeout,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
              ),
              if (_busy) ...[SizedBox(height: DoayaSpacing.m), const LinearProgressIndicator()],
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
        SagePillButton(
          label: l.switchModel,
          size: PillSize.medium,
          onPressed: _busy || _model.text.trim().isEmpty ? null : _save,
        ),
      ],
    );
  }
}

// ─── Prompts ────────────────────────────────────────────────────────────────

class _PromptsTab extends ConsumerStatefulWidget {
  const _PromptsTab();

  @override
  ConsumerState<_PromptsTab> createState() => _PromptsTabState();
}

class _PromptsTabState extends ConsumerState<_PromptsTab> {
  String _kind = 'assistant';
  int? _testing;

  Future<void> _do(Future<void> Function() job) async {
    final l = AppLocalizations.of(context);
    try {
      await job();
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    }
    ref.invalidate(promptsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    final notes = {
      'assistant': l.kindAssistantNote,
      'summary': l.kindSummaryNote,
      'classifier': l.kindClassifierNote,
    };
    return AsyncView(
      value: ref.watch(promptsProvider),
      retry: () => ref.invalidate(promptsProvider),
      data: (all) {
        final set = all[_kind]!;
        return ListView(
          children: [
            Wrap(
              spacing: DoayaSpacing.xs,
              children: [
                for (final k in ['assistant', 'summary', 'classifier'])
                  GlassPillButton(
                    label: kindName(l, k),
                    selected: k == _kind,
                    onPressed: () => setState(() => _kind = k),
                  ),
              ],
            ),
            SizedBox(height: DoayaSpacing.sm),
            Text(
              notes[_kind]!,
              style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
            ),
            SizedBox(height: DoayaSpacing.m),
            Panel(
              title:
                  '${l.inUse}: ${set.activeId == null ? l.builtIn : l.versionN(formatNumber(set.activeId!))}',
              trailing: Wrap(
                spacing: DoayaSpacing.xs,
                children: [
                  if (set.activeId != null)
                    GlassPillButton(
                      label: l.rollbackStep,
                      icon: DoayaIcons.returns,
                      onPressed: () async {
                        final ok = await confirm(context, l.rollbackConfirm);
                        if (ok) await _do(() => api.rollback(_kind));
                      },
                    ),
                  SagePillButton(
                    label: l.newDraft,
                    icon: DoayaIcons.add,
                    size: PillSize.medium,
                    onPressed: () async {
                      final text = await editText(context, l.newDraft, set.text);
                      if (text != null) await _do(() => api.newDraft(_kind, text));
                    },
                  ),
                ],
              ),
              child: SelectableText(
                set.text,
                textDirection: TextDirection.ltr,
                style: DoayaTypography.bodySmall,
              ),
            ),
            SizedBox(height: DoayaSpacing.m),
            Panel(
              title: l.lockedTitle,
              trailing: Icon(DoayaIcons.lock, color: DoayaColors.textSecondary),
              child: SelectableText(
                set.locked.join('\n\n'),
                textDirection: TextDirection.ltr,
                style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
              ),
            ),
            SizedBox(height: DoayaSpacing.m),
            for (final v in set.versions) ...[
              _VersionCard(
                v,
                testing: _testing == v.id,
                onEdit: () async {
                  final text = await editText(context, l.editDraft, v.text);
                  if (text != null) await _do(() => api.editDraft(v.id, text));
                },
                onTest: () async {
                  setState(() => _testing = v.id);
                  await _do(() => api.testDraft(v.id));
                  if (mounted) setState(() => _testing = null);
                },
                onActivate: () => _do(() async {
                  await api.activate(v.id);
                  ref.invalidate(assistantStatsProvider(24));
                }),
              ),
              SizedBox(height: DoayaSpacing.sm),
            ],
            SizedBox(height: DoayaSpacing.xl),
          ],
        );
      },
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard(
    this.v, {
    required this.testing,
    required this.onEdit,
    required this.onTest,
    required this.onActivate,
  });

  final PromptVersionView v;
  final bool testing;
  final VoidCallback onEdit, onTest, onActivate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (status, tone) = switch (v.status) {
      'draft' => (l.statusDraft, StatusTone.warning),
      'active' => (l.statusActive, StatusTone.success),
      _ => (l.statusRetired, StatusTone.neutral),
    };
    final test = v.test;
    return Panel(
      title: '${l.versionN(formatNumber(v.id))}  ${formatDateTime(v.createdAt)}',
      trailing: StatusChip(label: status, tone: tone),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            v.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: DoayaTypography.caption,
          ),
          if (v.status == 'draft') ...[
            SizedBox(height: DoayaSpacing.m),
            Wrap(
              spacing: DoayaSpacing.sm,
              runSpacing: DoayaSpacing.sm,
              children: [
                GlassPillButton(
                  label: l.editDraft,
                  icon: DoayaIcons.edit,
                  onPressed: testing ? null : onEdit,
                ),
                GlassPillButton(
                  label: l.runTest,
                  icon: DoayaIcons.science,
                  onPressed: testing ? null : onTest,
                ),
                SagePillButton(
                  label: l.activateDraft,
                  icon: DoayaIcons.check,
                  size: PillSize.small,
                  onPressed: v.ready && !testing ? onActivate : null,
                ),
              ],
            ),
          ],
          if (testing) ...[
            SizedBox(height: DoayaSpacing.m),
            Text(l.testRunning, style: DoayaTypography.bodySmall),
            const LinearProgressIndicator(),
          ] else if (test != null) ...[
            SizedBox(height: DoayaSpacing.m),
            TestReport(test),
          ],
        ],
      ),
    );
  }
}

/// The test's verdict and every case.
class TestReport extends StatelessWidget {
  const TestReport(this.t, {super.key});
  final TestResult t;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoticeBanner(
          tone: t.passed ? StatusTone.success : StatusTone.danger,
          icon: t.passed ? DoayaIcons.check : DoayaIcons.danger,
          message: [
            t.passed ? l.testPassed : l.testFailed(formatNumber(t.missed)),
            if (t.falseAlarms > 0) l.testFalseAlarms(formatNumber(t.falseAlarms)),
            if (!t.summaryOk) l.testSummaryBad,
          ].join('، '),
        ),
        SizedBox(height: DoayaSpacing.sm),
        for (final c in t.cases)
          Padding(
            padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  c.passed ? DoayaIcons.check : DoayaIcons.close,
                  size: DoayaSizes.iconS,
                  color: c.passed ? DoayaColors.accent : DoayaColors.dangerText,
                ),
                SizedBox(width: DoayaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.text, style: DoayaTypography.bodySmall),
                      if (c.guardBlocked)
                        Text(
                          l.guardBlockedCase,
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.dangerText),
                        ),
                      if (c.modelDown)
                        Text(
                          l.modelDownCase,
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.dangerText),
                        ),
                    ],
                  ),
                ),
                StatusChip(label: labelName(l, c.expected), tone: labelTone(c.expected)),
                SizedBox(width: DoayaSpacing.xs),
                StatusChip(
                  label: [
                    labelName(l, c.got),
                    if (c.source != null)
                      l.bySource(c.source == 'rules' ? l.sourceRules : l.sourceModel),
                  ].join(' '),
                  tone: c.passed ? StatusTone.neutral : StatusTone.danger,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<bool> confirm(BuildContext context, String message) async {
  final l = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(message, style: DoayaTypography.body),
          actions: [
            GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context, false)),
            SagePillButton(
              label: l.confirm,
              size: PillSize.medium,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ) ??
      false;
}

/// A big text box for a prompt; null when cancelled.
Future<String?> editText(BuildContext context, String title, String initial) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(title: title, initial: initial),
    );

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.initial});
  final String title;
  final String initial;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.wideFormWidth,
        child: GlassTextField(
          label: l.draftText,
          controller: _c,
          maxLines: 16,
          maxLength: 8000,
          textDirection: TextDirection.ltr,
          autofocus: true,
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
        SagePillButton(
          label: l.save,
          size: PillSize.medium,
          onPressed: () {
            final t = _c.text.trim();
            if (t.length >= 20) Navigator.pop(context, t);
          },
        ),
      ],
    );
  }
}

// ─── Safety examples ────────────────────────────────────────────────────────

class _ExamplesTab extends ConsumerStatefulWidget {
  const _ExamplesTab();

  @override
  ConsumerState<_ExamplesTab> createState() => _ExamplesTabState();
}

class _ExamplesTabState extends ConsumerState<_ExamplesTab> {
  TestResult? _result;
  bool _testing = false;

  Future<void> _test() async {
    final l = AppLocalizations.of(context);
    setState(() => _testing = true);
    try {
      _result = await ref.read(apiProvider).testCurrent();
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    }
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    return ListView(
      children: [
        Text(
          l.examplesSubtitle,
          style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.m),
        Wrap(
          spacing: DoayaSpacing.sm,
          children: [
            SagePillButton(
              label: l.addExample,
              icon: DoayaIcons.add,
              size: PillSize.medium,
              onPressed: () async {
                final added = await showDialog<bool>(
                  context: context,
                  builder: (_) => const _ExampleDialog(),
                );
                if (added == true) ref.invalidate(safetyExamplesProvider);
              },
            ),
            GlassPillButton(
              label: l.testCurrent,
              icon: DoayaIcons.science,
              onPressed: _testing ? null : _test,
            ),
          ],
        ),
        SizedBox(height: DoayaSpacing.m),
        if (_testing) ...[Text(l.testRunning), const LinearProgressIndicator()],
        if (_result != null && !_testing) ...[
          Panel(child: TestReport(_result!)),
          SizedBox(height: DoayaSpacing.m),
        ],
        AsyncView(
          value: ref.watch(safetyExamplesProvider),
          retry: () => ref.invalidate(safetyExamplesProvider),
          data: (list) => list.isEmpty
              ? Panel(child: EmptyHint(l.examplesEmpty))
              : Column(
                  children: [
                    for (final e in list)
                      Padding(
                        padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                        child: GlassSurface(
                          padding: EdgeInsets.all(DoayaSpacing.m),
                          child: Row(
                            children: [
                              StatusChip(label: labelName(l, e.label), tone: labelTone(e.label)),
                              SizedBox(width: DoayaSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.text, style: DoayaTypography.body),
                                    if (e.note != null)
                                      Text(
                                        e.note!,
                                        style: DoayaTypography.caption.copyWith(
                                          color: DoayaColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                e.enabled ? l.exampleEnabled : l.noteDisabled,
                                style: DoayaTypography.caption,
                              ),
                              Switch(
                                value: e.enabled,
                                onChanged: (v) async {
                                  try {
                                    await api.editExample(e.id, enabled: v);
                                  } on Object catch (err) {
                                    if (context.mounted) {
                                      toast(context, errorText(l, err), error: true);
                                    }
                                  }
                                  ref.invalidate(safetyExamplesProvider);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

class _ExampleDialog extends ConsumerStatefulWidget {
  const _ExampleDialog();

  @override
  ConsumerState<_ExampleDialog> createState() => _ExampleDialogState();
}

class _ExampleDialogState extends ConsumerState<_ExampleDialog> {
  final _text = TextEditingController();
  final _note = TextEditingController();
  String _label = 'doctor';
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_text.text.trim().length < 3) return setState(() => _error = l.required);
    try {
      await ref
          .read(apiProvider)
          .addExample(
            _text.text.trim(),
            _label,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = errorText(l, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addExample, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassTextField(label: l.exampleText, controller: _text, maxLines: 3, autofocus: true),
            SizedBox(height: DoayaSpacing.m),
            Text(l.exampleLabel, style: DoayaTypography.label),
            SizedBox(height: DoayaSpacing.sm),
            Wrap(
              spacing: DoayaSpacing.xs,
              children: [
                for (final label in ['emergency', 'doctor', 'normal'])
                  GlassPillButton(
                    label: labelName(l, label),
                    selected: label == _label,
                    onPressed: () => setState(() => _label = label),
                  ),
              ],
            ),
            SizedBox(height: DoayaSpacing.m),
            GlassTextField(label: l.exampleNote, controller: _note),
            if (_error != null) ...[
              SizedBox(height: DoayaSpacing.m),
              NoticeBanner(message: _error!, tone: StatusTone.danger),
            ],
          ],
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
        SagePillButton(label: l.save, size: PillSize.medium, onPressed: _save),
      ],
    );
  }
}

// ─── Sandbox ────────────────────────────────────────────────────────────────

class _SandboxTab extends ConsumerStatefulWidget {
  const _SandboxTab();

  @override
  ConsumerState<_SandboxTab> createState() => _SandboxTabState();
}

class _SandboxTabState extends ConsumerState<_SandboxTab> {
  final _input = TextEditingController();
  final _lines = <({String role, String text, SandboxTurn? turn})>[];
  final _drafts = <int>{};
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final turn = await ref
          .read(apiProvider)
          .sandbox(
            [for (final m in _lines) (role: m.role, text: m.text)],
            text,
            drafts: _drafts.toList(),
          );
      _lines
        ..add((role: 'patient', text: text, turn: null))
        ..add((role: 'assistant', text: turn.text, turn: turn));
      _input.clear();
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final drafts = [
      for (final set in ref.watch(promptsProvider).value?.values ?? const <PromptSet>[])
        for (final v in set.versions)
          if (v.status == 'draft') v,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.sandboxSubtitle,
          style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.sm),
        if (drafts.isEmpty)
          Text(l.noDrafts, style: DoayaTypography.caption)
        else
          Wrap(
            spacing: DoayaSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l.useDrafts, style: DoayaTypography.caption),
              for (final v in drafts)
                GlassPillButton(
                  label: '${kindName(l, v.kind)}: ${l.versionN(formatNumber(v.id))}',
                  selected: _drafts.contains(v.id),
                  onPressed: () => setState(
                    () => _drafts.contains(v.id) ? _drafts.remove(v.id) : _drafts.add(v.id),
                  ),
                ),
            ],
          ),
        SizedBox(height: DoayaSpacing.m),
        Expanded(
          child: GlassSurface(
            padding: EdgeInsets.all(DoayaSpacing.l),
            child: ListView(children: [for (final m in _lines) _Bubble(m.role, m.text, m.turn)]),
          ),
        ),
        SizedBox(height: DoayaSpacing.m),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                label: l.sandboxHint,
                controller: _input,
                onSubmitted: (_) => _send(),
              ),
            ),
            SizedBox(width: DoayaSpacing.sm),
            SagePillButton(label: l.send, size: PillSize.medium, onPressed: _busy ? null : _send),
            SizedBox(width: DoayaSpacing.xs),
            GlassPillButton(
              label: l.restart,
              icon: DoayaIcons.refresh,
              onPressed: () => setState(_lines.clear),
            ),
          ],
        ),
        SizedBox(height: DoayaSpacing.m),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.role, this.text, this.turn);
  final String role;
  final String text;
  final SandboxTurn? turn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mine = role == 'patient';
    final t = turn;
    final (label, tone) = switch (t?.kind) {
      'emergency' => (l.turnEmergency, StatusTone.danger),
      'doctor' => (l.turnDoctor, StatusTone.warning),
      'summary' => (l.turnSummary, StatusTone.accent),
      'fallback' => (l.turnFallback, StatusTone.warning),
      _ => (l.turnReply, StatusTone.neutral),
    };
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: EdgeInsets.only(bottom: DoayaSpacing.sm),
        padding: EdgeInsets.all(DoayaSpacing.m),
        decoration: BoxDecoration(
          color: mine ? DoayaColors.subtleFill : DoayaColors.accentSoftFill,
          borderRadius: BorderRadius.circular(DoayaRadii.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t != null)
              Wrap(
                spacing: DoayaSpacing.xs,
                children: [
                  StatusChip(label: label, tone: tone),
                  if (t.redFlagSource != null)
                    StatusChip(label: t.redFlagSource == 'rules' ? l.sourceRules : l.sourceModel),
                  if (t.guardBlocked)
                    StatusChip(label: l.guardBlockedTurn, tone: StatusTone.warning),
                ],
              ),
            Text(text, style: DoayaTypography.bodySmall),
            if (t != null && t.quickReplies.isNotEmpty)
              Text(t.quickReplies.join(' / '), style: DoayaTypography.caption),
          ],
        ),
      ),
    );
  }
}
