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

  /// No description provided for @navInsights.
  ///
  /// In it, this message translates to:
  /// **'Consigli'**
  String get navInsights;

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
