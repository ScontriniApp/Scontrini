import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/analytics/data/demo_history_seed.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings section that loads or removes the demo history, so the analytics
/// screens can be tried on a phone. Shown in debug builds only.
class DemoDataSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.watch(appDatabaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            l10n.demoDataTitle,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.science_outlined),
          title: Text(l10n.demoDataLoad),
          subtitle: Text(l10n.demoDataLoadHint),
          onTap: () async {
            final result = await seedDemoHistory(db, today: DateTime.now());
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.demoDataLoaded(result.confirmed))),
              );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text(l10n.demoDataRemove),
          onTap: () async {
            await removeDemoHistory(db);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.demoDataRemoved)));
          },
        ),
      ],
    );
  }
}
