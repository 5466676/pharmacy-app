import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../central/inbox_controller.dart';
import '../../sync/discovery.dart';
import '../../sync/sync_api.dart';
import '../../sync/sync_controller.dart';
import '../format.dart';
import '../widgets.dart';

/// Arabic message for a failed server call.
String syncErrorText(AppLocalizations l, Object e) => switch (e) {
  SyncCertificateException() => l.errWrongServer,
  SyncNetworkException() => l.serverNotResponding,
  SyncApiException(code: 'bad_credentials') => l.errBadCredentials,
  SyncApiException(code: 'phone_taken') => l.errPhoneTaken,
  SyncApiException(code: 'too_many_attempts') => l.errTooManyAttempts,
  SyncApiException(code: 'already_set_up') => l.errAlreadySetUp,
  SyncApiException(code: 'device_other_pharmacy') => l.errDeviceOtherPharmacy,
  SyncApiException(code: 'pharmacy_inactive') => l.errPharmacyInactive,
  SyncApiException(code: 'bad_pharmacy_key') => l.errBadPharmacyKey,
  SyncApiException(code: 'central_unreachable') => l.errCentralUnreachable,
  SyncApiException(code: 'central_not_configured') => l.inboxNotConnected,
  SyncApiException(:final code) => l.errServer(code),
  _ => l.errServer('$e'),
};

/// "host:port، رمز السيرفر: AB12-CD34" for a server address.
String serverLabel(AppLocalizations l, Uri url) => [
  ltrIsolate('${url.host}:${url.port}'),
  if (serverPin(url) case final pin?) l.serverCode(ltrIsolate(serverCode(pin))),
].join('، ');

/// Finds the pharmacy's server on the Wi-Fi (or takes a typed address) and
/// confirms it answers. Returns the chosen address.
class ServerPicker extends ConsumerStatefulWidget {
  const ServerPicker({super.key, required this.onChosen});

  final ValueChanged<Uri> onChosen;

  @override
  ConsumerState<ServerPicker> createState() => _ServerPickerState();
}

class _ServerPickerState extends ConsumerState<ServerPicker> {
  final _address = TextEditingController();
  List<FoundServer>? _found;
  var _searching = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _searching = true;
      _error = null;
    });
    List<FoundServer> found;
    try {
      found = await discoverServers();
    } on Object {
      found = const [];
    }
    if (!mounted) return;
    setState(() {
      _searching = false;
      _found = found;
    });
  }

  Future<void> _useTyped() async {
    final l = AppLocalizations.of(context);
    final typed = parseServerAddress(toLatinDigits(_address.text));
    final url = typed == null ? null : await ref.read(syncApiProvider).probe(typed);
    if (url == null) {
      if (mounted) setState(() => _error = l.serverNotResponding);
      return;
    }
    widget.onChosen(url);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPillButton(
          label: _searching ? l.searchingServer : l.findServer,
          icon: DoayaIcons.search,
          size: PillSize.medium,
          expand: true,
          onPressed: _searching ? null : _search,
        ),
        if (_found != null && _found!.isEmpty) ...[
          const SizedBox(height: DoayaSpacing.sm),
          Text(l.noServerFound, style: secondary),
        ],
        for (final s in _found ?? const <FoundServer>[])
          Padding(
            padding: const EdgeInsets.only(top: DoayaSpacing.sm),
            child: CaseRow(
              initials: initialsOf(s.pharmacyName ?? l.appName),
              title: s.pharmacyName ?? l.newServer,
              subtitle: serverLabel(l, s.url),
              onTap: () => widget.onChosen(s.url),
            ),
          ),
        const SizedBox(height: DoayaSpacing.l),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GlassTextField(
                label: l.serverAddressLabel,
                hint: l.serverAddressHint,
                controller: _address,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _useTyped(),
              ),
            ),
            const SizedBox(width: DoayaSpacing.sm),
            GlassPillButton(label: l.useThisServer, onPressed: _useTyped),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: DoayaSpacing.sm),
          Text(_error!, style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.dangerText)),
        ],
      ],
    );
  }
}

