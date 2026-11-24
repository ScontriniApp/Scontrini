import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:scontrini/app/router.dart';
import 'package:scontrini/features/capture/data/capture_providers.dart';
import 'package:scontrini/features/capture/data/receipt_capture_service.dart';
import 'package:scontrini/features/capture/domain/receipt_source.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// Phase 1: choose how to acquire a receipt.
class CaptureScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Loads PaddleOCR while the user takes the photo.
    void warmUpPhotoReader() => unawaited(
      ref
          .read(paddleOcrProvider)
          .warmUp()
          .onError((error, _) => debugPrint('OCR warm-up failed: $error')),
    );

    Future<void> capture(
      Future<ReceiptSource?> Function(ReceiptCaptureService service) action,
    ) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final source = await action(ref.read(receiptCaptureServiceProvider));
        if (source != null && context.mounted) {
          await context.push(Routes.extraction, extra: source);
        }
      } on Exception catch (error) {
        debugPrint('Capture failed: $error');
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.captureFailed)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CaptureOption(
            icon: Icons.document_scanner_outlined,
            label: l10n.captureScan,
            onTap: () {
              warmUpPhotoReader();
              unawaited(capture((s) => s.scan()));
            },
          ),
          _CaptureOption(
            icon: Icons.photo_library_outlined,
            label: l10n.captureGallery,
            onTap: () {
              warmUpPhotoReader();
              unawaited(capture((s) => s.pickImages()));
            },
          ),
          _CaptureOption(
            icon: Icons.picture_as_pdf_outlined,
            label: l10n.capturePdf,
            onTap: () => capture((s) => s.pickPdf()),
          ),
        ],
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
