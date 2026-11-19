import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/domain/models/ocr_document.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_line.dart';
import 'package:scontrini/features/extraction/domain/models/ocr_page.dart';
import 'package:scontrini/features/extraction/domain/models/text_box.dart';
import 'package:scontrini/features/extraction/domain/models/text_source.dart';

/// What one GLM-OCR call cost, to estimate the time on a phone.
class GlmUsage {
  const new({
    required this.promptTokens,
    required this.completionTokens,
    required this.milliseconds,
  });

  /// Mostly image tokens: grows with the image resolution.
  final int promptTokens;

  /// Generated text: on a phone, time grows linearly with this.
  final int completionTokens;
  final int milliseconds;
}

/// Reads receipt photos with GLM-OCR (a 0.9B vision-language OCR model)
/// served on the PC by LM Studio's OpenAI-compatible API. Experiment only:
/// it measures whether the model reads receipts better than ML Kit before
/// anyone spends time running it on a phone.
///
/// Start it with `lms load glm-ocr` and `lms server start` (see README).
class GlmOcrReader {
  new({
    this.endpoint = 'http://localhost:1234/v1/chat/completions',
    this.model = 'glm-ocr',
    this.maxSide = 2048,
  });

  final String endpoint;
  final String model;

  /// Longer images are scaled down first: LM Studio sends the image at full
  /// size, and phone photos would cost thousands of image tokens.
  final int maxSide;

  /// The model's own prompt for plain text output.
  static const _prompt = 'Text Recognition:';

  /// Reads each image (one page per image) and returns the text as an
  /// [OcrDocument] with one line per printed row.
  Future<(OcrDocument, GlmUsage)> read(List<String> imagePaths) async {
    final pages = <OcrPage>[];
    var promptTokens = 0;
    var completionTokens = 0;
    final watch = Stopwatch()..start();
    for (final path in imagePaths) {
      final (text, usage) = await _recognize(path);
      promptTokens += usage.$1;
      completionTokens += usage.$2;
      pages.add(textToPage(text));
    }
    return (
      OcrDocument(source: TextSource.ocr, pages: pages),
      GlmUsage(
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        milliseconds: watch.elapsedMilliseconds,
      ),
    );
  }

  /// One [OcrLine] per non-empty line, stacked so that `RowBuilder` keeps
  /// each one as its own row: the model already returns printed rows.
  static OcrPage textToPage(String text) {
    final lines = [
      for (final line in const LineSplitter().convert(text))
        if (line.trim().isNotEmpty && !line.trim().startsWith('```'))
          line.trim(),
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

  Future<(String, (int, int))> _recognize(String path) async {
    final (bytes, mime) = _prepare(path);
    final body = jsonEncode({
      'model': model,
      'temperature': 0,
      'max_tokens': 4096,
      // No system message: the model was not trained with one.
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mime;base64,${base64Encode(bytes)}'},
            },
            {'type': 'text', 'text': _prompt},
          ],
        },
      ],
    });

    // flutter_test replaces HttpClient with a fake that answers 400 to
    // everything; this experiment needs the real one.
    final response = await HttpOverrides.runWithHttpOverrides(() async {
      final client = HttpClient();
      try {
        final request = await client.postUrl(Uri.parse(endpoint));
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(body));
        final reply = await request.close();
        final text = await reply.transform(utf8.decoder).join();
        if (reply.statusCode != 200) {
          throw HttpException('LM Studio ${reply.statusCode}: $text');
        }
        return jsonDecode(text) as Map<String, Object?>;
      } on SocketException {
        throw StateError(
          'LM Studio is not reachable at $endpoint: '
          'run `lms load glm-ocr` and `lms server start`',
        );
      } finally {
        client.close();
      }
    }, _RealHttp());

    final choice = (response['choices']! as List).first as Map<String, Object?>;
    final message = choice['message']! as Map<String, Object?>;
    final usage = response['usage'] as Map<String, Object?>? ?? const {};
    return (
      message['content']! as String,
      (
        (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
        (usage['completion_tokens'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  (List<int>, String) _prepare(String path) {
    final bytes = File(path).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw FormatException('cannot decode $path');
    }
    final longest = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    final extension = p.extension(path).toLowerCase();
    if (longest <= maxSide && (extension == '.png' || extension == '.jpg')) {
      return (bytes, extension == '.png' ? 'image/png' : 'image/jpeg');
    }
    // Too big, or a format the server may not take (webp, bmp): re-encode.
    final resized = longest <= maxSide
        ? decoded
        : img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? maxSide : null,
            height: decoded.height > decoded.width ? maxSide : null,
          );
    return (img.encodeJpg(resized, quality: 92), 'image/jpeg');
  }
}

class _RealHttp extends HttpOverrides;
