import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../central/central_api.dart';
import '../../central/inbox_controller.dart';
import '../../central/pickup.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../format.dart';
import '../patient_photo.dart';
import '../widgets.dart';
import 'patient_orders_view.dart';
import 'sync_screen.dart' show syncErrorText;

/// "34 سنة، ذكر".
String patientLine(AppLocalizations l, CasePatient p) => [
  if (p.age != null) l.patientAge(formatQty(p.age!)),
  if (p.sex == 'm') l.sexMale,
  if (p.sex == 'f') l.sexFemale,
].join('، ');

StatusTone caseTone(String status, {bool urgent = false}) => switch (status) {
  _ when urgent && CaseStatus.open.contains(status) => StatusTone.danger,
  CaseStatus.sent || CaseStatus.emergency => StatusTone.warning,
  CaseStatus.ready => StatusTone.accent,
  _ => StatusTone.neutral,
};

/// A red banner explaining where the inbox stands, or nothing.
Widget? inboxNotice(AppLocalizations l, InboxPhase phase) => switch (phase) {
  InboxPhase.notLinked => NoticeBanner(message: l.inboxNotLinked),
  InboxPhase.notConnected => NoticeBanner(message: l.inboxNotConnected),
  InboxPhase.offline => NoticeBanner(message: l.inboxOffline, tone: StatusTone.warning),
  _ => null,
};

/// Patients' cases from the AI assistant and their pickup orders.
/// Everyone at the pharmacy sees them; every action records who did it.
class CasesScreen extends ConsumerStatefulWidget {
  const CasesScreen({super.key, this.tab = 'cases', this.selected});

  final String tab;

  /// Opened case or order (phone: its own page).
  final String? selected;

  @override
  ConsumerState<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends ConsumerState<CasesScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  bool get _orders => widget.tab == 'orders';

