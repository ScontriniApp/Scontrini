import 'package:material_ui/material_ui.dart';
import 'package:scontrini/l10n/app_localizations.dart';

// TODO(capture): wire the options to cunning_document_scanner, image_picker
// and file_picker, then hand the result to extraction.

/// Phase 1: choose how to acquire a receipt.
class CaptureScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void notImplemented() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CaptureOption(
            icon: Icons.document_scanner_outlined,
            label: l10n.captureScan,
            onTap: notImplemented,
          ),
          _CaptureOption(
            icon: Icons.photo_library_outlined,
            label: l10n.captureGallery,
            onTap: notImplemented,
          ),
          _CaptureOption(
            icon: Icons.picture_as_pdf_outlined,
            label: l10n.capturePdf,
            onTap: notImplemented,
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
