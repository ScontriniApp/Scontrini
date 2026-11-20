import 'dart:math' as math;

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
  ///
  /// The column layout read from the headings decides which number on a row
  /// is the price. If that reading doesn't add up to the printed total, the
  /// other readings are tried (no layout, VAT column after the price, VAT
  /// column before it) and the first that adds up wins: the arithmetic is
  /// the referee when the headings were misread or not read at all.
  ParsedReceipt parseLines(List<String> lines) {
    final receipt = _Parse().run(lines);
    if (receipt.totalCents == null || receipt.isBalanced) return receipt;
    for (final alternative in [
      _Parse(useLayout: false),
      _Parse(useLayout: false, vatSide: _VatSide.afterPrice),
      _Parse(useLayout: false, vatSide: _VatSide.beforePrice),
    ]) {
      final other = alternative.run(lines);
      if (other.isBalanced) return other;
    }
    return receipt;
  }
}

// An amount as printed: 1,29 · 1.29 · -0,50 · 0,50- · 1.234,56.
const _amount = r'(?<![\d.,])-?\d+(?:[.,]\d{3})*[.,]\d{2}-?(?!\d)';

// VAT rate or code printed next to a price: 4% · 10% · 22 % · A · B · VI · *.
const _vatCode = r'(?:\d{1,2}(?:,\d{1,2})?\s?%|[A-Z]{1,2}\d?|\*)';

final _amountRe = RegExp(_amount);

// An Italian VAT rate (4, 5, 10, 22) as printed in a VAT column: 04,00 ·
// 10,00 · 22,00% · 4% · 10 %. Group 1 is the leading zero, if any.
const _rate = r'(0?)(?:4|5|10|22)(?:[.,]00\s?%?|\s?%)';

// A rate as the last column, after the price (Carrefour `LATTE 1,85 04,00`).
// Group 1: the row without it; group 2: the leading zero.
final _rateAfterRe = RegExp('^(.*\\d[.,]\\d{2}-?)\\s+$_rate\$');

// A rate right before the price (`CAFFE 10,00 4,00`). Group 1: what comes
// before it; group 2: the leading zero; group 3: the price and what follows.
final _rateBeforeRe = RegExp(
  '^(.*\\S)\\s+$_rate\\s+((?:$_amount)(?:\\s*$_vatCode)?)\$',
);

// Unit price and line total in two columns, with the quantity in a column of
// its own before the name (Conad: `2 PANE BAULETTO 1,29 2,58`). OCR may lose
// the quantity: then it comes from total ÷ unit price.
final _unitAndTotalRe = RegExp(
  r'^(?:(?<qty>\d{1,3})\s+)?(?<name>.*?[A-Z].*?)\s+'
  '(?<unitPrice>$_amount)\\s+(?<total>$_amount)\$',
);
final _onlyAmountRe = RegExp('^($_amount)(?:\\s*$_vatCode)?\$');

final _itemRe = RegExp(
  r'^(?<name>.*?[A-Z].*?)\s+'
  // VAT before the price: a code (Esselunga `*c`) or a rate (PAM `10,00%`).
  r'(?:(?<vatBefore>\*[A-Z]{1,2}|\d{1,2}(?:,\d{1,2})?\s?%)\s+)?'
  '(?<price>$_amount)'
  '(?:\\s*(?<vatAfter>$_vatCode))?\$',
);

final _quantityRe = RegExp(
  r'^(?:NET(?:TO)?\s+)?(?<qty>\d+(?:[.,]\d{1,3})?)\s*(?<unit>KG|L|PZ)?\s*'
  // `×` is how some OCR engines read a printed `x`.
  r'[X*×]\s*'
  '(?<unitPrice>$_amount)'
  r'(?:\s*(?:EUR|€)?\s*/\s*(?<perUnit>KG|L|PZ)\b|\s*EUR\b)?'
  '(?:\\s*=?\\s*(?<total>$_amount))?'
  '(?:\\s*(?<vat>$_vatCode))?\$',
);

// Esselunga prints the weight row before the item: `KG. 0,18 14,39`
// (weight, price per kg).
final _weightRe = RegExp(
  '^KG\\.?\\s*(?<qty>\\d+[.,]\\d{1,3})\\s+(?<unitPrice>$_amount)\$',
);

