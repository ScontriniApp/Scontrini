import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/core/section_colors/section_surface.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/category_label.dart';
import 'package:scontrini/features/pantry/presentation/category_sprites.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/category_section_header.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_actions_sheet.dart';
import 'package:scontrini/features/pantry/presentation/widgets/pantry_lot_tile.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The pantry tab: lots grouped by category, a slider per lot, actions on
/// tap. The app bar's add opens a receipt typed in by hand, so what is
/// bought without a photo still lands in the history and the statistics.
class PantryScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  bool _showClosed = false;

  /// Open sections, by category id (`null`: uncategorised). All start
  /// closed: a section header shows its name and how many lots it holds.
  final _open = <int?>{};

  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
            onPressed: () => context.push(Routes.manualReceipt),
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
    final query = _normalise(_query);
    final groups = <int?, List<PantryLot>>{};
    for (final lot in lots) {
      if (query.isNotEmpty && !_normalise(lot.name).contains(query)) continue;
      final key = byId.containsKey(lot.categoryId) ? lot.categoryId : null;
      groups.putIfAbsent(key, () => []).add(lot);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return categoryLabel(
          l10n,
          byId[a]!.name,
        ).compareTo(categoryLabel(l10n, byId[b]!.name));
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SearchBar(
            controller: _search,
            hintText: l10n.pantrySearchHint,
            leading: const Icon(Icons.search),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  tooltip: l10n.pantrySearchClear,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: keys.isEmpty
              ? Center(child: Text(l10n.pantryNoResults))
              : ListView(
                  // Clear of the shell's FAB.
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    for (final key in keys)
                      SectionSurface(
                        panel: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CategorySectionHeader(
                              title: key == null
                                  ? l10n.pantryUncategorised
                                  : categoryLabel(l10n, byId[key]!.name),
                              sprite: categorySprite(byId[key]?.name),
                              trailing: '${groups[key]!.length}',
                              // While searching, every section with a match is
                              // open; otherwise the user opens them.
                              open: query.isNotEmpty || _open.contains(key),
                              onTap: query.isNotEmpty
                                  ? null
                                  : () => setState(
                                      () => _open.contains(key)
                                          ? _open.remove(key)
                                          : _open.add(key),
                                    ),
                            ),
                            if (query.isNotEmpty || _open.contains(key))
                              for (final lot in groups[key]!)
                                PantryLotTile(
                                  key: ValueKey(lot.id),
                                  lot: lot,
                                  color: key == null
                                      ? _fallbackColor
                                      : Color(byId[key]!.color),
                                  onSetRemaining: (value) =>
                                      _setRemaining(lot, value),
                                  onTap: () => _choose(lot),
                                ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Lower case, without accents: `caffè` finds `CAFFE`.
  static String _normalise(String text) => text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[àáâä]'), 'a')
      .replaceAll(RegExp('[èéêë]'), 'e')
      .replaceAll(RegExp('[ìíîï]'), 'i')
      .replaceAll(RegExp('[òóôö]'), 'o')
      .replaceAll(RegExp('[ùúûü]'), 'u');

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

  /// A tap on a lot: manage it in the pantry, or see its product's
  /// statistics (only for lots linked to a product).
  Future<void> _choose(PantryLot lot) async {
    final l10n = AppLocalizations.of(context);
    final productId = lot.productId;
    final choice = await showModalBottomSheet<_LotChoice>(
      context: context,
      showDragHandle: true,
      // Above the shell's FAB and navigation bar.
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                lot.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.kitchen_outlined),
              title: Text(l10n.pantryManage),
              onTap: () => Navigator.of(context).pop(_LotChoice.manage),
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: Text(l10n.pantryStatistics),
              enabled: productId != null,
              onTap: () => Navigator.of(context).pop(_LotChoice.statistics),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _LotChoice.manage:
        await _actions(lot);
      case _LotChoice.statistics when productId != null:
        await context.push(Routes.product(productId));
      case _:
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

/// The two ways into a lot from the pantry list.
enum _LotChoice { manage, statistics }
