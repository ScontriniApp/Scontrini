import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/core/paper/paper_settings.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/extraction_result.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/receipt_draft.dart';
import 'package:scontrini/features/extraction/presentation/review_item_sheet.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Phase 3 review, the one screen where a receipt is checked before it is
/// saved. After a scan, for every product the user confirms it was read
/// correctly or corrects it by hand (name, quantity, price, category), adds
/// missed rows and drops wrong ones; the store, date, total and discount can
/// be corrected too. Typed in by hand ([ReceiptReviewScreen.manual]) it
/// starts empty, dated now, and every row added is already confirmed.
///
/// Laid out as a printed receipt on paper (the paper lab's saved look and
/// the lab receipt's type): the store as the title, then date, total,
/// discount and the rows' sum, centred; then the products' count with "add"
/// and "confirm all"; then the products. A problem shows as a warning
/// triangle on its own line. Tapping a line (a product or a header line)
/// selects it, one at a time: it grows and turns bold, and its buttons
/// ("Corretto" / "Correggi", "Usa la somma") show below it.
///
/// Warnings follow every edit. Once every row is confirmed, saving stores
/// the receipt (`saveConfirmed`, so it reaches the history, dashboard and
/// statistics), puts all its products in the pantry and opens the saved
/// receipt in the history.
class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const new({
    required ReceiptSource this.source,
    required ExtractionResult this.result,
    required ReceiptDraft this.initialDraft,
    this.onPaperReady,
    super.key,
  });

  /// A receipt typed in by hand: no capture, nothing read.
  const new manual({super.key})
    : source = null,
      result = null,
      initialDraft = null,
      onPaperReady = null;

  /// Called once the receipt's paper is ready to be seen
  /// ([PaperBubble.onReady]).
  final VoidCallback? onPaperReady;

  final ReceiptSource? source;

  /// What was read; `null` for a receipt typed in by hand.
  final ExtractionResult? result;

  /// `null`: an empty receipt dated now.
  final ReceiptDraft? initialDraft;

  bool get isManual => result == null;

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late ReceiptDraft _draft =
      widget.initialDraft ?? ReceiptDraft.empty(ref.read(clockProvider)());
  var _edited = false;
  var _saving = false;
  var _saved = false;

  /// The line whose buttons are shown (a [_Head] or a product's index);
  /// at most one.
  Object? _selected;

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Applies an edit; rows may have moved, so nothing stays selected.
  void _update(ReceiptDraft draft) => setState(() {
    _draft = draft;
    _edited = true;
    _selected = null;
  });

  void _select(Object line) =>
      setState(() => _selected = _selected == line ? null : line);

  List<PantryCategory> get _categories =>
      ref.read(pantryCategoriesProvider).value ?? const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(pantryCategoriesProvider).value ?? const [];
    final names = {
      for (final c in categories) c.id: categoryLabel(l10n, c.name),
    };
    // A correction (sheet, dialog, picker) is open on top: this screen dims
    // itself around the paper, the receipt stays lit. The modals bring no
    // scrim of their own ([_noScrim]).
    final dim = ModalRoute.isCurrentOf(context) == false;

    return PopScope(
      canPop: !_edited || _saved,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: _DimmedBar(
          dim: dim,
          child: AppBar(
            title: Text(
              widget.isManual ? l10n.manualReceiptTitle : l10n.reviewTitle,
            ),
            actions: [
              if (kDebugMode && !widget.isManual)
                IconButton(
                  icon: const Icon(Icons.bug_report_outlined),
                  tooltip: l10n.exportFixture,
                  onPressed: _export,
                ),
            ],
          ),
        ),
        // Products still to check: "Conferma tutti". Once none is left the
        // bar splits: "Annulla tutto" (back to check) and "Salva".
        bottomNavigationBar: _Dim(
          dim: dim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _draft.pendingCount > 0
                  ? FilledButton.icon(
                      key: const Key('review-confirm-all'),
                      icon: const Icon(Icons.done_all),
                      label: Text(l10n.reviewConfirmAll(_draft.pendingCount)),
                      onPressed: _saving
                          ? null
                          : () => _update(_draft.confirmAll()),
                    )
                  : Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('review-unconfirm-all'),
                            icon: const Icon(Icons.undo),
                            label: Text(l10n.reviewUnconfirmAll),
                            onPressed: _saving || _draft.items.isEmpty
                                ? null
                                : () => _update(_draft.unconfirmAll()),
                          ),
                        ),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('review-save'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _saveGreen,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.reviewSave),
                            onPressed: _saving || !_draft.canSave
                                ? null
                                : _confirm,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        // The receipt printed on paper; the sheet scrolls with it. The side
        // padding is the room the paper bleeds into.
        body: Stack(
          children: [
            // Under the paper: the scrim darkens only what is around it.
            Positioned.fill(child: _Scrim(visible: dim)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              // Top, not centred: a short receipt must not move when it grows.
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: PaperBubble(
                    params: ref.watch(paperSettingsProvider).receipt,
                    controller: _scroll,
                    onReady: widget.onPaperReady,
                    hideUntilReady: true,
                    child: _PrintTheme(
                      child: _StuckToPaper(
                        // Not a lazy list: the sheet is as long as the content.
                        child: SingleChildScrollView(
                          controller: _scroll,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(
                                draft: _draft,
                                onChanged: _update,
                                // By hand: no total = the rows' sum.
                                manual: widget.isManual,
                                selected: _selected,
                                onSelect: _select,
                              ),
                              const _Rule(),
                              _ItemsHeading(draft: _draft, onAdd: _addItem),
                              const _Rule(),
                              if (_draft.items.isEmpty)
                                // Its own context: the style must come from the
                                // print's theme (ink), not this screen's.
                                Builder(
                                  builder: (context) => Text(
                                    l10n.reviewNoItems,
                                    textAlign: TextAlign.center,
                                    style: _body(context),
                                  ),
                                ),
                              for (final (i, item) in _draft.items.indexed)
                                _ItemLine(
                                  item: item,
                                  categoryName: names[item.categoryId],
                                  selected: _selected == i,
                                  onTap: () => _select(i),
                                  onCorrect: () => _editItem(i),
                                  onConfirm: (confirmed) => _update(
                                    _draft.withConfirmed(
                                      i,
                                      confirmed: confirmed,
                                    ),
                                  ),
                                ),
                              const _Rule(),
                              if (widget.result?.receipt.unparsedLines ??
                                      const <String>[]
                                  case final unparsed when unparsed.isNotEmpty)
                                ExpansionTile(
                                  title: Text(l10n.extractionUnparsed),
                                  subtitle: Text(l10n.reviewUnparsedHint),
                                  children: [
                                    for (final line in unparsed)
                                      ListTile(
                                        dense: true,
                                        title: Text(
                                          line,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    final result = await showReviewItemSheet(context, categories: _categories);
    if (result is! ItemEdited) return;
    var added = result.item;
    // No category picked: guess it from the name, as for the rows read.
    if (added.categoryId == null) {
      final guessed = await ref.read(receiptRepositoryProvider).guessCategories(
        [added.item.rawName],
      );
      added = DraftItem(
        item: added.item,
        categoryId: guessed.single,
        confirmed: added.confirmed,
      );
    }
    if (mounted) _update(_draft.addItem(added));
  }

  Future<void> _editItem(int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final removed = _draft.items[index];
    final result = await showReviewItemSheet(
      context,
      categories: _categories,
      item: removed,
    );
    switch (result) {
      case ItemEdited(:final item):
        _update(_draft.replaceItem(index, item));
      case ItemDeleted():
        _update(_draft.removeItem(index));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.reviewItemDeleted(removed.item.rawName)),
              action: SnackBarAction(
                label: l10n.reviewUndo,
                onPressed: () {
                  if (!mounted) return;
                  _update(_draft.insertItem(index, removed));
                },
              ),
            ),
          );
      case null:
        break;
    }
  }

  /// Saves the reviewed receipt, puts its products in the pantry, then
  /// opens it in the history (`go`, so this screen is gone and the receipt
  /// can't be saved twice).
  Future<void> _confirm() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final receiptId = await ref
          .read(receiptRepositoryProvider)
          .saveConfirmed(
            _draft.receipt,
            categoryIds: _draft.categoryIds,
            sourcePath: widget.source?.paths.firstOrNull,
            rawOcrText: widget.result?.rowsText,
          );
      final inPantry = await ref
          .read(pantryRepositoryProvider)
          .addAllFromReceipt(receiptId);
      setState(() => _saved = true);
      router.go(Routes.receipt(receiptId));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.reviewSaved(inPantry))));
    } on Object catch (error) {
      debugPrint('Saving the receipt failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.confirmFailed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final name = await ref.read(fixtureExporterProvider).export(widget.result!);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.exportFixtureDone(name))));
  }
}

Future<bool> _confirmDiscard(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final discard = await showDialog<bool>(
    context: context,
    barrierColor: _noScrim,
    builder: (context) => AlertDialog(
      title: Text(l10n.reviewDiscardTitle),
      content: Text(l10n.reviewDiscardBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.reviewDiscard),
        ),
      ],
    ),
  );
  return discard ?? false;
}

/// Modals of this screen bring no scrim: the screen dims itself around the
/// paper instead, so the receipt being corrected stays lit.
const Color _noScrim = Colors.transparent;

/// The dark veil behind a modal, faded in and out.
class _Scrim extends StatelessWidget {
  const new({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: const ColoredBox(color: Colors.black54),
    ),
  );
}

/// [child] with [_Scrim] over it while [dim].
class _Dim extends StatelessWidget {
  const new({required this.dim, required this.child});

  final bool dim;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned.fill(child: _Scrim(visible: dim)),
    ],
  );
}

