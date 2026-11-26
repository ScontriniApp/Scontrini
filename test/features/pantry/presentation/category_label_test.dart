import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/default_categories.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

void main() {
  final it = lookupAppLocalizations(const Locale('it'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('every seeded category has an English name', () {
    for (final seed in defaultCategories) {
      expect(categoryLabel(it, seed.name), seed.name, reason: seed.name);
      expect(
        categoryLabel(en, seed.name),
        isNot(seed.name),
        reason: '${seed.name} has no English name in categoryLabel',
      );
    }
    expect(categoryLabel(en, 'Pane e pasta'), 'Bread and pasta');
  });

  test('a category the user named is shown as stored', () {
    expect(categoryLabel(en, 'Cibo per gatti'), 'Cibo per gatti');
  });
}
