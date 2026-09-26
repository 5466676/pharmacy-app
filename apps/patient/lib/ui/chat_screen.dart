import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'photo_widgets.dart';
import 'doses_screen.dart' show RemindMeButton;
import 'summary_editor.dart';

/// From design/patient_chat.html: the assistant asks, summarises, the
/// patient checks the summary and sends it; then the pharmacist answers
/// here too. A red flag stops the assistant and shows the emergency lines.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  /// What the patient just sent, shown until the answer comes back.
  String? _pending;
  var _busy = false;

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  ConsultationController get _ctl => ref.read(consultationProvider(widget.id).notifier);

  Future<void> _act(Future<void> Function() call, {String? pending}) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _pending = pending;
    });
    try {
      await call();
    } on Object catch (e) {
      if (pending != null && _input.text.isEmpty) _input.text = pending;
      if (mounted) toast(context, errorText(l, e), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _pending = null;
        });
      }
    }
  }

  void _say([String? quick]) {
    final text = (quick ?? _input.text).trim();
    if (text.isEmpty || _busy) return;
    if (quick == null) _input.clear();
    _act(() => _ctl.say(text), pending: text);
  }

  Future<void> _photo() async {
    final picked = await pickPhoto(context, ref);
    if (picked == null || !mounted) return;
    await _act(() => _ctl.sendPhoto(picked.bytes, picked.name));
  }

  Future<void> _editSummary(Consultation c) async {
    final edited = await showSummaryEditor(context, c.summary ?? const {});
    if (edited != null) await _act(() => _ctl.correctSummary(edited));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(consultationProvider(widget.id));
    final pharmacy = ref.watch(authProvider).patient?.pharmacy;
    final c = async.value;

    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          padding: false,
          child: Column(
            children: [
              _Header(consultation: c, pharmacyName: pharmacy?.name),
              Expanded(
                child: switch (async) {
                  AsyncValue(value: final c?) => _Messages(
                    consultation: c,
                    pending: _pending,
                    busy: _busy,
                    pharmacyName: pharmacy?.name,
                    onEditSummary: () => _editSummary(c),
                    onSendSummary: () => _act(_ctl.send),
                  ),
                  AsyncError(:final error) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(DoayaSpacing.xl),
                      child: NoticeBanner(
                        message: errorText(l, error),
                        action: GlassPillButton(
                          label: l.retry,
                          size: PillSize.small,
                          onPressed: () => ref.invalidate(consultationProvider(widget.id)),
                        ),
                      ),
                    ),
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
              if (c != null) ..._bottom(l, c),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _bottom(AppLocalizations l, Consultation c) {
    final gutter = EdgeInsets.symmetric(horizontal: DoayaSpacing.screenGutter);
    final emergency = c.status == ConsultStatus.emergency || (c.redFlag != null && !c.finished);
    return [
      if (emergency) Padding(padding: gutter, child: const EmergencyPanel()),
      if (!_busy && c.quickReplies.isNotEmpty)
        Padding(
          padding: gutter.copyWith(top: DoayaSpacing.sm),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: DoayaSpacing.sm,
              runSpacing: DoayaSpacing.sm,
              children: [
                for (final q in c.quickReplies)
                  GlassPillButton(label: q, size: PillSize.small, onPressed: () => _say(q)),
              ],
            ),
          ),
        ),
      if (c.status == ConsultStatus.chatting && c.messages.any((m) => m.mine))
        Padding(
          padding: gutter.copyWith(top: DoayaSpacing.sm),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassPillButton(
              label: l.sendToPharmacyNow,
              icon: DoayaIcons.pharmacy,
              size: PillSize.small,
              onPressed: _busy ? null : () => _act(_ctl.send),
            ),
          ),
        ),
      if (c.finished)
        Padding(
          padding: gutter.copyWith(top: DoayaSpacing.sm, bottom: DoayaSpacing.xl),
          child: NoticeBanner(message: l.consultationClosed, tone: StatusTone.neutral),
        )
      else
        _InputBar(
          controller: _input,
          focusNode: _focus,
          busy: _busy,
          hint: l.messageHint,
          sendLabel: l.send,
          onSend: _say,
          photoLabel: l.attachPhoto,
          onPhoto: _busy ? null : _photo,
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.consultation, required this.pharmacyName});

  final Consultation? consultation;
  final String? pharmacyName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = consultation;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DoayaSpacing.screenGutter,
        DoayaSpacing.sm,
        DoayaSpacing.screenGutter,
        DoayaSpacing.ml,
      ),
      child: Row(
        children: [
          RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.cancel,
            onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
          ),
          SizedBox(width: DoayaSpacing.ml),
          const GlassSurface(
            tone: SurfaceTone.strong,
            width: DoayaSizes.roundButton,
            height: DoayaSizes.roundButton,
            borderRadius: BorderRadius.all(Radius.circular(DoayaRadii.pill)),
            child: Center(child: DoayaLogo(size: DoayaSizes.logoSmall)),
          ),
          SizedBox(width: DoayaSpacing.ml),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.assistantTitle, style: DoayaTypography.titleSmall),
                if (pharmacyName != null)
                  Row(
                    children: [
                      const StatusDot(),
                      SizedBox(width: DoayaSpacing.s),
                      Flexible(
                        child: Text(
                          l.pharmacyFollowing(pharmacyName!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (c != null && !c.withAssistant)
            StatusChip(label: l.status(c.status), tone: consultTone(c.status)),
        ],
      ),
    );
  }
}

class _Messages extends StatelessWidget {
  const _Messages({
    required this.consultation,
    required this.pending,
    required this.busy,
    required this.pharmacyName,
    required this.onEditSummary,
    required this.onSendSummary,
  });

  final Consultation consultation;
  final String? pending;
  final bool busy;
  final String? pharmacyName;
  final VoidCallback onEditSummary;
  final VoidCallback onSendSummary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = consultation;
    final items = <Widget>[
      for (final m in c.messages) _Bubble(message: m),
      if (pending != null) _Bubble.pending(pending!),
      if (busy && pending != null && c.withAssistant) const _Thinking(),
      if (c.status == ConsultStatus.summary && c.summary != null)
        SummaryCard(summary: c.summary!, busy: busy, onEdit: onEditSummary, onSend: onSendSummary),
      if (!c.withAssistant && !c.finished && c.status != ConsultStatus.emergency)
        _Steps(status: c.status),
      if (c.decision != null) _DecisionCard(decision: c.decision!, pharmacyName: pharmacyName),
      if (c.decision != null && !c.finished)
        RemindMeButton(consultationId: c.id, decision: c.decision!),
    ];
    if (items.isEmpty) {
      items.add(
        Padding(
          padding: EdgeInsets.only(top: DoayaSpacing.huge),
          child: Text(
            l.heroSubtitle,
            textAlign: TextAlign.center,
            style: DoayaTypography.bodyMedium.copyWith(color: DoayaColors.textSecondary),
          ),
        ),
      );
    }
    // Reversed: the newest stays in view as the conversation grows.
    return ListView.separated(
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: DoayaSpacing.screenGutter,
        vertical: DoayaSpacing.sm,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.ml),
      itemBuilder: (_, i) => items[items.length - 1 - i],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required ChatMessage this.message}) : text = null;
  const _Bubble.pending(String this.text) : message = null;

  final ChatMessage? message;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = message;
    final body = m?.text ?? text!;
    if (m?.role == 'system') {
      return NoticeBanner(message: body, tone: StatusTone.accent, icon: DoayaIcons.pharmacy);
    }
    final mine = m == null || m.mine;
    final r = Radius.circular(DoayaRadii.bubble);
    final tail = Radius.circular(DoayaRadii.bubbleTail);
    // RTL: the patient's bubbles start on the right, with the tail there.
    final radius = BorderRadiusDirectional.only(
      topStart: r,
      topEnd: r,
      bottomStart: mine ? tail : r,
      bottomEnd: mine ? r : tail,
    ).resolve(Directionality.of(context));
    final style = DoayaTypography.body.copyWith(
      color: mine ? DoayaColors.onSage : DoayaColors.textPrimary,
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (m?.role == 'pharmacist')
          Padding(
            padding: EdgeInsets.only(bottom: DoayaSpacing.xs),
            child: Text(
              [l.rolePharmacist, ?m!.author].join(': '),
              style: DoayaTypography.caption.copyWith(color: DoayaColors.accent),
            ),
          ),
        if (m?.photoId case final photo?) ...[
          PhotoThumb(id: photo),
          SizedBox(height: DoayaSpacing.xs),
        ],
        Text(body, style: style),
        if (m != null)
          Text(
            formatTime(m.createdAt),
            style: DoayaTypography.micro.copyWith(
              color: mine ? DoayaColors.onSage : DoayaColors.textSecondary,
            ),
          ),
      ],
    );
    final padding = EdgeInsets.symmetric(horizontal: DoayaSpacing.xl, vertical: DoayaSpacing.ml);
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: FractionallySizedBox(
        widthFactor: mine ? 0.8 : 0.86,
        alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
        child: Align(
          alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
          child: Opacity(
            opacity: m == null ? DoayaOpacity.disabled : 1,
            child: mine
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [DoayaColors.sageTop, DoayaColors.sageBottom],
                      ),
                    ),
                    child: Padding(padding: padding, child: content),
                  )
                : GlassSurface(
                    tone: m.role == 'pharmacist' ? SurfaceTone.accentSoft : SurfaceTone.normal,
                    borderRadius: radius,
                    padding: padding,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.bubble),
      padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.xl, vertical: DoayaSpacing.m),
      child: Text(
        AppLocalizations.of(context).thinking,
        style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
      ),
    ),
  );
}

