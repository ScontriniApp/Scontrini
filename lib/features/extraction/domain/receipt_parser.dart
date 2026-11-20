import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

/// Turns the text of an Italian receipt ("documento commerciale") into a
/// [ParsedReceipt].
///
/// The receipt is read top to bottom in three sections:
/// - header: store name, address, VAT number, up to the first priced row
///   (or a "DOCUMENTO COMMERCIALE" / "DESCRIZIONE" marker);
/// - items: product rows, quantity rows (`2 X 0,89`, `0,456 KG X 1,99 /KG`)
///   and discounts, up to the `TOTALE` row;
/// - footer: payment details, ignored except for the date.
///
/// It never throws: whatever it cannot read ends up in
/// [ParsedReceipt.warnings] or [ParsedReceipt.unparsedLines] for the review
/// screen.
class ReceiptParser {
  const new({this.rowBuilder = const RowBuilder()});

  final RowBuilder rowBuilder;

  ParsedReceipt parse(OcrDocument document) =>
      parseLines([for (final row in rowBuilder.build(document)) row.text]);

  /// Parses rows of text, one printed row per entry.
  ParsedReceipt parseLines(List<String> lines) => _Parse().run(lines);
}

// An amount as printed: 1,29 · 1.29 · -0,50 · 0,50- · 1.234,56.
const _amount = r'(?<![\d.,])-?\d+(?:[.,]\d{3})*[.,]\d{2}-?(?!\d)';

// VAT rate or code printed next to a price: 4% · 10% · 22 % · A · B · VI · *.
const _vatCode = r'(?:\d{1,2}(?:,\d{1,2})?\s?%|[A-Z]{1,2}\d?|\*)';

final _amountRe = RegExp(_amount);

// A VAT rate printed after the price as a plain number, without `%`
// (Carrefour: `LATTE 1,85 04,00`, `2 X 0,65 04,00`). Group 1 is the row
// without it; group 2 the rate.
final _trailingRateRe = RegExp(r'^(.*\d[.,]\d{2}-?)\s+(0?\d{1,2})[.,]00\s*%?$');
const _vatRates = {4, 5, 10, 22};

// Column heading announcing a VAT column: `PREZZO %IVA`, `% IVA`.
final _vatColumnRe = RegExp(r'%\s*IVA\b');
final _onlyAmountRe = RegExp('^($_amount)(?:\\s*$_vatCode)?\$');

final _itemRe = RegExp(
  r'^(?<name>.*?[A-Z].*?)\s+'
  r'(?:\d{1,2}(?:,\d{1,2})?\s?%\s+)?' // VAT column before the price
  '(?<price>$_amount)'
  '(?:\\s*$_vatCode)?\$',
);

final _quantityRe = RegExp(
  r'^(?<qty>\d+(?:[.,]\d{1,3})?)\s*(?<unit>KG|L|PZ)?\s*[X*]\s*'
  '(?<unitPrice>$_amount)'
  r'(?:\s*/?\s*(?<perUnit>KG|L|PZ)\b)?'
  '(?:\\s*=?\\s*(?<total>$_amount))?'
  '(?:\\s*$_vatCode)?\$',
);

final _totalRe = RegExp(r'^T[O0]TALE\b(?!\s+(?:IVA|ARTICOLI|PEZZI|PZ)\b)');
final _subtotalRe = RegExp(r'^SUB\s?-?\s?T[O0]TALE');

// Summary of the discounts already printed under each item (`Totale Sconti
// Ottenuti -3,92`): neither the total nor another discount.
final _discountSummaryRe = RegExp(
  r'^T[O0]TALE\s+(?:SCONT|RISPARMI)|^(?:HAI\s+)?RISPARMIAT',
);
final _discountRe = RegExp(
  r'\b(?:SCONTO|SC\.|OFFERTA|PROMO|RIDUZIONE|BUONO|COUPON)',
);
final _sectionStartRe = RegExp('DOCUMENTO COMMERCIALE|^DESCRIZIONE');
final _skipRe = RegExp(
  r'DOCUMENTO COMMERCIALE|VENDITA O PRESTAZIONE|^DESCRIZIONE|^IVA\b|'
  r'^PREZZO|^EURO$|^CASSA\b|^OPERATORE\b',
);
final _letterRe = RegExp('[A-Z]');

