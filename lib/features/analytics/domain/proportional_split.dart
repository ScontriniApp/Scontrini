/// Splits [amount] cents into parts proportional to [weights], so that the
/// parts add up to exactly [amount].
///
/// Uses the largest-remainder method: every part gets its rounded-down share,
/// then the cents left over go one each to the parts with the largest
/// remainders, earlier parts first on ties. A part never differs from its
/// exact share by a cent or more.
///
/// [amount] must be non-negative, and [weights] non-negative with a positive
/// sum.
List<int> splitProportionally(int amount, List<int> weights) {
  if (amount < 0) {
    throw ArgumentError.value(amount, 'amount', 'must not be negative');
  }
  final total = weights.fold(0, (sum, w) => sum + w);
  if (weights.any((w) => w < 0) || total <= 0) {
    throw ArgumentError.value(
      weights,
      'weights',
      'must be non-negative with a positive sum',
    );
  }

  final parts = [for (final w in weights) amount * w ~/ total];
  var left = amount - parts.fold(0, (sum, p) => sum + p);

  int remainder(int i) => amount * weights[i] % total;
  final order = List.generate(weights.length, (i) => i)
    ..sort((a, b) {
      final byRemainder = remainder(b).compareTo(remainder(a));
      return byRemainder != 0 ? byRemainder : a.compareTo(b);
    });
  for (var k = 0; left > 0; k++, left--) {
    parts[order[k]]++;
  }
  return parts;
}
