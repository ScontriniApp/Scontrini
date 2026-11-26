import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/capture/data/capture_providers.dart';
import 'package:scontrini/features/capture/data/receipt_capture_service.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/text_extractor.dart';

class _MockCapture extends Mock implements ReceiptCaptureService;

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
  setUpAll(() => registerFallbackValue(_source));

  late _MockCapture capture;
  late _MockExtractor extractor;

  setUp(() {
    capture = _MockCapture();
    extractor = _MockExtractor();
  });

  /// The review loads category guesses from Drift, which runs on real
  /// async work the fake clock never advances: give it real time.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> openCapture(WidgetTester tester) async {
    // A tall phone, so the review's rows fit without scrolling.
    tester.view
      ..physicalSize = const Size(1080, 9000)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    // The app opens on the dashboard, which watches the database: unmount
    // and let Drift's timers run before closing it (as in widget_test.dart).
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          receiptCaptureServiceProvider.overrideWithValue(capture),
          textExtractorProvider.overrideWithValue(extractor),
        ],
        child: const ScontriniApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
  }

  testWidgets('a scanned receipt is read and shown', (tester) async {
    when(() => capture.scan()).thenAnswer((_) async => _source);
    when(() => extractor.extract(_source, onProgress: any(named: 'onProgress')))
        .thenAnswer(
          (_) async => _document([
            'SUPERMERCATO ESEMPIO',
            'LATTE INTERO 1,29',
            'PANE 1,10',
            'TOTALE 3,00',
          ]),
        );

    await openCapture(tester);
    await tester.tap(find.text('Scansiona con la fotocamera'));
    await settle(tester);

    expect(find.text('Controlla lo scontrino'), findsOneWidget);
    expect(find.text('SUPERMERCATO ESEMPIO'), findsOneWidget);
    expect(find.text('LATTE INTERO'), findsOneWidget);
    expect(find.text('Articoli (2), 2 da controllare'), findsOneWidget);
    // Problems show on their line, not as banners.
    expect(find.text('Data non trovata'), findsNothing);
    expect(find.text('Somma articoli'), findsOneWidget);
  });

  testWidgets('cancelling the picker stays on the capture screen', (
    tester,
  ) async {
    when(() => capture.pickImages()).thenAnswer((_) async => null);

    await openCapture(tester);
    await tester.tap(find.text('Scegli dalla galleria'));
    await tester.pumpAndSettle();

    expect(find.text('Nuovo scontrino'), findsOneWidget);
    verifyNever(
      () => extractor.extract(any(), onProgress: any(named: 'onProgress')),
    );
  });

  testWidgets('a capture error shows a message', (tester) async {
    when(() => capture.pickPdf()).thenThrow(Exception('no file'));

    await openCapture(tester);
    await tester.tap(find.text('Importa PDF'));
    await tester.pump();

    expect(find.text('Impossibile acquisire lo scontrino.'), findsOneWidget);
  });

  testWidgets('an extraction error can be retried', (tester) async {
    var calls = 0;
    when(() => capture.scan()).thenAnswer((_) async => _source);
    when(() => extractor.extract(_source, onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async {
          if (calls++ == 0) throw Exception('OCR failed');
          return _document(['PANE 1,10', 'TOTALE 1,10']);
        });

    await openCapture(tester);
    await tester.tap(find.text('Scansiona con la fotocamera'));
    await tester.pumpAndSettle();
    expect(find.text('Impossibile leggere lo scontrino.'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await settle(tester);
    expect(find.text('PANE'), findsOneWidget);
  });

  testWidgets('a progress bar shows how far reading is', (tester) async {
    final done = Completer<OcrDocument>();
    when(() => capture.scan()).thenAnswer((_) async => _source);
    when(() => extractor.extract(_source, onProgress: any(named: 'onProgress')))
        .thenAnswer((invocation) {
          final onProgress =
              invocation.namedArguments[#onProgress] as OnReadProgress?;
          onProgress?.call((step: ReadStep.readingLines, fraction: 0.5));
          return done.future;
        });

    await openCapture(tester);
    await tester.tap(find.text('Scansiona con la fotocamera'));
    await tester.pump();
    await tester.pump();
    // The bar eases to the new value.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Leggo le righe… 50%'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(0.5, 0.01));

    done.complete(_document(['PANE 1,10', 'TOTALE 1,10']));
    await settle(tester);
    expect(find.text('PANE'), findsOneWidget);
  });
}
