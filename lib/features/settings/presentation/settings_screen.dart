import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/analytics/presentation/demo_data_section.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Column(
        children: [
          Expanded(
            child: PlaceholderView(
              icon: Icons.tune,
              message: l10n.settingsEmpty,
            ),
          ),
          if (kDebugMode) const SafeArea(top: false, child: DemoDataSection()),
        ],
      ),
    );
  }
}