/// The app bar, dimmed like [_Dim].
class _DimmedBar extends StatelessWidget implements PreferredSizeWidget {
  const new({required this.dim, required this.child});

  final bool dim;
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) => _Dim(dim: dim, child: child);
}

/// The save button's green.
const _saveGreen = Color(0xFF2E7D32);

/// The receipt's body type, as in the paper lab's receipt.
TextStyle? _body(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium;

/// Buttons, icons and tiles in the ink the paper prints with, not the
/// theme's lighter accents (they would print pale).
class _PrintTheme extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ink = DefaultTextStyle.of(context).style.color ?? receiptInk;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: ink,
          secondary: ink,
          onSurface: ink,
          onSurfaceVariant: ink,
        ),
      ),
      // Ink (ripples) on the print, not under the paper.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Keeps the print on its paper: no overscroll effect. Android's stretch
/// (and a bounce) would move or stretch the text at the ends while the
/// paper, drawn from the scroll position, stays put. Only this receipt:
/// the app's other lists keep the platform's effect.
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

/// The header lines that can be selected.
enum _Head { store, date, total, discount, sum }

/// A line of the receipt that can be selected: tapped, it grows a little
/// and turns bold, and [actions] show below it. No highlight box.
class _Selectable extends StatelessWidget {
  const new({
    required this.style,
    required this.selected,
    required this.onTap,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final TextStyle? style;
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final size = base.fontSize ?? 14;
    final line = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: selected
              ? base.copyWith(
                  fontSize: size * 1.12,
                  fontWeight: FontWeight.bold,
                )
              : base,
          child: child,
        ),
      ),
    );
    if (!selected || actions.isEmpty) return line;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        line,
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: actions,
          ),
        ),
      ],
    );
  }
}