/// Phone + password (+ confirmation when creating the account).
class AccountForm extends StatefulWidget {
  const AccountForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.confirmPassword = false,
  });

  final String submitLabel;
  final bool confirmPassword;

  /// Returns an error text, or null on success.
  final Future<String?> Function(String phone, String password) onSubmit;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onSubmit(toLatinDigits(_phone.text.trim()), _password.text);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Tab stays inside the form (not into the server panel next to it).
    return FocusTraversalGroup(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassTextField(
              label: l.phoneAccountLabel,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              autofocus: true,
              validator: (v) => whatsappNumber(v) == null ? l.invalidPhone : null,
            ),
            const SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: l.passwordLabel,
              controller: _password,
              obscureText: true,
              validator: (v) => (v ?? '').length < 6 ? l.passwordTooShort : null,
              onSubmitted: widget.confirmPassword ? null : (_) => _submit(),
            ),
            if (widget.confirmPassword) ...[
              const SizedBox(height: DoayaSpacing.l),
              GlassTextField(
                label: l.passwordConfirmLabel,
                controller: _confirm,
                obscureText: true,
                validator: (v) => v == _password.text ? null : l.passwordMismatch,
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: DoayaSpacing.sm),
              Text(
                _error!,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.dangerText),
              ),
            ],
            const SizedBox(height: DoayaSpacing.xl),
            SagePillButton(
              label: widget.submitLabel,
              expand: true,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// السيرفر والمزامنة: link this device, see sync state; the owner manages
/// linked devices and employees' accounts.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(syncProvider);
    return ListView(
      children: [
        PageHeader(title: l.syncTitle),
        if (!status.linked) const _NotLinked() else const _Linked(),
      ],
    );
  }
}

class _NotLinked extends ConsumerStatefulWidget {
  const _NotLinked();

  @override
  ConsumerState<_NotLinked> createState() => _NotLinkedState();
}

class _NotLinkedState extends ConsumerState<_NotLinked> {
  Uri? _server;
  bool? _needsSetup;

