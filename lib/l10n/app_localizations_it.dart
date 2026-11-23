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

  @override
  String get demoDataTitle => 'Dati demo (solo debug)';

  @override
  String get demoDataLoad => 'Carica dati demo';

  @override
  String get demoDataLoadHint =>
      '6 mesi di acquisti inventati. Si sommano agli scontrini veri finché non li rimuovi.';

  @override
  String get demoDataRemove => 'Rimuovi dati demo';

  @override
  String demoDataLoaded(int count) {
    return 'Caricati $count scontrini demo';
  }

  @override
  String get demoDataRemoved => 'Dati demo rimossi';

  @override
  String dashboardMonthSpent(String month) {
    return 'Speso a $month';
  }

  @override
  String dashboardReceiptCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scontrini',
      one: '1 scontrino',
      zero: 'Nessuno scontrino',
    );
    return '$_temp0';
  }

  @override
  String dashboardUsual(String amount) {
    return 'Di solito $amount a questo punto del mese';
  }

  @override
  String get dashboardNoUsual =>
      'Il confronto con i mesi scorsi apparirà dal mese prossimo';

  @override
  String get dashboardCategoriesTitle => 'Categorie del mese';

  @override
  String get dashboardCategoriesEmpty => 'Nessuna spesa questo mese';

  @override
  String get dashboardOtherCategories => 'Altre categorie';

  @override
  String get dashboardInsightsTitle => 'Consigli';

  @override
  String get dashboardInsightsEmpty =>
      'Qui appariranno 2–3 consigli sui tuoi acquisti: prezzi in aumento, occasioni di risparmio, categorie in crescita.';

  @override
  String get dashboardCategoryHint =>
      'Tocca una categoria per vederne gli articoli';

  @override
  String dashboardItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli',
      one: '1 articolo',
      zero: 'Nessun articolo',
    );
    return '$_temp0';
  }

  @override
  String dashboardUnassigned(String amount) {
    return '$amount non legati a un articolo (sconti sul totale, righe non lette)';
  }

  @override
  String dashboardFullPrice(String amount) {
    return 'prezzo pieno $amount';
  }
}