/// The warning triangle of a line with a problem.
class _Flag extends StatelessWidget {
  const new();

  // In ink: the theme's error colour prints pale (pink in dark mode).
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.warning_amber, size: 18);
}

/// The receipt's head, centred as printed: the store as the title, then
/// date, total, discount on the total and the sum of the rows. Each line is
/// selected with a tap and corrected with its button; a missing or wrong
/// value shows a warning triangle.
class _Header extends StatelessWidget {
  const new({
    required this.draft,
    required this.onChanged,
    required this.manual,
    required this.selected,
    required this.onSelect,
  });

  final ReceiptDraft draft;
  final ValueChanged<ReceiptDraft> onChanged;

  /// Typed in by hand: no total yet is fine (the rows' sum is used).
  final bool manual;

  final Object? selected;
  final ValueChanged<_Head> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final receipt = draft.receipt;
    final date = receipt.purchaseDate;
    final total = receipt.totalCents;
    final warnings = receipt.warnings;
    const missing = '—';
    final mismatch = warnings.contains(ParseWarning.totalMismatch);

    Widget correct(VoidCallback onPressed) => TextButton.icon(
      icon: const Icon(Icons.edit_outlined),
      label: Text(l10n.reviewCorrectItem),
      onPressed: onPressed,
    );