// P.IVA · P. IVA · P.I.V.A. · P.I. · PARTITA IVA, then 11 digits (OCR may
// space them out).
final _vatNumberRe = RegExp(
  r'(?:\bP\.?\s*I\.?\s*V\.?\s*A\b\.?|\bP\.\s*I\.|PARTITA\s+I\.?V\.?A\.?)'
  r'\s*[:.]?\s*(?:IT\s*)?(\d[\d ]{9,14}\d)',
);
final _addressRe = RegExp(
  r'^(?:VIA|V\.LE|VIALE|PIAZZA|P\.ZZA|P\.ZA|PZA|CORSO|C\.SO|LARGO|STRADA|'
  r'LOC\.|LOCALITA)\s',
);
final _postcodeRe = RegExp(r'^\d{5}\s*-?\s*[A-Z]');

// A town on its own row under the address (`VIA ROMA 12` / `MILANO`).
final _townRe = RegExp(r"^[A-Z][A-Z' ]{1,30}$");
final _phoneRe = RegExp(r'\bTEL\b|TELEFONO');
final _dateRe = RegExp(
  r'(?<!\d)(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{4}|\d{2})(?!\d)'
  // Optional time on the same row: 18:42 · ORE 18.42 · ORA: 11: 17.
  r'(?:\s*(?:ORE|ORA|H)?\s*:?\s+(\d{1,2})\s?[:.]\s?(\d{2})(?!\d))?',
);

/// Uppercases, drops the euro sign, joins amounts that OCR split
/// (`1 ,29`, `1, 29`) and collapses whitespace.
String _normalize(String row) => row
    .toUpperCase()
    .replaceAll('€', ' ')
    .replaceAllMapped(
      RegExp(r'(\d)\s*([.,])\s+(\d{2})(?!\d)'),
      (m) => '${m[1]}${m[2]}${m[3]}',
    )
    .replaceAllMapped(
      RegExp(r'(\d)\s+([.,])(\d{2})(?!\d)'),
      (m) => '${m[1]}${m[2]}${m[3]}',
    )
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

enum _Section { header, items, footer }

class _Quantity {
  new(this.raw, this.quantity, this.unit, this.unitPriceCents);

  final String raw;
  final double quantity;
  final QuantityUnit unit;
  final int unitPriceCents;

  int get computedTotalCents => (quantity * unitPriceCents).round();

  /// Allows 1 cent of rounding on weighed items.
  bool fits(int lineTotalCents) =>
      (computedTotalCents - lineTotalCents).abs() <= 1;
}

class _ItemDraft {
  new(this.rawName, this.lineTotalCents);

  final String rawName;
  final int lineTotalCents;
  _Quantity? quantity;
  int discountCents = 0;

  ParsedItem build() {
    final q = quantity;
    return ParsedItem(
      rawName: rawName,
      lineTotalCents: lineTotalCents,
      unitPriceCents: q?.unitPriceCents ?? lineTotalCents,
      quantity: q?.quantity ?? 1,
      unit: q?.unit ?? QuantityUnit.piece,
      discountCents: discountCents,
      warnings: [
        if (q != null && !q.fits(lineTotalCents))
          ParseWarning.lineTotalMismatch,
      ],
    );
  }
}

/// State of one parse, read row by row.
class _Parse {
  final _header = <String>[];
  final _items = <_ItemDraft>[];
  final _unparsed = <String>[];

  _Section _section = _Section.header;
  var _subtotalSeen = false;
  var _receiptDiscount = 0;
  int? _total;
  var _totalOnNextRow = false;

  /// Whether the headings announced a VAT column (`PREZZO %IVA`), so a plain
  /// `10,00` after a price is a rate, not an amount.
  var _vatColumn = false;

  /// Whether the previous meaningful row was a product row, so a following
  /// quantity row may belong to it.
  var _lastRowWasItem = false;

  /// A quantity row not yet assigned. Some receipts print it after its
  /// product, others before, so it waits for the next product row.
  _Quantity? _pendingQuantity;
  _ItemDraft? _pendingQuantityPrevious;

  /// How quantity rows were resolved so far, used as a tie-breaker when the
  /// amounts don't settle it.
  var _quantitiesAfter = 0;
  var _quantitiesBefore = 0;

  /// A row with a name but no price, e.g. a product whose price is on the
  /// following quantity row (`MOZZARELLA` / `3 X 0,99 2,97`).
  String? _pendingName;
  String? _pendingNameRaw;

