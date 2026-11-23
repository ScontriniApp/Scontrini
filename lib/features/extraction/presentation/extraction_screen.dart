import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/domain/extraction_result.dart';
import 'package:scontrini/features/extraction/domain/image_text_reader.dart';
import 'package:scontrini/features/extraction/domain/models/parse_warning.dart';
import 'package:scontrini/features/extraction/domain/models/parsed_item.dart';
import 'package:scontrini/features/extraction/domain/models/quantity_unit.dart';
import 'package:scontrini/features/extraction/presentation/extraction_result_provider.dart';
import 'package:scontrini/features/pantry/presentation/triage_screen.dart';
import 'package:scontrini/features/receipts/data/receipt_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

// TODO(extraction): replace with the review screen (edit fields, confirm,
// save to the database). For now this is a read-only preview.

/// Phase 2: shows what was read from a captured receipt.
class ExtractionScreen extends ConsumerWidget {
  const new({required this.source, super.key});

  final ReceiptSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(extractionResultProvider(source));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.extractionTitle),
        actions: [
          if (kDebugMode && result.hasValue)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: l10n.exportFixture,
              onPressed: () => _export(context, ref, result.requireValue),
            ),
        ],
      ),
      bottomNavigationBar: result.hasValue
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.kitchen_outlined),
                  label: Text(l10n.confirmAndSort),
                  onPressed: () =>
                      _confirmAndSort(context, ref, result.requireValue),
                ),
              ),
            )
          : null,
      body: switch (result) {
        AsyncData(:final value) => _ResultView(result: value),
        AsyncError() => _Message(
          icon: Icons.error_outline,
          text: l10n.extractionFailed,
          action: FilledButton(
            onPressed: () => ref.invalidate(extractionResultProvider(source)),
            child: Text(l10n.retry),
          ),
        ),
        _ => _Progress(source: source),
      },
    );
  }

  /// Saves the receipt as confirmed, then opens the pantry triage on it.
  Future<void> _confirmAndSort(
    BuildContext context,
    WidgetRef ref,
    ExtractionResult result,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final receiptId = await ref
          .read(receiptRepositoryProvider)
          .saveConfirmed(
            result.receipt,
            sourcePath: source.paths.firstOrNull,
            rawOcrText: result.rowsText,
          );
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ReceiptTriageScreen(receiptId: receiptId),
        ),
      );
    } on Object catch (error) {
      debugPrint('Saving the receipt failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.confirmFailed)));
    }
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ExtractionResult result,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final name = await ref.read(fixtureExporterProvider).export(result);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.exportFixtureDone(name))));
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

class _ResultView extends StatelessWidget {
  const new({required this.result});

  final ExtractionResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final receipt = result.receipt;
    final date = receipt.purchaseDate;
    final total = receipt.totalCents;
    const missing = '—';

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.extractionPreviewNotice),
        ),
        for (final warning in receipt.warnings)
          ListTile(
            leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
            title: Text(warningLabel(l10n, warning)),
          ),
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Field(l10n.fieldStore, receipt.storeName ?? missing),
              _Field(
                l10n.fieldDate,
                date == null
                    ? missing
                    : DateFormat.yMd(locale).add_Hm().format(date),
              ),
              _Field(
                l10n.fieldTotal,
                total == null ? missing : Money.format(total),
              ),
              _Field(
                l10n.fieldItemsTotal,
                Money.format(receipt.computedTotalCents),
              ),
            ],
          ),
        ),
        _SectionTitle(l10n.extractionItems(receipt.items.length)),
        for (final item in receipt.items) _ItemTile(item: item),
        if (receipt.discountCents > 0)
          ListTile(
            title: Text(l10n.extractionReceiptDiscount),
            trailing: Text(Money.format(-receipt.discountCents)),
          ),
        if (receipt.unparsedLines.isNotEmpty) ...[
          _SectionTitle(l10n.extractionUnparsed),
          for (final line in receipt.unparsedLines)
            ListTile(
              dense: true,
              title: Text(
                line,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
        ],
        ExpansionTile(
          title: Text(l10n.extractionRawText),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            SelectableText(
              result.rowsText,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

String warningLabel(AppLocalizations l10n, ParseWarning warning) =>
    switch (warning) {
      ParseWarning.missingStore => l10n.warningMissingStore,
      ParseWarning.missingDate => l10n.warningMissingDate,
      ParseWarning.missingTotal => l10n.warningMissingTotal,
      ParseWarning.totalMismatch => l10n.warningTotalMismatch,
      ParseWarning.lineTotalMismatch => l10n.warningLineTotalMismatch,
    };

class _Field extends StatelessWidget {
  const new(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(dense: true, title: Text(label), trailing: Text(value));
  }
}

class _SectionTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const new({required this.item});

  final ParsedItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final details = [
      if (item.quantity != 1 || item.unit != QuantityUnit.piece)
        _quantityText(item, locale),
      if (item.discountCents > 0)
        l10n.extractionDiscount(Money.format(item.discountCents)),
      for (final warning in item.warnings) warningLabel(l10n, warning),
    ];

    return ListTile(
      leading: item.warnings.isEmpty
          ? null
          : Icon(Icons.warning_amber, color: theme.colorScheme.error),
      title: Text(item.rawName),
      subtitle: details.isEmpty ? null : Text(details.join('\n')),
      trailing: Text(Money.format(item.netCents)),
    );
  }

  static String _quantityText(ParsedItem item, String locale) {
    final quantity = NumberFormat('0.###', locale).format(item.quantity);
    final price = Money.format(item.unitPriceCents);
    return switch (item.unit) {
      QuantityUnit.piece => '$quantity × $price',
      QuantityUnit.kilogram => '$quantity kg × $price/kg',
      QuantityUnit.litre => '$quantity l × $price/l',
    };
  }
}
