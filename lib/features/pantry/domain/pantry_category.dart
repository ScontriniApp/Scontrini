/// A category as the pantry shows it.
class PantryCategory {
  const new({required this.id, required this.name, required this.color});

  final int id;
  final String name;

  /// ARGB.
  final int color;
}
