/// Categories and starter keywords inserted when the database is created.
///
/// Keywords are matched against normalised (upper-case) item names from
/// receipts. They are only a starting point: user corrections are stored in
/// `product_aliases` and take priority.
class CategorySeed {
  const new(this.name, this.icon, this.color, this.keywords);

  final String name;
  final String icon;
  final int color;
  final List<String> keywords;
}

const defaultCategories = <CategorySeed>[
  CategorySeed('Frutta e verdura', 'eco', 0xFF43A047, [
    'MELE',
    'BANANE',
    'ARANCE',
    'POMODORI',
    'INSALATA',
    'PATATE',
    'ZUCCHINE',
    'CAROTE',
    'LIMONI',
    'CIPOLLE',
  ]),
  CategorySeed('Carne e pesce', 'set_meal', 0xFFE53935, [
    'POLLO',
    'MANZO',
    'MAIALE',
    'TACCHINO',
    'SALMONE',
    'TONNO',
    'MACINATO',
    'PROSCIUTTO',
    'SALAME',
  ]),
  CategorySeed('Latticini e uova', 'egg', 0xFFFDD835, [
    'LATTE',
    'YOGURT',
    'MOZZARELLA',
    'FORMAGGIO',
    'BURRO',
    'UOVA',
    'PARMIGIANO',
    'GRANA',
    'RICOTTA',
  ]),
  CategorySeed('Pane e pasta', 'bakery_dining', 0xFFFB8C00, [
    'PANE',
    'PASTA',
    'RISO',
    'FARINA',
    'BISCOTTI',
    'GRISSINI',
    'CRACKERS',
    'SPAGHETTI',
    'PENNE',
    'FETTE',
  ]),
  CategorySeed('Bevande', 'local_drink', 0xFF1E88E5, [
    'ACQUA',
    'VINO',
    'BIRRA',
    'SUCCO',
    'COCA',
    'CAFFE',
    'BIBITA',
  ]),
  CategorySeed('Dispensa', 'kitchen', 0xFF8D6E63, [
    'OLIO',
    'ZUCCHERO',
    'SALE',
    'PASSATA',
    'LEGUMI',
    'CEREALI',
    'MARMELLATA',
  ]),
  CategorySeed('Surgelati', 'ac_unit', 0xFF00ACC1, [
    'SURG',
    'GELATO',
    'BASTONCINI',
  ]),
  CategorySeed('Casa e igiene', 'cleaning_services', 0xFF8E24AA, [
    'DETERSIVO',
    'SAPONE',
    'SHAMPOO',
    'CARTA IGIENICA',
    'DENTIFRICIO',
    'AMMORBIDENTE',
    'SCOTTEX',
  ]),
  CategorySeed('Altro', 'category', 0xFF9E9E9E, []),
];
