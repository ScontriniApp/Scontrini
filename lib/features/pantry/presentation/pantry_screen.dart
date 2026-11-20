import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/manual_add_sheet.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_actions_sheet.dart';
import 'package:scontrini/features/pantry/presentation/widgets/pantry_lot_tile.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The pantry tab: lots grouped by category, a slider per lot, actions on
/// tap, manual add in the app bar.
class PantryScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  bool _showClosed = false;

  static const _fallbackColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lots = ref.watch(
      _showClosed ? pantryAllLotsProvider : pantryActiveLotsProvider,
    );
    final categories =
        ref.watch(pantryCategoriesProvider).value ?? const <PantryCategory>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPantry),
        actions: [
          IconButton(
            tooltip: _showClosed
                ? l10n.pantryHideClosed
                : l10n.pantryShowClosed,
            icon: Icon(_showClosed ? Icons.history_toggle_off : Icons.history),
            onPressed: () => setState(() => _showClosed = !_showClosed),
          ),
          IconButton(
            tooltip: l10n.pantryAdd,
            icon: const Icon(Icons.add),
            onPressed: () => _addManual(categories),
          ),
        ],
      ),
      body: switch (lots) {
        AsyncData(:final value) when value.isEmpty => PlaceholderView(
          icon: Icons.kitchen_outlined,
          message: l10n.pantryEmpty,
        ),
        AsyncData(:final value) => _list(l10n, value, categories),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _list(
    AppLocalizations l10n,
    List<PantryLot> lots,
    List<PantryCategory> categories,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final groups = <int?, List<PantryLot>>{};
    for (final lot in lots) {
      final key = byId.containsKey(lot.categoryId) ? lot.categoryId : null;
      groups.putIfAbsent(key, () => []).add(lot);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return byId[a]!.name.compareTo(byId[b]!.name);
      });

    return ListView(
      padding: const EdgeInsets.only(bottom: 96), // clear of the shell's FAB
      children: [
        for (final key in keys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              key == null ? l10n.pantryUncategorised : byId[key]!.name,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          for (final lot in groups[key]!)
            PantryLotTile(
              key: ValueKey(lot.id),
              lot: lot,
              color: key == null ? _fallbackColor : Color(byId[key]!.color),
              onSetRemaining: (value) => _setRemaining(lot, value),
              onTap: () => _actions(lot),
            ),
        ],
      ],
    );
  }

  Future<void> _setRemaining(PantryLot lot, double value) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(pantryRepositoryProvider).setRemaining(lot.id, value);
    final used = lot.remainingQuantity - value;
    if (used > 0) {
      _undoable(
        lot,
        l10n.pantryConsumedMessage(
          lot.name,
          formatQuantity(l10n, used, lot.unit),
        ),
      );
    }
  }

  Future<void> _actions(PantryLot lot) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(pantryRepositoryProvider);
    final action = await showLotActions(context, lot);
    if (!mounted || action == null) return;
    switch (action) {
      case ConsumeAllAction():
        await repo.consume(lot.id, lot.remainingQuantity);
        _undoable(lot, l10n.pantryFinishedMessage(lot.name));
      case DiscardAction(:final reason):
        await repo.discard(lot.id, reason);
        _undoable(lot, l10n.pantryDiscardedMessage(lot.name));
      case UndoAction():
        final undone = await repo.undoLast(lot.id);
        if (!undone) _snack(l10n.pantryNothingToUndo);
      case DeleteAction():
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(l10n.pantryDeleteConfirm(lot.name)),
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
        if (confirmed ?? false) await repo.deleteLot(lot.id);
    }
  }

  Future<void> _addManual(List<PantryCategory> categories) async {
    final draft = await showManualAddSheet(context, categories);
    if (draft == null) return;
    await ref
        .read(pantryRepositoryProvider)
        .addManual(
          name: draft.name,
          quantity: draft.quantity,
          unit: draft.unit,
          source: draft.source,
          priceCents: draft.priceCents,
          categoryId: draft.categoryId,
        );
  }

  void _undoable(PantryLot lot, String message) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(pantryRepositoryProvider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.pantryUndo,
            onPressed: () => repo.undoLast(lot.id),
          ),
        ),
      );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