// VAT legend under the total: `*a = IVA 04%`, `A = 4%`, `*NS = NON SOGGETTA`.
final _legendRateRe = RegExp(
  r'^\*?([A-Z]{1,2})\s*=\s*(?:IVA\s*)?(\d{1,2})(?:[.,]\d+)?\s*%',
);
final _legendExemptRe = RegExp(
  r'^\*?([A-Z]{1,2})\s*=\s*(?:NON\s+SOGG|ESENT|ESCLUS|FUORI\s+CAMPO)',
);

// A service column in front of the name on most rows of a receipt: PAM
// `T MACINATO`, Interspar `*RANA`.
final _namePrefixRe = RegExp(r'^(?:\*\s*|[A-Z]\s+)(?=\S)');

// Header rows that are never the store name.
final _notStoreNameRe = RegExp(
  r'CODICE A BARRE|GRAZIE|ARRIVEDERCI|BENVENUT|SCONTRINO|^CASSA\b|'
  '^(?:[A-Z] ){3,}',
);

final _totalRe = RegExp(r'^T[O0]TALE\b(?!\s+(?:IVA|ARTICOLI|PEZZI|PZ)\b)');
// SUBTOTALE, SUB-TOTALE, SUBTOTAL.
final _subtotalRe = RegExp(r'^SUB\s?-?\s?T[O0]TAL');

// Summary of the discounts already printed under each item (`Totale Sconti
// Ottenuti -3,92`): neither the total nor another discount.
final _discountSummaryRe = RegExp(
  r'^T[O0]TALE\s+(?:SCONT|RISPARMI)|^(?:HAI\s+)?RISPARMIAT',
);
final _discountRe = RegExp(
  r'\b(?:SCONTO|SC\.|OFFERTA|PROMO|RIDUZIONE|BUONO|COUPON)',
);

// A voucher on the whole receipt, not on the item above it (Esselunga
// `BUONO SPESA 8,00-S`, printed just before the total).
final _voucherRe = RegExp(r'^BUONO\s+(?:SPESA|SCONTO)\b');
final _sectionStartRe = RegExp('DOCUMENTO COMMERCIALE|^DESCRIZIONE');
final _skipRe = RegExp(
  r'DOCUMENTO COMMERCIALE|VENDITA O PRESTAZIONE|^DESCRIZIONE|^IVA\b|'
  r'^PREZZO|^EURO$|^CASSA\b|^OPERATORE\b',
);
final _letterRe = RegExp('[A-Z]');

