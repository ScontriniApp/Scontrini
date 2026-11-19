import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/extraction_result.dart';
import 'package:scontrini/features/extraction/domain/receipt_parser.dart';
import 'package:scontrini/features/extraction/domain/row_builder.dart';

/// Runs text extraction, row rebuilding and parsing for one captured receipt.
final FutureProviderFamily<ExtractionResult, ReceiptSource>
extractionResultProvider = FutureProvider.autoDispose
    .family<ExtractionResult, ReceiptSource>(
      (ref, source) async {
        final document = await ref.watch(textExtractorProvider).extract(source);
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
