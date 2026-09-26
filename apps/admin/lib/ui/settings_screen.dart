import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/identity.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';
import 'shell.dart' show identityName;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(identityProvider);
    String note(AdminIdentity i) => switch (i) {
      AdminIdentity.console => l.designConsoleNote,
      AdminIdentity.ledger => l.designLedgerNote,
      AdminIdentity.family => l.designFamilyNote,
    };
    return ListView(
      children: [
        PageHeader(title: l.settingsTitle),
        Panel(
          title: l.designTitle,
          child: Wrap(
            spacing: DoayaSpacing.m,
            runSpacing: DoayaSpacing.m,
            children: [
              for (final i in AdminIdentity.values)
                SizedBox(
                  width: 260,
                  child: _DesignCard(
                    name: identityName(l, i),
                    note: note(i),
                    look: i.look,
                    selected: i == current,
                    onTap: () => ref.read(identityProvider.notifier).set(i),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: DoayaSpacing.m),
        const _Server(),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({
    required this.name,
    required this.note,
    required this.look,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String note;
  final DoayaLook look;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The card previews the design's own colours.
    final p = DoayaPalette.of(look);
    return GlassSurface(
      tone: selected ? SurfaceTone.selected : SurfaceTone.normal,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DoayaRadii.card),
        child: Padding(
          padding: EdgeInsets.all(DoayaSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final c in [p.bgMid, p.surfaceRaised, p.accent, p.warningText])
                    Container(
                      width: DoayaSizes.colorDot,
                      height: DoayaSizes.colorDot,
                      margin: EdgeInsetsDirectional.only(end: DoayaSpacing.xs),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(DoayaRadii.key),
                        border: Border.all(color: DoayaColors.border),
                      ),
                    ),
                  const Spacer(),
                  if (selected) Icon(DoayaIcons.check, color: DoayaColors.accent),
                ],
              ),
              SizedBox(height: DoayaSpacing.sm),
              Text(name, style: DoayaTypography.label),
              Text(note, style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Server extends ConsumerStatefulWidget {
  const _Server();

  @override
  ConsumerState<_Server> createState() => _ServerState();
}

class _ServerState extends ConsumerState<_Server> {
  String? _check;
  bool _checking = false;

  Future<void> _run() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _checking = true;
      _check = null;
    });
    try {
      final r = await ref.read(apiProvider).modelCheck();
      _check = r.ok ? l.modelOk(formatNumber(r.ms ?? 0)) : l.modelDown(r.error ?? '');
    } on Object catch (e) {
      _check = errorText(l, e);
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Panel(
      title: l.serverTitle,
      child: AsyncView(
        value: ref.watch(settingsProvider),
        retry: () => ref.invalidate(settingsProvider),
        data: (s) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.serverNote,
              style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
            ),
            SizedBox(height: DoayaSpacing.m),
            Wrap(
              spacing: DoayaSpacing.sm,
              runSpacing: DoayaSpacing.sm,
              children: [
                Fact(label: l.modelUrl, value: s.llmBaseUrl, ltr: true),
                Fact(label: l.modelName, value: s.llmModel, ltr: true),
                Fact(label: l.emergencyNumbers, value: l.emergencyValue(s.ambulance, s.general)),
                Fact(
                  label: l.corsOrigins,
                  value: s.corsOrigins.isEmpty ? l.none : s.corsOrigins.join(', '),
                  ltr: s.corsOrigins.isNotEmpty,
                ),
                Fact(label: l.serverVersion, value: s.serverVersion, ltr: true),
              ],
            ),
            SizedBox(height: DoayaSpacing.m),
            Row(
              children: [
                GlassPillButton(
                  label: l.modelCheck,
                  icon: DoayaIcons.refresh,
                  onPressed: _checking ? null : _run,
                ),
                SizedBox(width: DoayaSpacing.m),
                if (_checking)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (_check != null)
                  Expanded(child: Text(_check!, style: DoayaTypography.bodySmall)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
