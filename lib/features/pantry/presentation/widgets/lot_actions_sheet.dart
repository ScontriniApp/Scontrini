import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';
import 'package:scontrini/features/pantry/domain/lot_ledger.dart';
import 'package:scontrini/features/pantry/domain/pantry_lot.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// What the user picked in the lot's action sheet.
sealed class LotAction {
  const new();
}

class ConsumeAllAction extends LotAction {
  const new();
}

class DiscardAction extends LotAction {
  const new(this.reason);
  final PantryEventReason reason;
}

class UndoAction extends LotAction {
  const new();
}

class DeleteAction extends LotAction {
  const new();
}

Future<LotAction?> showLotActions(BuildContext context, PantryLot lot) {
  final l10n = AppLocalizations.of(context);
  final active = lot.status == PantryLotStatus.active;
  return showModalBottomSheet<LotAction>(
    context: context,
    showDragHandle: true,
    // Above the shell's FAB and navigation bar.
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              lot.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (active) ...[
            _item(
              context,
              Icons.check_circle_outline,
              l10n.pantryConsumeAll,
              const ConsumeAllAction(),
            ),
            for (final (reason, label) in [
              (PantryEventReason.expired, l10n.pantryReasonExpired),
              (PantryEventReason.spoiled, l10n.pantryReasonSpoiled),
              (PantryEventReason.other, l10n.pantryReasonOther),
            ])
              _item(
                context,
                Icons.delete_outline,
                '${l10n.pantryDiscard}: $label',
                DiscardAction(reason),
              ),
          ],
          _item(context, Icons.undo, l10n.pantryUndoLast, const UndoAction()),
          _item(
            context,
            Icons.remove_circle_outline,
            l10n.pantryDelete,
            const DeleteAction(),
          ),
        ],
      ),
    ),
  );
}

Widget _item(
  BuildContext context,
  IconData icon,
  String label,
  LotAction action,
) => ListTile(
  leading: Icon(icon),
  title: Text(label),
  onTap: () => Navigator.of(context).pop(action),
);
