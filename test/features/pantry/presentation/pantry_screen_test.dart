import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/products/presentation/product_stats_screen.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';
import 'package:scontrini/features/receipts/presentation/receipt_detail_screen.dart';

void main() {
  late AppDatabase db;
  late PantryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PantryRepository(db);
  });
  tearDown(() => db.close());

  /// Drift runs its queries on real async work, which the test's fake clock
  /// never advances: give it real time, then rebuild. Avoids pumpAndSettle
  /// while the loading spinner (an endless animation) is on screen.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Unmounts the app and flushes the zero-length timers drift starts when
  /// its stream queries are cancelled.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  Future<void> openPantry(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ScontriniApp(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Dispensa'));
    await settle(tester);
  }

  testWidgets('the pantry tab replaces Insights and starts empty', (
    tester,
  ) async {
    await openPantry(tester);

    expect(find.text('Consigli'), findsNothing);
    expect(find.textContaining('La dispensa è vuota'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('lots are grouped by category with their receipt tag', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final dairy = await (db.select(
        db.categories,
      )..where((c) => c.name.equals('Latticini e uova'))).getSingle();
      final receiptId = await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              purchaseDate: DateTime.utc(2026, 11, 18),
              totalCents: 258,
              status: ReceiptStatus.confirmed,
              transactionHash: const Value('a3f91c02deadbeef'),
            ),
          );
      await db
          .into(db.receiptItems)
          .insert(
            ReceiptItemsCompanion.insert(
              receiptId: receiptId,
              rawName: 'LATTE PS',
              quantity: const Value(2),
              unitPriceCents: 129,
              lineTotalCents: 258,
              categoryId: Value(dairy.id),
            ),
          );
      final card = (await repo.triageCards(receiptId)).single;
      await repo.addFromReceipt(receiptId, card);
      await repo.addManual(
        name: 'Riso',
        quantity: 1,
        source: PantrySource.initialStock,
      );
    });

    await openPantry(tester);

    // Sections start closed: name and number of lots only.
    expect(find.text('Latticini e uova'), findsOneWidget);
    expect(find.text('Senza categoria'), findsOneWidget);
    expect(find.text('LATTE PS'), findsNothing);

    await tester.tap(find.text('Latticini e uova'));
    await tester.tap(find.text('Senza categoria'));
    await settle(tester);
    expect(find.text('LATTE PS'), findsOneWidget);
    expect(find.text('#a3f91c02 · 2 pz di 2 pz'), findsOneWidget);
    expect(find.text('Già in casa · 1 pz di 1 pz'), findsOneWidget);
    expect(find.text('100%'), findsNWidgets(2));
    final slider = tester.widget<Slider>(find.byType(Slider).first);
    expect((slider.value, slider.max), (100, 100));

    // A tap closes the section again.
    await tester.tap(find.text('Latticini e uova'));
    await settle(tester);
    expect(find.text('LATTE PS'), findsNothing);

    await closeApp(tester);
  });

  testWidgets('search shows matching lots, sections open', (tester) async {
    await tester.runAsync(() async {
      await repo.addManual(
        name: 'Caffè macinato',
        quantity: 1,
        source: PantrySource.initialStock,
      );
      await repo.addManual(
        name: 'Riso',
        quantity: 1,
        source: PantrySource.initialStock,
      );
    });
    await openPantry(tester);

    await tester.enterText(find.byType(SearchBar), 'caffe');
    await settle(tester);
    expect(find.text('Caffè macinato'), findsOneWidget);
    expect(find.text('Riso'), findsNothing);

    await tester.enterText(find.byType(SearchBar), 'zucchero');
    await settle(tester);
    expect(find.text('Nessun prodotto trovato.'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancella ricerca'));
    await settle(tester);
    expect(find.text('Senza categoria'), findsOneWidget);
    expect(find.text('Riso'), findsNothing); // closed again

    await closeApp(tester);
  });

  testWidgets('throwing away shows an undo that restores the lot', (
    tester,
  ) async {
    final id = (await tester.runAsync(
      () => repo.addManual(
        name: 'Pane',
        quantity: 1,
        source: PantrySource.manualPurchase,
      ),
    ))!;
    await openPantry(tester);
    await tester.tap(find.text('Senza categoria'));
    await settle(tester);

    await tester.tap(find.text('Pane'));
    await settle(tester);
    await tester.tap(find.text('Gestisci in dispensa'));
    await settle(tester);
    await tester.tap(find.text('Butta via: Andato a male'));
    await settle(tester);

    expect(find.text('Pane buttato'), findsOneWidget);
    expect(find.text('Pane'), findsNothing);

    await tester.tap(find.text('Annulla'));
    await settle(tester);

    expect(find.text('Pane'), findsOneWidget);
    final ledger = LotLedger((await tester.runAsync(() => repo.events(id)))!);
    expect(ledger.discarded, 0);
    expect(ledger.status, PantryLotStatus.active);

    await closeApp(tester);
  });

  testWidgets('a lot opens its product statistics', (tester) async {
    await tester.runAsync(() async {
      final receipts = ReceiptRepository(db);
      ParsedReceipt milk(DateTime date, int cents) => ParsedReceipt(
        storeName: 'CONAD',
        purchaseDate: date,
        totalCents: cents,
        items: [
          ParsedItem(
            rawName: 'LATTE INTERO',
            unitPriceCents: cents,
            lineTotalCents: cents,
          ),
        ],
      );
      await receipts.saveConfirmed(milk(DateTime(2026, 11, 2, 10), 129));
      final id = await receipts.saveConfirmed(
        milk(DateTime(2026, 11, 16, 10), 139),
      );
      await repo.addFromReceipt(id, (await repo.triageCards(id)).single);
    });
    await openPantry(tester);
    await tester.tap(find.text('Latticini e uova'));
    await settle(tester);

    await tester.tap(find.text('LATTE INTERO'));
    await settle(tester);
    expect(find.text('Gestisci in dispensa'), findsOneWidget);
    await tester.tap(find.text('Visualizza statistiche'));
    await settle(tester);

    expect(find.text('2 volte'), findsOneWidget);
    expect(find.text('14 giorni circa'), findsOneWidget);
    expect(find.text('Prezzi pagati · al pezzo'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Acquisti'), 200);
    expect(find.textContaining('CONAD · 1 pz'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Ne hai ancora 1 pz'), 200);

    // A purchase opens its receipt over the statistics; back returns there.
    await tester.scrollUntilVisible(
      find.textContaining('CONAD · 1 pz').first,
      -200,
    );
    await tester.tap(find.textContaining('CONAD · 1 pz').first);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(ReceiptDetailScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.byType(ReceiptDetailScreen), findsNothing);
    expect(find.byType(ProductStatsScreen), findsOneWidget);

    await closeApp(tester);
  });
}
