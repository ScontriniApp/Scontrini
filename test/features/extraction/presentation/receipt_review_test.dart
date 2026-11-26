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
import 'package:scontrini/core/paper/paper_bubble.dart';
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

  /// The bottom bar's "Conferma tutti", shown while products are left.
  Finder confirmAll() => find.byKey(const Key('review-confirm-all'));

  /// The Android back button.
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  /// Selects the header line [field], then types [text] in the dialog its
  /// "Correggi" opens.
  Future<void> editField(WidgetTester tester, String field, String text) async {
    await tester.tap(find.text(field));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Correggi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('review-dialog-field')), text);
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
  }

  /// Selects the product [name] and opens its correction form.
  Future<void> correct(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Correggi'));
    await tester.pumpAndSettle();
  }

  /// Selects the rows' sum and takes it as the total.
  Future<void> useSum(WidgetTester tester) async {
    await tester.tap(find.text('Somma articoli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usa la somma'));
    await tester.pumpAndSettle();
  }

  /// The text style a line's [text] is drawn with (grows when selected).
  TextStyle styleOf(WidgetTester tester, String text) => tester
      .widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      )
      .style;

  Future<int> categoryId(String name) async => (await (db.select(
    db.categories,
  )..where((c) => c.name.equals(name))).getSingle()).id;

  testWidgets('a receipt on paper: header, items heading, products', (
    tester,
  ) async {
    await openReview(tester);
    expect(find.text('Controlla lo scontrino'), findsOneWidget);
    expect(find.byType(PaperBubble), findsOneWidget);
    expect(find.text('LATTE INTERO'), findsOneWidget);
    expect(find.textContaining('Latticini e uova'), findsOneWidget);

    // No advice and no banners: problems are triangles on their line.
    expect(find.textContaining('Controlla ogni prodotto'), findsNothing);
    expect(find.text('Data non trovata'), findsNothing);
    expect(
      find.text('La somma degli articoli non corrisponde al totale'),
      findsNothing,
    );
    Finder flagged(String line) => find.descendant(
      of: find.byKey(ValueKey('review-$line')),
      matching: find.byIcon(Icons.warning_amber),
    );
    expect(flagged('date'), findsOneWidget);
    expect(flagged('total'), findsOneWidget);
    expect(flagged('sum'), findsOneWidget);
    expect(flagged('store'), findsNothing);
    expect(flagged('discount'), findsNothing);

    // The store is the title, centred like the rest of the head.
    final store = tester.getCenter(find.text('SUPERMERCATO ESEMPIO')).dx;
    final sheet = tester.getCenter(find.byType(PaperBubble)).dx;
    expect(store, closeTo(sheet, 2));

    // Printed in receipt order.
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    final order = [
      'SUPERMERCATO ESEMPIO',
      'Data',
      'Totale',
      'Sconti sul totale',
      'Somma articoli',
      'Articoli (2), 2 da controllare',
      'Aggiungi articolo',
      'LATTE INTERO',
      'PANE',
    ].map(top).toList();
    expect(order, [...order]..sort());

    // No buttons until a line is tapped.
    expect(find.text('Corretto'), findsNothing);
    expect(find.text('Correggi'), findsNothing);
    expect(find.text('Usa la somma'), findsNothing);
  });

  testWidgets('header lines are selected like products', (tester) async {
    await openReview(tester);
    final plain = styleOf(tester, 'Data');
    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    expect(find.text('Correggi'), findsOneWidget);
    expect(find.text('Corretto'), findsNothing);
    final picked = styleOf(tester, 'Data');
    expect(picked.fontWeight, FontWeight.bold);
    expect(picked.fontSize, greaterThan(plain.fontSize!));

    // The sum offers itself as the total; one line at a time.
    await tester.tap(find.text('Somma articoli'));
    await tester.pumpAndSettle();
    expect(find.text('Usa la somma'), findsOneWidget);
    expect(find.text('Correggi'), findsNothing);
    expect(styleOf(tester, 'Data').fontWeight, isNot(FontWeight.bold));
  });

  testWidgets('one product at a time shows its buttons', (tester) async {
    await openReview(tester);
    await tester.tap(find.text('LATTE INTERO'));
    await tester.pumpAndSettle();
    expect(find.text('Corretto'), findsOneWidget);
    expect(find.text('Correggi'), findsOneWidget);

    // Another product takes the selection.
    await tester.tap(find.text('PANE'));
    await tester.pumpAndSettle();
    expect(find.text('Corretto'), findsOneWidget);
    final buttons = tester.getTopLeft(find.text('Corretto')).dy;
    expect(buttons, greaterThan(tester.getTopLeft(find.text('PANE')).dy));
    // Selected: bigger and bold, no highlight box.
    expect(styleOf(tester, 'PANE').fontWeight, FontWeight.bold);
    expect(styleOf(tester, 'LATTE INTERO').fontWeight, isNot(FontWeight.bold));
    expect(
      find.ancestor(of: find.text('PANE'), matching: find.byType(ListTile)),
      findsNothing,
    );

    // Tapped again, it closes.
    await tester.tap(find.text('PANE'));
    await tester.pumpAndSettle();
    expect(find.text('Corretto'), findsNothing);
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
    await useSum(tester);
    expect(find.text('Usa la somma'), findsNothing);
    expect(
      find.text(Money.format(239)),
      findsNWidgets(2),
    ); // total and items sum

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Correggi'));
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

    await correct(tester, 'PANE');
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

    await correct(tester, 'LATTE INTERO');
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
    // No save yet: the bar offers to confirm the two left.
    expect(find.text('Conferma tutti (2)'), findsOneWidget);
    expect(find.byKey(const Key('review-save')), findsNothing);

    await tester.tap(find.text('LATTE INTERO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corretto'));
    await tester.pumpAndSettle();
    expect(find.text('Conferma tutti (1)'), findsOneWidget);
    // Confirmed, the row closes.
    expect(find.text('Corretto'), findsNothing);

    // A correction confirms the row.
    await correct(tester, 'PANE');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Articoli (2)'), findsOneWidget);
    expect(confirmAll(), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);

    // A confirmed row can be put back to check again.
    await tester.tap(find.text('LATTE INTERO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Da ricontrollare'));
    await tester.pumpAndSettle();
    expect(find.text('Conferma tutti (1)'), findsOneWidget);
  });

  testWidgets('confirm all splits into undo all and save', (tester) async {
    await openReview(tester);
    // Only in the bottom bar, not on the receipt.
    expect(
      find.descendant(
        of: find.byType(PaperBubble),
        matching: find.textContaining('Conferma tutti'),
      ),
      findsNothing,
    );
    await tester.tap(confirmAll());
    await tester.pumpAndSettle();
    expect(find.text('Articoli (2)'), findsOneWidget);
    expect(confirmAll(), findsNothing);
    expect(saveButton(tester).onPressed, isNotNull);
    // Undo all on the left, save on the right, in green.
    final undo = tester.getCenter(
      find.byKey(const Key('review-unconfirm-all')),
    );
    final save = tester.getCenter(find.byKey(const Key('review-save')));
    expect(undo.dx, lessThan(save.dx));
    expect(
      saveButton(tester).style?.backgroundColor?.resolve({}),
      const Color(0xFF2E7D32),
    );

    await tester.tap(find.text('Annulla tutto'));
    await tester.pumpAndSettle();
    expect(find.text('Articoli (2), 2 da controllare'), findsOneWidget);
    expect(find.text('Conferma tutti (2)'), findsOneWidget);
    expect(find.byKey(const Key('review-save')), findsNothing);
  });

  testWidgets('the print does not slide off its paper when dragged', (
    tester,
  ) async {
    await openReview(tester);
    final before = tester.getTopLeft(find.text('LATTE INTERO'));
    // Pulled past the top (the receipt fits: nothing to scroll), held.
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('LATTE INTERO')),
    );
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    expect(tester.getTopLeft(find.text('LATTE INTERO')), before);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('LATTE INTERO')), before);
  });

  testWidgets('the recognised text is not shown', (tester) async {
    await openReview(tester);
    expect(find.text('Testo riconosciuto'), findsNothing);
  });

  testWidgets('saving stores the receipt and puts its products in the pantry', (
    tester,
  ) async {
    await openReview(tester);
    await editField(tester, 'SUPERMERCATO ESEMPIO', 'Coop');
    await useSum(tester);

    await correct(tester, 'PANE');
    await tester.tap(find.byKey(const Key('review-item-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa e igiene').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LATTE INTERO'));
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
