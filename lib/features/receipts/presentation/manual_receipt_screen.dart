import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/clock.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_receipt.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// A receipt typed in by hand: store, day and the items bought. It is
/// saved as a confirmed receipt, so it shows in the history and the
/// dashboard like a photographed one, and its items can go straight into
/// the pantry (lots tagged with the receipt). Pops with the receipt id.
class ManualReceiptScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ManualReceiptScreen> createState() =>
      _ManualReceiptScreenState();
}

class _ManualReceiptScreenState extends ConsumerState<ManualReceiptScreen> {
  final _form = GlobalKey<FormState>();
  final _store = TextEditingController();
  final _items = <_ItemDraft>[_ItemDraft()];
  late DateTime _day = _today;
  bool _toPantry = true;
  bool _saving = false;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _store.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  int get _totalCents => _items.fold(
    0,
    (sum, item) => sum + (Money.parseCents(item.price.text.trim()) ?? 0),
  );

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2000),
      lastDate: _today,
    );
    if (picked != null) setState(() => _day = picked);
  }

  void _addItem() => setState(() => _items.add(_ItemDraft()));

  void _removeItem(_ItemDraft item) => setState(() {
    _items.remove(item);
    item.dispose();
  });

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = ref.read(clockProvider)();
    // The chosen day at the current time: two receipts typed the same day
    // with the same total and store stay two receipts.
    final date = DateTime(
      _day.year,
      _day.month,
      _day.day,
      now.hour,
      now.minute,
      now.second,
    );
    final items = [
      for (final item in _items)
        _item(
          item.name.text.trim(),
          _parseQuantity(item.quantity.text)!,
          item.unit,
          Money.parseCents(item.price.text.trim())!,
        ),
    ];
    final store = _store.text.trim();
    try {
      final id = await ref
          .read(receiptRepositoryProvider)
          .saveConfirmed(
            ParsedReceipt(
              storeName: store.isEmpty ? null : store,
              purchaseDate: date,
              totalCents: _totalCents,
              items: items,
            ),
            categoryIds: [for (final item in _items) item.categoryId],
          );
      if (_toPantry) {
        final pantry = ref.read(pantryRepositoryProvider);
        for (final card in await pantry.triageCards(id)) {
          await pantry.addFromReceipt(id, card);
        }
      }
      if (!mounted) return;
      // The app-wide messenger: the snackbar shows on the screen below.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).manualReceiptSaved),
        ),
      );
      Navigator.of(context).pop(id);
    } on Exception catch (error) {
      debugPrint('Manual receipt not saved: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).manualReceiptFailed),
        ),
      );
    }
  }

  static ParsedItem _item(
    String name,
    double quantity,
    String unit,
    int priceCents,
  ) => ParsedItem(
    rawName: name,
    quantity: quantity,
    unit: switch (unit) {
      'kg' => QuantityUnit.kilogram,
      'l' => QuantityUnit.litre,
      _ => QuantityUnit.piece,
    },
    lineTotalCents: priceCents,
    unitPriceCents: (priceCents / quantity).round(),
  );

  static double? _parseQuantity(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories =
        ref.watch(pantryCategoriesProvider).value ?? const <PantryCategory>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manualReceiptTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _store,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.manualReceiptStore,
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.manualReceiptDate),
              subtitle: Text(DateFormat.yMMMMd(l10n.localeName).format(_day)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickDay,
            ),
            const SizedBox(height: 8),
            for (final (index, item) in _items.indexed)
              _ItemCard(
                key: ObjectKey(item),
                index: index,
                item: item,
                categories: categories,
                onRemove: _items.length > 1 ? () => _removeItem(item) : null,
                onChanged: () => setState(() {}),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: Text(l10n.manualReceiptAddItem),
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.manualReceiptTotal,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  Money.format(_totalCents),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.manualReceiptToPantry),
              value: _toPantry,
              onChanged: (value) => setState(() => _toPantry = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.manualReceiptSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// The fields of one item while it is being typed.
class _ItemDraft {
  final name = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final price = TextEditingController();
  String unit = 'pz';

  /// `null`: chosen from the name, like a photographed receipt's rows.
  int? categoryId;

  void dispose() {
    name.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class _ItemCard extends StatelessWidget {
  const new({
    required this.index,
    required this.item,
    required this.categories,
    required this.onRemove,
    required this.onChanged,
    super.key,
  });

  final int index;
  final _ItemDraft item;
  final List<PantryCategory> categories;
  final VoidCallback? onRemove;

  /// Something that changes the total or the layout changed.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.manualReceiptItem(index + 1),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: l10n.manualReceiptRemoveItem,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  TextFormField(
                    controller: item.name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.pantryFieldName,
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l10n.pantryInvalidName
                        : null,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: item.quantity,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.pantryFieldQuantity,
                          ),
                          validator: (v) {
                            final q = _ManualReceiptScreenState._parseQuantity(
                              v ?? '',
                            );
                            return q == null || q <= 0
                                ? l10n.pantryInvalidQuantity
                                : null;
                          },
                        ),
                      ),
                      SegmentedButton<String>(
                        segments: [
                          for (final unit in ['pz', 'kg', 'l'])
                            ButtonSegment(
                              value: unit,
                              label: Text(unitLabel(l10n, unit)),
                            ),
                        ],
                        selected: {item.unit},
                        showSelectedIcon: false,
                        onSelectionChanged: (s) {
                          item.unit = s.first;
                          onChanged();
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: item.price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.manualReceiptPrice,
                      suffixText: '€',
                    ),
                    onChanged: (_) => onChanged(),
                    validator: (v) {
                      final cents = Money.parseCents((v ?? '').trim());
                      return cents == null || cents < 0
                          ? l10n.pantryInvalidPrice
                          : null;
                    },
                  ),
                  DropdownButtonFormField<int?>(
                    initialValue: item.categoryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.pantryFieldCategory,
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text(l10n.manualReceiptCategoryAuto),
                      ),
                      for (final c in categories)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (id) => item.categoryId = id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
