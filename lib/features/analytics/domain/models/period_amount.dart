import 'package:freezed_annotation/freezed_annotation.dart';

part 'period_amount.freezed.dart';

/// An amount for a period together with the same amount for the previous
/// period of equal length, for "+12% vs last month" badges.
@freezed
abstract class PeriodAmount with _$PeriodAmount {
  const factory({required int cents, required int previousCents}) =
      _PeriodAmount;

  const new _();

  int get deltaCents => cents - previousCents;

  /// Change in percent, or `null` when the previous period is zero (no
  /// meaningful percentage).
  double? get changePercent =>
      previousCents == 0 ? null : deltaCents / previousCents.abs() * 100;
}
