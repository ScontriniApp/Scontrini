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

  /// Scrolls the form (a lazy list) until [finder] is built.
  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .ancestor(
              of: find.byType(TextFormField).first,
              matching: find.byType(Scrollable),
            )
            .last,
      );

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await scrollTo(tester, finder);
    await tester.pump();
    await tester.tap(finder);
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

  testWidgets('a receipt typed in the pantry lands in pantry and history', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Dispensa'));
    await settle(tester);

    await tester.tap(find.byTooltip('Aggiungi scontrino a mano'));
    await settle(tester);
    expect(find.text('Scontrino a mano'), findsOneWidget);

    // Nothing typed yet: the item needs a name and a price.
    await tapVisible(tester, find.text('Salva scontrino'));
    await settle(tester);
    expect(find.text('Inserisci un nome'), findsOneWidget);
    expect(find.text('Prezzo non valido'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Farina',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantità'),
      '1,5',
    );
    await tester.tap(find.text('kg'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prezzo pagato'),
      '2,10',
    );
    await tapVisible(tester, find.text('Aggiungi articolo'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome').last,
      'Latte intero',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prezzo pagato').last,
      '1,29',
    );
    await tester.pump();
    await scrollTo(tester, find.text('Salva scontrino'));
    expect(find.text(Money.format(339)), findsOneWidget);

    await tapVisible(tester, find.text('Salva scontrino'));
    await settle(tester);

    // Back in the pantry, with both items tagged with the receipt.
    expect(find.text('Scontrino salvato nello storico'), findsOneWidget);
    final lots = (await tester.runAsync(
      () => PantryRepository(db).watchLots().first,
    ))!;
    expect(lots.map((l) => (l.name, l.initialQuantity, l.unit)).toSet(), {
      ('Farina', 1.5, 'kg'),
      ('Latte intero', 1.0, 'pz'),
    });
    expect(lots.every((l) => l.source == PantrySource.receipt), isTrue);

    // The history lists it; its rows sit in closed category sections.
    await tester.tap(find.text('Storico'));
    await settle(tester);
    expect(find.text('Negozio sconosciuto'), findsOneWidget);
    expect(find.text(Money.format(339)), findsOneWidget);
    expect(find.textContaining('2 articoli · A mano'), findsOneWidget);

    await tester.tap(find.text('Negozio sconosciuto'));
    await settle(tester);
    expect(find.text('Latticini e uova'), findsOneWidget);
    expect(find.text('Latte intero'), findsNothing);
    await tester.tap(find.text('Latticini e uova'));
    await settle(tester);
    expect(find.text('Latte intero'), findsOneWidget);
    expect(find.text(Money.format(129)), findsNWidgets(2)); // section + row

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
