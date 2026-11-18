import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class InsightsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navInsights)),
      body: PlaceholderView(
        icon: Icons.tips_and_updates_outlined,
        message: l10n.insightsEmpty,
      ),
    );
  }
}
