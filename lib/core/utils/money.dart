import 'package:intl/intl.dart';

/// Money is always stored as integer cents to avoid floating-point errors.
abstract final class Money {
  static final NumberFormat _euro = NumberFormat.currency(
    locale: 'it_IT',
    symbol: '€',
  );

  /// Formats cents as an Italian euro string, e.g. `1234` → `12,34 €`.
  static String format(int cents) => _euro.format(cents / 100);

  /// Parses an amount as printed on an Italian receipt into cents.
  ///
  /// Accepts `1,29`, `1.29`, `-0,50`, `1.234,56` and `12`. Returns `null`
  /// when the text is not a valid amount.
  static int? parseCents(String text) {
    var s = text.replaceAll(RegExp(r'[€\s]'), '');
    if (s.isEmpty) return null;

    final negative = s.startsWith('-') || s.endsWith('-');
    s = s.replaceAll('-', '');

    final match = RegExp(r'^(\d{1,3}(?:[.,]\d{3})*|\d+)(?:[.,](\d{1,2}))?$')
        .firstMatch(s);
    if (match == null) return null;

    final whole = int.parse(match.group(1)!.replaceAll(RegExp('[.,]'), ''));
    final fraction = (match.group(2) ?? '0').padRight(2, '0');
    final cents = whole * 100 + int.parse(fraction);
    return negative ? -cents : cents;
  }
}
