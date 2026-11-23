import 'dart:convert';

import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';

/// Turns the plain text of an OCR model (GLM-OCR), which already comes as
/// one printed row per line, into an [OcrPage]: one [OcrLine] per non-empty
/// line, stacked so that `RowBuilder` keeps each one as its own row.
/// Markdown code fences around the text are dropped.
OcrPage modelTextToPage(String text) {
  final lines = [
    for (final line in const LineSplitter().convert(text))
      if (line.trim().isNotEmpty && !line.trim().startsWith('```')) line.trim(),
  ];
  const rowHeight = 20.0;
  return OcrPage(
    width: 1000,
    height: lines.length * rowHeight,
    lines: [
      for (final (i, line) in lines.indexed)
        OcrLine(
          text: line,
          box: TextBox(
            left: 0,
            top: i * rowHeight,
            right: 1000,
            bottom: i * rowHeight + rowHeight - 4,
          ),
        ),
    ],
  );
}