/// Sent → preparing → ready → picked up.
class _Steps extends StatelessWidget {
  const _Steps({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const order = [
      ConsultStatus.sent,
      ConsultStatus.preparing,
      ConsultStatus.ready,
      ConsultStatus.pickedUp,
    ];
    final labels = [l.stepSent, l.stepPreparing, l.stepReady, l.stepPickedUp];
    final at = order.indexOf(status);
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      padding: EdgeInsets.all(DoayaSpacing.l),
      child: Row(
        children: [
          for (var i = 0; i < order.length; i++)
            Expanded(
              child: Column(
                children: [
                  Icon(
                    i <= at ? DoayaIcons.check : DoayaIcons.clock,
                    size: DoayaSizes.iconS,
                    color: i <= at ? DoayaColors.accent : DoayaColors.dotInactive,
                  ),
                  SizedBox(height: DoayaSpacing.xs),
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: DoayaTypography.caption.copyWith(
                      color: i == at ? DoayaColors.accent : DoayaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// What the pharmacist prepared, in their own words.
class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision, required this.pharmacyName});

  final Map<String, Object?> decision;
  final String? pharmacyName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = (decision['items'] as List? ?? const []).cast<Map<String, Object?>>();
    final by = decision['by'] as String?;
    final note = decision['note'] as String?;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.cardLarge),
      padding: EdgeInsets.all(DoayaSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.decisionTitle, style: DoayaTypography.label.copyWith(color: DoayaColors.accent)),
          if (by != null) Text(l.decisionBy(by), style: secondary),
          SizedBox(height: DoayaSpacing.ml),
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.ml),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LatinText(item['name']! as String, style: DoayaTypography.label),
                      ),
                      Text(formatNumber(item['quantity']! as int), style: DoayaTypography.label),
                    ],
                  ),
                  Text(item['instructions']! as String, style: DoayaTypography.bodyMedium),
                ],
              ),
            ),
          if (note != null) Text(note, style: secondary),
          if (pharmacyName != null) ...[
            SizedBox(height: DoayaSpacing.sm),
            StatusChip(label: l.pickupAt(pharmacyName!), tone: StatusTone.accent),
          ],
        ],
      ),
    );
  }
}