    Widget line(
      _Head head, {
      required String? label,
      required String value,
      required List<Widget> actions,
      TextStyle? style,
      bool flagged = false,
    }) => _Selectable(
      key: ValueKey('review-${head.name}'),
      style: style ?? text.titleMedium,
      selected: selected == head,
      onTap: () => onSelect(head),
      actions: actions,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          if (flagged) const _Flag(),
          if (label != null) Text(label),
          Flexible(child: Text(value, textAlign: TextAlign.center)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        line(
          _Head.store,
          // A store read is the title alone, as printed.
          label: receipt.storeName == null ? l10n.fieldStore : null,
          value: receipt.storeName ?? missing,
          style: text.headlineSmall,
          flagged: warnings.contains(ParseWarning.missingStore),
          actions: [
            correct(() async {
              final name = await _editText(
                context,
                title: l10n.fieldStore,
                initial: receipt.storeName ?? '',
              );
              if (name != null) onChanged(draft.withStore(name));
            }),
          ],
        ),
        const SizedBox(height: 8),
        line(
          _Head.date,
          label: l10n.fieldDate,
          value: date == null
              ? missing
              : DateFormat.yMd(locale).add_Hm().format(date),
          flagged: warnings.contains(ParseWarning.missingDate),
          actions: [
            correct(() async {
              final picked = await _pickDateTime(context, date);
              if (picked != null) onChanged(draft.withDate(picked));
            }),
          ],
        ),
        line(
          _Head.total,
          label: l10n.fieldTotal,
          value: total == null ? missing : Money.format(total),
          style: text.titleLarge,
          flagged:
              (!manual && warnings.contains(ParseWarning.missingTotal)) ||
              mismatch,
          actions: [
            correct(() async {
              final cents = await _editAmount(
                context,
                title: l10n.fieldTotal,
                initial: total,
                allowEmpty: true,
              );
              if (cents != null) onChanged(draft.withTotal(cents.value));
            }),
          ],
        ),
        line(
          _Head.discount,
          label: l10n.extractionReceiptDiscount,
          value: Money.format(-receipt.discountCents),
          actions: [
            correct(() async {
              final cents = await _editAmount(
                context,
                title: l10n.extractionReceiptDiscount,
                initial: receipt.discountCents,
                allowEmpty: true,
              );
              if (cents != null) {
                onChanged(draft.withDiscount(cents.value ?? 0));
              }
            }),
          ],
        ),
        line(
          _Head.sum,
          label: l10n.fieldItemsTotal,
          value: Money.format(receipt.computedTotalCents),
          flagged: mismatch,
          actions: [
            if (mismatch)
              TextButton.icon(
                icon: const Icon(Icons.functions),
                label: Text(l10n.reviewUseItemsTotal),
                onPressed: () =>
                    onChanged(draft.withTotal(receipt.computedTotalCents)),
              ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// A dashed rule across the receipt, as printed.
class _Rule extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '-' * 80,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      style: _body(context),
    ),
  );
}

/// "Articoli (n), k da controllare", then "Aggiungi articolo", centred.
/// ("Conferma tutti" is the bottom bar's.)
class _ItemsHeading extends StatelessWidget {
  const new({required this.draft, required this.onAdd});

  final ReceiptDraft draft;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = draft.pendingCount;
    return Column(
      children: [
        Text(
          pending == 0
              ? l10n.extractionItems(draft.items.length)
              : l10n.reviewItemsPending(draft.items.length, pending),
          textAlign: TextAlign.center,
          style: _body(context),
        ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.reviewAddItem),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

/// A product as a receipt row: name and amount, then its details. The mark
/// in front is a check once confirmed, a triangle when something is off.
class _ItemLine extends StatelessWidget {
  const new({
    required this.item,
    required this.categoryName,
    required this.selected,
    required this.onTap,
    required this.onCorrect,
    required this.onConfirm,
  });

  final DraftItem item;
  final String? categoryName;

  /// Whether its buttons are shown (one line at a time).
  final bool selected;

  /// Selects the row, or deselects it when already selected.
  final VoidCallback onTap;

  /// Opens the correction form.
  final VoidCallback onCorrect;

  /// Marks the row as read correctly, or (false) to look at again.
  final ValueChanged<bool> onConfirm;

  static const double _mark = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final body = _body(context);
    final row = item.item;

    final details = [
      if (row.quantity != 1 || row.unit != QuantityUnit.piece)
        _quantityText(row.quantity, row.unit, row.unitPriceCents, locale),
      if (row.discountCents > 0)
        l10n.extractionDiscount(Money.format(row.discountCents)),
      categoryName ?? l10n.reviewUncategorised,
      for (final warning in row.warnings) warningLabel(l10n, warning),
    ];

    return _Selectable(
      style: body,
      selected: selected,
      onTap: onTap,
      actions: [
        if (item.confirmed)
          TextButton.icon(
            icon: const Icon(Icons.undo),
            label: Text(l10n.reviewUnconfirmItem),
            onPressed: () => onConfirm(false),
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.check),
            label: Text(l10n.reviewConfirmItem),
            onPressed: () => onConfirm(true),
          ),
        TextButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.reviewCorrectItem),
          onPressed: onCorrect,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _mark,
                child: item.confirmed
                    ? const Icon(Icons.check, size: 18)
                    : row.warnings.isEmpty
                    ? null
                    : const _Flag(),
              ),
              Expanded(child: Text(row.rawName)),
              const SizedBox(width: 8),
              Text(Money.format(row.netCents)),
            ],
          ),
          // Details keep their size: only the row itself grows.
          Padding(
            padding: const EdgeInsets.only(left: _mark),
            child: Text(details.join(' · '), style: body),
          ),
        ],
      ),
    );
  }

  static String _quantityText(
    double quantity,
    QuantityUnit unit,
    int unitPriceCents,
    String locale,
  ) {
    final q = NumberFormat('0.###', locale).format(quantity);
    final price = Money.format(unitPriceCents);
    return switch (unit) {
      QuantityUnit.piece => '$q × $price',
      QuantityUnit.kilogram => '$q kg × $price/kg',
      QuantityUnit.litre => '$q l × $price/l',
    };
  }
}

