import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/connection.dart';
import 'package:scontrini/core/database/database_key_store.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/plastic/plastic_settings.dart';
import 'package:scontrini/core/section_colors/section_colors_provider.dart';
import 'package:scontrini/core/section_colors/section_colors_store.dart';
import 'package:scontrini/features/settings/data/language_store.dart';
import 'package:scontrini/features/settings/presentation/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final key = await DatabaseKeyStore().readOrCreate();
  final database = AppDatabase(openEncryptedConnection(key));
  final languages = await PreferencesLanguageStore.open();
  final sectionColors = await PreferencesSectionColorsStore.open();
  final paper = await openPaperSettingsFile()
    ..flushOnPause();
  final plastic = await openPlasticSettingsFile()
    ..flushOnPause();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        languageStoreProvider.overrideWithValue(languages),
        sectionColorsStoreProvider.overrideWithValue(sectionColors),
        paperSettingsStoreProvider.overrideWithValue(paper),
        plasticSettingsStoreProvider.overrideWithValue(plastic),
      ],
      child: const ScontriniApp(),
    ),
  );
}
