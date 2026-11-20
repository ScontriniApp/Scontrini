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
  /// **'Lo storico degli acquisti apparirà qui.'**
  String get receiptsEmpty;

  /// No description provided for @analyticsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Grafici e statistiche appariranno qui.'**
  String get analyticsEmpty;

  /// No description provided for @settingsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Categorie, backup e sicurezza.'**
  String get settingsEmpty;

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
  /// **'Anteprima di sviluppo: lo scontrino non viene ancora salvato.'**
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
  /// **'Aggiungi prodotto'**
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

  /// No description provided for @pantryFieldPrice.
  ///
  /// In it, this message translates to:
  /// **'Prezzo pagato (facoltativo)'**
  String get pantryFieldPrice;

  /// No description provided for @pantryFieldCategory.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get pantryFieldCategory;

  /// No description provided for @pantryFieldSource.
  ///
  /// In it, this message translates to:
  /// **'Provenienza'**
  String get pantryFieldSource;

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
