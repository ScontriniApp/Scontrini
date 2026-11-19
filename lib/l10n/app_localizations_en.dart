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

  @override
  String get captureFailed => 'Couldn\'t capture the receipt.';

  @override
  String get extractionTitle => 'Receipt read';

  @override
  String get extractionLoading => 'Reading the receipt…';

  @override
  String get extractionFailed => 'Couldn\'t read the receipt.';

  @override
  String get retry => 'Retry';

  @override
  String get extractionPreviewNotice =>
      'Development preview: the receipt is not saved yet.';

  @override
  String get fieldStore => 'Store';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldItemsTotal => 'Items total';

  @override
  String extractionItems(int count) {
    return 'Items ($count)';
  }

  @override
  String extractionDiscount(String amount) {
    return 'Discount $amount';
  }

  @override
  String get extractionReceiptDiscount => 'Discounts on the total';

  @override
  String get extractionUnparsed => 'Unrecognised rows';

  @override
  String get extractionRawText => 'Recognised text';

  @override
  String get warningMissingStore => 'Store not found';

  @override
  String get warningMissingDate => 'Date not found';

  @override
  String get warningMissingTotal => 'Total not found';

  @override
  String get warningTotalMismatch => 'The items don\'t add up to the total';

  @override
  String get warningLineTotalMismatch =>
      'Quantity × price differs from the line amount';

  @override
  String get exportFixture => 'Export as test';

  @override
  String exportFixtureDone(String name) {
    return 'Saved: $name';
  }
}
