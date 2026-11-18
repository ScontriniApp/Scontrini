import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class AnalyticsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAnalytics)),
      body: PlaceholderView(
        icon: Icons.insert_chart_outlined,
        message: l10n.analyticsEmpty,
      ),
    );
  }
}
