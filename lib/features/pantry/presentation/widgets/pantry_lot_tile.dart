import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// One lot: avatar, name, origin, what is left and, while active, a slider.
/// The slider reports only on release, so one drag is one event.
class PantryLotTile extends StatefulWidget {
  const new({
    required this.lot,
    required this.color,
    required this.onSetRemaining,
    required this.onTap,
    super.key,
  });

  final PantryLot lot;
  final Color color;
  final ValueChanged<double> onSetRemaining;
  final VoidCallback onTap;

  @override
  State<PantryLotTile> createState() => _PantryLotTileState();
}

class _PantryLotTileState extends State<PantryLotTile> {
  /// Value under the finger while dragging; null otherwise.
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lot = widget.lot;
    final active = lot.status == PantryLotStatus.active;
    final shown = _dragging ?? lot.remainingQuantity;
    final remaining = l10n.pantryRemaining(
      formatQuantity(l10n, shown, lot.unit),
      formatQuantity(l10n, lot.initialQuantity, lot.unit),
    );

    return InkWell(
      onTap: widget.onTap,
      child: Opacity(
        opacity: active ? 1 : 0.6,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  LotAvatar(name: lot.name, color: widget.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lot.name, style: theme.textTheme.titleMedium),
                        Text(
                          _origin(l10n, lot),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    active ? remaining : _status(l10n, lot.status),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (active)
                Slider(
                  value: shown.clamp(0, lot.initialQuantity).toDouble(),
                  max: lot.initialQuantity,
                  divisions: sliderDivisions(lot.initialQuantity, lot.unit),
                  label: formatQuantity(l10n, shown, lot.unit),
                  onChanged: (value) => setState(() => _dragging = value),
                  onChangeEnd: (value) {
                    setState(() => _dragging = null);
                    if (value != lot.remainingQuantity) {
                      widget.onSetRemaining(value);
                    }
                  },
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static String _origin(AppLocalizations l10n, PantryLot lot) =>
      switch (lot.source) {
        PantrySource.receipt => switch (lot.transactionHash) {
          final String hash => shortTransactionTag(hash),
          null => '',
        },
        PantrySource.manualPurchase => l10n.pantrySourceManualPurchase,
        PantrySource.initialStock => l10n.pantrySourceInitialStock,
        PantrySource.gift => l10n.pantrySourceGift,
      };

  static String _status(AppLocalizations l10n, PantryLotStatus status) =>
      switch (status) {
        PantryLotStatus.discarded => l10n.pantryStatusDiscarded,
        _ => l10n.pantryStatusConsumed,
      };
}
