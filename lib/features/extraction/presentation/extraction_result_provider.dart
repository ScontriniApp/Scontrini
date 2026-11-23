import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/extraction_result.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

/// How far along reading one captured receipt is (see
/// [extractionResultProvider]); `null` before the first report.
final NotifierProviderFamily<ExtractionProgress, ReadProgress?, ReceiptSource>
extractionProgressProvider = NotifierProvider.autoDispose
    .family<ExtractionProgress, ReadProgress?, ReceiptSource>(
      (_) => ExtractionProgress(),
    );

class ExtractionProgress extends Notifier<ReadProgress?> {
  @override
  ReadProgress? build() => null;

  /// Safe to call from inside [extractionResultProvider]'s build (a
  /// reader may report before its first await): the update waits for a
  /// microtask, in order.
  void report(ReadProgress progress) => scheduleMicrotask(() {
    if (ref.mounted) state = progress;
  });
}

/// Runs text extraction, row rebuilding and parsing for one captured receipt.
final FutureProviderFamily<ExtractionResult, ReceiptSource>
extractionResultProvider = FutureProvider.autoDispose
    .family<ExtractionResult, ReceiptSource>(
      (ref, source) async {
        final progress = ref.watch(extractionProgressProvider(source).notifier);
        final document = await ref
            .watch(textExtractorProvider)
            .extract(source, onProgress: progress.report);
        progress.report((step: ReadStep.parsing, fraction: 1));
        final rows = const RowBuilder().build(document);
        final receipt = const ReceiptParser().parseLines([
          for (final row in rows) row.text,
        ]);
        return ExtractionResult(
          document: document,
          rows: rows,
          receipt: receipt,
        );
      },
      // An unreadable receipt won't get better by itself: show the error and
      // let the user retry.
      retry: (_, _) => null,
    );
