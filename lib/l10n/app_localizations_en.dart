// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Receipts';

  @override
  String get navHome => 'Home';

  @override
  String get navReceipts => 'History';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navInsights => 'Tips';

  @override
  String get addReceipt => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get captureTitle => 'New receipt';

  @override
  String get captureScan => 'Scan with camera';

  @override
  String get captureGallery => 'Choose from gallery';

  @override
  String get capturePdf => 'Import PDF';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get dashboardEmpty =>
      'No receipts yet.\nAdd your first one to see your spending.';

  @override
  String get receiptsEmpty => 'Your purchase history will appear here.';

  @override
  String get analyticsEmpty => 'Charts and statistics will appear here.';

  @override
  String get insightsEmpty => 'Personalised tips will appear here.';

  @override
  String get settingsEmpty => 'Categories, backup and security.';
}