  ParsedReceipt run(List<String> lines) {
    final rows = <String>[];
    for (final raw in lines) {
      final row = _normalize(raw);
      if (row.isEmpty) continue;
      rows.add(row);
      _read(raw.trim(), row);
    }
    _resolveQuantity(null);
    _flushName();

    final receipt = ParsedReceipt(
      items: [for (final item in _items) item.build()],
      storeName: _storeName(),
      vatNumber: _vatNumber(rows),
      address: _address(),
      purchaseDate: _date(rows),
      totalCents: _total,
      discountCents: _receiptDiscount,
      unparsedLines: _unparsed,
    );
    return receipt.copyWith(
      warnings: [
        if (receipt.storeName == null) ParseWarning.missingStore,
        if (receipt.purchaseDate == null) ParseWarning.missingDate,
        if (receipt.totalCents == null) ParseWarning.missingTotal,
        if (receipt.totalCents != null && !receipt.isBalanced)
          ParseWarning.totalMismatch,
      ],
    );
  }

  void _read(String raw, String row) {
    if (_totalOnNextRow) {
      _totalOnNextRow = false;
      final only = _onlyAmountRe.firstMatch(row);
      if (only != null) {
        _total = Money.parseCents(only[1]!);
        return;
      }
    }
    if (_section == _Section.footer) return;
    if (_vatColumnRe.hasMatch(row)) _vatColumn = true;
    if (_discountSummaryRe.hasMatch(row)) return;

    if (_totalRe.hasMatch(row)) {
      _resolveQuantity(null);
      _flushName();
      _section = _Section.footer;
      final amounts = _amountRe.allMatches(row);
      _total = amounts.isEmpty ? null : Money.parseCents(amounts.last[0]!);
      _totalOnNextRow = _total == null;
      return;
    }

    if (_section == _Section.header) {
      if (_sectionStartRe.hasMatch(row)) {
        _section = _Section.items;
        return;
      }
      if (!_amountRe.hasMatch(row)) {
        _header.add(row);
        return;
      }
      _section = _Section.items;
    }

    _readItemRow(raw, row);
  }

  void _readItemRow(String raw, String fullRow) {
    if (_skipRe.hasMatch(fullRow)) return;
    final row = _withoutVatRate(fullRow);

    if (_subtotalRe.hasMatch(row)) {
      _resolveQuantity(null);
      _flushName();
      _subtotalSeen = true;
      _lastRowWasItem = false;
      return;
    }

    final quantity = _quantityRe.firstMatch(row);
    if (quantity != null) {
      _readQuantity(raw, quantity);
      return;
    }

    final item = _itemRe.firstMatch(row);
    if (item != null) {
      final price = Money.parseCents(item.namedGroup('price')!);
      final name = item.namedGroup('name')!.trim();
      if (price == null) {
        _unparsed.add(raw);
      } else if (price < 0 || _discountRe.hasMatch(name)) {
        _addDiscount(price.abs());
      } else {
        _addItem(name, price);
      }
      return;
    }

    // Separators, stray numbers: nothing to keep.
    if (!_letterRe.hasMatch(row)) return;

    _flushName();
    _pendingName = row;
    _pendingNameRaw = raw;
    _lastRowWasItem = false;
  }

  /// Drops a VAT rate printed as a plain number after the price, which would
  /// otherwise be read as the price. `04,00` (leading zero) is never a price;
  /// `4,00` · `10,00` · `22,00` only count as rates when the headings
  /// announced a VAT column.
  String _withoutVatRate(String row) {
    final match = _trailingRateRe.firstMatch(row);
    if (match == null) return row;
    final rateText = match[2]!;
    final rate = int.parse(rateText);
    if (!_vatRates.contains(rate)) return row;
    if (!_vatColumn && !(rateText.length == 2 && rateText.startsWith('0'))) {
      return row;
    }
    return match[1]!;
  }

  void _readQuantity(String raw, RegExpMatch match) {
    final qtyText = match.namedGroup('qty')!.replaceAll(',', '.');
    final unitText = match.namedGroup('unit') ?? match.namedGroup('perUnit');
    final unit = switch (unitText) {
      'KG' => QuantityUnit.kilogram,
      'L' => QuantityUnit.litre,
      'PZ' => QuantityUnit.piece,
      _ => qtyText.contains('.') ? QuantityUnit.kilogram : QuantityUnit.piece,
    };
    final unitPrice = Money.parseCents(match.namedGroup('unitPrice')!);
    final quantityValue = double.tryParse(qtyText);
    if (unitPrice == null || quantityValue == null || quantityValue <= 0) {
      _unparsed.add(raw);
      return;
    }
    final quantity = _Quantity(raw, quantityValue, unit, unitPrice);

    // The product name was on the row above, and this row carries the price.
    final name = _pendingName;
    if (name != null) {
      final totalText = match.namedGroup('total');
      final total = totalText == null ? null : Money.parseCents(totalText);
      _pendingName = null;
      _pendingNameRaw = null;
      _items.add(
        _ItemDraft(name, total ?? quantity.computedTotalCents)
          ..quantity = quantity,
      );
      _lastRowWasItem = false;
      return;
    }

    _resolveQuantity(null);
    final previous = _items.isEmpty ? null : _items.last;
    _pendingQuantity = quantity;
    _pendingQuantityPrevious = _lastRowWasItem && previous?.quantity == null
        ? previous
        : null;
    _lastRowWasItem = false;
  }

