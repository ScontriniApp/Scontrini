import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/features/analytics/presentation/widgets/shelf_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// This month's spending so far, with the usual amount by the same day,
/// drawn as a [ShelfLabel]; the change against the usual amount sits under
/// the receipt count.
class MonthTotalCard extends StatelessWidget {
  const new({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(summary.month.start);
    final usual = summary.usualCents;
    final change = summary.changePercent;
    final number = NumberFormat.decimalPattern(locale);

    return ShelfLabel(
      title: l10n.dashboardMonthSpent(month),
      cents: summary.monthToDateCents,
      leading: l10n.dashboardReceiptCount(summary.receiptCount),
      corner: usual != null && change != null
          ? Row(
              children: [
                Icon(
                  change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: ShelfLabel.ink,
                ),
                Text(
                  '${number.format(change.abs().round())}%',
                  style: ShelfLabel.smallStyle(context),
                ),
              ],
            )
          : null,
      footer: usual == null
          ? l10n.dashboardNoUsual
          : l10n.dashboardUsual(Money.format(usual)),
    );
  }
}
