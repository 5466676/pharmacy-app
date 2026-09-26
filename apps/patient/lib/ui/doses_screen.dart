import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/doses.dart';
import '../data/reminders.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

/// «جرعاتي»: the dose reminders made from the pharmacist's decisions.
class DosesScreen extends ConsumerWidget {
  const DosesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(remindersProvider);
    final canSchedule = ref.watch(deviceNotificationsProvider).canSchedule;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return PhoneBody(
      child: ListView(
        children: [
          ScreenHeader(title: l.dosesTitle),
          if (!canSchedule) ...[
            NoticeBanner(
              message: l.reminderWebNote,
              tone: StatusTone.accent,
              icon: DoayaIcons.clock,
            ),
            const SizedBox(height: DoayaSpacing.l),
          ],
          ...switch (all) {
            AsyncData(:final value) when value.isEmpty => [
              const SizedBox(height: DoayaSpacing.xl),
              Text(l.noDoses, textAlign: TextAlign.center, style: secondary),
            ],
            AsyncData(:final value) => [
              for (final r in value)
                Padding(
                  padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                  child: ReminderCard(reminder: r),
                ),
            ],
            AsyncError(:final error) => [NoticeBanner(message: errorText(l, error))],
            _ => [const Center(child: CircularProgressIndicator())],
          },
          const SizedBox(height: DoayaSpacing.xl),
        ],
      ),
    );
  }
}

class ReminderCard extends ConsumerWidget {
  const ReminderCard({super.key, required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = reminder;
    final ctl = ref.read(remindersProvider.notifier);
    final now = DateTime.now();
    final finished = r.finishedAt(now);
    final next = r.upcoming(now, limit: 1).firstOrNull;
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      padding: const EdgeInsets.all(DoayaSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(DoayaIcons.medicine, color: DoayaColors.accent),
              const SizedBox(width: DoayaSpacing.ml),
              Expanded(child: LatinText(r.name, style: DoayaTypography.label)),
              Switch(
                value: r.enabled && !finished,
                onChanged: finished ? null : (on) => ctl.setEnabled(r.id, on),
              ),
            ],
          ),
          Text(r.instructions, style: DoayaTypography.bodyMedium),
          const SizedBox(height: DoayaSpacing.xs),
          Text(
            [
              if (finished)
                l.reminderFinished
              else if (r.days != null)
                l.reminderDays(r.days!)
              else
                l.reminderOngoing,
              if (next != null && r.enabled)
                l.nextDose('${formatDate(next)} ${formatMinutes(next.hour * 60 + next.minute)}'),
            ].join('، '),
            style: secondary,
          ),
          const SizedBox(height: DoayaSpacing.ml),
          Text(l.reminderTimes, style: secondary),
          const SizedBox(height: DoayaSpacing.xs),
          Wrap(
            spacing: DoayaSpacing.sm,
            runSpacing: DoayaSpacing.sm,
            children: [
              for (final (i, m) in r.times.indexed)
                _TimeChip(
                  minutes: m,
                  onChanged: finished ? null : (v) => ctl.setTimes(r.id, [...r.times]..[i] = v),
                ),
            ],
          ),
          Text(l.reminderTimesHelp, style: secondary),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              icon: const Icon(DoayaIcons.delete, size: DoayaSizes.iconS),
              label: Text(l.deleteReminder),
              onPressed: () => ctl.remove(r.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int>? onChanged;

  static const _step = 30;
  static const _day = 24 * 60;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const size = DoayaSizes.qtyButton;
    return GlassSurface(
      tone: SurfaceTone.accentSoft,
      shadow: false,
      borderRadius: BorderRadius.circular(DoayaRadii.pill),
      padding: const EdgeInsets.all(DoayaSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundIconButton(
            icon: DoayaIcons.remove,
            tooltip: l.earlier,
            size: size,
            onPressed: onChanged == null ? null : () => onChanged!((minutes - _step + _day) % _day),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.sm),
            child: Text(formatMinutes(minutes), style: DoayaTypography.label),
          ),
          RoundIconButton(
            icon: DoayaIcons.add,
            tooltip: l.later,
            size: size,
            onPressed: onChanged == null ? null : () => onChanged!((minutes + _step) % _day),
          ),
        ],
      ),
    );
  }
}

/// «ذكّرني بالجرعات» under the pharmacist's decision.
class RemindMeButton extends ConsumerWidget {
  const RemindMeButton({super.key, required this.consultationId, required this.decision});

  final String consultationId;
  final Map<String, Object?> decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final offered = remindersFromDecision(consultationId, decision, today: DateTime.now());
    if (offered.isEmpty) return const SizedBox.shrink();
    final have = {for (final r in ref.watch(remindersProvider).value ?? const <Reminder>[]) r.id};
    if (offered.every((r) => have.contains(r.id))) {
      return StatusChip(label: l.remindersActive, tone: StatusTone.success, icon: DoayaIcons.clock);
    }
    return SagePillButton(
      label: l.remindMe,
      icon: DoayaIcons.clock,
      size: PillSize.medium,
      expand: true,
      onPressed: () async {
        await ref.read(remindersProvider.notifier).put(offered);
        if (!context.mounted) return;
        toast(context, l.remindersAdded(offered.length));
        context.go(Routes.doses);
      },
    );
  }
}
