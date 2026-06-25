class SectorSimple {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  SectorSimple({required this.id, required this.name, this.description, this.isActive = true});
}

class InMemorySectors {
  static final List<SectorSimple> _sectors = [];

  static List<SectorSimple> all() => List.unmodifiable(_sectors);

  static void add(SectorSimple s) => _sectors.add(s);

  static void clear() => _sectors.clear();
}
