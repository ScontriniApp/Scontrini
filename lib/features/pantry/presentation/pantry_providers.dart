import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';

/// Lots still in the pantry.
final pantryActiveLotsProvider = StreamProvider<List<PantryLot>>(
  (ref) => ref.watch(pantryRepositoryProvider).watchLots(),
);

/// Every lot, finished and thrown away included.
final pantryAllLotsProvider = StreamProvider<List<PantryLot>>(
  (ref) => ref.watch(pantryRepositoryProvider).watchLots(includeClosed: true),
);

final pantryCategoriesProvider = StreamProvider<List<PantryCategory>>(
  (ref) => ref.watch(pantryRepositoryProvider).watchCategories(),
);
