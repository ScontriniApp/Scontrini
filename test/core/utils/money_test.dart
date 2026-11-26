import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/utils/money.dart';

void main() {
  group('Money.parseCents', () {
    test('parses Italian decimal comma', () {
      expect(Money.parseCents('1,29'), 129);
    });

    test('parses decimal point', () {
      expect(Money.parseCents('1.29'), 129);
    });

    test('parses thousands separator', () {
      expect(Money.parseCents('1.234,56'), 123456);
    });

    test('parses discounts with leading or trailing minus', () {
      expect(Money.parseCents('-0,50'), -50);
      expect(Money.parseCents('0,50-'), -50);
    });

    test('parses whole euros and euro sign', () {
      expect(Money.parseCents('12'), 1200);
      expect(Money.parseCents('€ 3,5'), 350);
    });

    test('rejects text that is not an amount', () {
      expect(Money.parseCents(''), isNull);
      expect(Money.parseCents('TOTALE'), isNull);
      expect(Money.parseCents('1,2,3'), isNull);
    });
  });

  test('Money.format uses Italian euro format', () {
    expect(Money.format(123456), contains('1.234,56'));
    expect(Money.format(123456), contains('€'));
  });

  group('Money in English', () {
    setUp(() => Money.locale = 'en');
    tearDown(() => Money.locale = 'it');

    test('formats with the euro sign first and a decimal point', () {
      expect(Money.format(123456), '€1,234.56');
    });

    test('edit text reads back in either language', () {
      expect(Money.inputText(129), '1.29');
      expect(Money.parseCents(Money.inputText(123456)), 123456);
      Money.locale = 'it';
      expect(Money.inputText(129), '1,29');
      expect(Money.parseCents(Money.inputText(123456)), 123456);
    });
  });
}
