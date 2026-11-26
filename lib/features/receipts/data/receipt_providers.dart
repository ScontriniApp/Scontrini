import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/receipts/data/bulk_receipt_importer.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => ReceiptRepository(ref.watch(appDatabaseProvider)),
);

/// Debug bulk import of PDFs, saved without review and kept out of the
/// pantry.
final bulkReceiptImporterProvider = Provider<BulkReceiptImporter>(
  (ref) => BulkReceiptImporter(
    ref.watch(textExtractorProvider),
    ref.watch(receiptRepositoryProvider),
  ),
);

/// Confirmed receipts, newest first (the history tab).
final receiptHistoryProvider = StreamProvider<List<ReceiptSummary>>(
  (ref) => ref.watch(receiptRepositoryProvider).watchHistory(),
);

/// One receipt with its rows; `null` once deleted.
final StreamProviderFamily<ReceiptDetail?, int> receiptDetailProvider =
    StreamProvider.autoDispose.family<ReceiptDetail?, int>(
      (ref, id) => ref.watch(receiptRepositoryProvider).watchReceipt(id),
    );
