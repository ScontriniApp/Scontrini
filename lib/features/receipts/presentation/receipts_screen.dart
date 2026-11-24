import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The history tab: confirmed receipts, newest first, under a heading per
/// month. A tap opens what was bought; the app bar adds one by hand.
class ReceiptsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final receipts = ref.watch(receiptHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navReceipts),
        actions: [
          IconButton(
            tooltip: l10n.manualReceiptTitle,
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push(Routes.manualReceipt),
          ),
        ],
      ),
      body: switch (receipts) {
        AsyncData(:final value) when value.isEmpty => PlaceholderView(
          icon: Icons.history,
          message: l10n.receiptsEmpty,
        ),
        AsyncData(:final value) => _list(context, value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _list(BuildContext context, List<ReceiptSummary> receipts) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final month = DateFormat.yMMMM(l10n.localeName);
    final day = DateFormat.MMMd(l10n.localeName);
    String? lastMonth;
    final children = <Widget>[];
    for (final receipt in receipts) {
      final heading = month.format(receipt.purchaseDate);
      if (heading != lastMonth) {
        lastMonth = heading;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              toBeginningOfSentenceCase(heading),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }
      children.add(
        ListTile(
          leading: Icon(
            receipt.manual ? Icons.edit_note : Icons.receipt_long_outlined,
          ),
          title: Text(receipt.storeName ?? l10n.receiptsUnknownStore),
          subtitle: Text(
            [
              day.format(receipt.purchaseDate),
              l10n.receiptsItemCount(receipt.itemCount),
              if (receipt.manual) l10n.receiptsManual,
            ].join(' · '),
          ),
          trailing: Text(
            Money.format(receipt.totalCents),
            style: theme.textTheme.titleMedium,
          ),
          onTap: () => context.push(Routes.receipt(receipt.id)),
        ),
      );
    }
    return ListView(
      // Clear of the shell's FAB.
      padding: const EdgeInsets.only(bottom: 96),
      children: children,
    );
  }
}
