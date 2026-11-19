import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/capture/data/receipt_file_store.dart';

void main() {
  test('copies files into receipts/ with unique lower-case names', () async {
    final temp = await Directory.systemTemp.createTemp('store_test');
    addTearDown(() => temp.delete(recursive: true));
    final a = await File('${temp.path}/A.JPG').writeAsString('a');
    final b = await File('${temp.path}/b.jpg').writeAsString('b');

    final kept = await ReceiptFileStore(() async => temp)
        .keepAll([a.path, b.path]);

    expect(kept, hasLength(2));
    expect(kept.toSet(), hasLength(2));
    for (final path in kept) {
      expect(path, startsWith('${temp.path}/receipts/'));
      expect(path, endsWith('.jpg'));
    }
    expect(await File(kept[1]).readAsString(), 'b');
    expect(a.existsSync(), isTrue, reason: 'the original is left in place');
  });
}