  Future<void> _choose(Uri url) async {
    bool needs;
    try {
      needs = await ref.read(syncApiProvider).needsSetup(url);
    } on Object catch (e) {
      if (mounted) toast(context, syncErrorText(AppLocalizations.of(context), e), error: true);
      return;
    }
    setState(() {
      _server = url;
      _needsSetup = needs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final server = _server;
    final phone = isPhoneLayout(context);
    Widget cell(Widget w) => phone ? w : Expanded(child: w);
    return Flex(
      direction: phone ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: phone ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        cell(
          Panel(
            title: l.findServer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.syncNotLinkedHelp, style: secondary),
                const SizedBox(height: DoayaSpacing.l),
                ServerPicker(onChosen: _choose),
              ],
            ),
          ),
        ),
        const SizedBox(width: DoayaSpacing.xl, height: DoayaSpacing.l),
        cell(
          server == null
              ? const SizedBox.shrink()
              : Panel(
                  title: _needsSetup! ? l.createOnServerTitle : l.linkTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(serverLabel(l, server), style: secondary),
                      if (serverPin(server) != null) Text(l.serverCodeHelp, style: secondary),
                      const SizedBox(height: DoayaSpacing.sm),
                      if (_needsSetup!) ...[
                        Text(l.createOnServerHelp, style: secondary),
                        const SizedBox(height: DoayaSpacing.l),
                      ],
                      if (_needsSetup! && !session.isOwner)
                        Text(l.ownerOnly, style: secondary)
                      else
                        AccountForm(
                          submitLabel: _needsSetup! ? l.createAndLink : l.linkButton,
                          confirmPassword: _needsSetup!,
                          onSubmit: (phone, password) async {
                            final sync = ref.read(syncProvider.notifier);
                            try {
                              if (_needsSetup!) {
                                await sync.setUpServer(
                                  server,
                                  ownerPhone: phone,
                                  password: password,
                                  owner: session.employee,
                                );
                              } else {
                                await sync.link(server, phone: phone, password: password);
                              }
                              return null;
                            } on Object catch (e) {
                              return syncErrorText(l, e);
                            }
                          },
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _Linked extends ConsumerWidget {
  const _Linked();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(syncProvider);
    final link = status.link!;
    final pending = ref.watch(pendingChangesProvider).value ?? 0;
    final owner = ref.watch(requireSessionProvider).isOwner;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final downloading =
        status.phase == SyncPhase.syncing && status.latest > 0 && status.cursor < status.latest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          title: l.linkedTo(link.pharmacyName),
          trailing: SagePillButton(
            label: l.syncNowButton,
            icon: DoayaIcons.sync,
            size: PillSize.medium,
            onPressed: status.phase == SyncPhase.syncing
                ? null
                : () => ref.read(syncProvider.notifier).syncNow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  syncStatusChip(l, status, pending),
                  const SizedBox(width: DoayaSpacing.sm),
                  if (pending > 0) StatusChip(label: l.pendingChanges(formatQty(pending))),
                ],
              ),
              const SizedBox(height: DoayaSpacing.sm),
              Text(
                [
                  l.signedInAs(link.userName),
                  serverLabel(l, link.url),
                  status.lastSyncAt == null
                      ? l.neverSynced
                      : l.lastSync(
                          '${formatDate(status.lastSyncAt!)}، ${formatTime(status.lastSyncAt!)}',
                        ),
                ].join('، '),
                style: secondary,
              ),
              if (downloading) ...[
                const SizedBox(height: DoayaSpacing.sm),
                Text(
                  l.syncDownloading(formatQty((status.cursor * 100) ~/ status.latest)),
                  style: secondary,
                ),
                const SizedBox(height: DoayaSpacing.xs),
                LinearProgressIndicator(
                  value: status.cursor / status.latest,
                  color: DoayaColors.accent,
                  backgroundColor: DoayaColors.divider,
                ),
              ],
              if (link.isOwner)
                if (ref.watch(_serverBackupProvider).value case final b?) ...[
                  const SizedBox(height: DoayaSpacing.xs),
                  Text(
                    b['error'] != null
                        ? l.serverBackupError
                        : b['latest'] == null
                        ? l.serverBackupNone
                        : () {
                            final t = DateTime.parse(b['latest']! as String);
                            return l.serverBackupLast('${formatDate(t)}، ${formatTime(t)}');
                          }(),
                    style: DoayaTypography.bodySmall.copyWith(
                      color: b['error'] != null || b['latest'] == null
                          ? DoayaColors.warningText
                          : DoayaColors.textSecondary,
                    ),
                  ),
                ],
              if (status.phase == SyncPhase.unlinked || status.phase == SyncPhase.wrongServer) ...[
                const SizedBox(height: DoayaSpacing.sm),
                NoticeBanner(
                  message: status.phase == SyncPhase.unlinked ? l.unlinkedHelp : l.wrongServerHelp,
                  tone: StatusTone.danger,
                ),
                const SizedBox(height: DoayaSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: GlassPillButton(
                    label: l.relinkButton,
                    icon: DoayaIcons.sync,
                    size: PillSize.medium,
                    onPressed: () async {
                      final ok = await showDoayaDialog<bool>(
                        context: context,
                        title: l.relinkButton,
                        content: Text(l.relinkConfirm, style: DoayaTypography.bodyMedium),
                        actions: [
                          GlassPillButton(
                            label: l.cancel,
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          SagePillButton(
                            label: l.confirm,
                            size: PillSize.small,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                      if (ok == true) await ref.read(syncProvider.notifier).forgetServer();
                    },
                  ),
                ),
              ],
              if (status.phase == SyncPhase.serverUnreachable) ...[
                const SizedBox(height: DoayaSpacing.sm),
                NoticeBanner(message: l.serverMissingHelp),
              ],
            ],
          ),
        ),
        if (owner && link.isOwner) ...[
          const SizedBox(height: DoayaSpacing.xl),
          if (isPhoneLayout(context)) ...[
            const _DevicesPanel(),
            const SizedBox(height: DoayaSpacing.l),
            const _AccountsPanel(),
          ] else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _DevicesPanel()),
                SizedBox(width: DoayaSpacing.xl),
                Expanded(child: _AccountsPanel()),
              ],
            ),
          const SizedBox(height: DoayaSpacing.l),
          const _CentralPanel(),
        ],
      ],
    );
  }
}

