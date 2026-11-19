import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';

final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => PantryRepository(ref.watch(appDatabaseProvider)),
);
