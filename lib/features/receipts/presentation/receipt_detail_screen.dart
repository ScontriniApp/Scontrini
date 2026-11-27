import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_params.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The paper a receipt is printed on in its detail screen: a crumpled
/// thermal receipt, tuned in the shader lab.
///
/// Only the knobs that differ from [PaperParams]' defaults are listed;
/// `receipt_detail_paper_test.dart` pins every value.
const receiptDetailPaper = PaperParams(
  creases: 0.64,
  crumple: 1.77,
  sharpness: 0.26,
  depth: 0.75,
  cameraTurn: 1.77,
  ambient: 0.73,
  occlusion: 1.07,
  softness: 0.53,
  sheen: 0,
  roughness: 0.13,
  inkFade: 0.37,
  lines: 0.44,
  dropout: 0.19,
  torn: 8.57,
);

/// A receipt as it was printed, on a scrolling sheet of
/// [receiptDetailPaper]: store and date, every product with its discount
/// and price, then the total and the total discount.
class ReceiptDetailScreen extends ConsumerStatefulWidget {
  const new({required this.receiptId, super.key});

  final int receiptId;

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  /// Room above the sheet, logical px.
  static const double _lead = 16;

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final receipt = ref.watch(receiptDetailProvider(widget.receiptId));
    final detail = receipt.value;
    return Scaffold(
      appBar: AppBar(
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
        AsyncData(value: final detail?) => _paper(l10n, detail),
        AsyncData() => Center(child: Text(l10n.receiptNotFound)),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _paper(AppLocalizations l10n, ReceiptDetail detail) {
    final summary = detail.summary;
    final date = DateFormat.yMMMMd(l10n.localeName)
        .add_Hm()
        .format(summary.purchaseDate);
    final totalDiscount = detail.lines.fold(
      detail.discountCents,
      (sum, line) => sum + line.discountCents,
    );
    final tag = summary.transactionHash;

    // The side padding is the room the paper bleeds into. The list reaches
    // the app bar, so print and paper scroll under it together; the sheet
    // starts [_lead] down, so its torn top shows when the receipt opens.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PaperBubble(
        params: receiptDetailPaper,
        controller: _scroll,
        leading: _lead,
        // Inside the paper, so the big styles carry its ink colour too.
        child: Builder(
          builder: (context) {
            final ink = Theme.of(context).textTheme;
            return ListView(
              controller: _scroll,
              // Bottom: room for the shell's "add" button over the last lines.
              padding: const EdgeInsets.fromLTRB(20, _lead + 32, 20, 112),
              children: [
                Text(
                  summary.storeName ?? l10n.receiptsUnknownStore,
                  textAlign: TextAlign.center,
                  style: ink.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(date, textAlign: TextAlign.center),
                if (summary.manual || tag != null)
                  Text(
                    [
                      if (summary.manual) l10n.receiptsManual,
                      if (tag != null) shortTransactionTag(tag),
                    ].join(' · '),
                    textAlign: TextAlign.center,
                  ),
                const _Rule(),
                for (final line in detail.lines) _LineRows(line: line),
                if (detail.discountCents > 0)
                  _Row(
                    l10n.extractionReceiptDiscount,
                    '-${Money.format(detail.discountCents)}',
                  ),
                const _Rule(),
                _Row(
                  l10n.receiptTotal,
                  Money.format(summary.totalCents),
                  style: ink.headlineSmall,
                ),
                if (totalDiscount > 0)
                  _Row(
                    l10n.receiptTotalDiscount,
                    '-${Money.format(totalDiscount)}',
                  ),
              ],
            );
          },
        ),
      ),
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

/// One product: name and price, quantity × unit price when it says more
/// than the price, then its discount.
class _LineRows extends StatelessWidget {
  const new({required this.line});

  final ReceiptLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Row(line.name, Money.format(line.lineTotalCents)),
          if (line.quantity != 1 || line.unit != 'pz')
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '${formatQuantity(l10n, line.quantity, line.unit)} × '
                '${Money.format(line.unitPriceCents)}',
              ),
            ),
          if (line.discountCents > 0)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _Row(
                l10n.receiptDiscount,
                '-${Money.format(line.discountCents)}',
              ),
            ),
        ],
      ),
    );
  }
}

/// A label on the left, an amount on the right.
class _Row extends StatelessWidget {
  const new(this.label, this.amount, {this.style});

  final String label;
  final String amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = style ?? Theme.of(context).textTheme.bodyLarge;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: text)),
        const SizedBox(width: 12),
        Text(amount, style: text),
      ],
    );
  }
}

/// A dashed line across the receipt.
class _Rule extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      '-' * 80,
      maxLines: 1,
      overflow: TextOverflow.clip,
      softWrap: false,
    ),
  );
}
