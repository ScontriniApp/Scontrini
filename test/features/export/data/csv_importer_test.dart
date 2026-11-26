import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/features/export/data/csv_importer.dart';
import 'package:scontrini/features/export/data/export_repository.dart';
import 'package:scontrini/features/export/domain/purchase_csv.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

/// One app's database and the repositories around it.
class _App {
  new() : db = AppDatabase(NativeDatabase.memory()) {
    receipts = ReceiptRepository(db);
    pantry = PantryRepository(db);
    export = ExportRepository(db, pantry);
    importer = CsvImporter(db, receipts, pantry);
  }

  final AppDatabase db;
  late final ReceiptRepository receipts;
  late final PantryRepository pantry;
  late final ExportRepository export;
  late final CsvImporter importer;

  Future<String> csv() async => PurchaseCsv.encode(await export.rows());

  Future<CsvImportResult> importCsv(String text) =>
      importer.import(PurchaseCsv.decode(text));
}

/// The file without its first column: receipt ids are local to each app.
String _withoutIds(String csv) => [
  for (final line in csv.split('\r\n'))
    line.replaceFirst(RegExp('^[^;]*;'), ''),
].join('\n');

void main() {
  late _App source;
  late _App target;

  // Two apps, two in-memory databases: on purpose.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    source = _App();
    target = _App();
    final db = source.db;

    // A printed name counted under another product (an alias).
    final milk = await db
        .into(db.products)
        .insert(ProductsCompanion.insert(canonicalName: 'LATTE INTERO'));
    await db
        .into(db.productAliases)
        .insert(
          ProductAliasesCompanion.insert(rawName: 'LATTE PS', productId: milk),
        );

    final pdf = await source.receipts.saveConfirmed(
      ParsedReceipt(
        storeName: 'CARREFOUR; MARKET',
        vatNumber: '02924950963',
        purchaseDate: DateTime(2026, 11, 23, 18, 30),
        totalCents: 458,
        discountCents: 20,
        items: const [
          ParsedItem(
            rawName: 'LATTE PS',
            unitPriceCents: 129,
            lineTotalCents: 129,
          ),
          ParsedItem(
            rawName: 'LATTE PS',
            unitPriceCents: 129,
            lineTotalCents: 129,
          ),
          ParsedItem(
            rawName: 'MELE "GOLDEN"',
            unitPriceCents: 200,
            lineTotalCents: 100,
            quantity: 0.5,
            unit: QuantityUnit.kilogram,
            discountCents: 10,
          ),
          ParsedItem(
            rawName: 'INSALATA',
            unitPriceCents: 120,
            lineTotalCents: 120,
          ),
          ParsedItem(
            rawName: 'SHOPPER',
            unitPriceCents: 10,
            lineTotalCents: 10,
          ),
        ],
      ),
      sourcePath: '/receipts/1.pdf',
      rawOcrText: 'x',
    );
    await source.receipts.saveConfirmed(
      ParsedReceipt(
        purchaseDate: DateTime(2026, 11, 20, 9, 5),
        items: const [
          ParsedItem(rawName: 'Pane', unitPriceCents: 150, lineTotalCents: 150),
        ],
      ),
    );
    await source.receipts.saveConfirmed(
      ParsedReceipt(
        storeName: 'PAM',
        purchaseDate: DateTime(2026, 11, 21, 12),
        items: const [
          ParsedItem(
            rawName: 'BISCOTTI',
            unitPriceCents: 250,
            lineTotalCents: 250,
          ),
        ],
      ),
      sourcePath: '/receipts/2.jpg',
      rawOcrText: 'x',
      categoryIds: [null],
    );

    await source.pantry.addAllFromReceipt(pdf);
    final lots = {
      for (final l in await source.pantry.watchLots().first) l.name: l.id,
    };
    await source.pantry.consume(lots['LATTE INTERO']!, 2);
    await source.pantry.consume(lots['MELE "GOLDEN"']!, 0.2);
    await source.pantry.discard(lots['INSALATA']!, PantryEventReason.spoiled);
  });
  tearDown(() async {
    await source.db.close();
    await target.db.close();
  });

  test('export → import → export gives the same file', () async {
    final exported = await source.csv();

    final result = await target.importCsv(exported);

    expect((result.receipts, result.duplicates, result.lots), (3, 0, 4));
    expect(_withoutIds(await target.csv()), _withoutIds(exported));
  });

  test('pantry lots come back in their state', () async {
    await target.importCsv(await source.csv());

    final lots = {
      for (final l in await target.pantry.watchLots(includeClosed: true).first)
        l.name: l,
    };
    expect(
      lots.keys,
      unorderedEquals(['LATTE INTERO', 'MELE "GOLDEN"', 'INSALATA', 'SHOPPER']),
    );
    expect(lots['LATTE INTERO']!.remainingQuantity, 0);
    expect(lots['MELE "GOLDEN"']!.remainingQuantity, closeTo(0.3, 1e-9));
    expect(lots['INSALATA']!.remainingQuantity, 0);
  });

  test('the alias comes back: both milk rows count as one product', () async {
    await target.importCsv(await source.csv());

    final products = await target.db.select(target.db.products).get();
    final aliases = await target.db.select(target.db.productAliases).get();
    final milk = products.singleWhere((p) => p.canonicalName == 'LATTE INTERO');
    expect(aliases.map((a) => (a.rawName, a.productId)), [
      ('LATTE PS', milk.id),
    ]);
    final rows = await (target.db.select(
      target.db.receiptItems,
    )..where((i) => i.rawName.equals('LATTE PS'))).get();
    expect(rows.map((r) => r.productId), [milk.id, milk.id]);
  });

  test('importing the same file twice adds nothing', () async {
    final exported = await source.csv();
    await target.importCsv(exported);
    final before = await target.csv();

    final again = await target.importCsv(exported);

    expect((again.receipts, again.duplicates, again.lots), (0, 3, 0));
    expect(await target.csv(), before);
  });

  test('importing into the exporting app itself adds nothing', () async {
    final exported = await source.csv();

    final result = await source.importCsv(exported);

    expect(result.duplicates, 3);
    expect(await source.csv(), exported);
  });
}
