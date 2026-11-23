import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/pantry/data/pantry_providers.dart';
import 'package:scontrini/features/pantry/domain/triage_grouping.dart';
import 'package:scontrini/features/pantry/presentation/triage_swipe.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// The pantry triage of a confirmed receipt: right swipes put the product
/// in the pantry (one lot per card), an undo removes that lot again.
class ReceiptTriageScreen extends ConsumerStatefulWidget {
  const new({required this.receiptId, super.key});

  final int receiptId;

  @override
  ConsumerState<ReceiptTriageScreen> createState() =>
      _ReceiptTriageScreenState();
}

class _ReceiptTriageScreenState extends ConsumerState<ReceiptTriageScreen> {
  late final Future<List<TriageCard>> _cards = ref
      .read(pantryRepositoryProvider)
      .triageCards(widget.receiptId);
  final _lots = <TriageCard, int>{};

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(pantryRepositoryProvider);
    return TriageScreen(
      cards: _cards,
      onDecision: (card, decision) async {
        if (decision == TriageDecision.keep) {
          _lots[card] = await repository.addFromReceipt(widget.receiptId, card);
        }
      },
      onUndo: (card, decision) async {
        final lot = _lots.remove(card);
        if (lot != null) await repository.deleteLot(lot);
      },
    );
  }
}

/// The triage page around [TriageSwipe]: loads the cards, then shows a
/// summary when every card is decided.
class TriageScreen extends StatefulWidget {
  const new({
    required this.cards,
    required this.onDecision,
    required this.onUndo,
    super.key,
  });

  final Future<List<TriageCard>> cards;
  final Future<void> Function(TriageCard card, TriageDecision decision)
  onDecision;
  final Future<void> Function(TriageCard card, TriageDecision decision) onUndo;

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  Map<TriageCard, TriageDecision>? _done;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.triageTitle)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<TriageCard>>(
              future: widget.cards,
              builder: (context, snapshot) {
                final cards = snapshot.data;
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.triageFailed));
                }
                if (cards == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final done = _done;
                if (cards.isEmpty || done != null) {
                  return _Summary(
                    kept:
                        done?.values
                            .where((d) => d == TriageDecision.keep)
                            .length ??
                        0,
                    skipped:
                        done?.values
                            .where((d) => d == TriageDecision.skip)
                            .length ??
                        0,
                  );
                }
                return TriageSwipe(
                  cards: cards,
                  onDecision: widget.onDecision,
                  onUndo: widget.onUndo,
                  onDone: (decisions) => setState(() => _done = decisions),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.kept, required this.skipped});

  final int kept;
  final int skipped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Icon(Icons.kitchen_outlined, size: 48),
            Text(
              l10n.triageSummary(kept, skipped),
              textAlign: TextAlign.center,
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(l10n.triageDone),
            ),
          ],
        ),
      ),
    );
  }
}
