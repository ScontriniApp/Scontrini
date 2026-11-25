import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/export/data/export_providers.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings entry "Esporta i dati raccolti": every bought item of the
/// confirmed receipts in one CSV file ([PurchaseCsv]), saved where the user
/// picks after a warning that the file isn't encrypted.
class ExportDataTile extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ExportDataTile> createState() => _ExportDataTileState();
}

class _ExportDataTileState extends ConsumerState<ExportDataTile> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(receiptHistoryProvider).value ?? const [];
    final items = history.fold(0, (sum, r) => sum + r.itemCount);

    return ListTile(
      leading: const Icon(Icons.file_download_outlined),
      title: Text(l10n.exportTitle),
      subtitle: Text(
        history.isEmpty
            ? l10n.exportNothing
            : l10n.exportSummary(history.length, items),
      ),
      trailing: _busy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      enabled: !_busy && history.isNotEmpty,
      onTap: _export,
    );
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportTitle),
        content: Text(l10n.exportWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.exportConfirm),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final rows = await ref.read(exportRepositoryProvider).rows();
      if (rows.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.exportNothing)));
        return;
      }
      final today = ref.read(clockProvider)();
      final fileName =
          'scontrini_${today.year}-${_two(today.month)}-${_two(today.day)}.csv';
      final saved = await ref.read(fileSaverProvider)(
        fileName: fileName,
        bytes: PurchaseCsv.bytes(rows),
        mimeType: 'text/csv',
      );
      if (saved) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.exportDone(rows.length, fileName))),
          );
      }
    } on Object catch (error) {
      debugPrint('Export failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
