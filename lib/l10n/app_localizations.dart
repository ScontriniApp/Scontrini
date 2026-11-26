import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Scontrini'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReceipts.
  ///
  /// In it, this message translates to:
  /// **'Storico'**
  String get navReceipts;

  /// No description provided for @navAnalytics.
  ///
  /// In it, this message translates to:
  /// **'Analisi'**
  String get navAnalytics;

  /// No description provided for @addReceipt.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get addReceipt;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @captureTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo scontrino'**
  String get captureTitle;

  /// No description provided for @captureScan.
  ///
  /// In it, this message translates to:
  /// **'Scansiona con la fotocamera'**
  String get captureScan;

  /// No description provided for @captureGallery.
  ///
  /// In it, this message translates to:
  /// **'Scegli dalla galleria'**
  String get captureGallery;

  /// No description provided for @capturePdf.
  ///
  /// In it, this message translates to:
  /// **'Importa PDF'**
  String get capturePdf;

  /// No description provided for @comingSoon.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità in arrivo'**
  String get comingSoon;

  /// No description provided for @dashboardEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scontrino ancora.\nAggiungi il primo per vedere le tue spese.'**
  String get dashboardEmpty;

  /// No description provided for @receiptsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scontrino salvato. Fotografane uno o inseriscilo a mano.'**
  String get receiptsEmpty;

  /// No description provided for @captureFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile acquisire lo scontrino.'**
  String get captureFailed;

  /// No description provided for @extractionTitle.
  ///
  /// In it, this message translates to:
  /// **'Scontrino letto'**
  String get extractionTitle;

  /// No description provided for @extractionLoading.
  ///
  /// In it, this message translates to:
  /// **'Lettura dello scontrino…'**
  String get extractionLoading;

  /// No description provided for @extractionFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile leggere lo scontrino.'**
  String get extractionFailed;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @fieldStore.
  ///
  /// In it, this message translates to:
  /// **'Negozio'**
  String get fieldStore;

  /// No description provided for @fieldDate.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get fieldDate;

  /// No description provided for @fieldTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get fieldTotal;

  /// No description provided for @fieldItemsTotal.
  ///
  /// In it, this message translates to:
  /// **'Somma articoli'**
  String get fieldItemsTotal;

  /// No description provided for @extractionItems.
  ///
  /// In it, this message translates to:
  /// **'Articoli ({count})'**
  String extractionItems(int count);

  /// No description provided for @extractionDiscount.
  ///
  /// In it, this message translates to:
  /// **'Sconto {amount}'**
  String extractionDiscount(String amount);

  /// No description provided for @extractionReceiptDiscount.
  ///
  /// In it, this message translates to:
  /// **'Sconti sul totale'**
  String get extractionReceiptDiscount;

  /// No description provided for @extractionUnparsed.
  ///
  /// In it, this message translates to:
  /// **'Righe non riconosciute'**
  String get extractionUnparsed;

  /// No description provided for @extractionRawText.
  ///
  /// In it, this message translates to:
  /// **'Testo riconosciuto'**
  String get extractionRawText;

  /// No description provided for @warningMissingStore.
  ///
  /// In it, this message translates to:
  /// **'Negozio non trovato'**
  String get warningMissingStore;

  /// No description provided for @warningMissingDate.
  ///
  /// In it, this message translates to:
  /// **'Data non trovata'**
  String get warningMissingDate;

  /// No description provided for @warningMissingTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale non trovato'**
  String get warningMissingTotal;

  /// No description provided for @warningTotalMismatch.
  ///
  /// In it, this message translates to:
  /// **'La somma degli articoli non corrisponde al totale'**
  String get warningTotalMismatch;

  /// No description provided for @warningLineTotalMismatch.
  ///
  /// In it, this message translates to:
  /// **'Quantità × prezzo diverso dall\'importo della riga'**
  String get warningLineTotalMismatch;

  /// No description provided for @exportFixture.
  ///
  /// In it, this message translates to:
  /// **'Esporta come test'**
  String get exportFixture;

  /// No description provided for @exportFixtureDone.
  ///
  /// In it, this message translates to:
  /// **'Salvato: {name}'**
  String exportFixtureDone(String name);

  /// No description provided for @navPantry.
  ///
  /// In it, this message translates to:
  /// **'Dispensa'**
  String get navPantry;

  /// No description provided for @pantryEmpty.
  ///
  /// In it, this message translates to:
  /// **'La dispensa è vuota.\nAggiungi prodotti da uno scontrino o a mano.'**
  String get pantryEmpty;

  /// No description provided for @pantryShowClosed.
  ///
  /// In it, this message translates to:
  /// **'Mostra finiti e buttati'**
  String get pantryShowClosed;

  /// No description provided for @pantryHideClosed.
  ///
  /// In it, this message translates to:
  /// **'Nascondi finiti e buttati'**
  String get pantryHideClosed;

  /// No description provided for @pantryAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi scontrino a mano'**
  String get pantryAdd;

  /// No description provided for @pantryUncategorised.
  ///
  /// In it, this message translates to:
  /// **'Senza categoria'**
  String get pantryUncategorised;

  /// No description provided for @pantryRemaining.
  ///
  /// In it, this message translates to:
  /// **'{remaining} di {initial}'**
  String pantryRemaining(String remaining, String initial);

  /// No description provided for @pantrySourceManualPurchase.
  ///
  /// In it, this message translates to:
  /// **'Comprato, senza scontrino'**
  String get pantrySourceManualPurchase;

  /// No description provided for @pantrySourceInitialStock.
  ///
  /// In it, this message translates to:
  /// **'Già in casa'**
  String get pantrySourceInitialStock;

  /// No description provided for @pantrySourceGift.
  ///
  /// In it, this message translates to:
  /// **'Regalo'**
  String get pantrySourceGift;

  /// No description provided for @pantryStatusConsumed.
  ///
  /// In it, this message translates to:
  /// **'Finito'**
  String get pantryStatusConsumed;

  /// No description provided for @pantryStatusDiscarded.
  ///
  /// In it, this message translates to:
  /// **'Buttato'**
  String get pantryStatusDiscarded;

  /// No description provided for @pantryConsumeAll.
  ///
  /// In it, this message translates to:
  /// **'Segna come finito'**
  String get pantryConsumeAll;

  /// No description provided for @pantryDiscard.
  ///
  /// In it, this message translates to:
  /// **'Butta via'**
  String get pantryDiscard;

  /// No description provided for @pantryReasonExpired.
  ///
  /// In it, this message translates to:
  /// **'Scaduto'**
  String get pantryReasonExpired;

  /// No description provided for @pantryReasonSpoiled.
  ///
  /// In it, this message translates to:
  /// **'Andato a male'**
  String get pantryReasonSpoiled;

  /// No description provided for @pantryReasonOther.
  ///
  /// In it, this message translates to:
  /// **'Altro motivo'**
  String get pantryReasonOther;

  /// No description provided for @pantryUndo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get pantryUndo;

  /// No description provided for @pantryUndoLast.
  ///
  /// In it, this message translates to:
  /// **'Annulla l\'ultima azione'**
  String get pantryUndoLast;

  /// No description provided for @pantryNothingToUndo.
  ///
  /// In it, this message translates to:
  /// **'Niente da annullare'**
  String get pantryNothingToUndo;

  /// No description provided for @pantryDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina dalla dispensa'**
  String get pantryDelete;

  /// No description provided for @pantryDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare {name}? Il suo storico di consumo andrà perso.'**
  String pantryDeleteConfirm(String name);

  /// No description provided for @pantryConsumedMessage.
  ///
  /// In it, this message translates to:
  /// **'{name}: usato {amount}'**
  String pantryConsumedMessage(String name, String amount);

  /// No description provided for @pantryDiscardedMessage.
  ///
  /// In it, this message translates to:
  /// **'{name} buttato'**
  String pantryDiscardedMessage(String name);

  /// No description provided for @pantryFinishedMessage.
  ///
  /// In it, this message translates to:
  /// **'{name} finito'**
  String pantryFinishedMessage(String name);

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @unitPieces.
  ///
  /// In it, this message translates to:
  /// **'pz'**
  String get unitPieces;

  /// No description provided for @unitKilograms.
  ///
  /// In it, this message translates to:
  /// **'kg'**
  String get unitKilograms;

  /// No description provided for @unitLitres.
  ///
  /// In it, this message translates to:
  /// **'l'**
  String get unitLitres;

  /// No description provided for @extractionStepPreparing.
  ///
  /// In it, this message translates to:
  /// **'Preparo la foto…'**
  String get extractionStepPreparing;

  /// No description provided for @extractionStepFindingLines.
  ///
  /// In it, this message translates to:
  /// **'Cerco le righe…'**
  String get extractionStepFindingLines;

  /// No description provided for @extractionStepReadingLines.
  ///
  /// In it, this message translates to:
  /// **'Leggo le righe…'**
  String get extractionStepReadingLines;

  /// No description provided for @extractionStepParsing.
  ///
  /// In it, this message translates to:
  /// **'Ricostruisco lo scontrino…'**
  String get extractionStepParsing;

  /// No description provided for @confirmFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare lo scontrino.'**
  String get confirmFailed;

  /// No description provided for @navInsights.
  ///
  /// In it, this message translates to:
  /// **'Consigli'**
  String get navInsights;

  /// No description provided for @insightsEmpty.
  ///
  /// In it, this message translates to:
  /// **'I consigli personalizzati appariranno qui.'**
  String get insightsEmpty;

  /// No description provided for @settingsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Categorie, backup e sicurezza.'**
  String get settingsEmpty;

  /// No description provided for @shaderLabTitle.
  ///
  /// In it, this message translates to:
  /// **'Laboratorio carta'**
  String get shaderLabTitle;

  /// No description provided for @shaderLabHint.
  ///
  /// In it, this message translates to:
  /// **'Regola l\'effetto scontrino stropicciato.'**
  String get shaderLabHint;

  /// No description provided for @shaderLabInkUnsupported.
  ///
  /// In it, this message translates to:
  /// **'Inchiostro col shader non disponibile qui (serve Impeller): il testo è disegnato sopra la carta.'**
  String get shaderLabInkUnsupported;

  /// No description provided for @shaderLabInk.
  ///
  /// In it, this message translates to:
  /// **'Inchiostro col shader'**
  String get shaderLabInk;

  /// No description provided for @shaderLabNewSeed.
  ///
  /// In it, this message translates to:
  /// **'Nuove pieghe'**
  String get shaderLabNewSeed;

  /// No description provided for @shaderLabReset.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get shaderLabReset;

  /// No description provided for @shaderLabCopy.
  ///
  /// In it, this message translates to:
  /// **'Copia valori'**
  String get shaderLabCopy;

  /// No description provided for @shaderLabCopied.
  ///
  /// In it, this message translates to:
  /// **'Valori copiati negli appunti'**
  String get shaderLabCopied;

  /// No description provided for @shaderLabHideControls.
  ///
  /// In it, this message translates to:
  /// **'Mostra/nascondi i controlli'**
  String get shaderLabHideControls;

  /// No description provided for @demoDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Dati demo (solo debug)'**
  String get demoDataTitle;

  /// No description provided for @demoDataLoad.
  ///
  /// In it, this message translates to:
  /// **'Carica dati demo'**
  String get demoDataLoad;

  /// No description provided for @demoDataLoadHint.
  ///
  /// In it, this message translates to:
  /// **'6 mesi di acquisti inventati. Si sommano agli scontrini veri finché non li rimuovi.'**
  String get demoDataLoadHint;

  /// No description provided for @demoDataRemove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dati demo'**
  String get demoDataRemove;

  /// No description provided for @demoDataLoaded.
  ///
  /// In it, this message translates to:
  /// **'Caricati {count} scontrini demo'**
  String demoDataLoaded(int count);

  /// No description provided for @demoDataRemoved.
  ///
  /// In it, this message translates to:
  /// **'Dati demo rimossi'**
  String get demoDataRemoved;

  /// No description provided for @dashboardMonthSpent.
  ///
  /// In it, this message translates to:
  /// **'Speso a {month}'**
  String dashboardMonthSpent(String month);

  /// No description provided for @dashboardReceiptCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuno scontrino} =1{1 scontrino} other{{count} scontrini}}'**
  String dashboardReceiptCount(int count);

  /// No description provided for @dashboardUsual.
  ///
  /// In it, this message translates to:
  /// **'Di solito {amount} a questo punto del mese'**
  String dashboardUsual(String amount);

  /// No description provided for @dashboardNoUsual.
  ///
  /// In it, this message translates to:
  /// **'Il confronto con i mesi scorsi apparirà dal mese prossimo'**
  String get dashboardNoUsual;

  /// No description provided for @dashboardCategoriesTitle.
  ///
  /// In it, this message translates to:
  /// **'Categorie del mese'**
  String get dashboardCategoriesTitle;

  /// No description provided for @dashboardCategoriesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa questo mese'**
  String get dashboardCategoriesEmpty;

  /// No description provided for @dashboardRestSlice.
  ///
  /// In it, this message translates to:
  /// **'Altro e senza categoria'**
  String get dashboardRestSlice;

  /// No description provided for @dashboardInsightsTitle.
  ///
  /// In it, this message translates to:
  /// **'Consigli'**
  String get dashboardInsightsTitle;

  /// No description provided for @dashboardInsightsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun consiglio per ora. Qui appariranno i prezzi in aumento, le categorie in cui spendi più del solito e i prodotti che butti spesso.'**
  String get dashboardInsightsEmpty;

  /// No description provided for @dashboardCategoryHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca una categoria per vederne gli articoli'**
  String get dashboardCategoryHint;

  /// No description provided for @dashboardItemCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessun articolo} =1{1 articolo} other{{count} articoli}}'**
  String dashboardItemCount(int count);

  /// No description provided for @dashboardUnassigned.
  ///
  /// In it, this message translates to:
  /// **'{amount} non legati a un articolo (sconti sul totale, righe non lette)'**
  String dashboardUnassigned(String amount);

  /// No description provided for @dashboardFullPrice.
  ///
  /// In it, this message translates to:
  /// **'prezzo pieno {amount}'**
  String dashboardFullPrice(String amount);

  /// No description provided for @pantrySearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca in dispensa'**
  String get pantrySearchHint;

  /// No description provided for @pantrySearchClear.
  ///
  /// In it, this message translates to:
  /// **'Cancella ricerca'**
  String get pantrySearchClear;

  /// No description provided for @pantryNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun prodotto trovato.'**
  String get pantryNoResults;

  /// No description provided for @captureManual.
  ///
  /// In it, this message translates to:
  /// **'Inserisci a mano'**
  String get captureManual;

  /// No description provided for @manualReceiptTitle.
  ///
  /// In it, this message translates to:
  /// **'Scontrino a mano'**
  String get manualReceiptTitle;

  /// No description provided for @manualReceiptNotice.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi i prodotti che hai comprato. Salvando, lo scontrino entra nello storico e i prodotti in dispensa.'**
  String get manualReceiptNotice;

  /// No description provided for @receiptsUnknownStore.
  ///
  /// In it, this message translates to:
  /// **'Negozio sconosciuto'**
  String get receiptsUnknownStore;

  /// No description provided for @receiptsManual.
  ///
  /// In it, this message translates to:
  /// **'A mano'**
  String get receiptsManual;

  /// No description provided for @receiptsItemCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 articolo} other{{count} articoli}}'**
  String receiptsItemCount(int count);

  /// No description provided for @receiptDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina scontrino'**
  String get receiptDelete;

  /// No description provided for @receiptDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare lo scontrino? Spariscono anche i suoi prodotti in dispensa.'**
  String get receiptDeleteConfirm;

  /// No description provided for @receiptDeleted.
  ///
  /// In it, this message translates to:
  /// **'Scontrino eliminato'**
  String get receiptDeleted;

  /// No description provided for @receiptNotFound.
  ///
  /// In it, this message translates to:
  /// **'Scontrino non trovato.'**
  String get receiptNotFound;

  /// No description provided for @pantryManage.
  ///
  /// In it, this message translates to:
  /// **'Gestisci in dispensa'**
  String get pantryManage;

  /// No description provided for @pantryStatistics.
  ///
  /// In it, this message translates to:
  /// **'Visualizza statistiche'**
  String get pantryStatistics;

  /// No description provided for @productStatsBought.
  ///
  /// In it, this message translates to:
  /// **'Comprato'**
  String get productStatsBought;

  /// No description provided for @productStatsTimes.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 volta} other{{count} volte}}'**
  String productStatsTimes(int count);

  /// No description provided for @productStatsLastPurchase.
  ///
  /// In it, this message translates to:
  /// **'Ultimo acquisto'**
  String get productStatsLastPurchase;

  /// No description provided for @productStatsEvery.
  ///
  /// In it, this message translates to:
  /// **'Lo compri ogni'**
  String get productStatsEvery;

  /// No description provided for @productStatsDays.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{giorno circa} other{{days} giorni circa}}'**
  String productStatsDays(int days);

  /// No description provided for @productStatsTotal.
  ///
  /// In it, this message translates to:
  /// **'Speso in tutto'**
  String get productStatsTotal;

  /// No description provided for @productStatsPrices.
  ///
  /// In it, this message translates to:
  /// **'Prezzi pagati'**
  String get productStatsPrices;

  /// No description provided for @productStatsPricePerPiece.
  ///
  /// In it, this message translates to:
  /// **'al pezzo'**
  String get productStatsPricePerPiece;

  /// No description provided for @productStatsPricePerKg.
  ///
  /// In it, this message translates to:
  /// **'al kg'**
  String get productStatsPricePerKg;

  /// No description provided for @productStatsPricePerLitre.
  ///
  /// In it, this message translates to:
  /// **'al litro'**
  String get productStatsPricePerLitre;

  /// No description provided for @productStatsOnePrice.
  ///
  /// In it, this message translates to:
  /// **'Il grafico appare dal secondo acquisto.'**
  String get productStatsOnePrice;

  /// No description provided for @productStatsMin.
  ///
  /// In it, this message translates to:
  /// **'Minimo'**
  String get productStatsMin;

  /// No description provided for @productStatsUsual.
  ///
  /// In it, this message translates to:
  /// **'Di solito'**
  String get productStatsUsual;

  /// No description provided for @productStatsMax.
  ///
  /// In it, this message translates to:
  /// **'Massimo'**
  String get productStatsMax;

  /// No description provided for @productStatsChangeUp.
  ///
  /// In it, this message translates to:
  /// **'Ultimo prezzo {percent} sopra il solito'**
  String productStatsChangeUp(String percent);

  /// No description provided for @productStatsChangeDown.
  ///
  /// In it, this message translates to:
  /// **'Ultimo prezzo {percent} sotto il solito'**
  String productStatsChangeDown(String percent);

  /// No description provided for @productStatsChangeSame.
  ///
  /// In it, this message translates to:
  /// **'Ultimo prezzo in linea con il solito'**
  String get productStatsChangeSame;

  /// No description provided for @productStatsPurchases.
  ///
  /// In it, this message translates to:
  /// **'Acquisti'**
  String get productStatsPurchases;

  /// No description provided for @productStatsNoPurchases.
  ///
  /// In it, this message translates to:
  /// **'Nessun acquisto registrato per questo prodotto.'**
  String get productStatsNoPurchases;

  /// No description provided for @productStatsPantry.
  ///
  /// In it, this message translates to:
  /// **'In dispensa'**
  String get productStatsPantry;

  /// No description provided for @productStatsPantryNow.
  ///
  /// In it, this message translates to:
  /// **'Ne hai ancora {quantity}'**
  String productStatsPantryNow(String quantity);

  /// No description provided for @productStatsPantryNone.
  ///
  /// In it, this message translates to:
  /// **'Non ne hai in dispensa'**
  String get productStatsPantryNone;

  /// No description provided for @productStatsLotsEnded.
  ///
  /// In it, this message translates to:
  /// **'Finiti: {consumed} · Buttati: {discarded}'**
  String productStatsLotsEnded(int consumed, int discarded);

  /// No description provided for @reviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla lo scontrino'**
  String get reviewTitle;

  /// No description provided for @reviewNotice.
  ///
  /// In it, this message translates to:
  /// **'Controlla ogni prodotto: confermalo se è stato letto bene, altrimenti correggilo. Salvando, lo scontrino entra nella dashboard e i prodotti in dispensa.'**
  String get reviewNotice;

  /// No description provided for @reviewAddItem.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi articolo'**
  String get reviewAddItem;

  /// No description provided for @reviewEditItem.
  ///
  /// In it, this message translates to:
  /// **'Modifica articolo'**
  String get reviewEditItem;

  /// No description provided for @reviewFieldName.
  ///
  /// In it, this message translates to:
  /// **'Nome sullo scontrino'**
  String get reviewFieldName;

  /// No description provided for @reviewFieldQuantity.
  ///
  /// In it, this message translates to:
  /// **'Quantità'**
  String get reviewFieldQuantity;

  /// No description provided for @reviewFieldUnitPrice.
  ///
  /// In it, this message translates to:
  /// **'Prezzo unitario'**
  String get reviewFieldUnitPrice;

  /// No description provided for @reviewFieldAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get reviewFieldAmount;

  /// No description provided for @reviewFieldDiscount.
  ///
  /// In it, this message translates to:
  /// **'Sconto (facoltativo)'**
  String get reviewFieldDiscount;

  /// No description provided for @reviewFieldCategory.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get reviewFieldCategory;

  /// No description provided for @reviewInvalidName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un nome'**
  String get reviewInvalidName;

  /// No description provided for @reviewInvalidQuantity.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una quantità maggiore di zero'**
  String get reviewInvalidQuantity;

  /// No description provided for @reviewInvalidAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo non valido'**
  String get reviewInvalidAmount;

  /// No description provided for @reviewDiscountTooLarge.
  ///
  /// In it, this message translates to:
  /// **'Lo sconto supera l\'importo'**
  String get reviewDiscountTooLarge;

  /// No description provided for @reviewUncategorised.
  ///
  /// In it, this message translates to:
  /// **'Senza categoria'**
  String get reviewUncategorised;

  /// No description provided for @reviewNoItems.
  ///
  /// In it, this message translates to:
  /// **'Nessun articolo: aggiungine almeno uno per confermare.'**
  String get reviewNoItems;

  /// No description provided for @reviewUnparsedHint.
  ///
  /// In it, this message translates to:
  /// **'Se manca un articolo, aggiungilo a mano.'**
  String get reviewUnparsedHint;

  /// No description provided for @reviewItemDeleted.
  ///
  /// In it, this message translates to:
  /// **'{name} eliminato'**
  String reviewItemDeleted(String name);

  /// No description provided for @reviewUndo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get reviewUndo;

  /// No description provided for @reviewDiscardTitle.
  ///
  /// In it, this message translates to:
  /// **'Scartare le modifiche?'**
  String get reviewDiscardTitle;

  /// No description provided for @reviewDiscardBody.
  ///
  /// In it, this message translates to:
  /// **'Lo scontrino non è ancora stato salvato.'**
  String get reviewDiscardBody;

  /// No description provided for @reviewDiscard.
  ///
  /// In it, this message translates to:
  /// **'Scarta'**
  String get reviewDiscard;

  /// No description provided for @reviewMismatchDetail.
  ///
  /// In it, this message translates to:
  /// **'Somma articoli {items}, totale {total}'**
  String reviewMismatchDetail(String items, String total);

  /// No description provided for @reviewMissingDateHint.
  ///
  /// In it, this message translates to:
  /// **'Senza data, viene usata quella di oggi.'**
  String get reviewMissingDateHint;

  /// No description provided for @reviewMissingTotalHint.
  ///
  /// In it, this message translates to:
  /// **'Senza totale, viene usata la somma degli articoli.'**
  String get reviewMissingTotalHint;

  /// No description provided for @reviewUseItemsTotal.
  ///
  /// In it, this message translates to:
  /// **'Usa la somma'**
  String get reviewUseItemsTotal;

  /// No description provided for @reviewSave.
  ///
  /// In it, this message translates to:
  /// **'Salva scontrino'**
  String get reviewSave;

  /// No description provided for @reviewSaveBlocked.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Manca 1 prodotto da controllare} other{Mancano {count} prodotti da controllare}}'**
  String reviewSaveBlocked(int count);

  /// No description provided for @reviewItemsPending.
  ///
  /// In it, this message translates to:
  /// **'Articoli ({count}), {pending} da controllare'**
  String reviewItemsPending(int count, int pending);

  /// No description provided for @reviewConfirmItem.
  ///
  /// In it, this message translates to:
  /// **'Corretto'**
  String get reviewConfirmItem;

  /// No description provided for @reviewCorrectItem.
  ///
  /// In it, this message translates to:
  /// **'Correggi'**
  String get reviewCorrectItem;

  /// No description provided for @reviewUnconfirmItem.
  ///
  /// In it, this message translates to:
  /// **'Da ricontrollare'**
  String get reviewUnconfirmItem;

  /// No description provided for @reviewSaved.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Scontrino salvato.} =1{Scontrino salvato, 1 prodotto in dispensa.} other{Scontrino salvato, {count} prodotti in dispensa.}}'**
  String reviewSaved(int count);

  /// No description provided for @reviewConfirmAll.
  ///
  /// In it, this message translates to:
  /// **'Conferma tutti ({count})'**
  String reviewConfirmAll(int count);

  /// No description provided for @analyticsTabSpending.
  ///
  /// In it, this message translates to:
  /// **'Spesa'**
  String get analyticsTabSpending;

  /// No description provided for @analyticsTabProducts.
  ///
  /// In it, this message translates to:
  /// **'Prodotti'**
  String get analyticsTabProducts;

  /// No description provided for @analyticsPeriodWeek.
  ///
  /// In it, this message translates to:
  /// **'Settimana'**
  String get analyticsPeriodWeek;

  /// No description provided for @analyticsPeriodMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese'**
  String get analyticsPeriodMonth;

  /// No description provided for @analyticsPeriodQuarter.
  ///
  /// In it, this message translates to:
  /// **'3 mesi'**
  String get analyticsPeriodQuarter;

  /// No description provided for @analyticsPeriodYear.
  ///
  /// In it, this message translates to:
  /// **'Anno'**
  String get analyticsPeriodYear;

  /// No description provided for @analyticsPickDates.
  ///
  /// In it, this message translates to:
  /// **'Scegli le date'**
  String get analyticsPickDates;

  /// No description provided for @analyticsPreviousPeriod.
  ///
  /// In it, this message translates to:
  /// **'Periodo precedente'**
  String get analyticsPreviousPeriod;

  /// No description provided for @analyticsNextPeriod.
  ///
  /// In it, this message translates to:
  /// **'Periodo successivo'**
  String get analyticsNextPeriod;

  /// No description provided for @analyticsNoReceipts.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scontrino in questo periodo'**
  String get analyticsNoReceipts;

  /// No description provided for @analyticsSpent.
  ///
  /// In it, this message translates to:
  /// **'Speso'**
  String get analyticsSpent;

  /// No description provided for @analyticsComparedWith.
  ///
  /// In it, this message translates to:
  /// **'{period}: {amount}'**
  String analyticsComparedWith(String period, String amount);

  /// No description provided for @analyticsNothingBefore.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa nel periodo prima ({period})'**
  String analyticsNothingBefore(String period);

  /// No description provided for @analyticsChangeVs.
  ///
  /// In it, this message translates to:
  /// **'{change} rispetto a {period}'**
  String analyticsChangeVs(String change, String period);

  /// No description provided for @analyticsOverTime.
  ///
  /// In it, this message translates to:
  /// **'Andamento'**
  String get analyticsOverTime;

  /// No description provided for @analyticsOverTimeHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca una barra per vederne il totale'**
  String get analyticsOverTimeHint;

  /// No description provided for @analyticsCategoriesTitle.
  ///
  /// In it, this message translates to:
  /// **'Categorie'**
  String get analyticsCategoriesTitle;

  /// No description provided for @analyticsUncategorised.
  ///
  /// In it, this message translates to:
  /// **'Senza categoria e altro'**
  String get analyticsUncategorised;

  /// No description provided for @analyticsStoresTitle.
  ///
  /// In it, this message translates to:
  /// **'Negozi'**
  String get analyticsStoresTitle;

  /// No description provided for @analyticsUnknownStore.
  ///
  /// In it, this message translates to:
  /// **'Negozio sconosciuto'**
  String get analyticsUnknownStore;

  /// No description provided for @analyticsStoreVisits.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 visita} other{{count} visite}} · spesa media {amount}'**
  String analyticsStoreVisits(int count, String amount);

  /// No description provided for @analyticsSavingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Risparmiato con gli sconti'**
  String get analyticsSavingsTitle;

  /// No description provided for @analyticsSavingsRate.
  ///
  /// In it, this message translates to:
  /// **'{percent} del prezzo pieno'**
  String analyticsSavingsRate(String percent);

  /// No description provided for @analyticsMostBoughtTitle.
  ///
  /// In it, this message translates to:
  /// **'Più acquistati'**
  String get analyticsMostBoughtTitle;

  /// No description provided for @analyticsTimesBought.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 volta} other{{count} volte}} · ultimo acquisto {date}'**
  String analyticsTimesBought(int count, String date);

  /// No description provided for @analyticsShowAll.
  ///
  /// In it, this message translates to:
  /// **'Mostra tutti ({count})'**
  String analyticsShowAll(int count);

  /// No description provided for @analyticsShowLess.
  ///
  /// In it, this message translates to:
  /// **'Mostra meno'**
  String get analyticsShowLess;

  /// No description provided for @analyticsPriceChangesTitle.
  ///
  /// In it, this message translates to:
  /// **'Variazioni di prezzo'**
  String get analyticsPriceChangesTitle;

  /// No description provided for @analyticsPriceRises.
  ///
  /// In it, this message translates to:
  /// **'In aumento'**
  String get analyticsPriceRises;

  /// No description provided for @analyticsPriceDrops.
  ///
  /// In it, this message translates to:
  /// **'In calo'**
  String get analyticsPriceDrops;

  /// No description provided for @analyticsPriceVsUsual.
  ///
  /// In it, this message translates to:
  /// **'{latest} contro {usual} di solito'**
  String analyticsPriceVsUsual(String latest, String usual);

  /// No description provided for @analyticsPriceChangesHint.
  ///
  /// In it, this message translates to:
  /// **'Prezzo pieno dell\'ultimo acquisto rispetto alla mediana dei 90 giorni prima (almeno 3 acquisti). Le offerte non contano.'**
  String get analyticsPriceChangesHint;

  /// No description provided for @analyticsNoPriceChanges.
  ///
  /// In it, this message translates to:
  /// **'Nessuna variazione di prezzo di rilievo in questo periodo'**
  String get analyticsNoPriceChanges;

  /// No description provided for @analyticsTabPantry.
  ///
  /// In it, this message translates to:
  /// **'Dispensa'**
  String get analyticsTabPantry;

  /// No description provided for @analyticsPantryEmpty.
  ///
  /// In it, this message translates to:
  /// **'La dispensa è vuota.\nSalva uno scontrino per vedere cosa usi e cosa butti.'**
  String get analyticsPantryEmpty;

  /// No description provided for @analyticsFateTitle.
  ///
  /// In it, this message translates to:
  /// **'Dove è finita la spesa'**
  String get analyticsFateTitle;

  /// No description provided for @analyticsFateSubtitle.
  ///
  /// In it, this message translates to:
  /// **'{amount} spesi in questo periodo'**
  String analyticsFateSubtitle(String amount);

  /// No description provided for @analyticsFateUsed.
  ///
  /// In it, this message translates to:
  /// **'Usato'**
  String get analyticsFateUsed;

  /// No description provided for @analyticsFateWasted.
  ///
  /// In it, this message translates to:
  /// **'Buttato'**
  String get analyticsFateWasted;

  /// No description provided for @analyticsFateInPantry.
  ///
  /// In it, this message translates to:
  /// **'Ancora in dispensa'**
  String get analyticsFateInPantry;

  /// No description provided for @analyticsFateNotInPantry.
  ///
  /// In it, this message translates to:
  /// **'Non in dispensa'**
  String get analyticsFateNotInPantry;

  /// No description provided for @analyticsFateNotInPantryHint.
  ///
  /// In it, this message translates to:
  /// **'prodotti non seguiti, sconti sul totale e righe senza prodotto'**
  String get analyticsFateNotInPantryHint;

  /// No description provided for @analyticsFateCoverage.
  ///
  /// In it, this message translates to:
  /// **'{untouched, plural, =0{Tutti i {count} prodotti sono stati aggiornati in dispensa.} =1{1 prodotto su {count} non è mai stato aggiornato: conta come ancora in dispensa.} other{{untouched} prodotti su {count} non sono mai stati aggiornati: contano come ancora in dispensa.}}'**
  String analyticsFateCoverage(int untouched, int count);

  /// No description provided for @analyticsFateNoReceipts.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scontrino in questo periodo'**
  String get analyticsFateNoReceipts;

  /// No description provided for @analyticsWasteTitle.
  ///
  /// In it, this message translates to:
  /// **'Sprechi'**
  String get analyticsWasteTitle;

  /// No description provided for @analyticsWasteSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Buttato in questo periodo, qualunque sia la data d\'acquisto'**
  String get analyticsWasteSubtitle;

  /// No description provided for @analyticsWasteRate.
  ///
  /// In it, this message translates to:
  /// **'{percent} di ciò che è uscito dalla dispensa'**
  String analyticsWasteRate(String percent);

  /// No description provided for @analyticsWasteNone.
  ///
  /// In it, this message translates to:
  /// **'Niente buttato in questo periodo'**
  String get analyticsWasteNone;

  /// No description provided for @analyticsWasteUnpriced.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Più 1 prodotto senza prezzo} other{Più {count} prodotti senza prezzo}}'**
  String analyticsWasteUnpriced(int count);

  /// No description provided for @analyticsWasteReasons.
  ///
  /// In it, this message translates to:
  /// **'Perché'**
  String get analyticsWasteReasons;

  /// No description provided for @analyticsWasteReasonExpired.
  ///
  /// In it, this message translates to:
  /// **'Scaduto'**
  String get analyticsWasteReasonExpired;

  /// No description provided for @analyticsWasteReasonSpoiled.
  ///
  /// In it, this message translates to:
  /// **'Andato a male'**
  String get analyticsWasteReasonSpoiled;

  /// No description provided for @analyticsWasteReasonOther.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get analyticsWasteReasonOther;

  /// No description provided for @analyticsWasteCategories.
  ///
  /// In it, this message translates to:
  /// **'Per categoria'**
  String get analyticsWasteCategories;

  /// No description provided for @analyticsWasteProducts.
  ///
  /// In it, this message translates to:
  /// **'Prodotti più buttati'**
  String get analyticsWasteProducts;

  /// No description provided for @analyticsWasteLots.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 volta} other{{count} volte}}'**
  String analyticsWasteLots(int count);

  /// No description provided for @analyticsNoCategory.
  ///
  /// In it, this message translates to:
  /// **'Senza categoria'**
  String get analyticsNoCategory;

  /// No description provided for @shoppingTitle.
  ///
  /// In it, this message translates to:
  /// **'Prossima spesa'**
  String get shoppingTitle;

  /// No description provided for @shoppingEmpty.
  ///
  /// In it, this message translates to:
  /// **'Niente da ricomprare nei prossimi giorni'**
  String get shoppingEmpty;

  /// No description provided for @shoppingHint.
  ///
  /// In it, this message translates to:
  /// **'In base a quanto usi in dispensa e a quanto spesso compri'**
  String get shoppingHint;

  /// No description provided for @shoppingFinished.
  ///
  /// In it, this message translates to:
  /// **'Finito in dispensa'**
  String get shoppingFinished;

  /// No description provided for @shoppingRunningLow.
  ///
  /// In it, this message translates to:
  /// **'Ne resta {quantity}: finisce {when}'**
  String shoppingRunningLow(String quantity, String when);

  /// No description provided for @shoppingUsual.
  ///
  /// In it, this message translates to:
  /// **'Di solito ogni {days, plural, =1{giorno} other{{days} giorni}}, l\'ultima volta il {date}'**
  String shoppingUsual(int days, String date);

  /// No description provided for @shoppingEvery.
  ///
  /// In it, this message translates to:
  /// **'di solito ogni {days, plural, =1{giorno} other{{days} giorni}}'**
  String shoppingEvery(int days);

  /// No description provided for @shoppingToday.
  ///
  /// In it, this message translates to:
  /// **'oggi'**
  String get shoppingToday;

  /// No description provided for @shoppingTomorrow.
  ///
  /// In it, this message translates to:
  /// **'domani'**
  String get shoppingTomorrow;

  /// No description provided for @shoppingInDays.
  ///
  /// In it, this message translates to:
  /// **'tra {days} giorni'**
  String shoppingInDays(int days);

  /// No description provided for @insightSpikeTitle.
  ///
  /// In it, this message translates to:
  /// **'{category}: {change} rispetto al solito'**
  String insightSpikeTitle(String category, String change);

  /// No description provided for @insightSpikeBody.
  ///
  /// In it, this message translates to:
  /// **'{amount} finora questo mese; di solito {usual} a questo punto ({months, plural, =1{nell\'ultimo mese} other{media degli ultimi {months} mesi}})'**
  String insightSpikeBody(String amount, String usual, int months);

  /// No description provided for @insightWasteTitle.
  ///
  /// In it, this message translates to:
  /// **'Butti spesso: {product}'**
  String insightWasteTitle(String product);

  /// No description provided for @insightWasteBody.
  ///
  /// In it, this message translates to:
  /// **'{wasted} volte su {total} negli ultimi {days} giorni, {amount} buttati. Prova a prenderne meno.'**
  String insightWasteBody(int wasted, int total, int days, String amount);

  /// No description provided for @insightPriceTitle.
  ///
  /// In it, this message translates to:
  /// **'Prezzo in aumento: {product}'**
  String insightPriceTitle(String product);

  /// No description provided for @insightPriceBody.
  ///
  /// In it, this message translates to:
  /// **'{latest} contro {usual} di solito{store, select, none{} other{ da {store}}} ({change}). Circa {amount} in più al mese per quanto ne compri.'**
  String insightPriceBody(
    String latest,
    String usual,
    String store,
    String change,
    String amount,
  );

  /// No description provided for @exportTitle.
  ///
  /// In it, this message translates to:
  /// **'Esporta i dati raccolti'**
  String get exportTitle;

  /// No description provided for @exportSummary.
  ///
  /// In it, this message translates to:
  /// **'{receipts, plural, =1{1 scontrino} other{{receipts} scontrini}} · {items, plural, =1{1 articolo} other{{items} articoli}}, in un file CSV'**
  String exportSummary(int receipts, int items);

  /// No description provided for @exportNothing.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scontrino da esportare'**
  String get exportNothing;

  /// No description provided for @exportWarning.
  ///
  /// In it, this message translates to:
  /// **'Tutti gli articoli degli scontrini confermati, uno per riga, in un file CSV che si apre con Excel, Fogli Google o un programma di analisi.\n\nIl file non è cifrato: chi lo apre vede i tuoi acquisti.'**
  String get exportWarning;

  /// No description provided for @exportConfirm.
  ///
  /// In it, this message translates to:
  /// **'Esporta'**
  String get exportConfirm;

  /// No description provided for @exportDone.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Esportato 1 articolo} other{Esportati {count} articoli}} in {fileName}'**
  String exportDone(int count, String fileName);

  /// No description provided for @exportFailed.
  ///
  /// In it, this message translates to:
  /// **'Esportazione non riuscita.'**
  String get exportFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
