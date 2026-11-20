import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scontrini/features/analytics/domain/models/period_amount.dart';

part 'savings.freezed.dart';

/// What the user did not pay thanks to discounts in a period (M8).
@freezed
abstract class Savings with _$Savings {
  const factory({
    /// Item and receipt discounts, with the previous equal-length period.
    required PeriodAmount saved,

    /// Amount actually paid in the period (M1).
    required int paidCents,
  }) = _Savings;

  const new _();

  /// Saved ÷ (paid + saved), as a fraction in 0..1; `null` when nothing was
  /// bought.
  double? get rate {
    final full = paidCents + saved.cents;
    return full <= 0 ? null : saved.cents / full;
  }
}
