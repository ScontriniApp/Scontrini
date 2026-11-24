import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';

/// A receipt row while the user reviews it: what was read, corrected, plus
/// its category (guessed, or chosen) and whether the user has confirmed it.
class DraftItem {
  const new({required this.item, this.categoryId, this.confirmed = false});

  final ParsedItem item;
  final int? categoryId;

  /// The user said the row was read correctly, or corrected it by hand.
  final bool confirmed;

  DraftItem withConfirmed(bool confirmed) =>
      DraftItem(item: item, categoryId: categoryId, confirmed: confirmed);
}

/// The receipt the review screen edits before it is saved. Immutable: each
/// edit returns a new draft with its warnings worked out again, so the
/// screen always flags what is still missing or doesn't add up.
///
/// Every row starts unconfirmed: the user confirms it was read correctly
/// or corrects it, and the receipt can be saved once all rows are done.
class ReceiptDraft {
  /// [receipt] as parsed, its rows with [categoryIds] (same order; missing
  /// entries are uncategorised).
  factory fromParsed(
    ParsedReceipt receipt, {
    List<int?> categoryIds = const [],
  }) => ReceiptDraft._(receipt, [
    for (final (i, item) in receipt.items.indexed)
      DraftItem(
        item: item,
        categoryId: i < categoryIds.length ? categoryIds[i] : null,
      ),
  ]);

  /// A receipt typed in by hand: dated [date], no store, no rows yet.
  factory empty(DateTime date) =>
      ReceiptDraft._(ParsedReceipt(purchaseDate: date, items: const []), []);

  new _(ParsedReceipt receipt, this.items)
    : receipt = _withWarnings(receipt, items);

  /// Header, receipt discount and warnings; its items are [items]'.
  final ParsedReceipt receipt;
  final List<DraftItem> items;

  /// The category of each row, in order (what `saveConfirmed` takes).
  List<int?> get categoryIds => [for (final i in items) i.categoryId];

  /// Rows the user hasn't confirmed or corrected yet.
  int get pendingCount => items.where((i) => !i.confirmed).length;

  /// Whether the receipt can be saved: it has rows, all confirmed.
  bool get canSave => items.isNotEmpty && pendingCount == 0;

  /// Marks every row as read correctly.
  ReceiptDraft confirmAll() => ReceiptDraft._(receipt, [
    for (final item in items) item.withConfirmed(true),
  ]);

  /// Marks row [index] as read correctly (or not, to look at it again).
  ReceiptDraft withConfirmed(int index, {bool confirmed = true}) =>
      ReceiptDraft._(
        receipt,
        [...items]..[index] = items[index].withConfirmed(confirmed),
      );

  ReceiptDraft withStore(String? name) {
    final trimmed = name?.trim();
    return _with(
      receipt.copyWith(
        storeName: trimmed == null || trimmed.isEmpty ? null : trimmed,
      ),
    );
  }

  ReceiptDraft withDate(DateTime? date) =>
      _with(receipt.copyWith(purchaseDate: date));

  /// The printed total; `null` when unknown (the rows' sum is saved).
  ReceiptDraft withTotal(int? cents) =>
      _with(receipt.copyWith(totalCents: cents));

  /// The discount on the whole receipt (not on one row), positive.
  ReceiptDraft withDiscount(int cents) =>
      _with(receipt.copyWith(discountCents: cents));

  ReceiptDraft replaceItem(int index, DraftItem item) =>
      ReceiptDraft._(receipt, [...items]..[index] = _checked(item));

  ReceiptDraft insertItem(int index, DraftItem item) =>
      ReceiptDraft._(receipt, [...items]..insert(index, _checked(item)));

  ReceiptDraft addItem(DraftItem item) => insertItem(items.length, item);

  ReceiptDraft removeItem(int index) =>
      ReceiptDraft._(receipt, [...items]..removeAt(index));

  ReceiptDraft _with(ParsedReceipt header) => ReceiptDraft._(header, items);

  /// An edited row, with its line warning worked out again.
  static DraftItem _checked(DraftItem draft) {
    final item = draft.item;
    return DraftItem(
      item: item.copyWith(
        warnings: [if (!lineAddsUp(item)) ParseWarning.lineTotalMismatch],
      ),
      categoryId: draft.categoryId,
      confirmed: draft.confirmed,
    );
  }

  /// Whether quantity × unit price is the row's amount: within a cent, or
  /// within the rounding of a weight printed to the gram.
  static bool lineAddsUp(ParsedItem item) {
    if (item.quantity == 1 && item.unit == QuantityUnit.piece) return true;
    final computed = (item.quantity * item.unitPriceCents).round();
    final slack = item.unit == QuantityUnit.piece
        ? 1
        : (item.unitPriceCents * 0.0005).ceil();
    return (computed - item.lineTotalCents).abs() <= (slack < 1 ? 1 : slack);
  }

  static ParsedReceipt _withWarnings(
    ParsedReceipt header,
    List<DraftItem> items,
  ) {
    final receipt = header.copyWith(items: [for (final i in items) i.item]);
    return receipt.copyWith(
      warnings: [
        if (receipt.storeName == null) ParseWarning.missingStore,
        if (receipt.purchaseDate == null) ParseWarning.missingDate,
        if (receipt.totalCents == null) ParseWarning.missingTotal,
        if (receipt.totalCents != null && !receipt.isBalanced)
          ParseWarning.totalMismatch,
      ],
    );
  }
}
