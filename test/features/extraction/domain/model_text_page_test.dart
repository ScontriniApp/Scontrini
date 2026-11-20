import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/extraction/domain/model_text_page.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

void main() {
  test('each line of model text stays its own row', () {
    const text = '''
```
* ESSELUNGA S.p.A. *

MARITOZZO *c 3,99
  SCONTO 30%   0,84-S
TOTALE EURO 14,00 *
```''';
    final rows = const RowBuilder().build(
      OcrDocument(source: TextSource.ocr, pages: [modelTextToPage(text)]),
    );

    expect(
      [for (final row in rows) row.text],
      [
        '* ESSELUNGA S.p.A. *',
        'MARITOZZO *c 3,99',
        'SCONTO 30%   0,84-S',
        'TOTALE EURO 14,00 *',
      ],
    );
  });
}
