import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/domain/receipt_draft.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// What the item sheet returns: the edited row, or a request to delete it.
sealed class ItemSheetResult {
  const new();
}

class ItemEdited extends ItemSheetResult {
  const new(this.item);

  final DraftItem item;
}

class ItemDeleted extends ItemSheetResult {
  const new();
}

/// Opens the form for [item] (a new row when `null`); `null` when
/// dismissed.
Future<ItemSheetResult?> showReviewItemSheet(
  BuildContext context, {
  required List<PantryCategory> categories,
  DraftItem? item,
}) => showModalBottomSheet<ItemSheetResult>(
  context: context,
  // The review screen dims itself around the receipt instead.
  barrierColor: Colors.transparent,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: _ItemForm(item: item, categories: categories),
  ),
);

class _ItemForm extends StatefulWidget {
  const new({required this.item, required this.categories});

  final DraftItem? item;
  final List<PantryCategory> categories;

  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _form = GlobalKey<FormState>();
  late final ParsedItem? _initial = widget.item?.item;
  late final _name = TextEditingController(text: _initial?.rawName);
  late final _quantity = TextEditingController(
    text: _formatQuantity(_initial?.quantity ?? 1),
  );
  late final _unitPrice = TextEditingController(
    text: _amountText(_initial?.unitPriceCents),
  );
  late final _amount = TextEditingController(
    text: _amountText(_initial?.lineTotalCents),
  );
  late final _discount = TextEditingController(
    text: (_initial?.discountCents ?? 0) == 0
        ? ''
        : _amountText(_initial!.discountCents),
  );
  late QuantityUnit _unit = _initial?.unit ?? QuantityUnit.piece;
  late int? _categoryId = widget.item?.categoryId;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    _amount.dispose();
    _discount.dispose();
    super.dispose();
  }

  static String _formatQuantity(double value) =>
      NumberFormat('0.###', Money.locale).format(value);

  static String _amountText(int? cents) =>
      cents == null ? '' : Money.inputText(cents);

  static double? _parseQuantity(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  /// Quantity or unit price changed: the amount follows, when both read.
  void _updateAmount() {
    final quantity = _parseQuantity(_quantity.text);
    final unitPrice = Money.parseCents(_unitPrice.text);
    if (quantity == null || unitPrice == null) return;
    _amount.text = _amountText((quantity * unitPrice).round());
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final quantity = _parseQuantity(_quantity.text)!;
    final amount = Money.parseCents(_amount.text)!;
    final discount = _discount.text.trim().isEmpty
        ? 0
        : Money.parseCents(_discount.text)!;
    final single = quantity == 1 && _unit == QuantityUnit.piece;
    final item =
        (_initial ??
                const ParsedItem(
                  rawName: '',
                  unitPriceCents: 0,
                  lineTotalCents: 0,
                ))
            .copyWith(
              rawName: _name.text.trim(),
              quantity: quantity,
              unit: _unit,
              // One piece: the price is the amount.
              unitPriceCents: single
                  ? amount
                  : Money.parseCents(_unitPrice.text) ?? amount,
              lineTotalCents: amount,
              discountCents: discount,
            );
    Navigator.of(context)
    // A row the user corrected (or typed) is confirmed.
    .pop(
      ItemEdited(
        DraftItem(item: item, categoryId: _categoryId, confirmed: true),
      ),
    );
  }

  String? _validateAmount(String? text, AppLocalizations l10n) {
    final cents = Money.parseCents(text ?? '');
    return cents == null || cents < 0 ? l10n.reviewInvalidAmount : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item == null
                          ? l10n.reviewAddItem
                          : l10n.reviewEditItem,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (widget.item != null)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.delete),
                      onPressed: () =>
                          Navigator.of(context).pop(const ItemDeleted()),
                    ),
                ],
              ),
              TextFormField(
                key: const Key('review-item-name'),
                controller: _name,
                autofocus: widget.item == null,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.reviewFieldName),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.reviewInvalidName : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('review-item-quantity'),
                      controller: _quantity,
                      keyboardType: decimal,
                      decoration: InputDecoration(
                        labelText: l10n.reviewFieldQuantity,
                      ),
                      onChanged: (_) => _updateAmount(),
                      validator: (v) {
                        final q = _parseQuantity(v ?? '');
                        return q == null || q <= 0
                            ? l10n.reviewInvalidQuantity
                            : null;
                      },
                    ),
                  ),
                  SegmentedButton<QuantityUnit>(
                    segments: [
                      for (final (unit, label) in [
                        (QuantityUnit.piece, l10n.unitPieces),
                        (QuantityUnit.kilogram, l10n.unitKilograms),
                        (QuantityUnit.litre, l10n.unitLitres),
                      ])
                        ButtonSegment(value: unit, label: Text(label)),
                    ],
                    selected: {_unit},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _unit = s.first),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('review-item-unit-price'),
                      controller: _unitPrice,
                      keyboardType: decimal,
                      decoration: InputDecoration(
                        labelText: l10n.reviewFieldUnitPrice,
                        suffixText: '€',
                      ),
                      onChanged: (_) => _updateAmount(),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? null
                          : _validateAmount(v, l10n),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      key: const Key('review-item-amount'),
                      controller: _amount,
                      keyboardType: decimal,
                      decoration: InputDecoration(
                        labelText: l10n.reviewFieldAmount,
                        suffixText: '€',
                      ),
                      validator: (v) => _validateAmount(v, l10n),
                    ),
                  ),
                ],
              ),
              TextFormField(
                key: const Key('review-item-discount'),
                controller: _discount,
                keyboardType: decimal,
                decoration: InputDecoration(
                  labelText: l10n.reviewFieldDiscount,
                  suffixText: '€',
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return null;
                  final invalid = _validateAmount(v, l10n);
                  if (invalid != null) return invalid;
                  final amount = Money.parseCents(_amount.text);
                  return amount != null && Money.parseCents(v!)! > amount
                      ? l10n.reviewDiscountTooLarge
                      : null;
                },
              ),
              DropdownButtonFormField<int?>(
                key: const Key('review-item-category'),
                initialValue: widget.categories.any((c) => c.id == _categoryId)
                    ? _categoryId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.reviewFieldCategory,
                ),
                items: [
                  DropdownMenuItem(child: Text(l10n.reviewUncategorised)),
                  for (final c in widget.categories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(categoryLabel(l10n, c.name)),
                    ),
                ],
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 4),
              FilledButton(onPressed: _submit, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
