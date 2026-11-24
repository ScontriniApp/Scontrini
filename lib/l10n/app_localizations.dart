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

  /// No description provided for @analyticsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Grafici e statistiche appariranno qui.'**
  String get analyticsEmpty;

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

  /// No description provided for @extractionPreviewNotice.
  ///
  /// In it, this message translates to:
  /// **'Controlla i dati: confermando, lo scontrino viene salvato e puoi smistarlo in dispensa.'**
  String get extractionPreviewNotice;

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

  /// No description provided for @pantryFieldName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get pantryFieldName;

  /// No description provided for @pantryFieldQuantity.
  ///
  /// In it, this message translates to:
  /// **'Quantità'**
  String get pantryFieldQuantity;

  /// No description provided for @pantryFieldCategory.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get pantryFieldCategory;

  /// No description provided for @pantryInvalidName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un nome'**
  String get pantryInvalidName;

  /// No description provided for @pantryInvalidQuantity.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una quantità maggiore di zero'**
  String get pantryInvalidQuantity;

  /// No description provided for @pantryInvalidPrice.
  ///
  /// In it, this message translates to:
  /// **'Prezzo non valido'**
  String get pantryInvalidPrice;

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

  /// No description provided for @settingsPhotoReading.
  ///
  /// In it, this message translates to:
  /// **'Lettura delle foto'**
  String get settingsPhotoReading;

  /// No description provided for @glmOcrModelTitle.
  ///
  /// In it, this message translates to:
  /// **'Modello di lettura avanzato'**
  String get glmOcrModelTitle;

  /// No description provided for @glmOcrModelChecking.
  ///
  /// In it, this message translates to:
  /// **'Verifica…'**
  String get glmOcrModelChecking;

  /// No description provided for @glmOcrModelMissing.
  ///
  /// In it, this message translates to:
  /// **'Non installato: le foto si leggono con il riconoscimento standard. GLM-OCR è più preciso ma sui telefoni meno potenti può richiedere minuti per scontrino. Download di {size}.'**
  String glmOcrModelMissing(String size);

  /// No description provided for @glmOcrModelPartial.
  ///
  /// In it, this message translates to:
  /// **'Download interrotto: {done} di {total}.'**
  String glmOcrModelPartial(String done, String total);

  /// No description provided for @glmOcrModelDownloading.
  ///
  /// In it, this message translates to:
  /// **'Download: {done} di {total}'**
  String glmOcrModelDownloading(String done, String total);

  /// No description provided for @glmOcrModelInstalled.
  ///
  /// In it, this message translates to:
  /// **'Installato ({size}): le foto si leggono sul telefono con GLM-OCR.'**
  String glmOcrModelInstalled(String size);

  /// No description provided for @glmOcrDownload.
  ///
  /// In it, this message translates to:
  /// **'Scarica'**
  String get glmOcrDownload;

  /// No description provided for @glmOcrResume.
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get glmOcrResume;

  /// No description provided for @glmOcrDownloadConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Scaricare il modello?'**
  String get glmOcrDownloadConfirmTitle;

  /// No description provided for @glmOcrDownloadConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Il modello GLM-OCR ({size}) si scarica da Hugging Face: meglio con il Wi-Fi. Gli scontrini non lasciano il telefono, il modello li legge senza connessione.'**
  String glmOcrDownloadConfirmBody(String size);

  /// No description provided for @glmOcrDeleteConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il modello?'**
  String get glmOcrDeleteConfirmTitle;

  /// No description provided for @glmOcrDeleteConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Libera {size}. Le foto torneranno a essere lette con il riconoscimento standard.'**
  String glmOcrDeleteConfirmBody(String size);

  /// No description provided for @glmOcrErrorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Download non riuscito: controlla la connessione.'**
  String get glmOcrErrorNetwork;

  /// No description provided for @glmOcrErrorCorrupt.
  ///
  /// In it, this message translates to:
  /// **'Il file scaricato è danneggiato: riprova.'**
  String get glmOcrErrorCorrupt;

  /// No description provided for @glmOcrErrorStorage.
  ///
  /// In it, this message translates to:
  /// **'Spazio insufficiente sul telefono.'**
  String get glmOcrErrorStorage;

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

  /// No description provided for @triageTitle.
  ///
  /// In it, this message translates to:
  /// **'Smista in dispensa'**
  String get triageTitle;

  /// No description provided for @triageCounter.
  ///
  /// In it, this message translates to:
  /// **'{current} di {total}'**
  String triageCounter(int current, int total);

  /// No description provided for @triageKeep.
  ///
  /// In it, this message translates to:
  /// **'In dispensa'**
  String get triageKeep;

  /// No description provided for @triageSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get triageSkip;

  /// No description provided for @triageDone.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get triageDone;

  /// No description provided for @triageFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare i prodotti.'**
  String get triageFailed;

  /// No description provided for @triageSummary.
  ///
  /// In it, this message translates to:
  /// **'{kept} in dispensa, {skipped} saltati.'**
  String triageSummary(int kept, int skipped);

  /// No description provided for @confirmAndSort.
  ///
  /// In it, this message translates to:
  /// **'Conferma e smista in dispensa'**
  String get confirmAndSort;

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

  /// No description provided for @dashboardOtherCategories.
  ///
  /// In it, this message translates to:
  /// **'Altre categorie'**
  String get dashboardOtherCategories;

  /// No description provided for @dashboardInsightsTitle.
  ///
  /// In it, this message translates to:
  /// **'Consigli'**
  String get dashboardInsightsTitle;

  /// No description provided for @dashboardInsightsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Qui appariranno 2–3 consigli sui tuoi acquisti: prezzi in aumento, occasioni di risparmio, categorie in crescita.'**
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

  /// No description provided for @manualReceiptStore.
  ///
  /// In it, this message translates to:
  /// **'Negozio (facoltativo)'**
  String get manualReceiptStore;

  /// No description provided for @manualReceiptDate.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get manualReceiptDate;

  /// No description provided for @manualReceiptItem.
  ///
  /// In it, this message translates to:
  /// **'Articolo {index}'**
  String manualReceiptItem(int index);

  /// No description provided for @manualReceiptAddItem.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi articolo'**
  String get manualReceiptAddItem;

  /// No description provided for @manualReceiptRemoveItem.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi articolo'**
  String get manualReceiptRemoveItem;

  /// No description provided for @manualReceiptPrice.
  ///
  /// In it, this message translates to:
  /// **'Prezzo pagato'**
  String get manualReceiptPrice;

  /// No description provided for @manualReceiptCategoryAuto.
  ///
  /// In it, this message translates to:
  /// **'Automatica (dal nome)'**
  String get manualReceiptCategoryAuto;

  /// No description provided for @manualReceiptTotal.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get manualReceiptTotal;

  /// No description provided for @manualReceiptToPantry.
  ///
  /// In it, this message translates to:
  /// **'Metti gli articoli in dispensa'**
  String get manualReceiptToPantry;

  /// No description provided for @manualReceiptSave.
  ///
  /// In it, this message translates to:
  /// **'Salva scontrino'**
  String get manualReceiptSave;

  /// No description provided for @manualReceiptSaved.
  ///
  /// In it, this message translates to:
  /// **'Scontrino salvato nello storico'**
  String get manualReceiptSaved;

  /// No description provided for @manualReceiptFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare lo scontrino.'**
  String get manualReceiptFailed;

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
