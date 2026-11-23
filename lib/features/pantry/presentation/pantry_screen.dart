import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/widgets/placeholder_view.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/pantry_category.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/category_sprites.dart';
import 'package:scontrini/features/pantry/presentation/manual_add_sheet.dart';
import 'package:scontrini/features/pantry/presentation/pantry_providers.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_actions_sheet.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';
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
    final theme = Theme.of(context);
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
        return byId[a]!.name.compareTo(byId[b]!.name);
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
                    for (final key in keys) ...[
                      _SectionHeader(
                        title: key == null
                            ? l10n.pantryUncategorised
                            : byId[key]!.name,
                        sprite: categorySprite(byId[key]?.name),
                        count: groups[key]!.length,
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
                        color: theme.colorScheme.primary,
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
                            onTap: () => _actions(lot),
                          ),
                    ],
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
    // Show the new lot: its section opens.
    if (mounted) setState(() => _open.add(draft.categoryId));
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

/// A category's heading: sprite, name, number of lots and a chevron. A tap
/// opens or closes the section ([onTap] null while searching: open).
class _SectionHeader extends StatelessWidget {
  const new({
    required this.title,
    required this.count,
    required this.open,
    required this.onTap,
    required this.color,
    this.sprite,
  });

  final String title;
  final String? sprite;
  final int count;
  final bool open;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          spacing: 12,
          children: [
            if (sprite case final sprite?)
              CategorySpriteImage(sprite, size: 40),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(color: color),
              ),
            ),
            Text('$count', style: theme.textTheme.titleMedium),
            Icon(open ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