  void _open(String id) {
    if (isPhoneLayout(context)) {
      context.go(Routes.caseItem(widget.tab, id));
    } else {
      setState(() => _selected = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inbox = ref.watch(inboxProvider);
    final phone = isPhoneLayout(context);
    final notice = inboxNotice(l, inbox.phase);

    if (phone && widget.selected != null) {
      return ListView(
        children: [
          PageHeader(
            title: _orders ? l.tabPatientOrders : l.tabCases,
            leading: RoundIconButton(
              icon: DoayaIcons.back,
              tooltip: l.back,
              onPressed: () => context.go(Routes.casesTab(widget.tab)),
            ),
          ),
          if (_orders)
            OrderDetailView(orderId: widget.selected!)
          else
            CaseDetailView(caseId: widget.selected!),
        ],
      );
    }

    final tabs = Wrap(
      spacing: DoayaSpacing.s,
      runSpacing: DoayaSpacing.s,
      children: [
        for (final (tab, label, count) in [
          ('cases', l.tabCases, inbox.cases.where((c) => c.open).length),
          ('orders', l.tabPatientOrders, inbox.orders.where((o) => o.open).length),
        ])
          GlassPillButton(
            label: count > 0 ? '$label (${formatQty(count)})' : label,
            selected: widget.tab == tab,
            onPressed: () => context.go(Routes.casesTab(tab)),
          ),
      ],
    );
    final list = _orders ? _orderList(l, inbox) : _caseList(l, inbox);
    final detail = _selected == null
        ? Panel(child: EmptyHint(l.chooseCase))
        : _orders
        ? OrderDetailView(key: ValueKey(_selected), orderId: _selected!)
        : CaseDetailView(key: ValueKey(_selected), caseId: _selected!);

    return ListView(
      children: [
        PageHeader(title: l.casesTitle, actions: [tabs]),
        if (notice != null) ...[notice, SizedBox(height: DoayaSpacing.l)],
        if (phone)
          list
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: DoayaSizes.listPaneWidth, child: list),
              SizedBox(width: DoayaSpacing.xl),
              Expanded(child: detail),
            ],
          ),
      ],
    );
  }

  Widget _caseList(AppLocalizations l, InboxState inbox) {
    if (inbox.cases.isEmpty) return Panel(child: EmptyHint(l.noCases));
    return Panel(
      child: Column(
        children: [
          for (final c in inbox.cases)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: CaseRow(
                initials: initialsOf(c.patient.name),
                title: c.title.isEmpty ? c.patient.name : c.title,
                subtitle: [
                  c.patient.name,
                  if (c.urgent && c.redFlag != null) l.redFlag(c.redFlag!),
                  if (c.doctorAdvice != null) l.doctorAdvised,
                  if (c.sentAt != null) '${formatDate(c.sentAt!)}، ${formatTime(c.sentAt!)}',
                ].join('، '),
                urgent: c.urgent && c.open,
                selected: c.id == _selected,
                trailing: StatusChip(
                  label: l.caseStatus(c.status),
                  tone: caseTone(c.status, urgent: c.urgent),
                ),
                onTap: () => _open(c.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _orderList(AppLocalizations l, InboxState inbox) {
    final currency = ref.watch(currencyProvider);
    if (inbox.orders.isEmpty) return Panel(child: EmptyHint(l.noPatientOrders));
    return Panel(
      child: Column(
        children: [
          for (final o in inbox.orders)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: CaseRow(
                initials: initialsOf(o.patient.name),
                title: o.patient.name,
                subtitle: [
                  l.orderLinesCount(formatQty(o.lines.length)),
                  formatMoney(o.totalMinor, currency),
                  '${formatDate(o.createdAt)}، ${formatTime(o.createdAt)}',
                ].join('، '),
                selected: o.id == _selected,
                trailing: StatusChip(
                  label: l.orderStatus(o.status),
                  tone: o.open ? StatusTone.warning : StatusTone.neutral,
                ),
                onTap: () => _open(o.id),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Case detail ─────────────────────────────────────────────────────────────

final _caseProvider = FutureProvider.autoDispose.family<CaseDetail, String>((ref, id) {
  // Refetched whenever the inbox refreshes (a new message, a status).
  ref.watch(inboxProvider.select((s) => s.lastUpdated));
  return ref.watch(centralApiProvider)!.caseDetail(id);
});

/// The local customer with the same phone number, if any.
final _customerByPhoneProvider = Provider.autoDispose.family<CustomerRow?, String>((ref, phone) {
  final wanted = whatsappNumber(phone);
  if (wanted == null) return null;
  return (ref.watch(customersProvider).value ?? const <CustomerRow>[])
      .where((c) => whatsappNumber(c.phone) == wanted)
      .firstOrNull;
});

final _customerSalesProvider = FutureProvider.autoDispose.family<List<SaleRow>, String>(
  (ref, customerId) => ref.watch(ledgerProvider).salesOfCustomer(customerId),
);

class CaseDetailView extends ConsumerWidget {
  const CaseDetailView({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_caseProvider(caseId));
    final c = async.value;
    if (c == null) {
      return Panel(
        child: async.hasError
            ? EmptyHint(syncErrorText(l, async.error!))
            : Center(child: CircularProgressIndicator(color: DoayaColors.accent)),
      );
    }
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final phone = isPhoneLayout(context);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          title: c.patient.name,
          trailing: StatusChip(
            label: l.caseStatus(c.status),
            tone: caseTone(c.status, urgent: c.urgent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                [
                  patientLine(l, c.patient),
                  ltrIsolate(c.patient.phone),
                  if (c.handledBy != null) l.handledBy(c.handledBy!),
                ].where((s) => s.isNotEmpty).join('، '),
                style: secondary,
              ),
              if (c.doctorAdvice != null && !c.urgent) ...[
                SizedBox(height: DoayaSpacing.sm),
                NoticeBanner(message: l.doctorAdvisedHelp, icon: DoayaIcons.warning),
              ],
              if (c.urgent) ...[
                SizedBox(height: DoayaSpacing.sm),
                NoticeBanner(
                  message:
                      '${l.urgentCase}: ${l.redFlag(c.redFlag ?? 'other')}. '
                      '${l.urgentHelp(ltrIsolate(c.patient.phone))}',
                  tone: StatusTone.danger,
                  icon: DoayaIcons.danger,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: DoayaSpacing.l),
        _SummaryPanel(detail: c),
        SizedBox(height: DoayaSpacing.l),
        _Conversation(detail: c),
        SizedBox(height: DoayaSpacing.l),
        _CustomerHistory(phone: c.patient.phone),
      ],
    );
    final decision = _DecisionPanel(key: ValueKey('decision-${c.id}'), detail: c);
    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          info,
          SizedBox(height: DoayaSpacing.l),
          decision,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: info),
        SizedBox(width: DoayaSpacing.xl),
        Expanded(child: decision),
      ],
    );
  }
}

Future<void> _correct(
  BuildContext context,
  WidgetRef ref,
  String caseId, {
  int? messageId,
  String? field,
}) async {
  final l = AppLocalizations.of(context);
  final text = TextEditingController();
  final form = GlobalKey<FormState>();
  final ok = await showDoayaDialog<bool>(
    context: context,
    title: l.correctionTitle,
    content: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.correctionHelp,
            style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
          ),
          SizedBox(height: DoayaSpacing.l),
          GlassTextField(
            label: l.correctionTitle,
            controller: text,
            autofocus: true,
            maxLines: 3,
            validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
          ),
        ],
      ),
    ),
    actions: [
      GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
      SagePillButton(
        label: l.confirm,
        size: PillSize.small,
        onPressed: () {
          if (form.currentState!.validate()) Navigator.of(context).pop(true);
        },
      ),
    ],
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(centralApiProvider)!
        .correct(caseId, correction: text.text.trim(), messageId: messageId, field: field);
    if (context.mounted) toast(context, l.correctionSaved);
  } on Object catch (e) {
    if (context.mounted) toast(context, syncErrorText(l, e), error: true);
  }
}

class _SummaryPanel extends ConsumerWidget {
  const _SummaryPanel({required this.detail});

  final CaseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = detail.summary;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    Widget row(String label, String? value) => value == null || value.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(bottom: DoayaSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: DoayaSizes.summaryLabelWidth,
                  child: Text(label, style: secondary),
                ),
                Expanded(child: Text(value, style: DoayaTypography.bodySmall)),
              ],
            ),
          );
    return Panel(
      title: l.assistantSummary,
      trailing: s == null
          ? null
          : GlassPillButton(
              label: l.correctAssistant,
              icon: DoayaIcons.edit,
              onPressed: () => _correct(context, ref, detail.id, field: 'summary'),
            ),
      child: s == null
          ? Text(detail.urgent ? l.noSummaryUrgent : l.noSummary, style: secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                row(l.sumSymptoms, s.symptoms.join('، ')),
                row(l.sumDuration, s.duration),
                row(l.sumAge, s.age),
                row(l.sumSex, s.sex),
                row(l.sumPregnancy, s.pregnancy),
                row(l.sumAllergies, s.allergies),
                row(l.sumMedications, s.medications),
                row(l.sumConditions, s.conditions),
                row(l.sumNotes, s.notes),
                if (s.deniedRedFlags.isNotEmpty) ...[
                  SizedBox(height: DoayaSpacing.xs),
                  StatusChip(
                    label: l.sumDenied(s.deniedRedFlags.join('، ')),
                    tone: StatusTone.accent,
                    icon: DoayaIcons.check,
                  ),
                ],
              ],
            ),
    );
  }
}

