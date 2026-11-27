import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/pantry/data/pantry_repository.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Drift works on real async time (see pantry_screen_test.dart).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ScontriniApp(),
      ),
    );
    await tester.pump();
  }

  /// Fills the review screen's row form and saves it.
  Future<void> addItem(
    WidgetTester tester,
    String name,
    String unitPrice, {
    String? kilograms,
  }) async {
    await tester.tap(find.text('Aggiungi articolo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('review-item-name')), name);
    if (kilograms != null) {
      await tester.enterText(
        find.byKey(const Key('review-item-quantity')),
        kilograms,
      );
      await tester.tap(find.text('kg'));
    }
    await tester.enterText(
      find.byKey(const Key('review-item-unit-price')),
      unitPrice,
    );
    await tester.pump();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
  }

  testWidgets('a receipt typed in by hand: review screen → pantry + history', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 6000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await openApp(tester);
    await tester.tap(find.text('Dispensa'));
    await settle(tester);

    await tester.tap(find.byTooltip('Aggiungi scontrino a mano'));
    await settle(tester);
    expect(find.text('Scontrino a mano'), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(find.byKey(const Key('review-save')))
          .onPressed,
      isNull,
    );
    // The total is the rows' sum: no warning about it.
    expect(find.text('Totale non trovato'), findsNothing);

    await addItem(tester, 'Farina', '1,40', kilograms: '1,5');
    await addItem(tester, 'Latte intero', '1,29');
    // Rows typed in by hand need no check.
    expect(find.text('Articoli (2)'), findsOneWidget);
    expect(find.text('Corretto'), findsNothing);

    await tester.tap(find.text('Salva scontrino'));
    await settle(tester);

    // Saved, in the pantry, and shown in the history's detail page.
    expect(
      find.text('Scontrino salvato, 2 prodotti in dispensa.'),
      findsOneWidget,
    );
    final lots = (await tester.runAsync(
      () => PantryRepository(db).watchLots().first,
    ))!;
    expect(lots.map((l) => (l.name, l.initialQuantity, l.unit)).toSet(), {
      ('Farina', 1.5, 'kg'),
      ('Latte intero', 1.0, 'pz'),
    });
    expect(lots.every((l) => l.source == PantrySource.receipt), isTrue);
    // Printed like the receipt: store, products, total discount, total.
    expect(find.text('Negozio sconosciuto'), findsOneWidget);
    expect(find.text('Farina'), findsOneWidget);
    expect(find.text('Latte intero'), findsOneWidget);
    expect(find.text('SCONTO TOTALE'), findsOneWidget);
    expect(find.text('TOTALE'), findsOneWidget);
    expect(find.text(Money.format(339)), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Negozio sconosciuto'), findsOneWidget);
    expect(find.text(Money.format(339)), findsOneWidget);
    expect(find.textContaining('2 articoli · A mano'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('a receipt in the history is printed on paper above "Aggiungi"', (
    tester,
  ) async {
    // Tall enough products to scroll: the end must clear the button.
    await tester.runAsync(
      () => ReceiptRepository(db).saveConfirmed(
        ParsedReceipt(
          storeName: 'CONAD',
          purchaseDate: DateTime(2026, 11, 20, 12, 30),
          totalCents: 2400,
          discountCents: 100,
          items: [
            for (var i = 0; i < 20; i++)
              ParsedItem(
                rawName: 'PRODOTTO $i',
                unitPriceCents: 125,
                lineTotalCents: 125,
                discountCents: i == 0 ? 50 : 0,
              ),
          ],
        ),
      ),
    );
    await openApp(tester);
    await tester.tap(find.text('Storico'));
    await settle(tester);
    await tester.tap(find.text('CONAD'));
    await settle(tester);

    // Store and date, no tag; the products; then the totals.
    expect(find.text('CONAD'), findsOneWidget);
    expect(find.text('20 novembre 2026 12:30'), findsOneWidget);
    expect(find.textContaining('#'), findsNothing);
    expect(find.text('PRODOTTO 0'), findsOneWidget);

    final paper = find.byType(SingleChildScrollView);
    await tester.drag(paper, const Offset(0, -3000));
    await settle(tester);
    // Line discount + receipt discount.
    expect(find.text('-${Money.format(150)}'), findsOneWidget);
    expect(find.text('SCONTO TOTALE'), findsOneWidget);
    expect(find.text(Money.format(2400)), findsOneWidget);

    final button = tester.getRect(find.byType(FloatingActionButton));
    final total = tester.getRect(find.text('TOTALE'));
    expect(total.bottom, lessThan(button.top));
    // The whole paper (and its torn bottom) ends above the button too.
    expect(tester.getRect(paper).bottom, lessThan(button.top));

    await closeApp(tester);
  });

  testWidgets('a receipt is deleted from its detail page', (tester) async {
    await tester.runAsync(
      () => ReceiptRepository(db).saveConfirmed(
        ParsedReceipt(
          storeName: 'CONAD',
          purchaseDate: DateTime(2026, 11, 20, 12),
          totalCents: 99,
          items: const [
            ParsedItem(rawName: 'PANE', unitPriceCents: 99, lineTotalCents: 99),
          ],
        ),
      ),
    );
    await openApp(tester);
    await tester.tap(find.text('Storico'));
    await settle(tester);
    expect(find.text('CONAD'), findsOneWidget);

    await tester.tap(find.text('CONAD'));
    await settle(tester);
    await tester.tap(find.byTooltip('Elimina scontrino'));
    await settle(tester);
    await tester.tap(find.text('Elimina'));
    await settle(tester);

    expect(find.text('Scontrino eliminato'), findsOneWidget);
    expect(find.text('CONAD'), findsNothing);
    expect(find.textContaining('Nessuno scontrino salvato'), findsOneWidget);

    await closeApp(tester);
  });
}
