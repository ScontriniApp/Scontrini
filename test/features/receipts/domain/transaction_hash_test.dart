import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';

void main() {
  final date = DateTime.utc(2026, 11, 18, 10, 41, 37);

  test('same receipt gives the same hash, seconds ignored', () {
    final a = transactionHash(
      purchaseDate: date,
      totalCents: 2345,
      vatNumber: 'IT 04916380159',
    );
    final b = transactionHash(
      purchaseDate: DateTime.utc(2026, 11, 18, 10, 41, 2),
      totalCents: 2345,
      vatNumber: '04916380159',
      storeName: 'ignored when the VAT number is known',
    );
    expect(a, b);
    expect(a, hasLength(64));
    expect(shortTransactionTag(a), matches(RegExp(r'^#[0-9a-f]{8}$')));
  });

  test('local and UTC times of the same instant match', () {
    expect(
      transactionHash(purchaseDate: date.toLocal(), totalCents: 1),
      transactionHash(purchaseDate: date, totalCents: 1),
    );
  });

  test('any identity field changes the hash', () {
    final base = transactionHash(
      purchaseDate: date,
      totalCents: 2345,
      storeName: 'Esselunga',
    );
    expect(
      transactionHash(
        purchaseDate: date,
        totalCents: 2345,
        storeName: '  esselunga ',
      ),
      base,
    );
    for (final other in [
      transactionHash(
        purchaseDate: date,
        totalCents: 2346,
        storeName: 'Esselunga',
      ),
      transactionHash(
        purchaseDate: date.add(const Duration(minutes: 1)),
        totalCents: 2345,
        storeName: 'Esselunga',
      ),
      transactionHash(purchaseDate: date, totalCents: 2345, storeName: 'PAM'),
      transactionHash(
        purchaseDate: date,
        totalCents: 2345,
        storeName: 'Esselunga',
        documentNumber: '1234-0056',
      ),
      transactionHash(
        purchaseDate: date,
        totalCents: 2345,
        storeName: 'Esselunga',
        attempt: 1,
      ),
    ]) {
      expect(other, isNot(base));
    }
  });
}
