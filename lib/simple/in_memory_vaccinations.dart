class VaccinationSimple {
  final String id;
  final String ownerName;
  final String? ownerCedula;
  final String? ownerPhone;
  final String petName;
  final String petType; // 'dog', 'cat'
  final String? petAge;
  final String? petSex; // 'male', 'female'
  final String vaccine;
  final String sectorId;
  final String? observations;
  final String? photoPath; // Ruta local de la foto
  final double? latitude; // Ubicación GPS
  final double? longitude;
  final DateTime createdAt;

  VaccinationSimple({
    required this.id,
    required this.ownerName,
    this.ownerCedula,
    this.ownerPhone,
    required this.petName,
    this.petType = 'dog',
    this.petAge,
    this.petSex,
    required this.vaccine,
    required this.sectorId,
    this.observations,
    this.photoPath,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class InMemoryVaccinations {
  static final List<VaccinationSimple> _items = [];

  static List<VaccinationSimple> all() => List.unmodifiable(_items);

  static void add(VaccinationSimple v) => _items.add(v);

  static void clear() => _items.clear();
}
