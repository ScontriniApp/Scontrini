import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/product_matcher.dart';

void main() {
  test('normalise ignores case, accents, spacing and word punctuation', () {
    expect(ProductMatcher.normalise('Latte intero'), 'LATTE INTERO');
    expect(ProductMatcher.normalise('  LATTE   INTERO. '), 'LATTE INTERO');
    expect(ProductMatcher.normalise("Caffè d'orzo"), 'CAFFE D ORZO');
    expect(ProductMatcher.normalise('POM. 500G'), 'POM 500G');
    expect(ProductMatcher.normalise('MOZZ.LATTE 1,5L'), 'MOZZ LATTE 1,5L');
    expect(ProductMatcher.normalise('--- '), isEmpty);
  });

  ProductMatcher matcher() => ProductMatcher(
    products: const [
      MatchableProduct(id: 1, canonicalName: 'LATTE INTERO'),
      MatchableProduct(id: 2, canonicalName: 'Uova'),
      MatchableProduct(id: 3, canonicalName: 'COCA COLA 1,5L'),
    ],
    aliases: const {'LATTE PS': 1, 'UNKNOWN PRODUCT': 99},
  );

  test('the same label matches, whatever the case and spacing', () {
    final m = matcher();
    expect(m.match('  latte   intero '), 1);
    expect(m.match('UOVA'), 2);
    expect(m.match('coca cola 1,5l'), 3);
  });

  test('an alias matches its product', () {
    expect(matcher().match('LATTE PS'), 1);
  });

  test('a different label never matches, however close', () {
    final m = matcher();
    expect(m.match('LATTE INTERA'), isNull);
    expect(m.match('LATTE INTERO BIO'), isNull);
    expect(m.match('COCA COLA 1.5L'), isNull);
    expect(m.match('COCA COLA 2L'), isNull);
    expect(m.match(''), isNull);
  });

  test('added products and aliases match from then on', () {
    final m = ProductMatcher()
      ..add(const MatchableProduct(id: 7, canonicalName: 'PANE'))
      ..addAlias('PANE CASERECCIO', 7);
    expect(m.match('pane'), 7);
    expect(m.match('PANE CASERECCIO'), 7);
  });

  test('an alias of an unknown product is ignored', () {
    expect(matcher().match('UNKNOWN PRODUCT'), isNull);
  });
}
