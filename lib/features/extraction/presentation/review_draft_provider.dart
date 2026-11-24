import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/receipt_draft.dart';
import 'package:scontrini/features/extraction/presentation/extraction_result_provider.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';

/// The draft the review screen starts from: the parsed receipt with a
/// guessed category on each row. Edits live in the screen, not here.
final FutureProviderFamily<ReceiptDraft, ReceiptSource> reviewDraftProvider =
    FutureProvider.autoDispose.family<ReceiptDraft, ReceiptSource>((
      ref,
      source,
    ) async {
      final result = await ref.watch(extractionResultProvider(source).future);
      final receipt = result.receipt;
      final categories = await ref
          .watch(receiptRepositoryProvider)
          .guessCategories([for (final i in receipt.items) i.rawName]);
      return ReceiptDraft.fromParsed(receipt, categoryIds: categories);
    }, retry: (_, _) => null);
