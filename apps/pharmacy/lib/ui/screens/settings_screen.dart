import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/demo_seed.dart';
import '../../data/people_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';
import 'backup_panel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _form = GlobalKey<FormState>();
  final _pharmacy = TextEditingController();
  final _code = TextEditingController();
  final _symbol = TextEditingController();
  final _decimals = TextEditingController();
  final _nearDays = TextEditingController();
  var _loaded = false;

  void _load(Map<String, String> s) {
    if (_loaded) return;
    _loaded = true;
    final c = PeopleRepository.currencyFrom(s);
    _pharmacy.text = s[SettingKeys.pharmacyName] ?? '';
    _code.text = c.code;
    _symbol.text = c.symbol;
    _decimals.text = '${c.decimals}';
    _nearDays.text = '${PeopleRepository.nearExpiryDaysFrom(s)}';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final people = ref.read(peopleProvider);
    await people.setSetting(SettingKeys.pharmacyName, _pharmacy.text.trim());
    await people.setSetting(SettingKeys.currencyCode, _code.text.trim().toUpperCase());
    await people.setSetting(SettingKeys.currencySymbol, _symbol.text.trim());
    // Decimals change the meaning of every stored amount: only while empty.
    if (!_hasData) await people.setSetting(SettingKeys.currencyDecimals, _decimals.text.trim());
    await people.setSetting(SettingKeys.nearExpiryDays, _nearDays.text.trim());
    if (mounted) toast(context, AppLocalizations.of(context).saved);
  }

  bool get _hasData => (ref.read(productsProvider).value ?? const []).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    if (!session.isOwner) return EmptyHint(l.ownerOnly);
    final settings = ref.watch(settingsProvider).value;
    if (settings != null) _load(settings);
    final employees = ref.watch(allEmployeesProvider).value ?? const [];
    final hasData = (ref.watch(productsProvider).value ?? const []).isNotEmpty;
    String? req(String? v) => (v ?? '').trim().isEmpty ? l.required : null;
    const gap = SizedBox(height: DoayaSpacing.l);

    return ListView(
      children: [
        PageHeader(
          title: l.settingsTitle,
          actions: [SagePillButton(label: l.save, size: PillSize.medium, onPressed: _save)],
        ),
        Form(
          key: _form,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Panel(
                  title: l.pharmacySection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassTextField(
                        label: l.pharmacyNameLabel,
                        controller: _pharmacy,
                        validator: req,
                      ),
                      gap,
                      GlassTextField(
                        label: l.nearExpiryDaysLabel,
                        controller: _nearDays,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0 ? null : l.invalidNumber,
                      ),
                      gap,
                      Text(
                        '${l.thisDevice}: ${session.device.name}',
                        style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DoayaSpacing.xl),
              Expanded(
                child: Panel(
                  title: l.currencySection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.currencyHelp,
                        style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                      ),
                      gap,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GlassTextField(
                              label: l.currencyCodeLabel,
                              controller: _code,
                              textDirection: TextDirection.ltr,
                              maxLength: 3,
                              validator: (v) => RegExp(r'^[A-Za-z]{3}$').hasMatch(v?.trim() ?? '')
                                  ? null
                                  : l.invalidNumber,
                            ),
                          ),
                          const SizedBox(width: DoayaSpacing.l),
                          Expanded(
                            child: GlassTextField(
                              label: l.currencySymbolLabel,
                              controller: _symbol,
                              validator: req,
                            ),
                          ),
                          const SizedBox(width: DoayaSpacing.l),
                          Expanded(
                            child: IgnorePointer(
                              ignoring: hasData,
                              child: Opacity(
                                opacity: hasData ? DoayaOpacity.disabled : 1,
                                child: GlassTextField(
                                  label: l.currencyDecimalsLabel,
                                  controller: _decimals,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    final n = int.tryParse(v ?? '');
                                    return n != null && n >= 0 && n <= 4 ? null : l.invalidNumber;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.xl),
        Panel(
          title: l.employeesSection,
          trailing: SagePillButton(
            label: l.addEmployee,
            icon: DoayaIcons.customer,
            size: PillSize.small,
            onPressed: () => _addEmployee(context),
          ),
          child: Column(
            children: [
              for (final e in employees)
                Padding(
                  padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                  child: CaseRow(
                    initials: initialsOf(e.name),
                    title: e.name,
                    subtitle: e.role == EmployeeRole.owner.name ? l.owner : l.employee,
                    trailing: e.id == session.employee.id
                        ? null
                        : GlassPillButton(
                            label: e.active ? l.deactivate : l.activate,
                            onPressed: () =>
                                ref.read(peopleProvider).setActive(e.id, active: !e.active),
                          ),
                    urgent: !e.active,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.xl),
        const BackupPanel(),
        if (!hasData) ...[
          const SizedBox(height: DoayaSpacing.xl),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GlassPillButton(
              label: l.loadDemo,
              icon: DoayaIcons.demo,
              onPressed: () async {
                await seedDemoData(
                  ref.read(catalogProvider),
                  ref.read(ledgerProvider),
                  ref.read(peopleProvider),
                  session.stamp,
                );
                if (context.mounted) toast(context, l.demoLoaded);
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addEmployee(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final form = GlobalKey<FormState>();
    final name = TextEditingController();
    final pin = TextEditingController();
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.addEmployee,
      content: Form(
        key: form,
        child: Column(
          children: [
            GlassTextField(
              label: l.employeeNameLabel,
              controller: name,
              autofocus: true,
              validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
            ),
            const SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: l.pinLabel,
              controller: pin,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => PeopleRepository.isValidPin(v ?? '') ? null : l.pinInvalid,
            ),
          ],
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(
          label: l.save,
          size: PillSize.small,
          onPressed: () {
            if (form.currentState!.validate()) Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    if (ok == true) await ref.read(peopleProvider).addEmployee(name: name.text, pin: pin.text);
  }
}
