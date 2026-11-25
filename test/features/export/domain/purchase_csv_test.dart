import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';

ExportRow _row({
  String rawName = 'MELE GOLDEN',
  String? storeName = 'CARREFOUR MARKET',
  ExportPantryState? state = ExportPantryState.active,
  double? remaining = 0.3,
  ReceiptOrigin origin = ReceiptOrigin.photo,
}) => ExportRow(
  receiptId: 12,
  purchasedAt: DateTime(2026, 11, 23, 18, 30),
  storeName: storeName,
  vatNumber: '02924950963',
  receiptTotalCents: 488,
  receiptDiscountCents: 0,
  origin: origin,
  rawName: rawName,
  productName: rawName,
  categoryName: 'Frutta e verdura',
  quantity: 0.5,
  unit: 'kg',
  unitPriceCents: 200,
  lineTotalCents: 100,
  discountCents: 40,
  pantryState: state,
  remaining: remaining,
);

void main() {
  test('one header and one line per row, Excel-Italian layout', () {
    final lines = PurchaseCsv.encode([_row()]).split('\r\n');
    expect(lines.first, PurchaseCsv.header.join(';'));
    expect(
      lines[1],
      [
        '12;2026-11-23;18:30;CARREFOUR MARKET;02924950963;4,88;0,00;foto',
        'MELE GOLDEN;MELE GOLDEN;Frutta e verdura;0,5;kg;2,00;1,00;0,40;0,60',
        'sì;attivo;0,3',
      ].join(';'),
    );
    expect(lines.last, isEmpty); // ends with a line break
  });

  test('items never in the pantry leave its columns empty', () {
    final line = PurchaseCsv.encode([
      _row(
        storeName: null,
        state: null,
        remaining: null,
        origin: ReceiptOrigin.manual,
      ),
    ]).split('\r\n')[1];
    expect(line, startsWith('12;2026-11-23;18:30;;02924950963;'));
    expect(line, contains(';a mano;'));
    expect(line, endsWith(';no;;'));
  });

  test('fields with separators, quotes or line breaks are quoted', () {
    final line = PurchaseCsv.encode([_row(rawName: 'PATATE; 2KG "BIO"')])
        .split('\r\n')[1];
    expect(line, contains(';"PATATE; 2KG ""BIO""";'));
  });

  test('numbers: euros with two decimals, quantities up to three', () {
    expect(PurchaseCsv.euros(129), '1,29');
    expect(PurchaseCsv.euros(5), '0,05');
    expect(PurchaseCsv.euros(-40), '-0,40');
    expect(PurchaseCsv.number(1), '1');
    expect(PurchaseCsv.number(10), '10');
    expect(PurchaseCsv.number(0.5), '0,5');
    expect(PurchaseCsv.number(1.2555), '1,256');
  });

  test('bytes start with the UTF-8 byte order mark', () {
    final bytes = PurchaseCsv.bytes([_row()]);
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    expect(utf8.decode(bytes.skip(3).toList()), contains('sì;attivo'));
  });
}
