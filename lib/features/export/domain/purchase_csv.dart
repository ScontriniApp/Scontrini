import 'dart:convert';
import 'dart:typed_data';

/// Where a receipt came from.
enum ReceiptOrigin { photo, pdf, manual }

/// What happened to a bought item in the pantry.
enum ExportPantryState { active, consumed, discarded }

/// One bought item, with its receipt and its pantry state: one row of the
/// export (see [PurchaseCsv]).
class ExportRow {
  const new({
    required this.receiptId,
    required this.purchasedAt,
    required this.receiptTotalCents,
    required this.receiptDiscountCents,
    required this.origin,
    required this.rawName,
    required this.quantity,
    required this.unit,
    required this.unitPriceCents,
    required this.lineTotalCents,
    required this.discountCents,
    this.storeName,
    this.vatNumber,
    this.productName,
    this.categoryName,
    this.pantryState,
    this.remaining,
  });

  final int receiptId;

  /// Local time.
  final DateTime purchasedAt;
  final String? storeName;
  final String? vatNumber;
  final int receiptTotalCents;
  final int receiptDiscountCents;
  final ReceiptOrigin origin;

  /// As printed (or typed).
  final String rawName;

  /// The canonical product the statistics group by.
  final String? productName;
  final String? categoryName;
  final double quantity;
  final String unit;
  final int unitPriceCents;
  final int lineTotalCents;
  final int discountCents;

  /// `null`: never put in the pantry.
  final ExportPantryState? pantryState;

  /// What is left of the item's pantry lot. `null` when it was never put
  /// in the pantry, or on the other rows of a lot several rows share (the
  /// same product printed twice on one receipt), so summing never counts a
  /// lot twice.
  final double? remaining;

  int get paidCents => lineTotalCents - discountCents;
}

/// The export file: one row per bought item, with its receipt's fields
/// repeated on every row and its pantry state, so a spreadsheet or pandas
/// can filter and pivot without joins.
///
/// Laid out for Italian Excel, which opens it with a double click: `;`
/// between fields, decimal comma, UTF-8 with a byte order mark. pandas:
/// `read_csv(path, sep=';', decimal=',')`. Amounts are euros with two
/// decimals; dates are `yyyy-MM-dd`, times `HH:mm`, local.
abstract final class PurchaseCsv {
  static const header = [
    'scontrino_id',
    'data',
    'ora',
    'negozio',
    'partita_iva',
    'totale_scontrino',
    'sconto_scontrino',
    'origine',
    'voce',
    'prodotto',
    'categoria',
    'quantita',
    'unita',
    'prezzo_unitario',
    'importo',
    'sconto',
    'pagato',
    'in_dispensa',
    'stato',
    'residuo',
  ];

  /// The file's text, header first, `\r\n` line ends (what Excel writes).
  static String encode(Iterable<ExportRow> rows) {
    final out = StringBuffer()..write(_line(header));
    for (final r in rows) {
      out.write(
        _line([
          '${r.receiptId}',
          _date(r.purchasedAt),
          _time(r.purchasedAt),
          r.storeName ?? '',
          r.vatNumber ?? '',
          euros(r.receiptTotalCents),
          euros(r.receiptDiscountCents),
          switch (r.origin) {
            ReceiptOrigin.photo => 'foto',
            ReceiptOrigin.pdf => 'PDF',
            ReceiptOrigin.manual => 'a mano',
          },
          r.rawName,
          r.productName ?? '',
          r.categoryName ?? '',
          number(r.quantity),
          r.unit,
          euros(r.unitPriceCents),
          euros(r.lineTotalCents),
          euros(r.discountCents),
          euros(r.paidCents),
          if (r.pantryState == null) 'no' else 'sì',
          switch (r.pantryState) {
            null => '',
            ExportPantryState.active => 'attivo',
            ExportPantryState.consumed => 'finito',
            ExportPantryState.discarded => 'buttato',
          },
          if (r.remaining case final left?) number(left) else '',
        ]),
      );
    }
    return out.toString();
  }

  /// [encode] as UTF-8 with a byte order mark, so Excel reads the accents.
  static Uint8List bytes(Iterable<ExportRow> rows) =>
      Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(encode(rows))]);

  /// `1,29`, `-0,40`: euros with a decimal comma, no symbol.
  static String euros(int cents) {
    final sign = cents < 0 ? '-' : '';
    final abs = cents.abs();
    return '$sign${abs ~/ 100},${(abs % 100).toString().padLeft(2, '0')}';
  }

  /// `1`, `0,5`, `1,255`: up to three decimals, decimal comma.
  static String number(double value) {
    final text = value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
    return text.replaceFirst('.', ',');
  }

  static String _date(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${_two(t.month)}-${_two(t.day)}';

  static String _time(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _line(List<String> fields) =>
      '${fields.map(_field).join(';')}\r\n';

  /// Quoted when it holds a separator, a quote or a line break.
  static String _field(String value) => value.contains(RegExp('[;"\r\n]'))
      ? '"${value.replaceAll('"', '""')}"'
      : value;
}
