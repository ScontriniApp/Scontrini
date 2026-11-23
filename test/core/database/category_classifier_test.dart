import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/category_classifier.dart';
import 'package:scontrini/core/database/default_categories.dart';

final _seed = CategoryClassifier<String>({
  for (final c in defaultCategories)
    for (final k in c.keywords) k: c.name,
});

void main() {
  test('every seed keyword is in one category only', () {
    final seen = <String, String>{};
    final duplicates = <String>[];
    for (final c in defaultCategories) {
      for (final k in c.keywords) {
        final key = k.trim().toUpperCase();
        if (seen.containsKey(key)) {
          duplicates.add('$key: ${seen[key]}, ${c.name}');
        }
        seen[key] = c.name;
      }
    }
    expect(duplicates, isEmpty);
  });

  test('a keyword matches at the start of a word, as a stem', () {
    final c = CategoryClassifier({'MOZZ': 'dairy', 'SALE': 'pantry'});
    expect(c.classify('MOZZ.TRIS SANTA LUCI'), 'dairy');
    expect(c.classify('Mozzarella 125g'), 'dairy');
    expect(c.classify('BUFALA MOZZ'), 'dairy');
    expect(c.classify('SALE IODATO'), 'pantry');
    expect(c.classify('INSALATA'), isNull); // SALE inside a word
    expect(c.classify('ACQUA'), isNull);
  });

  test('the keyword that comes first in the name wins', () {
    final c = CategoryClassifier({
      'POLLO': 'meat',
      'FETTE': 'bread',
      'PANIN': 'bread',
      'LATTE': 'dairy',
    });
    expect(c.classify('PETTO DI POLLO A FETTE'), 'meat');
    expect(c.classify('PANINI AL LATTE'), 'bread');
  });

  test('at the same position the longer keyword wins', () {
    final c = CategoryClassifier({
      'PATAT': 'vegetables',
      'PATATINE DA FORNO': 'frozen',
    });
    expect(c.classify('PATATINE DA FORNO'), 'frozen');
    expect(c.classify('PATATE NOVELLE'), 'vegetables');
  });

  test('seed: names as receipts print them', () {
    final expected = {
      'MOZZ.TRIS SANTA LUCI': 'Latticini e uova',
      'PARMIG.REGG. 100g': 'Latticini e uova',
      '6 UOVA PASTA GIALLA': 'Pane e pasta',
      'PANINI AL LATTE C/GO': 'Pane e pasta',
      'PETTO DI POLLO A FETTE 500G': 'Carne e pesce',
      'VIT. FETTINE SOTTILI': 'Carne e pesce',
      'POLPA DI POMODORO 34': 'Dispensa',
      'POMODORINO GRAPPOLO': 'Frutta e verdura',
      'FAGIOLINI': 'Frutta e verdura',
      'BONDUELLE BORLOTTI': 'Dispensa',
      'PATATINE DA FORNO': 'Surgelati',
      'ACQUA NATURALE 1,5L': 'Bevande',
      'DET. PIATTI ESS. LIMO': 'Casa e igiene',
      'SAC COMPOSTABILE': 'Altro',
      'SALSA SOIA KIKKOMAN': 'Dispensa',
    };
    expect({
      for (final name in expected.keys) name: _seed.classify(name),
    }, expected);
  });
}
