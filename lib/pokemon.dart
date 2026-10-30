class Pokemon {
  final int id;
  final String name;
  final int baseExperience;
  final List<String> types;
  final int height;
  final int weight;
  final List<AbilityEntry> abilities;
  final List<String> heldItems;
  final List<MoveEntry> moves;
  final String spriteUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.heldItems,
    required this.moves,
    required this.spriteUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final typesList = json['types'] as List? ?? [];
    final parsedTypes = typesList.map<String>((typeJson) {
      if (typeJson is String) return typeJson;
      return (typeJson['type']?['name'] ?? typeJson['name'] ?? 'unknown').toString();
    }).toList();

    final abilitiesList = json['abilities'] as List? ?? [];
    final parsedAbilities = abilitiesList
        .map((item) => AbilityEntry.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final heldItemsList = json['held_items'] as List? ?? [];
    final parsedHeldItems = heldItemsList.map<String>((item) {
      if (item is String) return item;
      return (item['item']?['name'] ?? item['name'] ?? 'unknown').toString();
    }).toList();

    final movesList = json['moves'] as List? ?? [];
    final parsedMoves = movesList
        .map((item) => MoveEntry.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final sprites = json['sprites'] as Map? ?? {};
    final other = sprites['other'] as Map? ?? {};
    final artwork = other['official-artwork'] as Map? ?? {};

    final extractedSprite = (artwork['front_default'] ??
            sprites['front_default'] ??
            json['sprite_url'] ??
            '')
        .toString();

    return Pokemon(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'unknown',
      baseExperience: json['base_experience'] as int? ?? json['baseExperience'] as int? ?? 0,
      types: parsedTypes,
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      abilities: parsedAbilities,
      heldItems: parsedHeldItems,
      moves: parsedMoves,
      spriteUrl: extractedSprite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'base_experience': baseExperience,
      'types': types.map((type) => {'type': {'name': type}}).toList(),
      'height': height,
      'weight': weight,
      'abilities': abilities.map((a) => a.toJson()).toList(),
      'held_items': heldItems.map((item) => {'item': {'name': item}}).toList(),
      'moves': moves.map((m) => m.toJson()).toList(),
      'sprite_url': spriteUrl,
    };
  }
}

class AbilityEntry {
  final String name;
  final int slot;
  final bool isHidden;

  AbilityEntry({
    required this.name,
    required this.slot,
    required this.isHidden,
  });

  factory AbilityEntry.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map? ?? {};
    return AbilityEntry(
      name: (ability['name'] ?? json['name'] ?? 'unknown').toString(),
      slot: json['slot'] as int? ?? 0,
      isHidden: json['is_hidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ability': {'name': name},
      'slot': slot,
      'is_hidden': isHidden,
    };
  }
}

class MoveEntry {
  final String name;

  MoveEntry({required this.name});

  factory MoveEntry.fromJson(Map<String, dynamic> json) {
    final move = json['move'] as Map? ?? {};
    return MoveEntry(
      name: (move['name'] ?? json['name'] ?? 'unknown').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'move': {'name': name},
    };
  }
}