import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/connection.dart';
import 'package:scontrini/core/database/database_key_store.dart';
import 'package:scontrini/core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final key = await DatabaseKeyStore().readOrCreate();
  final database = AppDatabase(openEncryptedConnection(key));

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const ScontriniApp(),
    ),
  );
}
