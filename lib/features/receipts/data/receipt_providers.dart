import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/core/database/database_provider.dart';
import 'package:scontrini/features/receipts/data/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => ReceiptRepository(ref.watch(appDatabaseProvider)),
);
