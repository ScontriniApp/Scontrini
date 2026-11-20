import 'package:flutter_test/flutter_test.dart';
import 'package:scontrini/features/analytics/domain/proportional_split.dart';

void main() {
  group('splitProportionally', () {
    test('parts add up exactly and stay within a cent of the exact share', () {
      final weights = [333, 333, 334, 1, 0, 999];
      for (final amount in [0, 1, 7, 100, 999, 123457]) {
        final parts = splitProportionally(amount, weights);
        expect(parts.fold(0, (s, p) => s + p), amount);
        final total = weights.fold(0, (s, w) => s + w);
        for (var i = 0; i < weights.length; i++) {
          expect((parts[i] - amount * weights[i] / total).abs(), lessThan(1));
        }
      }
    });

    test('leftover cents go to the largest remainders, earlier on ties', () {
      expect(splitProportionally(100, [600, 300]), [67, 33]);
      expect(splitProportionally(2, [1, 1, 1]), [1, 1, 0]);
      expect(splitProportionally(10, [0, 5, 0]), [0, 10, 0]);
    });

    test('rejects a negative amount and unusable weights', () {
      expect(() => splitProportionally(-1, [1]), throwsArgumentError);
      expect(() => splitProportionally(1, [0, 0]), throwsArgumentError);
      expect(() => splitProportionally(1, []), throwsArgumentError);
      expect(() => splitProportionally(1, [2, -1]), throwsArgumentError);
    });
  });
}
