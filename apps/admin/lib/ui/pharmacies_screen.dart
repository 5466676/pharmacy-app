import 'package:doaya_core/doaya_core.dart' show toLatinDigits;
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

String statusLabel(AppLocalizations l, String s) => switch (s) {
  'active' => l.statusActive,
  'pending' => l.statusPending,
  'suspended' => l.statusSuspended,
  'stopped' => l.statusStopped,
  'removed' => l.statusRemoved,
  _ => s,
};

StatusTone statusTone(String s) => switch (s) {
  'active' => StatusTone.success,
  'pending' => StatusTone.neutral,
  'suspended' => StatusTone.warning,
  _ => StatusTone.danger,
};

class PharmaciesScreen extends ConsumerWidget {
  const PharmaciesScreen({super.key, this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSearchField(
          hint: l.searchPharmacies,
          onChanged: (q) => ref.read(pharmacyQueryProvider.notifier).set(q),
        ),
        SizedBox(height: DoayaSpacing.m),
        Expanded(
          child: AsyncView(
            value: ref.watch(pharmaciesProvider),
            retry: () => ref.invalidate(pharmaciesProvider),
            data: (items) => items.isEmpty
                ? EmptyHint(l.noPharmacies)
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.xs),
                    itemBuilder: (_, i) => _Row(items[i], selected: items[i].id == selected),
                  ),
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.navPharmacies,
          trailing: SagePillButton(
            label: l.addPharmacy,
            icon: DoayaIcons.add,
            size: PillSize.medium,
            onPressed: () => _add(context, ref),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final detail = selected == null
                  ? Panel(child: EmptyHint(l.pickPharmacy))
                  : PharmacyDetail(id: selected!);
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

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final p = await showDialog<Pharmacy>(context: context, builder: (_) => const _AddDialog());
    if (p == null || !context.mounted) return;
    ref.invalidate(pharmaciesProvider);
    context.go(Routes.pharmacy(p.id));
    await showKey(context, p.key!);
  }
}

class _Row extends StatelessWidget {
  const _Row(this.p, {required this.selected});
  final Pharmacy p;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassSurface(
      tone: selected ? SurfaceTone.selected : SurfaceTone.normal,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(DoayaRadii.card),
        onTap: () => context.go(Routes.pharmacy(p.id)),
        child: Padding(
          padding: EdgeInsets.all(DoayaSpacing.m),
          child: Row(
            children: [
              StatusDot(color: p.connected ? DoayaColors.accent : DoayaColors.textSecondary),
              SizedBox(width: DoayaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: DoayaTypography.label),
                    Text(
                      [p.city, p.code].whereType<String>().join('، '),
                      style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(label: statusLabel(l, p.status), tone: statusTone(p.status)),
                  SizedBox(height: DoayaSpacing.xxs),
                  Text(
                    '${l.colResponse}: ${minutes(l, p.median)}',
                    style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PharmacyDetail extends ConsumerWidget {
  const PharmacyDetail({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncView(
    value: ref.watch(pharmacyProvider(id)),
    retry: () => ref.invalidate(pharmacyProvider(id)),
    data: (p) => _Detail(p),
  );
}

class _Detail extends ConsumerWidget {
  const _Detail(this.p);
  final Pharmacy p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final hb = p.heartbeat;
    final devices = [for (final d in (hb?['devices'] as List?) ?? const []) d as Json];
    final backup = DateTime.tryParse('${hb?['last_backup_at']}')?.toLocal();
    final facts = [
      Fact(label: l.factCode, value: p.code ?? '—', ltr: true),
      Fact(label: l.factLastContact, value: ago(l, p.lastHeartbeat)),
      Fact(label: l.factLicence, value: l.licenceDays(formatNumber(p.licenceDays))),
      Fact(label: l.colPatients, value: formatNumber(p.patients)),
      Fact(label: l.colResponse, value: minutes(l, p.median)),
      Fact(label: l.factDevices, value: formatNumber(devices.length)),
      Fact(label: l.factBackup, value: ago(l, backup)),
      Fact(label: l.factVersion, value: '${hb?['server_version'] ?? '—'}', ltr: true),
      if (hb?['disk_free_mb'] is num)
        Fact(label: l.factDisk, value: l.diskMb(formatNumber(hb!['disk_free_mb']! as num))),
      Fact(label: l.factKeys, value: formatNumber(p.activeKeys)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(p.name, style: DoayaTypography.titleSmall)),
                  if (!p.listed && p.status != 'removed') ...[
                    StatusChip(label: l.hidden, icon: DoayaIcons.hidden),
                    SizedBox(width: DoayaSpacing.xs),
                  ],
                  StatusChip(label: statusLabel(l, p.status), tone: statusTone(p.status)),
                ],
              ),
              if (p.reason != null) ...[
                SizedBox(height: DoayaSpacing.xs),
                Text(
                  '${l.reason}: ${p.reason}',
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
              SizedBox(height: DoayaSpacing.m),
              Wrap(spacing: DoayaSpacing.sm, runSpacing: DoayaSpacing.sm, children: facts),
            ],
          ),
        ),
        SizedBox(height: DoayaSpacing.m),
        _Actions(p),
        SizedBox(height: DoayaSpacing.m),
        _Health(p),
        SizedBox(height: DoayaSpacing.m),
        Panel(
          title: l.logTitle,
          child: p.actions.isEmpty
              ? EmptyHint(l.logEmpty)
              : Column(
                  children: [
                    for (final a in p.actions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(actionLabel(l, a.action), style: DoayaTypography.label),
                        subtitle: Text(
                          [l.logBy(a.by, formatDateTime(a.at)), ?a.reason].join('\n'),
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
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

String actionLabel(AppLocalizations l, String a) => switch (a) {
  'create' => l.actCreate,
  'approve' => l.actApprove,
  'suspend' => l.actSuspend,
  'resume' => l.actResume,
  'stop' => l.actStop,
  'remove' => l.actRemove,
  'list' => l.actList,
  'unlist' => l.actUnlist,
  'new_key' => l.actNewKey,
  'licence' => l.actLicence,
  'health_check' => l.actHealth,
  _ => a,
};

class _Actions extends ConsumerWidget {
  const _Actions(this.p);
  final Pharmacy p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = p.status;
    if (s == 'removed') return const SizedBox.shrink();
    Widget button(String action, IconData icon, {bool danger = false}) => GlassPillButton(
      label: actionLabel(l, action),
      icon: icon,
      onPressed: () => runAction(context, ref, p, action),
    );
    return Panel(
      title: l.actionsTitle,
      child: Wrap(
        spacing: DoayaSpacing.sm,
        runSpacing: DoayaSpacing.sm,
        children: [
          if (s == 'pending') button('approve', DoayaIcons.check),
          if (s == 'active') button('suspend', DoayaIcons.pause),
          if (s == 'suspended' || s == 'stopped') button('resume', DoayaIcons.play),
          if (s == 'active' || s == 'suspended') button('stop', DoayaIcons.lock),
          p.listed ? button('unlist', DoayaIcons.hidden) : button('list', DoayaIcons.visible),
          button('new_key', DoayaIcons.key),
          button('licence', DoayaIcons.clock),
          button('health_check', DoayaIcons.adjust),
          button('remove', DoayaIcons.delete),
        ],
      ),
    );
  }
}

/// Asks what the action needs (a reason, the days), confirms, runs it.
Future<void> runAction(BuildContext context, WidgetRef ref, Pharmacy p, String action) async {
  final l = AppLocalizations.of(context);
  final needsReason = {'suspend', 'stop', 'remove', 'new_key'}.contains(action);
  final explain = switch (action) {
    'suspend' => l.explainSuspend,
    'stop' => l.explainStop,
    'remove' => l.explainRemove,
    'new_key' => l.explainNewKey,
    'resume' => l.explainResume,
    _ => null,
  };
  String? reason;
  int? days;
  if (needsReason || explain != null || action == 'licence') {
    final answer = await showDialog<(String?, int?)>(
      context: context,
      builder: (_) => _ActionDialog(
        title: '${actionLabel(l, action)}: ${p.name}',
        explain: explain,
        askReason: needsReason,
        askDays: action == 'licence' ? p.licenceDays : null,
        danger: {'stop', 'remove'}.contains(action),
      ),
    );
    if (answer == null) return;
    (reason, days) = answer;
  }
  try {
    final out = await ref.read(apiProvider).act(p.id, action, reason: reason, licenceDays: days);
    ref
      ..invalidate(pharmacyProvider(p.id))
      ..invalidate(pharmaciesProvider)
      ..invalidate(overviewProvider);
    if (context.mounted && out.key != null) await showKey(context, out.key!);
  } on Object catch (e) {
    if (context.mounted) toast(context, errorText(l, e), error: true);
  }
}

class _ActionDialog extends StatefulWidget {
  const _ActionDialog({
    required this.title,
    this.explain,
    required this.askReason,
    this.askDays,
    this.danger = false,
  });

  final String title;
  final String? explain;
  final bool askReason;
  final int? askDays;
  final bool danger;

  @override
  State<_ActionDialog> createState() => _ActionDialogState();
}

class _ActionDialogState extends State<_ActionDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  late final _days = TextEditingController(text: widget.askDays == null ? '' : '${widget.askDays}');

  @override
  void dispose() {
    _reason.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.explain != null)
                NoticeBanner(
                  message: widget.explain!,
                  tone: widget.danger ? StatusTone.danger : StatusTone.warning,
                ),
              if (widget.askReason) ...[
                SizedBox(height: DoayaSpacing.m),
                GlassTextField(
                  label: l.reason,
                  hint: l.reasonHint,
                  controller: _reason,
                  autofocus: true,
                  maxLength: 500,
                  validator: (v) => (v ?? '').trim().length < 3 ? l.errReasonRequired : null,
                ),
              ],
              if (widget.askDays != null) ...[
                Text(l.licencePrompt, style: DoayaTypography.body),
                SizedBox(height: DoayaSpacing.m),
                GlassTextField(
                  label: l.days,
                  controller: _days,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  validator: (v) {
                    final n = int.tryParse(toLatinDigits((v ?? '').trim()));
                    return n == null || n < 1 || n > 365 ? l.required : null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context)),
        SagePillButton(
          label: l.confirm,
          size: PillSize.medium,
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(context, (
              widget.askReason ? _reason.text.trim() : null,
              widget.askDays != null ? int.parse(toLatinDigits(_days.text.trim())) : null,
            ));
          },
        ),
      ],
    );
  }
}

/// The server key, shown once, with a copy button.
Future<void> showKey(BuildContext context, String key) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.keyTitle, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NoticeBanner(message: l.keyOnce),
            SizedBox(height: DoayaSpacing.m),
            SelectableText(key, textDirection: TextDirection.ltr, style: DoayaTypography.label),
          ],
        ),
      ),
      actions: [
        GlassPillButton(
          label: l.copy,
          icon: DoayaIcons.share,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: key));
            if (context.mounted) toast(context, l.copied);
          },
        ),
        SagePillButton(
          label: l.close,
          size: PillSize.medium,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

class _Health extends ConsumerWidget {
  const _Health(this.p);
  final Pharmacy p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final checks = p.healthChecks;
    return Panel(
      title: l.healthTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.healthPrivacy,
            style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
          ),
          SizedBox(height: DoayaSpacing.sm),
          if (p.healthRequested) Text(l.healthRequested, style: DoayaTypography.bodySmall),
          if (checks.isEmpty)
            EmptyHint(l.healthNever)
          else ...[
            if (p.healthAt != null)
              Text(l.healthAt(formatDateTime(p.healthAt!)), style: DoayaTypography.bodySmall),
            SizedBox(height: DoayaSpacing.sm),
            for (final c in checks)
              Padding(
                padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xxs),
                child: Row(
                  children: [
                    Expanded(child: Text(checkLabel(l, c.id), style: DoayaTypography.bodySmall)),
                    if (c.count != null && c.level != 'ok' && c.id != 'disk' && c.id != 'backup')
                      Text(l.countOf(formatNumber(c.count!)), style: DoayaTypography.caption),
                    SizedBox(width: DoayaSpacing.sm),
                    StatusChip(
                      label: switch (c.level) {
                        'ok' => l.levelOk,
                        'warn' => l.levelWarn,
                        _ => l.levelProblem,
                      },
                      tone: switch (c.level) {
                        'ok' => StatusTone.success,
                        'warn' => StatusTone.warning,
                        _ => StatusTone.danger,
                      },
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String checkLabel(AppLocalizations l, String id) => switch (id) {
  'backup' => l.checkBackup,
  'devices_synced' => l.checkDevices,
  'stock_below_zero' => l.checkStockBelowZero,
  'expired_on_sale' => l.checkExpiredOnSale,
  'events_incomplete' => l.checkEvents,
  'open_shifts' => l.checkOpenShifts,
  'disk' => l.checkDisk,
  _ => id,
};

class _AddDialog extends ConsumerStatefulWidget {
  const _AddDialog();

  @override
  ConsumerState<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends ConsumerState<_AddDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _code = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _hours = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _city, _code, _address, _phone, _hours]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _busy) return;
    final l = AppLocalizations.of(context);
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final p = await ref
          .read(apiProvider)
          .addPharmacy(
            name: _name.text.trim(),
            city: _city.text.trim(),
            code: _code.text.trim(),
            address: opt(_address),
            phone: opt(_phone) == null ? null : toLatinDigits(opt(_phone)!),
            hours: opt(_hours),
          );
      if (mounted) Navigator.pop(context, p);
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
    String? required(String? v) => (v ?? '').trim().length < 2 ? l.required : null;
    return AlertDialog(
      title: Text(l.addPharmacy, style: DoayaTypography.lead),
      content: SizedBox(
        width: DoayaSizes.dialogWidth,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassTextField(
                  label: l.fieldName,
                  controller: _name,
                  validator: required,
                  autofocus: true,
                ),
                SizedBox(height: DoayaSpacing.sm),
                GlassTextField(label: l.fieldCity, controller: _city, validator: required),
                SizedBox(height: DoayaSpacing.sm),
                GlassTextField(
                  label: l.fieldCode,
                  controller: _code,
                  textDirection: TextDirection.ltr,
                  maxLength: 12,
                  validator: (v) => RegExp(r'^[A-Za-z0-9]{3,12}$').hasMatch((v ?? '').trim())
                      ? null
                      : l.errBadCode,
                ),
                GlassTextField(label: l.fieldAddress, controller: _address),
                SizedBox(height: DoayaSpacing.sm),
                GlassTextField(
                  label: l.fieldPhone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                ),
                SizedBox(height: DoayaSpacing.sm),
                GlassTextField(label: l.fieldHours, controller: _hours),
                if (_error != null) ...[
                  SizedBox(height: DoayaSpacing.m),
                  NoticeBanner(message: _error!, tone: StatusTone.danger),
                ],
              ],
            ),
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
