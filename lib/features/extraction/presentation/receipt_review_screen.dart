import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
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
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Phase 3 review, the one screen after a scan: for every product the user
/// confirms it was read correctly or corrects it by hand (name, quantity,
/// price, category), adds missed rows and drops wrong ones; the store,
/// date, total and discount can be corrected too. Warnings follow every
/// edit. Once every row is confirmed, saving stores the receipt
/// (`saveConfirmed`, so it reaches the dashboard and statistics), puts all
/// its products in the pantry and goes to the dashboard.
class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const new({
    required this.source,
    required this.result,
    required this.initialDraft,
    super.key,
  });

  final ReceiptSource source;
  final ExtractionResult result;
  final ReceiptDraft initialDraft;

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late ReceiptDraft _draft = widget.initialDraft;
  var _edited = false;
  var _saving = false;
  var _saved = false;

  void _update(ReceiptDraft draft) => setState(() {
    _draft = draft;
    _edited = true;
  });

  List<PantryCategory> get _categories =>
      ref.read(pantryCategoriesProvider).value ?? const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(pantryCategoriesProvider).value ?? const [];
    final names = {for (final c in categories) c.id: c.name};

    return PopScope(
      canPop: !_edited || _saved,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reviewTitle),
          actions: [
            if (kDebugMode)
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: l10n.exportFixture,
                onPressed: _export,
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              key: const Key('review-save'),
              icon: const Icon(Icons.check),
              label: Text(
                _draft.pendingCount == 0
                    ? l10n.reviewSave
                    : l10n.reviewSaveBlocked(_draft.pendingCount),
              ),
              onPressed: _saving || !_draft.canSave ? null : _confirm,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.reviewNotice),
            ),
            for (final warning in _draft.receipt.warnings)
              _WarningTile(
                warning: warning,
                draft: _draft,
                onUseItemsTotal: () => _update(
                  _draft.withTotal(_draft.receipt.computedTotalCents),
                ),
              ),
            _HeaderCard(draft: _draft, onChanged: _update),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _draft.pendingCount == 0
                          ? l10n.extractionItems(_draft.items.length)
                          : l10n.reviewItemsPending(
                              _draft.items.length,
                              _draft.pendingCount,
                            ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.reviewAddItem),
                    onPressed: _addItem,
                  ),
                ],
              ),
            ),
            if (_draft.items.isEmpty) ListTile(title: Text(l10n.reviewNoItems)),
            for (final (i, item) in _draft.items.indexed)
              _ItemTile(
                item: item,
                categoryName: names[item.categoryId],
                onCorrect: () => _editItem(i),
                onConfirm: (confirmed) =>
                    _update(_draft.withConfirmed(i, confirmed: confirmed)),
              ),
            if (widget.result.receipt.unparsedLines.isNotEmpty)
              ExpansionTile(
                title: Text(l10n.extractionUnparsed),
                subtitle: Text(l10n.reviewUnparsedHint),
                children: [
                  for (final line in widget.result.receipt.unparsedLines)
                    ListTile(
                      dense: true,
                      title: Text(
                        line,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                ],
              ),
            ExpansionTile(
              title: Text(l10n.extractionRawText),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                SelectableText(
                  widget.result.rowsText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    final result = await showReviewItemSheet(context, categories: _categories);
    if (result is ItemEdited) _update(_draft.addItem(result.item));
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

  /// Saves the reviewed receipt, puts its products in the pantry, then goes
  /// to the dashboard: the receipt is done, so it can't be saved twice.
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
            sourcePath: widget.source.paths.firstOrNull,
            rawOcrText: widget.result.rowsText,
          );
      final inPantry = await ref
          .read(pantryRepositoryProvider)
          .addAllFromReceipt(receiptId);
      setState(() => _saved = true);
      router.go(Routes.dashboard);
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
    final name = await ref.read(fixtureExporterProvider).export(widget.result);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.exportFixtureDone(name))));
  }
}

