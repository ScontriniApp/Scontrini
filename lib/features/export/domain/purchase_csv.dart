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

  /// Reads a file written by [encode] (or [bytes], with or without the byte
  /// order mark) back into rows. Columns are found by their header name, so
  /// a spreadsheet that reorders or adds columns still works. Throws a
  /// [FormatException] naming the line when something can't be read.
  static List<ExportRow> decode(String text) {
    final records = _records(
      text.startsWith('\uFEFF') ? text.substring(1) : text,
    );
    if (records.isEmpty) throw const FormatException('Empty file');
    final columns = {
      for (final (i, name) in records.first.indexed) name.trim(): i,
    };
    final missing = [
      for (final name in _required)
        if (!columns.containsKey(name)) name,
    ];
    if (missing.isNotEmpty) {
      throw FormatException('Missing columns: ${missing.join(', ')}');
    }
    return [
      for (final (i, fields) in records.skip(1).indexed)
        if (fields.any((f) => f.trim().isNotEmpty))
          _decodeRow(fields, columns, line: i + 2),
    ];
  }

  /// The columns [decode] needs; the others (`pagato`, a sum) are ignored.
  static const _required = [
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
    'in_dispensa',
    'stato',
    'residuo',
  ];

  static ExportRow _decodeRow(
    List<String> fields,
    Map<String, int> columns, {
    required int line,
  }) {
    String field(String name) {
      final i = columns[name]!;
      return i < fields.length ? fields[i].trim() : '';
    }

    String? optional(String name) {
      final value = field(name);
      return value.isEmpty ? null : value;
    }

    T read<T>(String name, T? Function(String) parse) {
      final value = field(name);
      final parsed = parse(value);
      if (parsed == null) {
        throw FormatException('Line $line: bad $name "$value"');
      }
      return parsed;
    }

    final inPantry = read('in_dispensa', (v) => _yesNo[v.toLowerCase()]);
    return ExportRow(
      receiptId: read('scontrino_id', int.tryParse),
      purchasedAt: read(
        'data',
        (v) => _dateTime(v, field('ora').isEmpty ? '00:00' : field('ora')),
      ),
      storeName: optional('negozio'),
      vatNumber: optional('partita_iva'),
      receiptTotalCents: read('totale_scontrino', parseEuros),
      receiptDiscountCents: read('sconto_scontrino', parseEuros),
      origin: read('origine', (v) => _origins[v.toLowerCase()]),
      rawName: read('voce', (v) => v.isEmpty ? null : v),
      productName: optional('prodotto'),
      categoryName: optional('categoria'),
      quantity: read('quantita', parseNumber),
      unit: read('unita', (v) => v.isEmpty ? null : v),
      unitPriceCents: read('prezzo_unitario', parseEuros),
      lineTotalCents: read('importo', parseEuros),
      discountCents: read('sconto', parseEuros),
      pantryState: inPantry
          ? read('stato', (v) => _states[v.toLowerCase()])
          : null,
      remaining: switch (optional('residuo')) {
        null => null,
        final v => read('residuo', (_) => parseNumber(v)),
      },
    );
  }

  static const _yesNo = {'sì': true, 'si': true, 'no': false};
  static const Map<String, ReceiptOrigin> _origins = {
    'foto': ReceiptOrigin.photo,
    'pdf': ReceiptOrigin.pdf,
    'a mano': ReceiptOrigin.manual,
  };
  static const Map<String, ExportPantryState> _states = {
    'attivo': ExportPantryState.active,
    'finito': ExportPantryState.consumed,
    'buttato': ExportPantryState.discarded,
  };

  /// [euros] read back: `1,29` → 129, `-0,40` → -40. Also takes a decimal
  /// point and a missing or one-digit decimal part (`3`, `2,5`), as a
  /// spreadsheet may write them. `null` when it isn't an amount.
  static int? parseEuros(String text) {
    final match = RegExp(r'^(-?)(\d+)(?:[,.](\d{1,2}))?$').firstMatch(text);
    if (match == null) return null;
    final cents =
        int.parse(match[2]!) * 100 +
        int.parse((match[3] ?? '0').padRight(2, '0'));
    return match[1] == '-' ? -cents : cents;
  }

  /// [number] read back: `0,5` → 0.5. `null` when it isn't a number.
  static double? parseNumber(String text) =>
      RegExp(r'^-?\d+([,.]\d+)?$').hasMatch(text)
      ? double.parse(text.replaceFirst(',', '.'))
      : null;

  /// `yyyy-MM-dd` and `HH:mm`, local time.
  static DateTime? _dateTime(String date, String time) {
    final d = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date);
    final t = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(time);
    if (d == null || t == null) return null;
    return DateTime(
      int.parse(d[1]!),
      int.parse(d[2]!),
      int.parse(d[3]!),
      int.parse(t[1]!),
      int.parse(t[2]!),
    );
  }

  /// Splits the text into records of fields: `;` between fields, `"…"`
  /// around a field holding `;`, quotes (doubled) or line breaks.
  static List<List<String>> _records(String text) {
    final records = <List<String>>[];
    var fields = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (quoted) {
        if (c != '"') {
          field.write(c);
        } else if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else if (c == '"') {
        quoted = true;
      } else if (c == ';') {
        fields.add(field.toString());
        field.clear();
      } else if (c == '\n' || c == '\r') {
        if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        fields.add(field.toString());
        field.clear();
        records.add(fields);
        fields = <String>[];
      } else {
        field.write(c);
      }
    }
    if (field.isNotEmpty || fields.isNotEmpty) {
      fields.add(field.toString());
      records.add(fields);
    }
    return records;
  }

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
