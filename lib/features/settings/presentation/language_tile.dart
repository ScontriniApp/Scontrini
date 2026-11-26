import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/settings/domain/app_language.dart';
import 'package:scontrini/features/settings/presentation/language_provider.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Settings row that switches the app between Italian and English. Each
/// option is written in its own language, so it can be found from either.
class LanguageTile extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.settingsLanguage),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SegmentedButton<AppLanguage>(
          segments: [
            for (final l in AppLanguage.values)
              ButtonSegment(value: l, label: Text(l.nativeName)),
          ],
          selected: {language},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              ref.read(appLanguageProvider.notifier).select(selection.single),
        ),
      ),
    );
  }
}