Future<bool> _confirmDiscard(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final discard = await showDialog<bool>(
    context: context,
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

class _WarningTile extends StatelessWidget {
  const new({
    required this.warning,
    required this.draft,
    required this.onUseItemsTotal,
  });

  final ParseWarning warning;
  final ReceiptDraft draft;
  final VoidCallback onUseItemsTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final receipt = draft.receipt;
    final mismatch = warning == ParseWarning.totalMismatch;
    return ListTile(
      leading: Icon(
        Icons.warning_amber,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(warningLabel(l10n, warning)),
      subtitle: switch (warning) {
        ParseWarning.totalMismatch => Text(
          l10n.reviewMismatchDetail(
            Money.format(receipt.computedTotalCents),
            Money.format(receipt.totalCents ?? 0),
          ),
        ),
        ParseWarning.missingDate => Text(l10n.reviewMissingDateHint),
        ParseWarning.missingTotal => Text(l10n.reviewMissingTotalHint),
        _ => null,
      },
      trailing: mismatch
          ? TextButton(
              onPressed: onUseItemsTotal,
              child: Text(l10n.reviewUseItemsTotal),
            )
          : null,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const new({required this.draft, required this.onChanged});

  final ReceiptDraft draft;
  final ValueChanged<ReceiptDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final receipt = draft.receipt;
    final date = receipt.purchaseDate;
    final total = receipt.totalCents;
    final warnings = receipt.warnings;
    const missing = '—';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _Field(
            label: l10n.fieldStore,
            value: receipt.storeName ?? missing,
            flagged: warnings.contains(ParseWarning.missingStore),
            onTap: () async {
              final name = await _editText(
                context,
                title: l10n.fieldStore,
                initial: receipt.storeName ?? '',
              );
              if (name != null) onChanged(draft.withStore(name));
            },
          ),
          _Field(
            label: l10n.fieldDate,
            value: date == null
                ? missing
                : DateFormat.yMd(locale).add_Hm().format(date),
            flagged: warnings.contains(ParseWarning.missingDate),
            onTap: () async {
              final picked = await _pickDateTime(context, date);
              if (picked != null) onChanged(draft.withDate(picked));
            },
          ),
          _Field(
            label: l10n.fieldTotal,
            value: total == null ? missing : Money.format(total),
            flagged:
                warnings.contains(ParseWarning.missingTotal) ||
                warnings.contains(ParseWarning.totalMismatch),
            onTap: () async {
              final cents = await _editAmount(
                context,
                title: l10n.fieldTotal,
                initial: total,
                allowEmpty: true,
              );
              if (cents != null) onChanged(draft.withTotal(cents.value));
            },
          ),
          _Field(
            label: l10n.extractionReceiptDiscount,
            value: Money.format(-receipt.discountCents),
            onTap: () async {
              final cents = await _editAmount(
                context,
                title: l10n.extractionReceiptDiscount,
                initial: receipt.discountCents,
                allowEmpty: true,
              );
              if (cents != null) {
                onChanged(draft.withDiscount(cents.value ?? 0));
              }
            },
          ),
          _Field(
            label: l10n.fieldItemsTotal,
            value: Money.format(receipt.computedTotalCents),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    this.flagged = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool flagged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return ListTile(
      dense: true,
      title: Text(label),
      leading: flagged
          ? Icon(Icons.warning_amber, color: error, size: 20)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text(value, style: flagged ? TextStyle(color: error) : null),
          if (onTap != null) const Icon(Icons.edit_outlined, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ItemTile extends StatelessWidget {
  const new({
    required this.item,
    required this.categoryName,
    required this.onCorrect,
    required this.onConfirm,
  });

  final DraftItem item;
  final String? categoryName;

  /// Opens the correction form.
  final VoidCallback onCorrect;

  /// Marks the row as read correctly, or (false) to look at again.
  final ValueChanged<bool> onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final row = item.item;

    final details = [
      if (row.quantity != 1 || row.unit != QuantityUnit.piece)
        _quantityText(row.quantity, row.unit, row.unitPriceCents, locale),
      if (row.discountCents > 0)
        l10n.extractionDiscount(Money.format(row.discountCents)),
      categoryName ?? l10n.reviewUncategorised,
      for (final warning in row.warnings) warningLabel(l10n, warning),
    ];

    final tile = ListTile(
      leading: item.confirmed
          ? IconButton(
              icon: Icon(Icons.check_circle, color: theme.colorScheme.primary),
              tooltip: l10n.reviewUnconfirmItem,
              onPressed: () => onConfirm(false),
            )
          : row.warnings.isEmpty
          ? const SizedBox(width: 48)
          : SizedBox(
              width: 48,
              child: Icon(Icons.warning_amber, color: theme.colorScheme.error),
            ),
      title: Text(row.rawName),
      subtitle: Text(details.join('\n')),
      trailing: Text(Money.format(row.netCents)),
      onTap: onCorrect,
    );
    if (item.confirmed) return tile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.check),
                label: Text(l10n.reviewConfirmItem),
                onPressed: () => onConfirm(true),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.reviewCorrectItem),
                onPressed: onCorrect,
              ),
            ],
          ),
        ),
      ],
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
    builder: (context) => _TextDialog(
      title: title,
      initial: initial == null || initial == 0
          ? ''
          : NumberFormat('0.00', 'it').format(initial / 100),
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
    initialDate: initial.isAfter(now) ? now : initial,
    firstDate: DateTime(2000),
    lastDate: now,
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
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
