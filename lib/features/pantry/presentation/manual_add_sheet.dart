import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// What the manual-add form returns.
class ManualLotDraft {
  const new({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.source,
    this.priceCents,
    this.categoryId,
  });

  final String name;
  final double quantity;
  final String unit;
  final PantrySource source;
  final int? priceCents;
  final int? categoryId;
}

/// Opens the form; null when dismissed. "Already at home" is the default
/// source, since manual adds are mostly the first fill of the pantry.
Future<ManualLotDraft?> showManualAddSheet(
  BuildContext context,
  List<PantryCategory> categories,
) => showModalBottomSheet<ManualLotDraft>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: _ManualAddForm(categories: categories),
  ),
);

class _ManualAddForm extends StatefulWidget {
  const new({required this.categories});

  final List<PantryCategory> categories;

  @override
  State<_ManualAddForm> createState() => _ManualAddFormState();
}

class _ManualAddFormState extends State<_ManualAddForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _price = TextEditingController();
  String _unit = 'pz';
  PantrySource _source = PantrySource.initialStock;
  int? _categoryId;

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  static double? _parseQuantity(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final price = _price.text.trim();
    Navigator.of(context).pop(
      ManualLotDraft(
        name: _name.text.trim(),
        quantity: _parseQuantity(_quantity.text)!,
        unit: _unit,
        source: _source,
        priceCents: _source == PantrySource.manualPurchase && price.isNotEmpty
            ? Money.parseCents(price)
            : null,
        categoryId: _categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.pantryAdd,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.pantryFieldName),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.pantryInvalidName : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.pantryFieldQuantity,
                      ),
                      validator: (v) {
                        final q = _parseQuantity(v ?? '');
                        return q == null || q <= 0
                            ? l10n.pantryInvalidQuantity
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<String>(
                    segments: [
                      for (final unit in ['pz', 'kg', 'l'])
                        ButtonSegment(
                          value: unit,
                          label: Text(unitLabel(l10n, unit)),
                        ),
                    ],
                    selected: {_unit},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _unit = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PantrySource>(
                initialValue: _source,
                decoration: InputDecoration(labelText: l10n.pantryFieldSource),
                items: [
                  for (final (source, label) in [
                    (PantrySource.initialStock, l10n.pantrySourceInitialStock),
                    (
                      PantrySource.manualPurchase,
                      l10n.pantrySourceManualPurchase,
                    ),
                    (PantrySource.gift, l10n.pantrySourceGift),
                  ])
                    DropdownMenuItem(value: source, child: Text(label)),
                ],
                onChanged: (s) => setState(() => _source = s!),
              ),
              if (_source == PantrySource.manualPurchase) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.pantryFieldPrice,
                    suffixText: '€',
                  ),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    return text.isEmpty || (Money.parseCents(text) ?? -1) >= 0
                        ? null
                        : l10n.pantryInvalidPrice;
                  },
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: l10n.pantryFieldCategory,
                ),
                items: [
                  DropdownMenuItem(child: Text(l10n.pantryUncategorised)),
                  for (final c in widget.categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
