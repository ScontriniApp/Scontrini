import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/export/data/export_providers.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings entry "Importa dati da CSV": reads back a file written by
/// "Esporta i dati raccolti" ([PurchaseCsv]) and adds its receipts and
/// pantry lots (`CsvImporter`); a snackbar says what was added.
class ImportDataTile extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ImportDataTile> createState() => _ImportDataTileState();
}

class _ImportDataTileState extends ConsumerState<ImportDataTile> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.file_upload_outlined),
      title: Text(l10n.importTitle),
      subtitle: Text(l10n.importHint),
      trailing: _busy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      enabled: !_busy,
      onTap: _import,
    );
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = await ref.read(textFilePickerProvider)();
    if (text == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final rows = PurchaseCsv.decode(text);
      final result = await ref.read(csvImporterProvider).import(rows);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.importDone(result.receipts, result.lots, result.duplicates),
            ),
          ),
        );
    } on Object catch (error) {
      debugPrint('Import failed: $error');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
