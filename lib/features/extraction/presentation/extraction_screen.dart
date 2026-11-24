import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/presentation/extraction_result_provider.dart';
import 'package:scontrini/features/extraction/presentation/receipt_review_screen.dart';
import 'package:scontrini/features/extraction/presentation/review_draft_provider.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Phases 2–3: reads a captured receipt (progress bar, error with retry),
/// then hands it to the [ReceiptReviewScreen].
class ExtractionScreen extends ConsumerWidget {
  const new({required this.source, super.key});

  final ReceiptSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(extractionResultProvider(source));
    final draft = ref.watch(reviewDraftProvider(source));

    if ((result.value, draft.value) case (final r?, final d?)
        when !result.isLoading && !draft.isLoading) {
      // A new draft (after a retry) starts a fresh review.
      return ReceiptReviewScreen(
        key: ObjectKey(d),
        source: source,
        result: r,
        initialDraft: d,
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

/// While the receipt is read: the step and a bar that fills up as lines
/// are read (indeterminate when the reader can't tell, e.g. ML Kit).
class _Progress extends ConsumerWidget {
  const new({required this.source});

  final ReceiptSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(extractionProgressProvider(source));
    final fraction = progress?.fraction;
    final step = switch (progress?.step) {
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
              tween: Tween(end: fraction ?? 0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) => LinearProgressIndicator(
                value: fraction == null ? null : value,
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