/// Top-bar / screen chip for the sync state.
StatusChip syncStatusChip(AppLocalizations l, SyncStatus s, int pending) => switch (s.phase) {
  SyncPhase.notLinked => StatusChip(label: l.offline, dot: true),
  SyncPhase.syncing => StatusChip(label: l.statusSyncing, icon: DoayaIcons.sync),
  SyncPhase.idle => StatusChip(
    label: s.lastSyncAt == null ? l.statusSyncing : l.statusSynced(formatTime(s.lastSyncAt!)),
    tone: StatusTone.accent,
    dot: true,
  ),
  SyncPhase.serverUnreachable => StatusChip(
    label: l.statusServerMissing,
    tone: StatusTone.warning,
    dot: true,
  ),
  SyncPhase.unlinked => StatusChip(label: l.statusUnlinked, tone: StatusTone.danger, dot: true),
  SyncPhase.wrongServer => StatusChip(
    label: l.statusWrongServer,
    tone: StatusTone.danger,
    dot: true,
  ),
  SyncPhase.failed => StatusChip(label: l.statusFailed, tone: StatusTone.danger, dot: true),
};

final _devicesProvider = FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  ref.watch(syncProvider.select((s) => s.lastSyncAt));
  final c = ref.watch(syncProvider.notifier).client;
  if (c == null) return const [];
  return ((await c.getJson('devices')) as List).cast<Map<String, Object?>>();
});

final _serverBackupProvider = FutureProvider.autoDispose<Map<String, Object?>?>((ref) async {
  ref.watch(syncProvider.select((s) => s.lastSyncAt));
  final c = ref.watch(syncProvider.notifier).client;
  if (c == null) return null;
  try {
    return (await c.getJson('backups'))! as Map<String, Object?>;
  } on Object {
    return null; // older server or offline: just don't show it
  }
});

final _accountsProvider = FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  final c = ref.watch(syncProvider.notifier).client;
  if (c == null) return const [];
  return ((await c.getJson('users')) as List).cast<Map<String, Object?>>();
});

