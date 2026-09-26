import 'dart:io';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/backup_controller.dart';
import '../../data/device_backup.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/sync_controller.dart';
import '../format.dart';
import '../widgets.dart';

/// Settings (owner): this device's daily backups: the folder, the last
/// copy, "back up now", and restoring an earlier copy.
class BackupPanel extends ConsumerStatefulWidget {
  const BackupPanel({super.key});

  @override
  ConsumerState<BackupPanel> createState() => _BackupPanelState();
}

class _BackupPanelState extends ConsumerState<BackupPanel> {
  final _folder = TextEditingController();
  var _folderShown = false;

  @override
  void initState() {
    super.initState();
    Future(() => ref.read(backupProvider.notifier).refresh()).catchError((Object _) {});
  }

  @override
  void dispose() {
    _folder.dispose();
    super.dispose();
  }

  /// The date a backup file was made, from its name (doaya-20260925-143000).
  static DateTime? _dateOf(File f) {
    final m = RegExp(r'doaya-(\d{4})(\d\d)(\d\d)-(\d\d)(\d\d)').firstMatch(f.path);
    if (m == null) return null;
    final p = [for (var i = 1; i <= 5; i++) int.parse(m.group(i)!)];
    return DateTime(p[0], p[1], p[2], p[3], p[4]);
  }

  static String _when(DateTime t) => '${formatDate(t)}، ${formatTime(t)}';

  Future<void> _restore(File file) async {
    final l = AppLocalizations.of(context);
    final when = _dateOf(file);
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.restoreButton,
      content: Text(
        l.restoreConfirm(when == null ? file.path : _when(when)),
        style: DoayaTypography.bodyMedium,
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(
          label: l.confirm,
          size: PillSize.small,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (ok != true) return;
    await DeviceBackup.scheduleRestore((await getApplicationSupportDirectory()).path, file);
    if (!mounted) return;
    await showDoayaDialog<void>(
      context: context,
      title: l.restoreButton,
      content: Text(l.restoreRestart, style: DoayaTypography.bodyMedium),
      actions: [
        SagePillButton(
          label: l.close,
          size: PillSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(backupProvider);
    final linked = ref.watch(syncProvider).linked;
    if (!_folderShown && s.folder != null) {
      _folderShown = true;
      _folder.text = s.folder!;
    }
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final controller = ref.read(backupProvider.notifier);

    return Panel(
      title: l.backupSection,
      trailing: SagePillButton(
        label: s.busy ? l.backingUp : l.backupNow,
        icon: DoayaIcons.receive,
        size: PillSize.small,
        onPressed: s.busy
            ? null
            : () async {
                await controller.backupNow();
                if (context.mounted && ref.read(backupProvider).error == null) {
                  toast(context, l.backupDone);
                }
              },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.backupHelp, style: secondary),
          SizedBox(height: DoayaSpacing.sm),
          Text(
            s.last == null ? l.backupNone : l.backupLast(_when(s.last!)),
            style: DoayaTypography.label.copyWith(
              color: s.last == null ? DoayaColors.warningText : DoayaColors.textPrimary,
            ),
          ),
          if (s.error != null) ...[
            SizedBox(height: DoayaSpacing.sm),
            NoticeBanner(message: l.backupFailed, tone: StatusTone.warning),
          ],
          SizedBox(height: DoayaSpacing.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassTextField(
                  label: l.backupFolderLabel,
                  controller: _folder,
                  textDirection: TextDirection.ltr,
                ),
              ),
              SizedBox(width: DoayaSpacing.sm),
              GlassPillButton(
                label: l.saveFolder,
                onPressed: s.busy
                    ? null
                    : () {
                        if (_folder.text.trim().isNotEmpty) controller.setFolder(_folder.text);
                      },
              ),
            ],
          ),
          if (s.files.isNotEmpty) ...[
            SizedBox(height: DoayaSpacing.l),
            if (linked) ...[
              Text(l.restoreLinkedNote, style: secondary),
              SizedBox(height: DoayaSpacing.sm),
            ],
            for (final f in s.files.take(5))
              Padding(
                padding: EdgeInsets.only(bottom: DoayaSpacing.s),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(switch (_dateOf(f)) {
                        final t? => _when(t),
                        null => f.uri.pathSegments.last,
                      }, style: DoayaTypography.bodySmall),
                    ),
                    if (!linked)
                      GlassPillButton(label: l.restoreButton, onPressed: () => _restore(f)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
