import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/pantry/domain/triage_grouping.dart';
import 'package:scontrini/features/pantry/presentation/quantity_format.dart';
import 'package:scontrini/features/pantry/presentation/widgets/lot_avatar.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// What the user decided for a triage card.
enum TriageDecision {
  /// Swiped right: the product goes in the pantry.
  keep,

  /// Swiped left: not in the pantry (the purchase still counts).
  skip,
}

/// The pantry triage: one card per product of a receipt, swiped right to
/// put it in the pantry, left to leave it out (docs/pantry_and_stats.md).
/// The buttons do the same, and the last decision can be undone.
class TriageSwipe extends StatefulWidget {
  const new({
    required this.cards,
    required this.onDecision,
    required this.onUndo,
    required this.onDone,
    this.spriteFor,
    super.key,
  });

  /// The sprite asset of a card's category, if it has one.
  final String? Function(TriageCard card)? spriteFor;

  final List<TriageCard> cards;
  final Future<void> Function(TriageCard card, TriageDecision decision)
  onDecision;
  final Future<void> Function(TriageCard card, TriageDecision decision) onUndo;

  /// Called after the last card, with every decision.
  final void Function(Map<TriageCard, TriageDecision> decisions) onDone;

  /// Horizontal drag, as a share of the card width, that decides.
  static const threshold = 0.3;

  @override
  State<TriageSwipe> createState() => _TriageSwipeState();
}

class _TriageSwipeState extends State<TriageSwipe>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  final _decisions = <TriageCard, TriageDecision>{};
  final _history = <TriageCard>[];

  /// The top card's drag, in pixels.
  Offset _drag = Offset.zero;
  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Offset>? _flyAnimation;
  var _busy = false;

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  TriageCard? get _current =>
      _index < widget.cards.length ? widget.cards[_index] : null;

  Future<void> _decide(TriageDecision decision, double width) async {
    final card = _current;
    if (card == null || _busy) return;
    _busy = true;
    // The card flies off on the side of the decision, then the next shows.
    final end = Offset(
      (decision == TriageDecision.keep ? 1.5 : -1.5) * width,
      _drag.dy,
    );
    _flyAnimation = Tween(
      begin: _drag,
      end: end,
    ).animate(CurvedAnimation(parent: _fly, curve: Curves.easeOut));
    await _fly.forward(from: 0);
    await widget.onDecision(card, decision);
    if (!mounted) return;
    setState(() {
      _decisions[card] = decision;
      _history.add(card);
      _index++;
      _drag = Offset.zero;
      _flyAnimation = null;
      _busy = false;
    });
    if (_current == null) widget.onDone(Map.of(_decisions));
  }

  Future<void> _undo() async {
    if (_history.isEmpty || _busy) return;
    final card = _history.removeLast();
    final decision = _decisions.remove(card)!;
    await widget.onUndo(card, decision);
    if (!mounted) return;
    setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final current = _current;
        final next = _index + 1 < widget.cards.length
            ? widget.cards[_index + 1]
            : null;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    l10n.triageCounter(
                      math.min(_index + 1, widget.cards.length),
                      widget.cards.length,
                    ),
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _history.isEmpty ? null : _undo,
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.pantryUndo),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: widget.cards.isEmpty ? 1 : _index / widget.cards.length,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (next != null)
                      Transform.scale(
                        scale: 0.94,
                        child: _CardFace(
                          next,
                          sprite: widget.spriteFor?.call(next),
                        ),
                      ),
                    if (current != null)
                      AnimatedBuilder(
                        animation: _fly,
                        builder: (context, child) {
                          final offset = _flyAnimation?.value ?? _drag;
                          return Transform.translate(
                            offset: offset,
                            child: Transform.rotate(
                              angle: offset.dx / width * 0.3,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onPanUpdate: (d) => setState(() => _drag += d.delta),
                          onPanEnd: (_) {
                            final share = _drag.dx / width;
                            if (share > TriageSwipe.threshold) {
                              unawaited(_decide(TriageDecision.keep, width));
                            } else if (share < -TriageSwipe.threshold) {
                              unawaited(_decide(TriageDecision.skip, width));
                            } else {
                              setState(() => _drag = Offset.zero);
                            }
                          },
                          child: _CardFace(
                            current,
                            hint: _drag.dx / width,
                            sprite: widget.spriteFor?.call(current),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundButton(
                    icon: Icons.close,
                    label: l10n.triageSkip,
                    color: theme.colorScheme.error,
                    onPressed: current == null
                        ? null
                        : () => _decide(TriageDecision.skip, width),
                  ),
                  _RoundButton(
                    icon: Icons.kitchen_outlined,
                    label: l10n.triageKeep,
                    color: theme.colorScheme.primary,
                    onPressed: current == null
                        ? null
                        : () => _decide(TriageDecision.keep, width),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One product: avatar, name, quantity and price. [hint] is the drag as a
/// share of the width: the side's label fades in as the card moves.
class _CardFace extends StatelessWidget {
  const new(this.card, {this.hint = 0, this.sprite});

  final TriageCard card;
  final double hint;
  final String? sprite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final keep = (hint / TriageSwipe.threshold).clamp(0.0, 1.0);
    final skip = (-hint / TriageSwipe.threshold).clamp(0.0, 1.0);
    return Card(
      elevation: 4,
      child: SizedBox(
        width: double.infinity,
        height: 360,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  SizedBox.square(
                    dimension: 96,
                    child: FittedBox(
                      child: LotAvatar(
                        name: card.name,
                        color: theme.colorScheme.primaryContainer,
                        sprite: sprite,
                      ),
                    ),
                  ),
                  Text(
                    card.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    '${formatQuantity(l10n, card.quantity, card.unit)} · '
                    '${Money.format(card.priceCents)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Opacity(
                opacity: keep,
                child: _Stamp(l10n.triageKeep, theme.colorScheme.primary),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Opacity(
                opacity: skip,
                child: _Stamp(l10n.triageSkip, theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const new(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: color, width: 3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      IconButton.outlined(
        iconSize: 32,
        color: color,
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: label,
      ),
      Text(label),
    ],
  );
}
