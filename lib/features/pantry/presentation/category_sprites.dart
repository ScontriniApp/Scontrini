/// 8-bit sprites (16×16 PNG, `assets/sprites/categories/`) by seed category
/// name. Categories without one keep the initials tile (see `LotAvatar`).
const _sprites = {'Pane e pasta': 'assets/sprites/categories/pane_e_pasta.png'};

/// The sprite asset of the category named [name], or `null`.
String? categorySprite(String? name) => name == null ? null : _sprites[name];