class _DevicesPanel extends ConsumerWidget {
  const _DevicesPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final devices = ref.watch(_devicesProvider).value ?? const [];
    final me = ref.watch(thisDeviceProvider).value?.id;
    return Panel(
      title: l.devicesTitle,
      child: Column(
        children: [
          for (final d in devices)
            Padding(
              padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d['name']! as String, style: DoayaTypography.label),
                        if (d['last_seen_at'] != null)
                          Text(
                            l.lastSeen(() {
                              final t = DateTime.parse(d['last_seen_at']! as String);
                              return '${formatDate(t)}، ${formatTime(t)}';
                            }()),
                            style: DoayaTypography.caption.copyWith(
                              color: DoayaColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (d['id'] == me)
                    StatusChip(label: l.thisDeviceTag, tone: StatusTone.accent)
                  else if (d['revoked'] == true)
                    StatusChip(label: l.deviceUnlinkedTag, tone: StatusTone.danger)
                  else
                    GlassPillButton(
                      label: l.unlinkDevice,
                      onPressed: () async {
                        final ok = await showDoayaDialog<bool>(
                          context: context,
                          title: l.unlinkDevice,
                          content: Text(
                            l.unlinkConfirm(d['name']! as String),
                            style: DoayaTypography.bodyMedium,
                          ),
                          actions: [
                            GlassPillButton(
                              label: l.cancel,
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            SagePillButton(
                              label: l.confirm,
                              size: PillSize.small,
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                        if (ok != true) return;
                        try {
                          await ref
                              .read(syncProvider.notifier)
                              .client!
                              .postJson('devices/${d['id']}/unlink');
                          ref.invalidate(_devicesProvider);
                        } on Object catch (e) {
                          if (context.mounted) toast(context, syncErrorText(l, e), error: true);
                        }
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountsPanel extends ConsumerWidget {
  const _AccountsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref.watch(_accountsProvider).value ?? const [];
    final employees = ref.watch(employeesProvider).value ?? const <EmployeeRow>[];
    final byEmployee = {for (final a in accounts) a['employee_id']: a};
    return Panel(
      title: l.accountsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.accountsHelp,
            style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
          ),
          const SizedBox(height: DoayaSpacing.l),
          for (final e in employees)
            Padding(
              padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(e.name, style: DoayaTypography.label)),
                  if (byEmployee[e.id] case final a?)
                    LatinText(
                      a['phone']! as String,
                      style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                    )
                  else
                    GlassPillButton(
                      label: l.addAccount,
                      icon: DoayaIcons.add,
                      onPressed: () => _addAccount(context, ref, e),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addAccount(BuildContext context, WidgetRef ref, EmployeeRow e) async {
    final l = AppLocalizations.of(context);
    await showDoayaDialog<void>(
      context: context,
      title: '${l.addAccount}: ${e.name}',
      content: AccountForm(
        submitLabel: l.save,
        confirmPassword: true,
        onSubmit: (phone, password) async {
          try {
            await ref.read(syncProvider.notifier).client!.postJson('users', {
              'name': e.name,
              'phone': phone,
              'password': password,
              'employee_id': e.id,
            });
            ref.invalidate(_accountsProvider);
            if (context.mounted) Navigator.of(context).pop();
            return null;
          } on Object catch (err) {
            return syncErrorText(l, err);
          }
        },
      ),
    );
  }
}

final _centralLinkProvider = FutureProvider.autoDispose<Map<String, Object?>>((ref) async {
  final api = ref.watch(centralApiProvider);
  if (api == null) return const {};
  return api.linkState();
});

/// Owner: links this pharmacy to Doaya online with the key its team gave,
/// so patients see the shelf and send cases and orders.
class _CentralPanel extends ConsumerStatefulWidget {
  const _CentralPanel();

  @override
  ConsumerState<_CentralPanel> createState() => _CentralPanelState();
}

class _CentralPanelState extends ConsumerState<_CentralPanel> {
  final _url = TextEditingController();
  final _key = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _do(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(_centralLinkProvider);
      await ref.read(inboxProvider.notifier).refresh();
      if (mounted) toast(context, l.saved);
    } on Object catch (e) {
      if (mounted) toast(context, syncErrorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(_centralLinkProvider).value;
    final linked = state?['linked'] == true;
    final api = ref.watch(centralApiProvider);
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Panel(
      title: l.centralSection,
      trailing: StatusChip(
        label: linked ? l.centralLinked(ltrIsolate('${state!['url']}')) : l.centralNotLinked,
        tone: linked ? StatusTone.accent : StatusTone.neutral,
        dot: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.centralHelp, style: secondary),
          const SizedBox(height: DoayaSpacing.l),
          if (linked)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GlassPillButton(
                label: l.centralUnlink,
                onPressed: _busy || api == null ? null : () => _do(api.unlink),
              ),
            )
          else ...[
            GlassTextField(
              label: l.centralUrlLabel,
              controller: _url,
              hint: ltrIsolate(l.centralUrlHint),
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: DoayaSpacing.sm),
            GlassTextField(
              label: l.centralKeyLabel,
              controller: _key,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: DoayaSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SagePillButton(
                label: l.centralLink,
                size: PillSize.small,
                onPressed: _busy || api == null
                    ? null
                    : () => _do(() => api.link(_url.text.trim(), _key.text.trim())),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
