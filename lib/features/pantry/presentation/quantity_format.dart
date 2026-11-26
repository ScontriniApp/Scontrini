import 'package:intl/intl.dart';
import 'package:scontrini/l10n/app_localizations.dart';

/// `1.5, 'kg'` → `1,5 kg` (`1.5 kg` in English); `2, 'pz'` → `2 pz`.
String formatQuantity(AppLocalizations l10n, double value, String unit) =>
    '${NumberFormat('#,##0.###', l10n.localeName).format(value)} '
    '${unitLabel(l10n, unit)}';

String unitLabel(AppLocalizations l10n, String unit) => switch (unit) {
  'kg' => l10n.unitKilograms,
  'l' => l10n.unitLitres,
  _ => l10n.unitPieces,
};
