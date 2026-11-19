import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scontrini/app/app.dart';
import 'package:scontrini/core/database/app_database.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/capture/data/capture_providers.dart';
import 'package:scontrini/features/capture/data/receipt_capture_service.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
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

  Future<void> openCapture(WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
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
    when(() => extractor.extract(_source)).thenAnswer(
      (_) async => _document([
        'SUPERMERCATO ESEMPIO',
        'LATTE INTERO 1,29',
        'PANE 1,10',
        'TOTALE 3,00',
      ]),
    );

    await openCapture(tester);
    await tester.tap(find.text('Scansiona con la fotocamera'));
    await tester.pumpAndSettle();

    expect(find.text('Scontrino letto'), findsOneWidget);
    expect(find.text('SUPERMERCATO ESEMPIO'), findsOneWidget);
    expect(find.text('LATTE INTERO'), findsOneWidget);
    expect(find.text('Articoli (2)'), findsOneWidget);
    expect(find.text('Data non trovata'), findsOneWidget);
    expect(
      find.text('La somma degli articoli non corrisponde al totale'),
      findsOneWidget,
    );
  });

  testWidgets('cancelling the picker stays on the capture screen', (
    tester,
  ) async {
    when(() => capture.pickImages()).thenAnswer((_) async => null);

    await openCapture(tester);
    await tester.tap(find.text('Scegli dalla galleria'));
    await tester.pumpAndSettle();

    expect(find.text('Nuovo scontrino'), findsOneWidget);
    verifyNever(() => extractor.extract(any()));
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
    when(() => extractor.extract(_source)).thenAnswer((_) async {
      if (calls++ == 0) throw Exception('OCR failed');
      return _document(['PANE 1,10', 'TOTALE 1,10']);
    });

    await openCapture(tester);
    await tester.tap(find.text('Scansiona con la fotocamera'));
    await tester.pumpAndSettle();
    expect(find.text('Impossibile leggere lo scontrino.'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();
    expect(find.text('PANE'), findsOneWidget);
  });
}
