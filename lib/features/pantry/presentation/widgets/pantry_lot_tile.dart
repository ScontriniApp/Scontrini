import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';
import 'package:scontrini/features/receipts/domain/transaction_hash.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// One lot: initials tile, name, origin and quantity, the share left and,
/// while active, a 0-100 % slider. The slider reports only on release, so
/// one drag is one event, and hands back a quantity
/// ([onSetRemaining] = initial × percent).
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
  /// Percent under the finger while dragging; null otherwise.
  double? _dragging;

  /// Slider steps of 5 %.
  static const _divisions = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lot = widget.lot;
    final active = lot.status == PantryLotStatus.active;
    final initial = lot.initialQuantity;
    final percent = _dragging ?? lot.remainingFraction * 100;
    final remaining = l10n.pantryRemaining(
      formatQuantity(l10n, initial * percent / 100, lot.unit),
      formatQuantity(l10n, initial, lot.unit),
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
                          [
                            _origin(l10n, lot),
                            if (active) remaining,
                          ].where((t) => t.isNotEmpty).join(' · '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    active ? '${percent.round()}%' : _status(l10n, lot.status),
                    style: active
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (active)
                Slider(
                  value: percent,
                  max: 100,
                  divisions: _divisions,
                  label: '${percent.round()}%',
                  onChanged: (value) => setState(() => _dragging = value),
                  onChangeEnd: (value) {
                    setState(() => _dragging = null);
                    final quantity = initial * value / 100;
                    if ((quantity - lot.remainingQuantity).abs() > 1e-9) {
                      widget.onSetRemaining(quantity);
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
