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

  @override
  String get navPantry => 'Pantry';

  @override
  String get pantryEmpty =>
      'Your pantry is empty.\nAdd products from a receipt or by hand.';

  @override
  String get pantryShowClosed => 'Show finished and thrown away';

  @override
  String get pantryHideClosed => 'Hide finished and thrown away';

  @override
  String get pantryAdd => 'Add product';

  @override
  String get pantryUncategorised => 'Uncategorised';

  @override
  String pantryRemaining(String remaining, String initial) {
    return '$remaining of $initial';
  }

  @override
  String get pantrySourceManualPurchase => 'Bought, no receipt';

  @override
  String get pantrySourceInitialStock => 'Already at home';

  @override
  String get pantrySourceGift => 'Gift';

  @override
  String get pantryStatusConsumed => 'Finished';

  @override
  String get pantryStatusDiscarded => 'Thrown away';

  @override
  String get pantryConsumeAll => 'Mark as finished';

  @override
  String get pantryDiscard => 'Throw away';

  @override
  String get pantryReasonExpired => 'Expired';

  @override
  String get pantryReasonSpoiled => 'Spoiled';

  @override
  String get pantryReasonOther => 'Other reason';

  @override
  String get pantryUndo => 'Undo';

  @override
  String get pantryUndoLast => 'Undo last action';

  @override
  String get pantryNothingToUndo => 'Nothing to undo';

  @override
  String get pantryDelete => 'Remove from pantry';

  @override
  String pantryDeleteConfirm(String name) {
    return 'Remove $name? Its usage history will be lost.';
  }

  @override
  String pantryConsumedMessage(String name, String amount) {
    return '$name: used $amount';
  }

  @override
  String pantryDiscardedMessage(String name) {
    return '$name thrown away';
  }

  @override
  String pantryFinishedMessage(String name) {
    return '$name finished';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get pantryFieldName => 'Name';

  @override
  String get pantryFieldQuantity => 'Quantity';

  @override
  String get pantryFieldPrice => 'Price paid (optional)';

  @override
  String get pantryFieldCategory => 'Category';

  @override
  String get pantryFieldSource => 'Source';

  @override
  String get pantryInvalidName => 'Enter a name';

  @override
  String get pantryInvalidQuantity => 'Enter a quantity above zero';

  @override
  String get pantryInvalidPrice => 'Invalid price';

  @override
  String get unitPieces => 'pcs';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitLitres => 'l';

  @override
  String get settingsPhotoReading => 'Reading photos';

  @override
  String get glmOcrModelTitle => 'Advanced reading model';

  @override
  String get glmOcrModelChecking => 'Checking…';

  @override
  String glmOcrModelMissing(String size) {
    return 'Not installed: photos are read with basic recognition, which is less accurate. $size download.';
  }

  @override
  String glmOcrModelPartial(String done, String total) {
    return 'Download stopped: $done of $total.';
  }

  @override
  String glmOcrModelDownloading(String done, String total) {
    return 'Downloading: $done of $total';
  }

  @override
  String glmOcrModelInstalled(String size) {
    return 'Installed ($size): photos are read on the phone with GLM-OCR.';
  }

  @override
  String get glmOcrDownload => 'Download';

  @override
  String get glmOcrResume => 'Resume';

  @override
  String get glmOcrDownloadConfirmTitle => 'Download the model?';

  @override
  String glmOcrDownloadConfirmBody(String size) {
    return 'The GLM-OCR model ($size) is downloaded from Hugging Face: Wi-Fi is best. Receipts never leave the phone, the model reads them offline.';
  }

  @override
  String get glmOcrDeleteConfirmTitle => 'Delete the model?';

  @override
  String glmOcrDeleteConfirmBody(String size) {
    return 'Frees $size. Photos will be read with basic recognition again.';
  }

  @override
  String get glmOcrErrorNetwork => 'Download failed: check the connection.';

  @override
  String get glmOcrErrorCorrupt => 'The downloaded file is damaged: try again.';

  @override
  String get glmOcrErrorStorage => 'Not enough space on the phone.';
}
