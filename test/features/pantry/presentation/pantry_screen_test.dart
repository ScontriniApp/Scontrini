import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';

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

    expect(find.text('Latticini e uova'), findsOneWidget);
    expect(find.text('Senza categoria'), findsOneWidget);
    expect(find.text('LATTE PS'), findsOneWidget);
    expect(find.text('#a3f91c02'), findsOneWidget);
    expect(find.text('2 pz di 2 pz'), findsOneWidget);
    expect(find.text('Già in casa'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));

    await closeApp(tester);
  });

  testWidgets('manual add creates a lot with the chosen source', (
    tester,
  ) async {
    await openPantry(tester);

    await tester.tap(find.byTooltip('Aggiungi prodotto'));
    await settle(tester);
    await tester.tap(find.text('Salva'));
    await settle(tester);
    expect(find.text('Inserisci un nome'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Farina',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantità'),
      '1,5',
    );
    await tester.tap(find.text('kg'));
    await tester.tap(find.text('Salva'));
    await settle(tester);

    expect(find.text('Farina'), findsOneWidget);
    final lot = (await tester.runAsync(() => repo.watchLots().first))!.single;
    expect(lot.initialQuantity, 1.5);
    expect(lot.unit, 'kg');
    expect(lot.source, PantrySource.initialStock);

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

    await tester.tap(find.text('Pane'));
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
}
