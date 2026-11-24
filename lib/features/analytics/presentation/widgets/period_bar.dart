import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/domain/models/analytics_period.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/presentation/analytics_overview_providers.dart';
import 'package:scontrini/features/analytics/presentation/period_format.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Week / month / 3 months / year, the period's name between back and
/// forward arrows, and a button for a custom range.
class PeriodBar extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final notifier = ref.read(analyticsPeriodProvider.notifier);
    final today = ref.watch(clockProvider)();

    Future<void> pickDates() async {
      final shown = period.toDate(today);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateRange.day(today).start,
        initialDateRange: shown.isEmpty
            ? null
            : DateTimeRange(
                start: shown.start,
                end: DateTime(
                  shown.end.year,
                  shown.end.month,
                  shown.end.day - 1,
                ),
              ),
      );
      if (picked == null) return;
      // The picker's end is the last day, inclusive.
      notifier.custom(
        DateRange(
          picked.start,
          DateTime(picked.end.year, picked.end.month, picked.end.day + 1),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<PeriodKind>(
                  showSelectedIcon: false,
                  emptySelectionAllowed: true,
                  segments: [
                    ButtonSegment(
                      value: PeriodKind.week,
                      label: Text(l10n.analyticsPeriodWeek),
                    ),
                    ButtonSegment(
                      value: PeriodKind.month,
                      label: Text(l10n.analyticsPeriodMonth),
                    ),
                    ButtonSegment(
                      value: PeriodKind.quarter,
                      label: Text(l10n.analyticsPeriodQuarter),
                    ),
                    ButtonSegment(
                      value: PeriodKind.year,
                      label: Text(l10n.analyticsPeriodYear),
                    ),
                  ],
                  selected: {if (period.kind != PeriodKind.custom) period.kind},
                  onSelectionChanged: (kinds) {
                    if (kinds.isNotEmpty) notifier.select(kinds.first);
                  },
                ),
              ),
              IconButton(
                tooltip: l10n.analyticsPickDates,
                isSelected: period.kind == PeriodKind.custom,
                icon: const Icon(Icons.date_range_outlined),
                selectedIcon: const Icon(Icons.date_range),
                onPressed: pickDates,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: l10n.analyticsPreviousPeriod,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => notifier.shift(-1),
              ),
              Expanded(
                child: Text(
                  PeriodFormat.period(period, l10n.localeName),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.analyticsNextPeriod,
                icon: const Icon(Icons.chevron_right),
                onPressed: period.hasNext(today)
                    ? () => notifier.shift(1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
