import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

class _MockExtractor extends Mock implements TextExtractor;

const _source = ReceiptSource.images(['/receipts/1.jpg']);

/// One OCR line per row, so the row builder keeps them in order.
OcrDocument _document(List<String> rows) => OcrDocument(
  source: TextSource.ocr,
  pages: [
    OcrPage(
      width: 1000,
      height: 2000,
      lines: [
        for (final (i, text) in rows.indexed)
          OcrLine(
            text: text,
            box: TextBox(left: 0, top: i * 40, right: 500, bottom: i * 40 + 30),
          ),
      ],
    ),
  ],
);

void main() {
  late AppDatabase db;
  late _MockExtractor extractor;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    extractor = _MockExtractor();
    when(() => extractor.extract(_source, onProgress: any(named: 'onProgress')))
        .thenAnswer(
          (_) async => _document([
            'SUPERMERCATO ESEMPIO',
            'LATTE INTERO 1,29',
            'PANE 1,10',
            'TOTALE 3,00',
          ]),
        );
  });

  /// Drift runs on real async work, which the fake clock never advances:
  /// give it real time, then rebuild.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Opens the review of the receipt above, straight from the router.
  Future<void> openReview(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1080, 9000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          textExtractorProvider.overrideWithValue(extractor),
        ],
        child: const ScontriniApp(),
      ),
    );
    await settle(tester);
    final context = tester.element(find.byType(Scaffold).first);
    unawaited(
      ProviderScope.containerOf(context)
          .read(routerProvider)
          .push(Routes.extraction, extra: _source),
    );
    await settle(tester);
  }

  ButtonStyleButton saveButton(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(find.byKey(const Key('review-save')));

  /// The Android back button.
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  /// Types [text] in the field dialog opened by tapping [field].
  Future<void> editField(WidgetTester tester, String field, String text) async {
    await tester.tap(find.text(field));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('review-dialog-field')), text);
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
  }

  Future<int> categoryId(String name) async => (await (db.select(
    db.categories,
  )..where((c) => c.name.equals(name))).getSingle()).id;

  testWidgets('shows the guessed categories and the warnings', (tester) async {
    await openReview(tester);
    expect(find.text('Controlla lo scontrino'), findsOneWidget);
    expect(find.text('LATTE INTERO'), findsOneWidget);
    expect(find.textContaining('Latticini e uova'), findsOneWidget);
    expect(find.text('Data non trovata'), findsOneWidget);
    expect(
      find.text(
        'Somma articoli ${Money.format(239)}, totale ${Money.format(300)}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('header edits clear their warnings', (tester) async {
    await openReview(tester);

    await editField(tester, 'SUPERMERCATO ESEMPIO', 'Coop Milano');
    expect(find.text('Coop Milano'), findsOneWidget);

    await editField(tester, 'Totale', '2,39');
    expect(
      find.text('La somma degli articoli non corrisponde al totale'),
      findsNothing,
    );

    await editField(tester, 'Totale', '3,00');
    await tester.tap(find.text('Usa la somma'));
    await tester.pumpAndSettle();
    expect(find.text('Usa la somma'), findsNothing);
    expect(
      find.text(Money.format(239)),
      findsNWidgets(2),
    ); // total and items sum

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // date
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // time
    await tester.pumpAndSettle();
    expect(find.text('Data non trovata'), findsNothing);
    expect(find.text('—'), findsNothing);
  });

  testWidgets('a row can be corrected, added and deleted with undo', (
    tester,
  ) async {
    await openReview(tester);

    await tester.tap(find.text('PANE'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('review-item-name')),
      'PANE INTEGRALE',
    );
    await tester.enterText(find.byKey(const Key('review-item-amount')), '1,71');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('PANE INTEGRALE'), findsOneWidget);
    expect(find.text(Money.format(171)), findsOneWidget);
    expect(
      find.text('La somma degli articoli non corrisponde al totale'),
      findsNothing,
    );

    await tester.tap(find.text('Aggiungi articolo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('review-item-name')), 'MELE');
    await tester.enterText(
      find.byKey(const Key('review-item-quantity')),
      '0,5',
    );
    await tester.tap(find.text('kg'));
    await tester.enterText(
      find.byKey(const Key('review-item-unit-price')),
      '2,00',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('review-item-amount')),
              matching: find.byType(TextField),
            ),
          )
          .controller!
          .text,
      '1,00',
    );
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Articoli (3), 1 da controllare'), findsOneWidget);
    expect(
      find.textContaining('0,5 kg × ${Money.format(200)}/kg'),
      findsOneWidget,
    );

    await tester.tap(find.text('LATTE INTERO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    expect(find.text('LATTE INTERO'), findsNothing);
    expect(find.text('Articoli (2)'), findsOneWidget);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('LATTE INTERO'), findsOneWidget);
    expect(find.text('Articoli (3), 1 da controllare'), findsOneWidget);
  });

  testWidgets('leaving with edits asks before discarding them', (tester) async {
    await openReview(tester);
    await editField(tester, 'SUPERMERCATO ESEMPIO', 'Coop');

    await systemBack(tester);
    await tester.pumpAndSettle();
    expect(find.text('Scartare le modifiche?'), findsOneWidget);
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Coop'), findsOneWidget);

    await systemBack(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scarta'));
    await settle(tester);
    expect(find.text('Controlla lo scontrino'), findsNothing);
  });

  testWidgets('every product must be confirmed or corrected to save', (
    tester,
  ) async {
    await openReview(tester);
    expect(find.text('Articoli (2), 2 da controllare'), findsOneWidget);
    expect(find.text('Mancano 2 prodotti da controllare'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(find.text('Corretto').first);
    await tester.pumpAndSettle();
    expect(find.text('Manca 1 prodotto da controllare'), findsOneWidget);
    expect(find.text('Corretto'), findsOneWidget);

    // A correction confirms the row.
    await tester.tap(find.text('Correggi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Articoli (2)'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    // A confirmed row can be put back to check again.
    await tester.tap(find.byTooltip('Da ricontrollare').first);
    await tester.pumpAndSettle();
    expect(find.text('Manca 1 prodotto da controllare'), findsOneWidget);
  });

  testWidgets('saving stores the receipt and puts its products in the pantry', (
    tester,
  ) async {
    await openReview(tester);
    await editField(tester, 'SUPERMERCATO ESEMPIO', 'Coop');
    await tester.tap(find.text('Usa la somma'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PANE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('review-item-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa e igiene').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corretto'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva scontrino'));
    await settle(tester);
    expect(find.text('Controlla lo scontrino'), findsNothing);
    expect(
      find.text('Scontrino salvato, 2 prodotti in dispensa.'),
      findsOneWidget,
    );

    final receipt = await tester.runAsync(
      () => db.select(db.receipts).getSingle(),
    );
    expect(receipt!.totalCents, 239);
    expect(receipt.status, ReceiptStatus.confirmed);
    final store = await tester.runAsync(() => db.select(db.stores).getSingle());
    expect(store!.name, 'Coop');
    final rows = await tester.runAsync(
      () => (db.select(
        db.receiptItems,
      )..orderBy([(r) => OrderingTerm.asc(r.id)])).get(),
    );
    final dairy = await tester.runAsync(() => categoryId('Latticini e uova'));
    final home = await tester.runAsync(() => categoryId('Casa e igiene'));
    expect(rows!.map((r) => (r.rawName, r.categoryId)), [
      ('LATTE INTERO', dairy),
      ('PANE', home),
    ]);
    expect(rows.every((r) => r.pantryLotId != null), isTrue);
    final lots = await tester.runAsync(() => db.select(db.pantryLots).get());
    expect(lots!.map((l) => (l.name, l.receiptId)), [
      ('LATTE INTERO', receipt.id),
      ('PANE', receipt.id),
    ]);
  });

  testWidgets('without rows the receipt cannot be confirmed', (tester) async {
    when(() => extractor.extract(_source, onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => _document(['SUPERMERCATO ESEMPIO']));
    await openReview(tester);
    expect(
      find.text('Nessun articolo: aggiungine almeno uno per confermare.'),
      findsOneWidget,
    );
    expect(saveButton(tester).onPressed, isNull);
  });
}