// P.IVA · P. IVA · P.I.V.A. · P.I. · PARTITA IVA, then 11 digits (OCR may
// space them out).
final _vatNumberRe = RegExp(
  r'(?:\bP\.?\s*I\.?\s*V\.?\s*A\b\.?|\bP\.\s*I\b\.?|PARTITA\s+I\.?V\.?A\.?)'
  r'\s*[:.]?\s*(?:IT\s*)?(\d[\d ]{9,14}\d)',
);
final _addressRe = RegExp(
  r'^(?:VIA|V\.LE|VIALE|PIAZZA|P\.ZZA|P\.ZA|PZA|CORSO|C\.SO|LARGO|STRADA|'
  r'LOC\.|LOCALITA|C\.DA|CONTRADA|FRAZ\.|FRAZIONE)\s',
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

/// Uppercases, drops the euro sign and an `EUR` printed after an amount
/// (`12,99 EUR`), joins amounts that OCR split (`1 ,29`, `1, 29`) and
/// collapses whitespace.
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
    .replaceAllMapped(
      RegExp(r'([.,]\d{2}-?)\s*EUR\b'),
      (m) => '${m[1]} ',
    )
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

enum _Section { header, items, footer }

enum _Column { quantity, description, price, vat }

enum _VatSide { afterPrice, beforePrice }

/// Column headings as printed above the items, by the column they name.
const _headings = <String, _Column>{
  'QTA': _Column.quantity,
  "QTA'": _Column.quantity,
  'Q.TA': _Column.quantity,
  'QUANTITA': _Column.quantity,
  "QUANTITA'": _Column.quantity,
  'DESCRIZIONE': _Column.description,
  'ARTICOLO': _Column.description,
  'PREZZO': _Column.price,
  'EURO': _Column.price,
  'EUR': _Column.price,
  'IMPORTO': _Column.price,
  'TOTALE': _Column.price,
  'IVA': _Column.vat,
  '%IVA': _Column.vat,
  'ALIQ': _Column.vat,
  'ALIQ.': _Column.vat,
  'ALIQUOTA': _Column.vat,
};

/// Order of the item columns, read from the headings
/// (`DESCRIZIONE PREZZO %IVA`, `IVA EURO`, `QTA' DESCRIZIONE PREZZO TOTALE`).
/// Headings split over consecutive rows add up.
class _ColumnLayout {
  final _columns = <_Column>[];

  bool get isKnown => _columns.isNotEmpty;

  /// Reads [row] as a row of headings. Returns `false`, changing nothing,
  /// when it is anything else.
  bool add(String row) {
    final words = row
        .replaceAll(RegExp('[()€]'), ' ')
        .replaceAll(RegExp(r'%\s+IVA\b'), '%IVA')
        .split(' ')
        // OCR often turns QTA' into QTA* or QTA.: compare the bare word.
        .map((w) => w.replaceAll(RegExp(r"[':*.,;]+$"), ''))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return false;
    final columns = [for (final w in words) _headings[w]];
    if (columns.contains(null)) return false;
    // A single word is a heading only if it can't be anything else.
    if (words.length == 1 &&
        columns.single != _Column.description &&
        columns.single != _Column.quantity) {
      return false;
    }
    _columns.addAll(columns.nonNulls);
    return true;
  }

  int _first(_Column column) => _columns.indexOf(column);

  /// The VAT column comes after the price (Carrefour).
  bool get vatAfterPrice =>
      _first(_Column.vat) >= 0 &&
      _first(_Column.price) >= 0 &&
      _columns.lastIndexOf(_Column.vat) > _first(_Column.price);

  /// The VAT column comes before the price (PAM, Esselunga).
  bool get vatBeforePrice =>
      _first(_Column.vat) >= 0 &&
      _first(_Column.price) >= 0 &&
      _first(_Column.vat) < _first(_Column.price);

  /// The quantity has its own column before the name, and unit price and
  /// line total have one each (Conad: `QTA' DESCRIZIONE PREZZO TOTALE`).
  bool get quantityAndTotalColumns =>
      _first(_Column.quantity) >= 0 &&
      (_first(_Column.description) < 0 ||
          _first(_Column.quantity) < _first(_Column.description)) &&
      _columns.where((c) => c == _Column.price).length >= 2;
}

class _Quantity {
  new(
    this.raw,
    this.quantity,
    this.unit,
    this.unitPriceCents, {
    this.decimals = 0,
    this.vat,
  });

  final String raw;
  final double quantity;
  final QuantityUnit unit;
  final int unitPriceCents;

  /// Decimals printed in the quantity: a weight printed as 0,18 may really
  /// be anything from 0,175 to 0,185.
  final int decimals;

  /// VAT printed on the quantity row (Carrefour `2 X 0,65 04,00`), for the
  /// item it belongs to.
  final _Vat? vat;

  int get computedTotalCents => (quantity * unitPriceCents).round();

  /// Allows 1 cent of rounding, or what the rounding of a printed weight
  /// can account for.
  bool fits(int lineTotalCents) {
    final weightSlack = decimals == 0
        ? 0
        : (unitPriceCents * 0.5 / math.pow(10, decimals)).ceil();
    return (computedTotalCents - lineTotalCents).abs() <=
        math.max(1, weightSlack);
  }
}

/// VAT as printed next to an item: a rate, or a code resolved later with
/// the legend at the bottom of the receipt (`*a = IVA 04%`).
class _Vat {
  new({this.percent, this.code});

  final int? percent;
  final String? code;

  /// Reads `*C`, `B`, `10,00%`, `4 %`. Returns `null` for anything else.
  static _Vat? parse(String? text) {
    if (text == null) return null;
    final t = text.replaceAll(' ', '');
    final rate = RegExp(r'^(\d{1,2})(?:[.,]\d{1,2})?%$').firstMatch(t);
    if (rate != null) return _Vat(percent: int.parse(rate[1]!));
    final code = RegExp(r'^\*?([A-Z]{1,2})\d?$').firstMatch(t);
    if (code != null) return _Vat(code: code[1]);
    return null;
  }
}

class _ItemDraft {
  new(this.rawName, this.lineTotalCents, {this.vat});

  String rawName;
  final int lineTotalCents;
  _Quantity? quantity;
  int discountCents = 0;
  _Vat? vat;

  ParsedItem build(Map<String, int> legend) {
    final q = quantity;
    final v = vat ?? q?.vat;
    return ParsedItem(
      rawName: rawName,
      lineTotalCents: lineTotalCents,
      unitPriceCents: q?.unitPriceCents ?? lineTotalCents,
      quantity: q?.quantity ?? 1,
      unit: q?.unit ?? QuantityUnit.piece,
      discountCents: discountCents,
      vatPercent: v?.percent ?? (v?.code == null ? null : legend[v!.code]),
      warnings: [
        if (q != null && !q.fits(lineTotalCents))
          ParseWarning.lineTotalMismatch,
      ],
    );
  }
}

/// State of one parse, read row by row.
class _Parse {
  new({this.useLayout = true, this.vatSide});

  /// Side of the VAT column assumed without headings (see
  /// [ReceiptParser.parseLines]).
  final _VatSide? vatSide;

  bool get _vatAfterPrice =>
      vatSide == _VatSide.afterPrice ||
      (layoutApplied && _layout.vatAfterPrice);

  bool get _vatBeforePrice =>
      vatSide == _VatSide.beforePrice ||
      (layoutApplied && _layout.vatBeforePrice);

  final _header = <String>[];
  final _items = <_ItemDraft>[];
  final _unparsed = <String>[];

  _Section _section = _Section.header;
  var _subtotalSeen = false;
  var _receiptDiscount = 0;
  int? _total;
  var _totalOnNextRow = false;

  /// Column order from the headings. Ignored when [useLayout] is false.
  final _layout = _ColumnLayout();

  /// Whether the column layout read from the headings is applied. The
  /// parser runs again without it when it doesn't add up (see
  /// [ReceiptParser.parseLines]).
  final bool useLayout;

  bool get layoutApplied => useLayout && _layout.isKnown;

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

  /// VAT codes from the legend (`*a = IVA 04%` → `A: 4`), usually printed
  /// under the total.
  final _legend = <String, int>{};

  ParsedReceipt run(List<String> lines) {
    final rows = <String>[];
    for (final raw in lines) {
      final row = _normalize(raw);
      if (row.isEmpty) continue;
      rows.add(row);
      _readLegend(row);
      _read(raw.trim(), row);
    }
    _resolveQuantity(null);
    _flushName();
    _dropNamePrefixColumn();

    final receipt = ParsedReceipt(
      items: [for (final item in _items) item.build(_legend)],
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

  void _readLegend(String row) {
    final rate = _legendRateRe.firstMatch(row);
    if (rate != null) {
      _legend[rate[1]!] = int.parse(rate[2]!);
      return;
    }
    final exempt = _legendExemptRe.firstMatch(row);
    if (exempt != null) _legend[exempt[1]!] = 0;
  }

  /// Removes a service column printed in front of most item names (PAM
  /// `T `/`X `, Interspar `*`). Only when most items have one, so a name
  /// that really starts with a single letter is left alone.
  void _dropNamePrefixColumn() {
    if (_items.length < 2) return;
    final prefixed = _items.where((i) => _namePrefixRe.hasMatch(i.rawName));
    if (prefixed.length * 2 < _items.length) return;
    for (final item in prefixed) {
      item.rawName = item.rawName.replaceFirst(_namePrefixRe, '');
    }
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
    if (_discountSummaryRe.hasMatch(row)) return;

    // Column headings, before the first item. `TOTALE EURO` on its own is the
    // total, not a heading.
    if (_items.isEmpty && !_totalRe.hasMatch(row) && _layout.add(row)) {
      if (_section == _Section.header) _section = _Section.items;
      return;
    }

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
    final (row, rate) = _withoutVatRate(fullRow);

    if (_subtotalRe.hasMatch(row)) {
      _resolveQuantity(null);
      _flushName();
      _subtotalSeen = true;
      _lastRowWasItem = false;
      return;
    }

    final quantity = _quantityRe.firstMatch(row) ?? _weightRe.firstMatch(row);
    if (quantity != null) {
      _readQuantity(raw, quantity, rate);
      return;
    }

    if (layoutApplied &&
        _layout.quantityAndTotalColumns &&
        _readUnitAndTotal(raw, row)) {
      return;
    }

    final item = _itemRe.firstMatch(row);
    if (item != null) {
      final price = Money.parseCents(item.namedGroup('price')!);
      final name = item.namedGroup('name')!.trim();
      if (price == null) {
        _unparsed.add(raw);
      } else if (price < 0 || _discountRe.hasMatch(name)) {
        _addDiscount(price.abs(), onReceipt: _voucherRe.hasMatch(name));
      } else {
        final vat =
            rate ??
            _Vat.parse(item.namedGroup('vatBefore')) ??
            _Vat.parse(item.namedGroup('vatAfter'));
        _addItem(name, price, vat);
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

  /// Drops a VAT rate printed next to the price, which would otherwise be
  /// read as the price (after it) or end up in the name (before it).
  ///
  /// The side comes from the headings: with `PREZZO %IVA` only a rate after
  /// the price is dropped, with `IVA PREZZO` only one before it, so a real
  /// price that happens to be 4,00 or 10,00 is never lost. Without headings
  /// only a leading-zero rate (`04,00`) is dropped, since no price is
  /// printed that way. Returns the row without the rate, and the rate.
  (String, _Vat?) _withoutVatRate(String row) {
    final after = _rateAfterRe.firstMatch(row);
    if (after != null && (after[2]!.isNotEmpty || _vatAfterPrice)) {
      return (after[1]!, _rateIn(row.substring(after[1]!.length)));
    }
    final before = _rateBeforeRe.firstMatch(row);
    if (before != null && (before[2]!.isNotEmpty || _vatBeforePrice)) {
      final rateText = row.substring(
        before[1]!.length,
        row.length - before[3]!.length,
      );
      return ('${before[1]} ${before[3]}', _rateIn(rateText));
    }
    return (row, null);
  }

  static _Vat? _rateIn(String text) {
    final m = RegExp(r'(\d{1,2})[.,%\s]').firstMatch('${text.trim()} ');
    return m == null ? null : _Vat(percent: int.parse(m[1]!));
  }

  /// `2 PANE BAULETTO 1,29 2,58` under a `QTA' DESCRIZIONE PREZZO TOTALE`
  /// heading. Only taken when quantity × unit price gives the line total;
  /// otherwise the row is read as usual. If OCR lost the quantity, it is
  /// total ÷ unit price when that is a whole number.
  bool _readUnitAndTotal(String raw, String row) {
    final match = _unitAndTotalRe.firstMatch(row);
    if (match == null) return false;
    final unitPrice = Money.parseCents(match.namedGroup('unitPrice')!);
    final total = Money.parseCents(match.namedGroup('total')!);
    if (unitPrice == null || total == null || unitPrice <= 0 || total <= 0) {
      return false;
    }
    final qtyText = match.namedGroup('qty');
    final quantity = qtyText != null
        ? int.parse(qtyText)
        : (total % unitPrice == 0 ? total ~/ unitPrice : 0);
    if (quantity <= 0) return false;
    final q = _Quantity(
      raw,
      quantity.toDouble(),
      QuantityUnit.piece,
      unitPrice,
    );
    if (!q.fits(total)) return false;

    _resolveQuantity(null);
    _flushName();
    _items.add(
      _ItemDraft(match.namedGroup('name')!.trim(), total)..quantity = q,
    );
    _lastRowWasItem = true;
    return true;
  }

  void _readQuantity(String raw, RegExpMatch match, _Vat? rate) {
    String? group(String name) =>
        match.groupNames.contains(name) ? match.namedGroup(name) : null;
    final qtyText = match.namedGroup('qty')!.replaceAll(',', '.');
    final unitText = group('unit') ?? group('perUnit');
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
    final quantity = _Quantity(
      raw,
      quantityValue,
      unit,
      unitPrice,
      decimals: qtyText.contains('.') ? qtyText.split('.').last.length : 0,
      vat: rate ?? _Vat.parse(group('vat')),
    );

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

  void _addItem(String name, int priceCents, _Vat? vat) {
    _flushName();
    final item = _ItemDraft(name, priceCents, vat: vat);
    _resolveQuantity(item);
    _items.add(item);
    _lastRowWasItem = true;
  }

  /// A discount goes to the item above it, unless it comes after the
  /// subtotal or is a voucher on the whole receipt (`BUONO SPESA`).
  void _addDiscount(int cents, {bool onReceipt = false}) {
    _resolveQuantity(null);
    _flushName();
    if (onReceipt || _subtotalSeen || _items.isEmpty) {
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
          _skipRe.hasMatch(row) ||
          _notStoreNameRe.hasMatch(row)) {
        continue;
      }
      // Decorations around the name: `* ESSELUNGA S.P.A. *`, `**** PAM ****`.
      return row.replaceAll(RegExp(r'^[*\-=\s]+|[*\-=\s]+$'), '');
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
