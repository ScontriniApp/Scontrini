import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/paper/paper_bubble.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/presentation/extraction_result_provider.dart';
import 'package:scontrini/features/extraction/presentation/receipt_review_screen.dart';
import 'package:scontrini/features/extraction/presentation/review_draft_provider.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Phases 2–3: reads a captured receipt (progress bar, error with retry),
/// then hands it to the [ReceiptReviewScreen]. The progress stays up
/// ("preparing the receipt") until the review's paper is ready, so the
/// receipt never shows without it.
class ExtractionScreen extends ConsumerWidget {
  const new({required this.source, super.key});

  final ReceiptSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(extractionResultProvider(source));
    final draft = ref.watch(reviewDraftProvider(source));
    // The paper's shaders load while the receipt is read.
    ref.watch(paperProgramProvider);

    if ((result.value, draft.value) case (final r?, final d?)
        when !result.isLoading && !draft.isLoading) {
      // A new draft (after a retry) starts a fresh review.
      return _PaperGate(
        key: ObjectKey(d),
        cover: Scaffold(
          appBar: AppBar(title: Text(l10n.extractionTitle)),
          body: _Progress(source: source, finishing: true),
        ),
        builder: (onReady) => ReceiptReviewScreen(
          source: source,
          result: r,
          initialDraft: d,
          onPaperReady: onReady,
        ),
      );
    }
    final failed = result.hasError || draft.hasError;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.extractionTitle)),
      body: failed
          ? _Message(
              icon: Icons.error_outline,
              text: l10n.extractionFailed,
              action: FilledButton(
                onPressed: () =>
                    ref.invalidate(extractionResultProvider(source)),
                child: Text(l10n.retry),
              ),
            )
          : _Progress(source: source),
    );
  }
}

/// The review built underneath [cover], shown once its paper is ready
/// (or after [PaperBubble.readyTimeout], so it never hangs).
class _PaperGate extends StatefulWidget {
  const new({required this.cover, required this.builder, super.key});

  final Widget cover;
  final Widget Function(VoidCallback onReady) builder;

  @override
  State<_PaperGate> createState() => _PaperGateState();
}

class _PaperGateState extends State<_PaperGate> {
  bool _ready = !PaperBubble.waitForPaper;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    if (!_ready) _timeout = Timer(PaperBubble.readyTimeout, _show);
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  void _show() {
    _timeout?.cancel();
    if (mounted && !_ready) setState(() => _ready = true);
  }

  @override
  // Offstage: laid out (the paper needs its size), not painted or found
  // under the cover.
  Widget build(BuildContext context) => Stack(
    children: [
      Offstage(offstage: !_ready, child: widget.builder(_show)),
      if (!_ready) widget.cover,
    ],
  );
}

/// While the receipt is read: the step and a bar that fills up as lines
/// are read (indeterminate when the reader can't tell, e.g. ML Kit). With
/// [finishing], the receipt is read and its paper is being prepared.
class _Progress extends ConsumerWidget {
  const new({required this.source, this.finishing = false});

  final ReceiptSource source;
  final bool finishing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(extractionProgressProvider(source));
    final fraction = finishing ? null : progress?.fraction;
    final step = finishing
        ? l10n.extractionStepPaper
        : switch (progress?.step) {
            null || ReadStep.preparing => l10n.extractionStepPreparing,
            ReadStep.findingLines => l10n.extractionStepFindingLines,
            ReadStep.readingLines => l10n.extractionStepReadingLines,
            ReadStep.parsing => l10n.extractionStepParsing,
          };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Icon(Icons.document_scanner_outlined, size: 48),
            Text(l10n.extractionLoading, textAlign: TextAlign.center),
            TweenAnimationBuilder<double>(
              // Eases between reports, so the bar moves rather than jumps.
              tween: Tween(end: finishing ? 1 : fraction ?? 0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) => LinearProgressIndicator(
                value: finishing || fraction != null ? value : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              fraction == null ? step : '$step ${(fraction * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const new({required this.icon, required this.text, required this.action});

  final IconData icon;
  final String text;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(icon, size: 48),
            Text(text, textAlign: TextAlign.center),
            action,
          ],
        ),
      ),
    );
  }
}
