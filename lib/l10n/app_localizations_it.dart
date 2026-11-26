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
  String get receiptsEmpty =>
      'Nessuno scontrino salvato. Fotografane uno o inseriscilo a mano.';

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
  String get pantryAdd => 'Aggiungi scontrino a mano';

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
  String get unitPieces => 'pz';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitLitres => 'l';

  @override
  String get extractionStepPreparing => 'Preparo la foto…';

  @override
  String get extractionStepFindingLines => 'Cerco le righe…';

  @override
  String get extractionStepReadingLines => 'Leggo le righe…';

  @override
  String get extractionStepParsing => 'Ricostruisco lo scontrino…';

  @override
  String get confirmFailed => 'Impossibile salvare lo scontrino.';

  @override
  String get navInsights => 'Consigli';

  @override
  String get insightsEmpty => 'I consigli personalizzati appariranno qui.';

  @override
  String get settingsEmpty => 'Categorie, backup e sicurezza.';

  @override
  String get shaderLabTitle => 'Laboratorio carta';

  @override
  String get shaderLabHint => 'Regola l\'effetto scontrino stropicciato.';

  @override
  String get shaderLabInkUnsupported =>
      'Inchiostro col shader non disponibile qui (serve Impeller): il testo è disegnato sopra la carta.';

  @override
  String get shaderLabReceipt => 'Scontrino';

  @override
  String get shaderLabComponents => 'Componenti';

  @override
  String get shaderLabInkOff => 'Sopra';

  @override
  String get shaderLabInkThermal => 'Termica';

  @override
  String get shaderLabInkColour => 'Colori';

  @override
  String get shaderLabNewSeed => 'Nuove pieghe';

  @override
  String get shaderLabReset => 'Ripristina';

  @override
  String get shaderLabCopy => 'Copia valori';

  @override
  String get shaderLabCopied => 'Valori copiati negli appunti';

  @override
  String get shaderLabTiltLight => 'Luce dal giroscopio';

  @override
  String get shaderLabTiltLightHint =>
      'La luce viene dall\'alto: inclina il telefono.';

  @override
  String get shaderLabHideControls => 'Mostra/nascondi i controlli';

  @override
  String get plasticLabTitle => 'Laboratorio plastica';

  @override
  String get plasticLabHint =>
      'Regola la targhetta di plastica: bordo, lucido, inclinazione al tocco.';

  @override
  String get plasticLabUnsupported =>
      'Luce della plastica non disponibile qui (serve Impeller): la targhetta si inclina senza riflessi.';

  @override
  String get plasticLabTouchHint =>
      'Tocca e trascina la targhetta per inclinarla.';

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
  String get dashboardRestSlice => 'Altro e senza categoria';

  @override
  String get dashboardInsightsTitle => 'Consigli';

  @override
  String get dashboardInsightsEmpty =>
      'Nessun consiglio per ora. Qui appariranno i prezzi in aumento, le categorie in cui spendi più del solito e i prodotti che butti spesso.';

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

  @override
  String get captureManual => 'Inserisci a mano';

  @override
  String get manualReceiptTitle => 'Scontrino a mano';

  @override
  String get receiptsUnknownStore => 'Negozio sconosciuto';

  @override
  String get receiptsManual => 'A mano';

  @override
  String receiptsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli',
      one: '1 articolo',
    );
    return '$_temp0';
  }

  @override
  String get receiptDelete => 'Elimina scontrino';

  @override
  String get receiptDeleteConfirm =>
      'Eliminare lo scontrino? Spariscono anche i suoi prodotti in dispensa.';

  @override
  String get receiptDeleted => 'Scontrino eliminato';

  @override
  String get receiptNotFound => 'Scontrino non trovato.';

  @override
  String get pantryManage => 'Gestisci in dispensa';

  @override
  String get pantryStatistics => 'Visualizza statistiche';

  @override
  String get productStatsBought => 'Comprato';

  @override
  String productStatsTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volte',
      one: '1 volta',
    );
    return '$_temp0';
  }

  @override
  String get productStatsLastPurchase => 'Ultimo acquisto';

  @override
  String get productStatsEvery => 'Lo compri ogni';

  @override
  String productStatsDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni circa',
      one: 'giorno circa',
    );
    return '$_temp0';
  }

  @override
  String get productStatsTotal => 'Speso in tutto';

  @override
  String get productStatsPrices => 'Prezzi pagati';

  @override
  String get productStatsPricePerPiece => 'al pezzo';

  @override
  String get productStatsPricePerKg => 'al kg';

  @override
  String get productStatsPricePerLitre => 'al litro';

  @override
  String get productStatsOnePrice => 'Il grafico appare dal secondo acquisto.';

  @override
  String get productStatsMin => 'Minimo';

  @override
  String get productStatsUsual => 'Di solito';

  @override
  String get productStatsMax => 'Massimo';

  @override
  String productStatsChangeUp(String percent) {
    return 'Ultimo prezzo $percent sopra il solito';
  }

  @override
  String productStatsChangeDown(String percent) {
    return 'Ultimo prezzo $percent sotto il solito';
  }

  @override
  String get productStatsChangeSame => 'Ultimo prezzo in linea con il solito';

  @override
  String get productStatsPurchases => 'Acquisti';

  @override
  String get productStatsNoPurchases =>
      'Nessun acquisto registrato per questo prodotto.';

  @override
  String get productStatsPantry => 'In dispensa';

  @override
  String productStatsPantryNow(String quantity) {
    return 'Ne hai ancora $quantity';
  }

  @override
  String get productStatsPantryNone => 'Non ne hai in dispensa';

  @override
  String productStatsLotsEnded(int consumed, int discarded) {
    return 'Finiti: $consumed · Buttati: $discarded';
  }

  @override
  String get reviewTitle => 'Controlla lo scontrino';

  @override
  String get reviewAddItem => 'Aggiungi articolo';

  @override
  String get reviewEditItem => 'Modifica articolo';

  @override
  String get reviewFieldName => 'Nome sullo scontrino';

  @override
  String get reviewFieldQuantity => 'Quantità';

  @override
  String get reviewFieldUnitPrice => 'Prezzo unitario';

  @override
  String get reviewFieldAmount => 'Importo';

  @override
  String get reviewFieldDiscount => 'Sconto (facoltativo)';

  @override
  String get reviewFieldCategory => 'Categoria';

  @override
  String get reviewInvalidName => 'Inserisci un nome';

  @override
  String get reviewInvalidQuantity => 'Inserisci una quantità maggiore di zero';

  @override
  String get reviewInvalidAmount => 'Importo non valido';

  @override
  String get reviewDiscountTooLarge => 'Lo sconto supera l\'importo';

  @override
  String get reviewUncategorised => 'Senza categoria';

  @override
  String get reviewNoItems =>
      'Nessun articolo: aggiungine almeno uno per confermare.';

  @override
  String get reviewUnparsedHint => 'Se manca un articolo, aggiungilo a mano.';

  @override
  String reviewItemDeleted(String name) {
    return '$name eliminato';
  }

  @override
  String get reviewUndo => 'Annulla';

  @override
  String get reviewDiscardTitle => 'Scartare le modifiche?';

  @override
  String get reviewDiscardBody => 'Lo scontrino non è ancora stato salvato.';

  @override
  String get reviewDiscard => 'Scarta';

  @override
  String get reviewUseItemsTotal => 'Usa la somma';

  @override
  String get reviewSave => 'Salva scontrino';

  @override
  String reviewItemsPending(int count, int pending) {
    return 'Articoli ($count), $pending da controllare';
  }

  @override
  String get reviewConfirmItem => 'Corretto';

  @override
  String get reviewCorrectItem => 'Correggi';

  @override
  String get reviewUnconfirmItem => 'Da ricontrollare';

  @override
  String reviewSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scontrino salvato, $count prodotti in dispensa.',
      one: 'Scontrino salvato, 1 prodotto in dispensa.',
      zero: 'Scontrino salvato.',
    );
    return '$_temp0';
  }

  @override
  String reviewConfirmAll(int count) {
    return 'Conferma tutti ($count)';
  }

  @override
  String get reviewUnconfirmAll => 'Annulla tutto';

  @override
  String get analyticsTabSpending => 'Spesa';

  @override
  String get analyticsTabProducts => 'Prodotti';

  @override
  String get analyticsPeriodWeek => 'Settimana';

  @override
  String get analyticsPeriodMonth => 'Mese';

  @override
  String get analyticsPeriodQuarter => '3 mesi';

  @override
  String get analyticsPeriodYear => 'Anno';

  @override
  String get analyticsPickDates => 'Scegli le date';

  @override
  String get analyticsPreviousPeriod => 'Periodo precedente';

  @override
  String get analyticsNextPeriod => 'Periodo successivo';

  @override
  String get analyticsNoReceipts => 'Nessuno scontrino in questo periodo';

  @override
  String get analyticsSpent => 'Speso';

  @override
  String analyticsComparedWith(String period, String amount) {
    return '$period: $amount';
  }

  @override
  String analyticsNothingBefore(String period) {
    return 'Nessuna spesa nel periodo prima ($period)';
  }

  @override
  String analyticsChangeVs(String change, String period) {
    return '$change rispetto a $period';
  }

  @override
  String get analyticsOverTime => 'Andamento';

  @override
  String get analyticsOverTimeHint => 'Tocca una barra per vederne il totale';

  @override
  String get analyticsCategoriesTitle => 'Categorie';

  @override
  String get analyticsUncategorised => 'Senza categoria e altro';

  @override
  String get analyticsStoresTitle => 'Negozi';

  @override
  String get analyticsUnknownStore => 'Negozio sconosciuto';

  @override
  String analyticsStoreVisits(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visite',
      one: '1 visita',
    );
    return '$_temp0 · spesa media $amount';
  }

  @override
  String get analyticsSavingsTitle => 'Risparmiato con gli sconti';

  @override
  String analyticsSavingsRate(String percent) {
    return '$percent del prezzo pieno';
  }

  @override
  String get analyticsMostBoughtTitle => 'Più acquistati';

  @override
  String analyticsTimesBought(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volte',
      one: '1 volta',
    );
    return '$_temp0 · ultimo acquisto $date';
  }

  @override
  String analyticsShowAll(int count) {
    return 'Mostra tutti ($count)';
  }

  @override
  String get analyticsShowLess => 'Mostra meno';

  @override
  String get analyticsPriceChangesTitle => 'Variazioni di prezzo';

  @override
  String get analyticsPriceRises => 'In aumento';

  @override
  String get analyticsPriceDrops => 'In calo';

  @override
  String analyticsPriceVsUsual(String latest, String usual) {
    return '$latest contro $usual di solito';
  }

  @override
  String get analyticsPriceChangesHint =>
      'Prezzo pieno dell\'ultimo acquisto rispetto alla mediana dei 90 giorni prima (almeno 3 acquisti). Le offerte non contano.';

  @override
  String get analyticsNoPriceChanges =>
      'Nessuna variazione di prezzo di rilievo in questo periodo';

  @override
  String get analyticsTabPantry => 'Dispensa';

  @override
  String get analyticsPantryEmpty =>
      'La dispensa è vuota.\nSalva uno scontrino per vedere cosa usi e cosa butti.';

  @override
  String get analyticsFateTitle => 'Dove è finita la spesa';

  @override
  String analyticsFateSubtitle(String amount) {
    return '$amount spesi in questo periodo';
  }

  @override
  String get analyticsFateUsed => 'Usato';

  @override
  String get analyticsFateWasted => 'Buttato';

  @override
  String get analyticsFateInPantry => 'Ancora in dispensa';

  @override
  String get analyticsFateNotInPantry => 'Non in dispensa';

  @override
  String get analyticsFateNotInPantryHint =>
      'prodotti non seguiti, sconti sul totale e righe senza prodotto';

  @override
  String analyticsFateCoverage(int untouched, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      untouched,
      locale: localeName,
      other:
          '$untouched prodotti su $count non sono mai stati aggiornati: contano come ancora in dispensa.',
      one:
          '1 prodotto su $count non è mai stato aggiornato: conta come ancora in dispensa.',
      zero: 'Tutti i $count prodotti sono stati aggiornati in dispensa.',
    );
    return '$_temp0';
  }

  @override
  String get analyticsFateNoReceipts => 'Nessuno scontrino in questo periodo';

  @override
  String get analyticsWasteTitle => 'Sprechi';

  @override
  String get analyticsWasteSubtitle =>
      'Buttato in questo periodo, qualunque sia la data d\'acquisto';

  @override
  String analyticsWasteRate(String percent) {
    return '$percent di ciò che è uscito dalla dispensa';
  }

  @override
  String get analyticsWasteNone => 'Niente buttato in questo periodo';

  @override
  String analyticsWasteUnpriced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Più $count prodotti senza prezzo',
      one: 'Più 1 prodotto senza prezzo',
    );
    return '$_temp0';
  }

  @override
  String get analyticsWasteReasons => 'Perché';

  @override
  String get analyticsWasteReasonExpired => 'Scaduto';

  @override
  String get analyticsWasteReasonSpoiled => 'Andato a male';

  @override
  String get analyticsWasteReasonOther => 'Altro';

  @override
  String get analyticsWasteCategories => 'Per categoria';

  @override
  String get analyticsWasteProducts => 'Prodotti più buttati';

  @override
  String analyticsWasteLots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volte',
      one: '1 volta',
    );
    return '$_temp0';
  }

  @override
  String get analyticsNoCategory => 'Senza categoria';

  @override
  String get shoppingTitle => 'Prossima spesa';

  @override
  String get shoppingEmpty => 'Niente da ricomprare nei prossimi giorni';

  @override
  String get shoppingHint =>
      'In base a quanto usi in dispensa e a quanto spesso compri';

  @override
  String get shoppingFinished => 'Finito in dispensa';

  @override
  String shoppingRunningLow(String quantity, String when) {
    return 'Ne resta $quantity: finisce $when';
  }

  @override
  String shoppingUsual(int days, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: 'giorno',
    );
    return 'Di solito ogni $_temp0, l\'ultima volta il $date';
  }

  @override
  String shoppingEvery(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: 'giorno',
    );
    return 'di solito ogni $_temp0';
  }

  @override
  String get shoppingToday => 'oggi';

  @override
  String get shoppingTomorrow => 'domani';

  @override
  String shoppingInDays(int days) {
    return 'tra $days giorni';
  }

  @override
  String insightSpikeTitle(String category, String change) {
    return '$category: $change rispetto al solito';
  }

  @override
  String insightSpikeBody(String amount, String usual, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'media degli ultimi $months mesi',
      one: 'nell\'ultimo mese',
    );
    return '$amount finora questo mese; di solito $usual a questo punto ($_temp0)';
  }

  @override
  String insightWasteTitle(String product) {
    return 'Butti spesso: $product';
  }

  @override
  String insightWasteBody(int wasted, int total, int days, String amount) {
    return '$wasted volte su $total negli ultimi $days giorni, $amount buttati. Prova a prenderne meno.';
  }

  @override
  String insightPriceTitle(String product) {
    return 'Prezzo in aumento: $product';
  }

  @override
  String insightPriceBody(
    String latest,
    String usual,
    String store,
    String change,
    String amount,
  ) {
    String _temp0 = intl.Intl.selectLogic(store, {
      'none': '',
      'other': ' da $store',
    });
    return '$latest contro $usual di solito$_temp0 ($change). Circa $amount in più al mese per quanto ne compri.';
  }

  @override
  String get exportTitle => 'Esporta i dati raccolti';

  @override
  String exportSummary(int receipts, int items) {
    String _temp0 = intl.Intl.pluralLogic(
      receipts,
      locale: localeName,
      other: '$receipts scontrini',
      one: '1 scontrino',
    );
    String _temp1 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items articoli',
      one: '1 articolo',
    );
    return '$_temp0 · $_temp1, in un file CSV';
  }

  @override
  String get exportNothing => 'Nessuno scontrino da esportare';

  @override
  String get exportWarning =>
      'Tutti gli articoli degli scontrini confermati, uno per riga, in un file CSV che si apre con Excel, Fogli Google o un programma di analisi.\n\nIl file non è cifrato: chi lo apre vede i tuoi acquisti.';

  @override
  String get exportConfirm => 'Esporta';

  @override
  String exportDone(int count, String fileName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esportati $count articoli',
      one: 'Esportato 1 articolo',
    );
    return '$_temp0 in $fileName';
  }

  @override
  String get exportFailed => 'Esportazione non riuscita.';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get categoryFruitVegetables => 'Frutta e verdura';

  @override
  String get categoryMeatFish => 'Carne e pesce';

  @override
  String get categoryDairyEggs => 'Latticini e uova';

  @override
  String get categoryBreadPasta => 'Pane e pasta';

  @override
  String get categoryDrinks => 'Bevande';

  @override
  String get categoryPantry => 'Dispensa';

  @override
  String get categoryFrozen => 'Surgelati';

  @override
  String get categoryHousehold => 'Casa e igiene';

  @override
  String get categoryOther => 'Altro';

  @override
  String get importTitle => 'Importa dati da CSV';

  @override
  String get importHint =>
      'Un file esportato da questa app: scontrini e dispensa. Gli scontrini già presenti vengono saltati.';

  @override
  String importDone(int receipts, int lots, int duplicates) {
    String _temp0 = intl.Intl.pluralLogic(
      receipts,
      locale: localeName,
      other: 'Importati $receipts scontrini',
      one: 'Importato 1 scontrino',
    );
    return '$_temp0, $lots in dispensa, $duplicates già presenti';
  }

  @override
  String get importFailed =>
      'File non valido: scegli un CSV esportato da questa app';
}
