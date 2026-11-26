import 'package:scontrini/l10n/app_localizations.dart';

/// The name to show for the category stored as [name]. The built-in
/// categories are seeded in Italian (`defaultCategories`) and keep that
/// name in the database, where it also keys their sprite; this gives
/// their name in the app's language. Any other name is shown as stored.
String categoryLabel(AppLocalizations l10n, String name) => switch (name) {
  'Frutta e verdura' => l10n.categoryFruitVegetables,
  'Carne e pesce' => l10n.categoryMeatFish,
  'Latticini e uova' => l10n.categoryDairyEggs,
  'Pane e pasta' => l10n.categoryBreadPasta,
  'Bevande' => l10n.categoryDrinks,
  'Dispensa' => l10n.categoryPantry,
  'Surgelati' => l10n.categoryFrozen,
  'Casa e igiene' => l10n.categoryHousehold,
  'Altro' => l10n.categoryOther,
  _ => name,
};
