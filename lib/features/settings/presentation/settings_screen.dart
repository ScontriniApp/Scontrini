import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/analytics/presentation/demo_data_section.dart';
import 'package:scontrini/features/export/presentation/export_data_tile.dart';
import 'package:scontrini/features/export/presentation/import_data_tile.dart';
import 'package:scontrini/features/pantry_lab/presentation/pantry_lab_screen.dart';
import 'package:scontrini/features/plastic_lab/presentation/plastic_lab_screen.dart';
import 'package:scontrini/features/settings/presentation/language_tile.dart';
import 'package:scontrini/features/settings/presentation/section_colors_tile.dart';
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
          LanguageTile(),
          SectionColorsTile(),
          ExportDataTile(),
          ImportDataTile(),
          // Receipt paper shader tuning, debug builds only.
          if (kDebugMode) ShaderLabTile(),
          // Plastic shelf-label shader tuning, debug builds only.
          if (kDebugMode) PlasticLabTile(),
          // Pantry drawer shader tuning, debug builds only.
          if (kDebugMode) PantryLabTile(),
          // Demo purchase history, debug builds only.
          if (kDebugMode) SafeArea(top: false, child: DemoDataSection()),
        ],
      ),
    );
  }
}
