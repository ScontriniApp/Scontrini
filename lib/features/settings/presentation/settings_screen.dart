import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/analytics/presentation/demo_data_section.dart';
import 'package:scontrini/features/export/presentation/export_data_tile.dart';
import 'package:scontrini/features/receipts/presentation/bulk_import_tile.dart';
import 'package:scontrini/features/shader_lab/presentation/shader_lab_screen.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: const [
          ExportDataTile(),
          // Many PDFs at once, no review, no pantry; debug builds only.
          if (kDebugMode) BulkImportTile(),
          // Receipt paper shader tuning, debug builds only.
          if (kDebugMode) ShaderLabTile(),
          // Demo purchase history, debug builds only.
          if (kDebugMode) SafeArea(top: false, child: DemoDataSection()),
        ],
      ),
    );
  }
}
