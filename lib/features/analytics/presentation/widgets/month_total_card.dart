import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// This month's spending so far, with the usual amount by the same day.
class MonthTotalCard extends StatelessWidget {
  const new({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(summary.month.start);
    final usual = summary.usualCents;
    final change = summary.changePercent;
    final muted = theme.colorScheme.onSurfaceVariant;
    final number = NumberFormat.decimalPattern(locale);
    final changeText = change == null
        ? ''
        : '${number.format(change.abs().round())}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardMonthSpent(month),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              Money.format(summary.monthToDateCents),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.dashboardReceiptCount(summary.receiptCount),
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            if (usual == null)
              Text(
                l10n.dashboardNoUsual,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              )
            else
              Row(
                children: [
                  if (change != null) ...[
                    Icon(
                      change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                    ),
                    Text(changeText, style: theme.textTheme.labelLarge),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      l10n.dashboardUsual(Money.format(usual)),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
