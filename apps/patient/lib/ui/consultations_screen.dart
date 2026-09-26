import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'consultation_tile.dart';
import 'home_screen.dart' show startConsultation;

class ConsultationsScreen extends ConsumerWidget {
  const ConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(consultationsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(consultationsProvider.future),
      child: PhoneBody(
        child: ListView(
          children: [
            ScreenHeader(
              title: l.navConsultations,
              trailing: SagePillButton(
                label: l.startConsultation,
                icon: DoayaIcons.add,
                size: PillSize.small,
                onPressed: () => startConsultation(context, ref),
              ),
            ),
            ...switch (all) {
              AsyncData(:final value) when value.isEmpty => [
                SizedBox(height: DoayaSpacing.huge),
                Center(
                  child: Text(
                    l.noConsultations,
                    style: DoayaTypography.bodyMedium.copyWith(color: DoayaColors.textSecondary),
                  ),
                ),
              ],
              AsyncData(:final value) => [
                for (final c in value)
                  Padding(
                    padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: ConsultationTile(
                      consultation: c,
                      onTap: () => context.push(Routes.chat(c.id)),
                    ),
                  ),
              ],
              AsyncError(:final error) => [
                NoticeBanner(
                  message: errorText(l, error),
                  action: GlassPillButton(
                    label: l.retry,
                    size: PillSize.small,
                    onPressed: () => ref.invalidate(consultationsProvider),
                  ),
                ),
              ],
              _ => [const Center(child: CircularProgressIndicator())],
            },
          ],
        ),
      ),
    );
  }
}
