import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => ReceiptRepository(ref.watch(appDatabaseProvider)),
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