/// Call now: the ambulance and the general emergency line.
class EmergencyPanel extends StatelessWidget {
  const EmergencyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget call(String label, String number) => SagePillButton(
      label: label,
      icon: DoayaIcons.call,
      expand: true,
      size: PillSize.large,
      onPressed: () => launchUrl(Uri(scheme: 'tel', path: number)),
    );
    return GlassSurface(
      tone: SurfaceTone.danger,
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      padding: EdgeInsets.all(DoayaSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(DoayaIcons.danger, color: DoayaColors.dangerText),
              SizedBox(width: DoayaSpacing.sm),
              Text(
                l.emergencyTitle,
                style: DoayaTypography.label.copyWith(color: DoayaColors.dangerText),
              ),
            ],
          ),
          SizedBox(height: DoayaSpacing.ml),
          call(l.callAmbulance(ambulanceNumber), ambulanceNumber),
          SizedBox(height: DoayaSpacing.sm),
          call(l.callEmergency(emergencyNumber), emergencyNumber),
          SizedBox(height: DoayaSpacing.sm),
          Text(
            l.emergencyStillWrite,
            style: DoayaTypography.caption.copyWith(color: DoayaColors.dangerText),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.hint,
    required this.sendLabel,
    required this.onSend,
    required this.photoLabel,
    required this.onPhoto,
  });

  final String photoLabel;
  final VoidCallback? onPhoto;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final String hint;
  final String sendLabel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      DoayaSpacing.floatingInset,
      DoayaSpacing.m,
      DoayaSpacing.floatingInset,
      DoayaSpacing.xxxl,
    ),
    child: GlassSurface(
      tone: SurfaceTone.strong,
      blur: true,
      height: DoayaSizes.inputBar,
      borderRadius: BorderRadius.circular(DoayaRadii.pill),
      padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.s),
      child: Row(
        children: [
          IconButton(
            icon: Icon(DoayaIcons.camera, color: DoayaColors.textSecondary),
            tooltip: photoLabel,
            onPressed: onPhoto,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: DoayaSpacing.l),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: DoayaTypography.body,
                cursorColor: DoayaColors.accent,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: DoayaTypography.body.copyWith(color: DoayaColors.textSecondary),
                ),
              ),
            ),
          ),
          RoundIconButton(
            icon: DoayaIcons.send,
            tooltip: sendLabel,
            size: DoayaSizes.buttonMedium,
            tone: SurfaceTone.selected,
            iconColor: DoayaColors.accent,
            onPressed: busy ? null : onSend,
          ),
        ],
      ),
    ),
  );
}