class _Conversation extends ConsumerWidget {
  const _Conversation({required this.detail});

  final CaseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final caption = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return Panel(
      title: l.conversationTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in detail.messages)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(switch (m.role) {
                          'patient' => l.rolePatient,
                          'assistant' => l.roleAssistant,
                          'pharmacist' => m.author ?? l.employee,
                          _ => l.roleSystem,
                        }, style: caption),
                        if (m.photoId case final photo?) ...[
                          SizedBox(height: DoayaSpacing.xs),
                          PatientPhoto(id: photo),
                          SizedBox(height: DoayaSpacing.xs),
                        ],
                        Text(
                          m.text,
                          style: DoayaTypography.bodySmall.copyWith(
                            color: m.role == 'patient'
                                ? DoayaColors.textPrimary
                                : DoayaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (m.role == 'assistant' && detail.messages.first != m)
                    GlassPillButton(
                      label: l.correctAssistant,
                      onPressed: () => _correct(context, ref, detail.id, messageId: m.id),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomerHistory extends ConsumerWidget {
  const _CustomerHistory({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final customer = ref.watch(_customerByPhoneProvider(phone));
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    if (customer == null) {
      return Panel(
        title: l.customerHistory,
        child: Text(l.notACustomer, style: secondary),
      );
    }
    final debt = ref.watch(debtsProvider).value?.balance(customer.id) ?? 0;
    final sales = ref.watch(_customerSalesProvider(customer.id)).value ?? const <SaleRow>[];
    return Panel(
      title: l.customerHistory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(customer.name, style: DoayaTypography.label),
          if (debt > 0)
            Text(
              l.customerDebt(formatMoney(debt, currency)),
              style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.warningText),
            ),
          if (sales.isNotEmpty) ...[
            SizedBox(height: DoayaSpacing.sm),
            Text(l.lastPurchases, style: secondary),
            for (final s in sales)
              Text(
                '${formatDate(s.occurredAt)}: ${formatMoney(s.totalMinor, currency)}',
                style: DoayaTypography.bodySmall,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── The pharmacist's decision ──────────────────────────────────────────────

class _DraftItem {
  _DraftItem(this.product) : quantity = 1;

  final ProductRow product;
  int quantity;
  final instructions = TextEditingController();
  final timesPerDay = TextEditingController();
  final days = TextEditingController();

  void dispose() {
    instructions.dispose();
    timesPerDay.dispose();
    days.dispose();
  }
}

class _DecisionPanel extends ConsumerStatefulWidget {
  const _DecisionPanel({super.key, required this.detail});

  final CaseDetail detail;

  @override
  ConsumerState<_DecisionPanel> createState() => _DecisionPanelState();
}

class _DecisionPanelState extends ConsumerState<_DecisionPanel> {
  final _items = <_DraftItem>[];
  final _search = TextEditingController();
  final _note = TextEditingController();
  List<ProductRow> _results = const [];
  var _busy = false;

  @override
  void dispose() {
    for (final i in _items) {
      i.dispose();
    }
    _search.dispose();
    _note.dispose();
    super.dispose();
  }

  CentralApi get _api => ref.read(centralApiProvider)!;

  Future<void> _run(Future<Object?> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(_caseProvider(widget.detail.id));
      await ref.read(inboxProvider.notifier).refresh();
      if (mounted && done != null) toast(context, done);
    } on Object catch (e) {
      if (mounted) toast(context, syncErrorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askText(String title, {String? help, bool required = true}) async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController();
    final form = GlobalKey<FormState>();
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: title,
      content: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (help != null) ...[
              Text(
                help,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
              SizedBox(height: DoayaSpacing.l),
            ],
            GlassTextField(
              label: title,
              controller: text,
              autofocus: true,
              maxLines: 3,
              validator: (v) => required && (v ?? '').trim().isEmpty ? l.required : null,
            ),
          ],
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(
          label: l.confirm,
          size: PillSize.small,
          onPressed: () {
            if (form.currentState!.validate()) Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    return ok == true ? text.text.trim() : null;
  }

  Future<void> _ready() async {
    final l = AppLocalizations.of(context);
    if (_items.any((i) => i.instructions.text.trim().isEmpty)) {
      toast(context, l.instructionsRequired, error: true);
      return;
    }
    final items = [
      for (final i in _items)
        DecisionItem(
          productId: i.product.id,
          name: i.product.tradeName,
          quantity: i.quantity,
          instructions: i.instructions.text.trim(),
          timesPerDay: int.tryParse(toLatinDigits(i.timesPerDay.text)),
          days: int.tryParse(toLatinDigits(i.days.text)),
          priceMinor: i.product.priceMinor,
        ),
    ];
    final note = _note.text.trim();
    await _run(
      () => _api.decide(widget.detail.id, items, note: note.isEmpty ? null : note),
      done: l.decisionSent,
    );
  }

  void _pickup() {
    final decision = widget.detail.decision;
    final lines = [
      for (final i in (decision?['items'] as List? ?? const []).cast<Map<String, Object?>>())
        if (i['product_id'] != null) (i['product_id']! as String, i['quantity']! as int),
    ];
    final id = widget.detail.id;
    final api = _api;
    ref
        .read(pendingSaleProvider.notifier)
        .set(PendingSale(lines: lines, onSold: () => api.pickedUp(id)));
    context.go(Routes.pos);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.detail;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);

    if (c.status == CaseStatus.ready) {
      final items = (c.decision?['items'] as List? ?? const []).cast<Map<String, Object?>>();
      return Panel(
        title: l.yourDecision,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final i in items)
              Padding(
                padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LatinText(
                      '${i['name']} × ${formatQty(i['quantity']! as int)}',
                      style: DoayaTypography.label,
                    ),
                    Text(i['instructions']! as String, style: secondary),
                  ],
                ),
              ),
            SizedBox(height: DoayaSpacing.sm),
            SagePillButton(
              label: l.pickupAndSell,
              icon: DoayaIcons.pos,
              size: PillSize.medium,
              onPressed: _busy ? null : _pickup,
            ),
          ],
        ),
      );
    }
    if (!c.open) return const SizedBox.shrink();

    final stock = ref.watch(stockProvider).value;
    return Panel(
      title: l.yourDecision,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.decisionHelp, style: secondary),
          SizedBox(height: DoayaSpacing.l),
          for (final i in _items) ...[_itemEditor(l, i, stock), SizedBox(height: DoayaSpacing.l)],
          GlassTextField(
            label: l.addMedicine,
            hint: l.searchStock,
            controller: _search,
            onChanged: (q) async {
              final r = q.trim().isEmpty
                  ? const <ProductRow>[]
                  : await ref.read(catalogProvider).search(q, limit: 6);
              if (mounted) setState(() => _results = r);
            },
          ),
          for (final p in _results)
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                dense: true,
                title: LatinText(p.tradeName, style: DoayaTypography.label),
                subtitle: Text(
                  (stock?.onHand(p.id) ?? 0) > 0
                      ? l.onHandShort(formatQty(stock!.onHand(p.id)))
                      : l.outOfStock,
                  style: secondary,
                ),
                onTap: () => setState(() {
                  _items.add(_DraftItem(p));
                  _results = const [];
                  _search.clear();
                }),
              ),
            ),
          SizedBox(height: DoayaSpacing.l),
          GlassTextField(label: l.decisionNote, controller: _note, maxLines: 2),
          SizedBox(height: DoayaSpacing.l),
          SagePillButton(
            label: l.markReady,
            icon: DoayaIcons.check,
            size: PillSize.medium,
            expand: true,
            onPressed: _busy || _items.isEmpty ? null : _ready,
          ),
          SizedBox(height: DoayaSpacing.sm),
          Wrap(
            spacing: DoayaSpacing.sm,
            runSpacing: DoayaSpacing.sm,
            children: [
              GlassPillButton(
                label: l.askPatient,
                icon: DoayaIcons.chat,
                onPressed: _busy
                    ? null
                    : () async {
                        final q = await _askText(l.askPatient);
                        if (q != null) await _run(() => _api.ask(c.id, q));
                      },
              ),
              if (c.status == CaseStatus.sent || c.status == CaseStatus.emergency)
                GlassPillButton(
                  label: l.startPreparing,
                  onPressed: _busy ? null : () => _run(() => _api.preparing(c.id)),
                ),
              GlassPillButton(
                label: l.needsDoctorButton,
                icon: DoayaIcons.warning,
                onPressed: _busy
                    ? null
                    : () async {
                        final note = await _askText(
                          l.needsDoctorButton,
                          help: l.needsDoctorConfirm,
                          required: false,
                        );
                        if (note != null) {
                          await _run(
                            () => _api.needsDoctor(c.id, text: note.isEmpty ? null : note),
                          );
                        }
                      },
              ),
              if (c.status == CaseStatus.emergency)
                GlassPillButton(
                  label: l.closeCase,
                  onPressed: _busy ? null : () => _run(() => _api.close(c.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemEditor(AppLocalizations l, _DraftItem i, StockLedger? stock) {
    final onHand = stock?.onHand(i.product.id) ?? 0;
    final perBox = i.product.unitsPerPack < 1 ? 1 : i.product.unitsPerPack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: LatinText(i.product.tradeName, style: DoayaTypography.label)),
            QtyStepper(
              value: i.quantity,
              max: onHand ~/ perBox < 1 ? 1 : onHand ~/ perBox,
              onChanged: (q) => setState(() => i.quantity = q),
            ),
            RoundIconButton(
              icon: DoayaIcons.close,
              tooltip: l.removeItem,
              onPressed: () => setState(() {
                _items.remove(i);
                i.dispose();
              }),
            ),
          ],
        ),
        SizedBox(height: DoayaSpacing.sm),
        GlassTextField(label: l.instructionsLabel, controller: i.instructions, maxLines: 2),
        SizedBox(height: DoayaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                label: l.timesPerDayLabel,
                controller: i.timesPerDay,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: DoayaSpacing.sm),
            Expanded(
              child: GlassTextField(
                label: l.daysLabel,
                controller: i.days,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
