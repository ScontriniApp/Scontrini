import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/capture/data/capture_providers.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings tile (debug builds only): picks several PDFs and saves them
/// all as confirmed receipts, without review and without the pantry. A
/// dialog shows the progress; a snackbar the outcome.
class BulkImportTile extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.upload_file_outlined),
      title: Text(l10n.bulkImportTitle),
      subtitle: Text(l10n.bulkImportHint),
      onTap: () => _import(context, ref),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final sources = await ref.read(receiptCaptureServiceProvider).pickPdfs();
    if (sources.isEmpty || !context.mounted) return;

    final progress = ValueNotifier((done: 0, total: sources.length));
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: ValueListenableBuilder(
            valueListenable: progress,
            builder: (context, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.bulkImportProgress(value.done, value.total)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: value.done / value.total),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      final result = await ref
          .read(bulkReceiptImporterProvider)
          .import(
            sources,
            onProgress: (done, total) =>
                progress.value = (done: done, total: total),
          );
      for (final path in result.failed) {
        debugPrint('Bulk import: could not import $path');
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.bulkImportDone(
                result.saved,
                result.duplicates,
                result.failed.length,
              ),
            ),
          ),
        );
    } finally {
      navigator.pop();
      progress.dispose();
    }
  }
}
