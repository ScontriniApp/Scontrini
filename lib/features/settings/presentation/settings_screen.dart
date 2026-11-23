import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/analytics/presentation/demo_data_section.dart';
import 'package:scontrini/features/extraction/data/model_downloader.dart';
import 'package:scontrini/features/extraction/presentation/glm_ocr_model_controller.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            dense: true,
            title: Text(
              l10n.settingsPhotoReading,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const GlmOcrModelTile(),
          // Demo purchase history, debug builds only.
          if (kDebugMode) const SafeArea(top: false, child: DemoDataSection()),
        ],
      ),
    );
  }
}

/// GLM-OCR's model: download (with progress and cancel), or delete.
class GlmOcrModelTile extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(glmOcrModelProvider);
    final controller = ref.read(glmOcrModelProvider.notifier);
    String size(int bytes) => formatBytes(bytes, context);

    final (subtitle, action) = switch (state) {
      GlmOcrModelChecking() => (Text(l10n.glmOcrModelChecking), null),
      GlmOcrModelMissing(:final downloaded, :final total) => (
        Text(
          downloaded > 0
              ? l10n.glmOcrModelPartial(size(downloaded), size(total))
              : l10n.glmOcrModelMissing(size(total)),
        ),
        FilledButton(
          onPressed: () => _confirmDownload(context, ref, total),
          child: Text(downloaded > 0 ? l10n.glmOcrResume : l10n.glmOcrDownload),
        ),
      ),
      GlmOcrModelFailed(:final error, :final downloaded, :final total) => (
        Text(switch (error) {
          ModelDownloadError.network => l10n.glmOcrErrorNetwork,
          ModelDownloadError.corrupt => l10n.glmOcrErrorCorrupt,
          ModelDownloadError.storage => l10n.glmOcrErrorStorage,
        }, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        FilledButton(
          onPressed: controller.download,
          child: Text(downloaded > 0 ? l10n.glmOcrResume : l10n.retry),
        ),
      ),
      GlmOcrModelDownloading(:final received, :final total) => (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.glmOcrModelDownloading(size(received), size(total))),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? null : received / total,
            ),
          ],
        ),
        TextButton(onPressed: controller.cancel, child: Text(l10n.cancel)),
      ),
      GlmOcrModelInstalled(:final bytes) => (
        Text(l10n.glmOcrModelInstalled(size(bytes))),
        TextButton(
          onPressed: () => _confirmDelete(context, ref, bytes),
          child: Text(l10n.delete),
        ),
      ),
    };

    return ListTile(
      leading: const Icon(Icons.document_scanner_outlined),
      title: Text(l10n.glmOcrModelTitle),
      subtitle: subtitle,
      trailing: action,
      isThreeLine: true,
    );
  }

  Future<void> _confirmDownload(
    BuildContext context,
    WidgetRef ref,
    int total,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      context,
      title: l10n.glmOcrDownloadConfirmTitle,
      body: l10n.glmOcrDownloadConfirmBody(formatBytes(total, context)),
      action: l10n.glmOcrDownload,
    );
    if (ok) await ref.read(glmOcrModelProvider.notifier).download();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int bytes,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      context,
      title: l10n.glmOcrDeleteConfirmTitle,
      body: l10n.glmOcrDeleteConfirmBody(formatBytes(bytes, context)),
      action: l10n.delete,
    );
    if (ok) await ref.read(glmOcrModelProvider.notifier).delete();
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;
}

/// "950 MB", "1,4 GB" (decimal units, as phones show storage).
String formatBytes(int bytes, BuildContext context) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (bytes >= 1000 * 1000 * 1000) {
    return '${NumberFormat('0.0', locale).format(bytes / 1e9)} GB';
  }
  return '${NumberFormat('0', locale).format(bytes / 1e6)} MB';
}
