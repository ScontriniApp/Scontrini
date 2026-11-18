import 'package:drift/drift.dart';

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
  IntColumn get unitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
}