String warningLabel(AppLocalizations l10n, ParseWarning warning) =>
    switch (warning) {
      ParseWarning.missingStore => l10n.warningMissingStore,
      ParseWarning.missingDate => l10n.warningMissingDate,
      ParseWarning.missingTotal => l10n.warningMissingTotal,
      ParseWarning.totalMismatch => l10n.warningTotalMismatch,
      ParseWarning.lineTotalMismatch => l10n.warningLineTotalMismatch,
    };

/// A one-line text dialog; `null` when cancelled.
Future<String?> _editText(
  BuildContext context, {
  required String title,
  required String initial,
}) => showDialog<String>(
  context: context,
  barrierColor: _noScrim,
  builder: (context) => _TextDialog(title: title, initial: initial),
);

/// An amount the user typed: `value` in cents, `null` when left empty.
typedef _Amount = ({int? value});

/// An amount dialog; `null` when cancelled.
Future<_Amount?> _editAmount(
  BuildContext context, {
  required String title,
  required int? initial,
  bool allowEmpty = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final text = await showDialog<String>(
    context: context,
    barrierColor: _noScrim,
    builder: (context) => _TextDialog(
      title: title,
      initial: initial == null || initial == 0 ? '' : Money.inputText(initial),
      suffix: '€',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        final t = (v ?? '').trim();
        if (t.isEmpty) return allowEmpty ? null : l10n.reviewInvalidAmount;
        final cents = Money.parseCents(t);
        return cents == null || cents < 0 ? l10n.reviewInvalidAmount : null;
      },
    ),
  );
  if (text == null) return null;
  final t = text.trim();
  return (value: t.isEmpty ? null : Money.parseCents(t));
}

/// Date, then time (kept when the time picker is dismissed); `null` when
/// the date picker is dismissed.
Future<DateTime?> _pickDateTime(BuildContext context, DateTime? current) async {
  final now = DateTime.now();
  final initial = current ?? now;
  final day = await showDatePicker(
    context: context,
    barrierColor: _noScrim,
    initialDate: initial.isAfter(now) ? now : initial,
    firstDate: DateTime(2000),
    lastDate: now,
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    barrierColor: _noScrim,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  final t = time ?? TimeOfDay.fromDateTime(initial);
  return DateTime(day.year, day.month, day.day, t.hour, t.minute);
}

class _TextDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.initial,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  final String title;
  final String initial;
  final String? suffix;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _form = GlobalKey<FormState>();
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) Navigator.of(context).pop(_text.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: TextFormField(
          key: const Key('review-dialog-field'),
          controller: _text,
          autofocus: true,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(suffixText: widget.suffix),
          validator: widget.validator,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
