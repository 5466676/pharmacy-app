import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.logout,
      content: Text(l.logoutConfirm, style: DoayaTypography.bodyMedium),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.pop(context, false)),
        SagePillButton(label: l.confirm, onPressed: () => Navigator.pop(context, true)),
      ],
    );
    if (ok ?? false) await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(authProvider).patient;
    if (p == null) return const SizedBox.shrink();
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final card = BorderRadius.circular(DoayaRadii.card);
    return PhoneBody(
      child: ListView(
        children: [
          ScreenHeader(title: l.accountTitle),
          GlassSurface(
            borderRadius: card,
            padding: EdgeInsets.all(DoayaSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: DoayaTypography.titleSmall),
                SizedBox(height: DoayaSpacing.xs),
                Text(ltrIsolate(p.phone), style: secondary),
                Text(
                  [
                    if (p.birthYear != null) '${l.birthYearLabel}: ${p.birthYear}',
                    if (p.sex != null) p.sex == 'f' ? l.female : l.male,
                    ?p.city,
                  ].join('، '),
                  style: secondary,
                ),
              ],
            ),
          ),
          SizedBox(height: DoayaSpacing.xl),
          if (p.pharmacy case final ph?)
            GlassSurface(
              borderRadius: card,
              padding: EdgeInsets.all(DoayaSpacing.xl),
              child: Row(
                children: [
                  Icon(DoayaIcons.pharmacy, color: DoayaColors.accent),
                  SizedBox(width: DoayaSpacing.ml),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.yourPharmacy, style: secondary),
                        Text(ph.name, style: DoayaTypography.label),
                        Text([ph.city, ?ph.address].join('، '), style: secondary),
                        if (ph.hours != null) Text(l.pharmacyHours(ph.hours!), style: secondary),
                      ],
                    ),
                  ),
                  GlassPillButton(
                    label: l.change,
                    size: PillSize.small,
                    onPressed: () => context.push(Routes.pharmacy),
                  ),
                ],
              ),
            ),
          SizedBox(height: DoayaSpacing.huge),
          GlassPillButton(
            label: l.lookTitle,
            icon: DoayaIcons.settings,
            expand: true,
            onPressed: () => context.push(Routes.look),
          ),
          SizedBox(height: DoayaSpacing.sm),
          GlassPillButton(
            label: l.logout,
            icon: DoayaIcons.logout,
            expand: true,
            onPressed: () => _logout(context, ref),
          ),
          SizedBox(height: DoayaSpacing.xl),
        ],
      ),
    );
  }
}
