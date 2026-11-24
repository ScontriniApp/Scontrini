import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/presentation/category_sprites.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/category_section_header.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// What one receipt bought: a summary, then the rows in collapsible
/// category sections (closed at first, each with what it cost).
class ReceiptDetailScreen extends ConsumerStatefulWidget {
  const new({required this.receiptId, super.key});

  final int receiptId;

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  /// Open sections, by category id (`null`: uncategorised).
  final _open = <int?>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final receipt = ref.watch(receiptDetailProvider(widget.receiptId));
    final categories =
        ref.watch(pantryCategoriesProvider).value ?? const <PantryCategory>[];
    final detail = receipt.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          detail == null
              ? ''
              : detail.summary.storeName ?? l10n.receiptsUnknownStore,
        ),
        actions: [
          if (detail != null)
            IconButton(
              tooltip: l10n.receiptDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: switch (receipt) {
        AsyncData(value: final detail?) => _body(l10n, detail, categories),
        AsyncData() => Center(child: Text(l10n.receiptNotFound)),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(
    AppLocalizations l10n,
    ReceiptDetail detail,
    List<PantryCategory> categories,
  ) {
    final theme = Theme.of(context);
    final byId = {for (final c in categories) c.id: c};
    final groups = <int?, List<ReceiptLine>>{};
    for (final line in detail.lines) {
      final key = byId.containsKey(line.categoryId) ? line.categoryId : null;
      groups.putIfAbsent(key, () => []).add(line);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return byId[a]!.name.compareTo(byId[b]!.name);
      });
    final summary = detail.summary;
    final date = DateFormat.yMMMMd(l10n.localeName)
        .add_Hm()
        .format(summary.purchaseDate);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  Money.format(summary.totalCents),
                  style: theme.textTheme.headlineMedium,
                ),
                Text(date),
                Text(
                  [
                    l10n.receiptsItemCount(summary.itemCount),
                    if (summary.manual) l10n.receiptsManual,
                    if (summary.transactionHash case final hash?)
                      shortTransactionTag(hash),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                if (detail.discountCents > 0)
                  Text(
                    '${l10n.extractionReceiptDiscount}: '
                    '-${Money.format(detail.discountCents)}',
                  ),
              ],
            ),
          ),
        ),
        for (final key in keys) ...[
          CategorySectionHeader(
            title: key == null ? l10n.pantryUncategorised : byId[key]!.name,
            sprite: categorySprite(byId[key]?.name),
            trailing: Money.format(
              groups[key]!.fold(0, (sum, line) => sum + line.netCents),
            ),
            open: _open.contains(key),
            onTap: () => setState(
              () => _open.contains(key) ? _open.remove(key) : _open.add(key),
            ),
          ),
          if (_open.contains(key))
            for (final line in groups[key]!) _LineTile(line: line),
        ],
      ],
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.receiptDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(receiptRepositoryProvider);
    Navigator.of(context).pop();
    await repository.delete(widget.receiptId);
    messenger.showSnackBar(SnackBar(content: Text(l10n.receiptDeleted)));
  }
}

/// One row: name, quantity × unit price when it says more than the
/// total, discount, and what was paid.
class _LineTile extends StatelessWidget {
  const new({required this.line});

  final ReceiptLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quantity = formatQuantity(l10n, line.quantity, line.unit);
    final details = [
      if (line.quantity != 1 || line.unit != 'pz')
        '$quantity × ${Money.format(line.unitPriceCents)}',
      if (line.discountCents > 0)
        l10n.extractionDiscount(Money.format(line.discountCents)),
    ];
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(32, 0, 24, 0),
      title: Text(line.name),
      subtitle: details.isEmpty ? null : Text(details.join(' · ')),
      trailing: Text(
        Money.format(line.netCents),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
