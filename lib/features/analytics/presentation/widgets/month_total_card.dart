import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';
import 'package:scontrini/core/utils/money.dart';
import 'package:scontrini/features/analytics/domain/models/dashboard_summary.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// This month's spending so far, with the usual amount by the same day,
/// drawn as an electronic shelf label: white plastic frame, grey e-ink
/// screen, big euros with small cents and "€" beside them, and a QR code.
///
/// The label is a physical object, so it keeps its colours in dark mode.
class MonthTotalCard extends StatelessWidget {
  const new({required this.summary, super.key});

  final DashboardSummary summary;

  static const _frame = Color(0xFFF5F5F3);
  static const _frameEdge = Color(0xFFD9D9D6);
  static const _screen = Color(0xFFD3D3CE);
  static const _ink = Color(0xFF1C1D1A);

  /// What the label's QR code opens when scanned.
  static const qrLink = 'https://youtu.be/dQw4w9WgXcQ?si=T2WgO4j0cNmCg5pH';

  static final _qr = QrImage(
    QrCode(
      payload: QrPayload.fromString(qrLink),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(summary.month.start);
    final usual = summary.usualCents;
    final change = summary.changePercent;
    final number = NumberFormat.decimalPattern(locale);

    final total = summary.monthToDateCents;
    final euros = '${total < 0 ? '-' : ''}${number.format(total.abs() ~/ 100)}';
    final cents = (total.abs() % 100).toString().padLeft(2, '0');

    final small = theme.textTheme.bodyMedium?.copyWith(
      color: _ink,
      height: 0.95,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: _frame,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _frameEdge),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: _screen,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: _frameEdge, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.dashboardMonthSpent(month).toUpperCase(),
                maxLines: 1,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // The change sits in the empty corner under "7 scontrini", just
            // above the usual amount, so it adds no height to the label.
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sized to its text, so "7 scontrini" stays on one
                    // line; the price shrinks to fit instead.
                    Text(
                      l10n.dashboardReceiptCount(summary.receiptCount),
                      style: small,
                      softWrap: false,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Semantics(
                          label: Money.format(total),
                          excludeSemantics: true,
                          child: _Price(
                            euros: euros,
                            cents: cents,
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ExcludeSemantics(
                      child: CustomPaint(
                        size: const Size.square(52),
                        painter: _QrPainter(_qr),
                      ),
                    ),
                  ],
                ),
                if (usual != null && change != null)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Icon(
                          change >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: _ink,
                        ),
                        Text(
                          '${number.format(change.abs().round())}%',
                          style: small,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              usual == null
                  ? l10n.dashboardNoUsual
                  : l10n.dashboardUsual(Money.format(usual)),
              style: small,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shelf-label price: big euros, then the cents raised and "€" below them.
class _Price extends StatelessWidget {
  const new({required this.euros, required this.cents, required this.style});

  final String euros;
  final String cents;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final big = style?.copyWith(fontSize: 96, height: 0.85);
    final side = style?.copyWith(fontSize: 38, height: 0.9);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(euros, style: big),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cents, style: side),
            const SizedBox(height: 10),
            Text('€', style: side?.copyWith(fontSize: 30)),
          ],
        ),
      ],
    );
  }
}

/// Draws [image]'s dark modules in the label's ink, filling the square.
class _QrPainter extends CustomPainter {
  const new(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final cell = size.width / count;
    final paint = Paint()
      ..color = MonthTotalCard._ink
      ..isAntiAlias = false;
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (!image.isDark(row, col)) continue;
        // A hair wider than the cell, so neighbours leave no seams.
        canvas.drawRect(
          Rect.fromLTWH(col * cell, row * cell, cell + 0.5, cell + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
