import 'package:intl/intl.dart';
import 'package:scontrini/l10n/app_localizations.dart';

final _number = NumberFormat('#,##0.###', 'it');

/// `1.5, 'kg'` → `1,5 kg`; `2, 'pz'` → `2 pz`.
String formatQuantity(AppLocalizations l10n, double value, String unit) =>
    '${_number.format(value)} ${unitLabel(l10n, unit)}';

String unitLabel(AppLocalizations l10n, String unit) => switch (unit) {
  'kg' => l10n.unitKilograms,
  'l' => l10n.unitLitres,
  _ => l10n.unitPieces,
};
