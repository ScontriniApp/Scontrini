import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scontrini/features/capture/data/receipt_capture_service.dart';
import 'package:scontrini/features/capture/data/receipt_file_store.dart';

final receiptFileStoreProvider = Provider<ReceiptFileStore>(
  (ref) => ReceiptFileStore(getApplicationDocumentsDirectory),
);

final receiptCaptureServiceProvider = Provider<ReceiptCaptureService>(
  (ref) => ReceiptCaptureService(ref.watch(receiptFileStoreProvider)),
);
