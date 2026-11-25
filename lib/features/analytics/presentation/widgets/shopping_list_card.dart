import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/features/analytics/domain/models/date_range.dart';
import 'package:scontrini/features/analytics/domain/models/shopping_suggestion.dart';
import 'package:scontrini/features/analytics/presentation/dashboard_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The dashboard's next-shopping list: what is finished, about to run out
/// or due by habit. A tap opens the product's statistics.
class ShoppingListCard extends ConsumerStatefulWidget {
  const new({super.key});

  /// Rows shown before "Mostra tutti".
  static const shown = 5;

  @override
  ConsumerState<ShoppingListCard> createState() => _ShoppingListCardState();
}

class _ShoppingListCardState extends ConsumerState<ShoppingListCard> {
  bool _expanded = false;

  String _subtitle(
    AppLocalizations l10n,
    ShoppingSuggestion s,
    DateTime today,
  ) {
    final interval = s.intervalDays;
    switch (s.reason) {
      case ShoppingReason.finished:
        return [
          l10n.shoppingFinished,
          if (interval != null) l10n.shoppingEvery(interval),
        ].join(' · ');
      case ShoppingReason.runningLow:
        final days = DateTime.utc(
          s.dueDay.year,
          s.dueDay.month,
          s.dueDay.day,
        ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
        final when = switch (days) {
          <= 0 => l10n.shoppingToday,
          1 => l10n.shoppingTomorrow,
          _ => l10n.shoppingInDays(days),
        };
        return l10n.shoppingRunningLow(
          formatQuantity(l10n, s.remaining ?? 0, s.unit ?? 'pz'),
          when,
        );
      case ShoppingReason.usualInterval:
        return l10n.shoppingUsual(
          interval ?? 0,
          DateFormat.MMMd(l10n.localeName).format(s.lastPurchase.toLocal()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final today = DateRange.day(ref.watch(clockProvider)()).start;
    final suggestions = ref.watch(shoppingSuggestionsProvider).value;
    if (suggestions == null) return const SizedBox.shrink();

    final canExpand = suggestions.length > ShoppingListCard.shown;
    final rows = _expanded || !canExpand
        ? suggestions
        : suggestions.take(ShoppingListCard.shown);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.shoppingTitle, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.shoppingEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ),
            for (final s in rows)
              ListTile(
                leading: Icon(switch (s.reason) {
                  ShoppingReason.finished =>
                    Icons.remove_shopping_cart_outlined,
                  ShoppingReason.runningLow => Icons.hourglass_bottom,
                  ShoppingReason.usualInterval => Icons.event_repeat_outlined,
                }),
                title: Text(s.name),
                subtitle: Text(_subtitle(l10n, s, today)),
                onTap: () =>
                    unawaited(context.push(Routes.product(s.productId))),
              ),
            if (canExpand)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? l10n.analyticsShowLess
                        : l10n.analyticsShowAll(suggestions.length),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                l10n.shoppingHint,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