  void _addItem(String name, int priceCents) {
    _flushName();
    final item = _ItemDraft(name, priceCents);
    _resolveQuantity(item);
    _items.add(item);
    _lastRowWasItem = true;
  }

  void _addDiscount(int cents) {
    _resolveQuantity(null);
    _flushName();
    if (_subtotalSeen || _items.isEmpty) {
      _receiptDiscount += cents;
    } else {
      _items.last.discountCents += cents;
    }
    _lastRowWasItem = false;
  }

  /// Assigns the pending quantity row to the product before it or to [next],
  /// whichever its amounts match. If neither matches, it goes to the side
  /// this receipt has used so far, flagged with a line-total mismatch.
  void _resolveQuantity(_ItemDraft? next) {
    final quantity = _pendingQuantity;
    if (quantity == null) return;
    final previous = _pendingQuantityPrevious;
    _pendingQuantity = null;
    _pendingQuantityPrevious = null;

    if (previous != null && quantity.fits(previous.lineTotalCents)) {
      previous.quantity = quantity;
      _quantitiesAfter++;
    } else if (next != null && quantity.fits(next.lineTotalCents)) {
      next.quantity = quantity;
      _quantitiesBefore++;
    } else if (previous != null &&
        (next == null || _quantitiesAfter >= _quantitiesBefore)) {
      previous.quantity = quantity;
    } else if (next != null) {
      next.quantity = quantity;
    } else {
      _unparsed.add(quantity.raw);
    }
  }

  void _flushName() {
    final raw = _pendingNameRaw;
    if (raw != null) _unparsed.add(raw);
    _pendingName = null;
    _pendingNameRaw = null;
  }

  String? _storeName() {
    for (final row in _header) {
      if (_letterRe.allMatches(row).length < 3) continue;
      if (_vatNumberRe.hasMatch(row) ||
          _addressRe.hasMatch(row) ||
          _postcodeRe.hasMatch(row) ||
          _phoneRe.hasMatch(row) ||
          _dateRe.hasMatch(row) ||
          _skipRe.hasMatch(row)) {
        continue;
      }
      return row;
    }
    return null;
  }

  String? _address() {
    for (final (i, row) in _header.indexed) {
      if (!_addressRe.hasMatch(row)) continue;
      final next = i + 1 < _header.length ? _header[i + 1] : null;
      final joins =
          next != null &&
          (_postcodeRe.hasMatch(next) ||
              (_townRe.hasMatch(next) && !_phoneRe.hasMatch(next)));
      return joins ? '$row, $next' : row;
    }
    return null;
  }

  static String? _vatNumber(List<String> rows) {
    for (final row in rows) {
      final match = _vatNumberRe.firstMatch(row);
      if (match == null) continue;
      final digits = match[1]!.replaceAll(' ', '');
      if (digits.length == 11) return digits;
    }
    return null;
  }

  /// The first valid date on the receipt, preferring one printed with a
  /// time (receipts often repeat the date, only sometimes with the time).
  static DateTime? _date(List<String> rows) {
    DateTime? dateOnly;
    for (final row in rows) {
      for (final m in _dateRe.allMatches(row)) {
        final day = int.parse(m[1]!);
        final month = int.parse(m[2]!);
        var year = int.parse(m[3]!);
        if (year < 100) year += 2000;
        if (year < 2000 || year > 2100) continue;
        final date = DateTime(year, month, day);
        // DateTime rolls invalid dates over (31/02 → 03/03): reject those.
        if (date.month != month || date.day != day) continue;

        final hour = m[4] == null ? null : int.parse(m[4]!);
        final minute = m[5] == null ? null : int.parse(m[5]!);
        if (hour != null && minute != null && hour < 24 && minute < 60) {
          return DateTime(year, month, day, hour, minute);
        }
        dateOnly ??= date;
      }
    }
    return dateOnly;
  }
}
