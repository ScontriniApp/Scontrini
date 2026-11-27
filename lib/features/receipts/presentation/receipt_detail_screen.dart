import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/features/receipts/domain/receipt_history.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// One saved receipt, printed on paper like the review screen after a scan
/// (the paper lab's saved look): the store, the date, every product with
/// its quantity and discount, then the total discount and the total.
///
/// The sheet scrolls with the print; its torn top shows when the receipt
/// opens and its torn bottom at the end.
class ReceiptDetailScreen extends ConsumerStatefulWidget {
  const new({required this.receiptId, super.key});

  final int receiptId;

  /// How far the scrolled paper reaches past its top edge, which is 8 px
  /// below the app bar: those 8 px, then hidden under the bar. The text
  /// slides up under the bar with the paper, no gap and no blank band.
  static const double _overscanTop = 40;

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
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
      // The store's name is printed on the paper.
      appBar: AppBar(
        // The paper scrolls under it: no tint or shadow when it does.
        notificationPredicate: (_) => false,
        scrolledUnderElevation: 0,
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

    // As the review screen: the side padding is the room the paper bleeds
    // into; top, not centred.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: PaperBubble(
            params: ref.watch(paperSettingsProvider).receipt,
            controller: _scroll,
            tilt: true,
            hideUntilReady: true,
            // Up under the app bar; down to the screen's edge.
            overscan: const EdgeInsets.only(
              top: ReceiptDetailScreen._overscanTop,
              bottom: 8,
            ),
            child: _StuckToPaper(
              // Not a lazy list: the sheet is as long as the content.
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const ClampingScrollPhysics(),
                // The print past the edges is read by the paper
                // (PaperBubble.overscan), which clips it.
                clipBehavior: Clip.none,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                // Inside the paper: the styles carry its ink.
                child: Builder(
                  builder: (context) {
                    final text = Theme.of(context).textTheme;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          summary.storeName ?? l10n.receiptsUnknownStore,
                          textAlign: TextAlign.center,
                          style: text.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          textAlign: TextAlign.center,
                          style: text.titleMedium,
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
                          l10n.receiptTotalDiscount,
                          '-${Money.format(totalDiscount)}',
                        ),
                        _Row(
                          l10n.receiptTotal,
                          Money.format(summary.totalCents),
                          style: text.headlineSmall,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
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

/// Keeps the print on its paper: no overscroll stretch or bounce, which
/// would move the text while the paper, drawn from the scroll position,
/// stays put (as on the review screen).
class _StuckToPaper extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: ScrollConfiguration.of(context)
        .copyWith(overscroll: false, physics: const ClampingScrollPhysics()),
    child: child,
  );
}

/// One product: name and price, quantity × unit price when it says more
/// than the price, then its discount.
class _LineRows extends StatelessWidget {
  const new({required this.line});

  final ReceiptLine line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final body = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
                style: body,
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
    final text = style ?? Theme.of(context).textTheme.titleMedium;
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

/// A dashed rule across the receipt, as printed.
class _Rule extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      '-' * 80,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );
}
