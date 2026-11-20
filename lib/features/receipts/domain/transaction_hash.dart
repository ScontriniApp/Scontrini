import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Identity of a receipt as a SHA-256 hex string, stored in
/// `receipts.transaction_hash`. The same receipt scanned twice gives the same
/// hash, so the unique column rejects the duplicate.
///
/// Compute it from the *reviewed* fields when the receipt is confirmed, and
/// again whenever one of them is corrected. Inputs:
/// - store: the VAT number when known (digits only), otherwise the
///   normalised store name;
/// - [purchaseDate] to the minute, in UTC;
/// - [totalCents];
/// - [documentNumber], the "documento commerciale" number, once the parser
///   reads it;
/// - [attempt] > 0 only when the user says a colliding receipt is really a
///   different purchase.
///
/// Changing the recipe changes every hash: bump the `v1` prefix and
/// recompute stored hashes in a migration.
String transactionHash({
  required DateTime purchaseDate,
  required int totalCents,
  String? vatNumber,
  String? storeName,
  String? documentNumber,
  int attempt = 0,
}) {
  final vat = vatNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
  final store = vat.isNotEmpty
      ? 'vat:$vat'
      : 'name:${_normalise(storeName ?? '')}';
  final utc = purchaseDate.toUtc();
  final minute =
      '${utc.year.toString().padLeft(4, '0')}-${_two(utc.month)}-'
      '${_two(utc.day)}T${_two(utc.hour)}:${_two(utc.minute)}';
  final document = (documentNumber ?? '').toUpperCase().replaceAll(
    RegExp(r'\s+'),
    '',
  );
  final identity = [
    'v1',
    store,
    minute,
    '$totalCents',
    document,
    if (attempt > 0) 'attempt:$attempt',
  ].join('|');
  return sha256.convert(utf8.encode(identity)).toString();
}

/// Short form shown in the UI, e.g. `#a3f91c02`.
String shortTransactionTag(String hash) => '#${hash.substring(0, 8)}';

String _normalise(String value) =>
    value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

String _two(int value) => value.toString().padLeft(2, '0');
