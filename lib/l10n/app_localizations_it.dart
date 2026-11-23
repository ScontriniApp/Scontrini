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
  String get captureFailed => 'Impossibile acquisire lo scontrino.';

  @override
  String get extractionTitle => 'Scontrino letto';

  @override
  String get extractionLoading => 'Lettura dello scontrino…';

  @override
  String get extractionFailed => 'Impossibile leggere lo scontrino.';

  @override
  String get retry => 'Riprova';

  @override
  String get extractionPreviewNotice =>
      'Controlla i dati: confermando, lo scontrino viene salvato e puoi smistarlo in dispensa.';

  @override
  String get fieldStore => 'Negozio';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldTotal => 'Totale';

  @override
  String get fieldItemsTotal => 'Somma articoli';

  @override
  String extractionItems(int count) {
    return 'Articoli ($count)';
  }

  @override
  String extractionDiscount(String amount) {
    return 'Sconto $amount';
  }

  @override
  String get extractionReceiptDiscount => 'Sconti sul totale';

  @override
  String get extractionUnparsed => 'Righe non riconosciute';

  @override
  String get extractionRawText => 'Testo riconosciuto';

  @override
  String get warningMissingStore => 'Negozio non trovato';

  @override
  String get warningMissingDate => 'Data non trovata';

  @override
  String get warningMissingTotal => 'Totale non trovato';

  @override
  String get warningTotalMismatch =>
      'La somma degli articoli non corrisponde al totale';

  @override
  String get warningLineTotalMismatch =>
      'Quantità × prezzo diverso dall\'importo della riga';

  @override
  String get exportFixture => 'Esporta come test';

  @override
  String exportFixtureDone(String name) {
    return 'Salvato: $name';
  }

  @override
  String get navPantry => 'Dispensa';

  @override
  String get pantryEmpty =>
      'La dispensa è vuota.\nAggiungi prodotti da uno scontrino o a mano.';

  @override
  String get pantryShowClosed => 'Mostra finiti e buttati';

  @override
  String get pantryHideClosed => 'Nascondi finiti e buttati';

  @override
  String get pantryAdd => 'Aggiungi prodotto';

  @override
  String get pantryUncategorised => 'Senza categoria';

  @override
  String pantryRemaining(String remaining, String initial) {
    return '$remaining di $initial';
  }

  @override
  String get pantrySourceManualPurchase => 'Comprato, senza scontrino';

  @override
  String get pantrySourceInitialStock => 'Già in casa';

  @override
  String get pantrySourceGift => 'Regalo';

  @override
  String get pantryStatusConsumed => 'Finito';

  @override
  String get pantryStatusDiscarded => 'Buttato';

  @override
  String get pantryConsumeAll => 'Segna come finito';

  @override
  String get pantryDiscard => 'Butta via';

  @override
  String get pantryReasonExpired => 'Scaduto';

  @override
  String get pantryReasonSpoiled => 'Andato a male';

  @override
  String get pantryReasonOther => 'Altro motivo';

  @override
  String get pantryUndo => 'Annulla';

  @override
  String get pantryUndoLast => 'Annulla l\'ultima azione';

  @override
  String get pantryNothingToUndo => 'Niente da annullare';

  @override
  String get pantryDelete => 'Elimina dalla dispensa';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Eliminare $name? Il suo storico di consumo andrà perso.';
  }

  @override
  String pantryConsumedMessage(String name, String amount) {
    return '$name: usato $amount';
  }

  @override
  String pantryDiscardedMessage(String name) {
    return '$name buttato';
  }

  @override
  String pantryFinishedMessage(String name) {
    return '$name finito';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get pantryFieldName => 'Nome';

  @override
  String get pantryFieldQuantity => 'Quantità';

  @override
  String get pantryFieldPrice => 'Prezzo pagato (facoltativo)';

  @override
  String get pantryFieldCategory => 'Categoria';

  @override
  String get pantryFieldSource => 'Provenienza';

  @override
  String get pantryInvalidName => 'Inserisci un nome';

  @override
  String get pantryInvalidQuantity => 'Inserisci una quantità maggiore di zero';

  @override
  String get pantryInvalidPrice => 'Prezzo non valido';

  @override
  String get unitPieces => 'pz';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitLitres => 'l';

  @override
  String get settingsPhotoReading => 'Lettura delle foto';

  @override
  String get glmOcrModelTitle => 'Modello di lettura avanzato';

  @override
  String get glmOcrModelChecking => 'Verifica…';

  @override
  String glmOcrModelMissing(String size) {
    return 'Non installato: le foto si leggono con il riconoscimento standard. GLM-OCR è più preciso ma sui telefoni meno potenti può richiedere minuti per scontrino. Download di $size.';
  }

  @override
  String glmOcrModelPartial(String done, String total) {
    return 'Download interrotto: $done di $total.';
  }

  @override
  String glmOcrModelDownloading(String done, String total) {
    return 'Download: $done di $total';
  }

  @override
  String glmOcrModelInstalled(String size) {
    return 'Installato ($size): le foto si leggono sul telefono con GLM-OCR.';
  }

  @override
  String get glmOcrDownload => 'Scarica';

  @override
  String get glmOcrResume => 'Riprendi';

  @override
  String get glmOcrDownloadConfirmTitle => 'Scaricare il modello?';

  @override
  String glmOcrDownloadConfirmBody(String size) {
    return 'Il modello GLM-OCR ($size) si scarica da Hugging Face: meglio con il Wi-Fi. Gli scontrini non lasciano il telefono, il modello li legge senza connessione.';
  }

  @override
  String get glmOcrDeleteConfirmTitle => 'Eliminare il modello?';

  @override
  String glmOcrDeleteConfirmBody(String size) {
    return 'Libera $size. Le foto torneranno a essere lette con il riconoscimento standard.';
  }

  @override
  String get glmOcrErrorNetwork =>
      'Download non riuscito: controlla la connessione.';

  @override
  String get glmOcrErrorCorrupt => 'Il file scaricato è danneggiato: riprova.';

  @override
  String get glmOcrErrorStorage => 'Spazio insufficiente sul telefono.';

  @override
  String get extractionStepPreparing => 'Preparo la foto…';

  @override
  String get extractionStepFindingLines => 'Cerco le righe…';

  @override
  String get extractionStepReadingLines => 'Leggo le righe…';

  @override
  String get extractionStepParsing => 'Ricostruisco lo scontrino…';

  @override
  String get triageTitle => 'Smista in dispensa';

  @override
  String triageCounter(int current, int total) {
    return '$current di $total';
  }

  @override
  String get triageKeep => 'In dispensa';

  @override
  String get triageSkip => 'Salta';

  @override
  String get triageDone => 'Fatto';

  @override
  String get triageFailed => 'Impossibile caricare i prodotti.';

  @override
  String triageSummary(int kept, int skipped) {
    return '$kept in dispensa, $skipped saltati.';
  }

  @override
  String get confirmAndSort => 'Conferma e smista in dispensa';

  @override
  String get confirmFailed => 'Impossibile salvare lo scontrino.';

  @override
  String get navInsights => 'Consigli';

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

  @override
  String get pantrySearchHint => 'Cerca in dispensa';

  @override
  String get pantrySearchClear => 'Cancella ricerca';

  @override
  String get pantryNoResults => 'Nessun prodotto trovato.';
}
