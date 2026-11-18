// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Scontrini';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'Storico';

  @override
  String get navAnalytics => 'Analisi';

  @override
  String get navInsights => 'Consigli';

  @override
  String get addReceipt => 'Aggiungi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get captureTitle => 'Nuovo scontrino';

  @override
  String get captureScan => 'Scansiona con la fotocamera';

  @override
  String get captureGallery => 'Scegli dalla galleria';

  @override
  String get capturePdf => 'Importa PDF';

  @override
  String get comingSoon => 'Funzionalità in arrivo';

  @override
  String get dashboardEmpty =>
      'Nessuno scontrino ancora.\nAggiungi il primo per vedere le tue spese.';

  @override
  String get receiptsEmpty => 'Lo storico degli acquisti apparirà qui.';

  @override
  String get analyticsEmpty => 'Grafici e statistiche appariranno qui.';

  @override
  String get insightsEmpty => 'I consigli personalizzati appariranno qui.';

  @override
  String get settingsEmpty => 'Categorie, backup e sicurezza.';
}
