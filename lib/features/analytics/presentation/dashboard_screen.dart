import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: PlaceholderView(
        icon: Icons.receipt_long_outlined,
        message: l10n.dashboardEmpty,
      ),
    );
  }
}
