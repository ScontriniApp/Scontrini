import 'package:drift/drift.dart';
import 'package:scontrini/core/database/tables/pantry_enums.dart';

export 'package:scontrini/core/database/tables/pantry_enums.dart';

/// Lifecycle of a receipt: drafts come out of OCR and become confirmed once
/// the user has reviewed them. Only confirmed receipts feed the analytics.
enum ReceiptStatus { draft, confirmed }

@DataClassName('Store')
class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Italian VAT number (P.IVA), useful to recognise the same store.
  TextColumn get vatNumber => text().nullable().unique()();
  TextColumn get address => text().nullable()();
}

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();

  /// Material icon name, resolved in the UI layer.
  TextColumn get icon => text().withDefault(const Constant('category'))();

  /// ARGB colour value.
  IntColumn get color => integer().withDefault(const Constant(0xFF9E9E9E))();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
}

@DataClassName('Product')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get canonicalName => text().unique()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Unit of measure: `kg`, `l` or `pz`.
  TextColumn get unit => text().nullable()();

  /// Whether the pantry triage offers this product (false for bags,
  /// newspapers and the like).
  BoolColumn get trackInPantry => boolean().withDefault(const Constant(true))();
}

/// Maps a raw (normalised) name read from a receipt to a canonical product.
/// Filled from user corrections, so recognition improves over time.
@DataClassName('ProductAlias')
class ProductAliases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawName => text().unique()();
  IntColumn get productId =>
      integer().references(Products, #id, onDelete: KeyAction.cascade)();
}

@DataClassName('CategoryKeyword')
class CategoryKeywords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get keyword => text().unique()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
}

@DataClassName('Receipt')
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get storeId => integer().nullable().references(Stores, #id)();

  /// Stored in UTC.
  DateTimeColumn get purchaseDate => dateTime()();
  IntColumn get totalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();

  /// Path of the original image/PDF inside the app documents directory.
  TextColumn get sourcePath => text().nullable()();

  /// Original OCR output, kept so receipts can be re-parsed later.
  TextColumn get rawOcrText => text().nullable()();
  TextColumn get status => textEnum<ReceiptStatus>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ReceiptItem')
class ReceiptItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get receiptId =>
      integer().references(Receipts, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().nullable().references(Products, #id)();

  /// Name exactly as printed on the receipt.
  TextColumn get rawName => text()();

  /// Pieces, or kg/l for weighed items.
  RealColumn get quantity => real().withDefault(const Constant(1))();

  /// Unit of [quantity]: `pz`, `kg` or `l`.
  TextColumn get unit => text().withDefault(const Constant('pz'))();
  IntColumn get unitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Pantry lot this row went into, if the user added it during triage.
  /// Several rows of the same product share one lot.
  IntColumn get pantryLotId => integer().nullable().references(
    PantryLots,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

/// What one origin (a receipt or a manual entry) put in the pantry for one
/// product. The remaining quantity is not stored: it is the sum of the
/// lot's [PantryEvents] deltas.
@DataClassName('PantryLotRow')
class PantryLots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Set exactly when [source] is `receipt`. Deleting the receipt deletes
  /// the lot and its events.
  IntColumn get receiptId => integer().nullable().references(
    Receipts,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get productId => integer().nullable().references(
    Products,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get name => text()();

  /// `pz`, `kg` or `l`.
  TextColumn get unit => text().withDefault(const Constant('pz'))();
  TextColumn get source => textEnum<PantrySource>()();

  /// Purchased quantity. Changes only when the purchase is corrected.
  RealColumn get initialQuantity => real()();

  /// What was paid for the lot after discounts, when known.
  IntColumn get priceCents => integer().nullable()();

  /// Stored in UTC.
  DateTimeColumn get addedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK ((source = 'receipt') = (receipt_id IS NOT NULL))",
    'CHECK (initial_quantity >= 0)',
  ];
}

/// Append-only log of pantry movements. Events are never edited; a mistake
/// is cancelled with a [PantryEventKind.revert] event.
@DataClassName('PantryEventRow')
class PantryEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lotId =>
      integer().references(PantryLots, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<PantryEventKind>()();
  TextColumn get reason => textEnum<PantryEventReason>().nullable()();

  /// Change actually applied to the remaining quantity, already clamped so
  /// the remaining quantity never goes below 0. A revert carries the
  /// opposite of the event it cancels.
  RealColumn get delta => real()();
  IntColumn get revertsEventId =>
      integer().nullable().references(PantryEvents, #id)();

  /// Stored in UTC.
  DateTimeColumn get at => dateTime()();
}
