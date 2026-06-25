// lib/features/vaccinations/data/models/vaccination_model.dart
// (Isar model para persistencia local)
// ============================================================
 
import 'package:isar/isar.dart';
 
part 'vaccination_model.g.dart';
 
/// Modelo de Isar para persistencia local offline-first.
/// Cada campo tiene una anotación @Index cuando se usará para filtros.
///
/// Decisión técnica: se usa Isar sobre Hive porque:
/// - Isar es más rápido (escrito en Rust)
/// - Soporta queries complejas con índices
/// - Genera código type-safe
/// - Mejor soporte para Flutter moderno
@Collection()
class VaccinationModel {
  Id isarId = Isar.autoIncrement;
 
  @Index(type: IndexType.value)
  String? remoteId;          // ID del servidor Supabase
 
  @Index(type: IndexType.value)
  String localId = '';       // UUID generado localmente
 
  String ownerName = '';
  String ownerCedula = '';
  String ownerPhone = '';
 
  @Index(type: IndexType.value)
  String petType = '';       // 'dog' | 'cat'
 
  String petName = '';
  String? petAge;
  String? petSex;
  String vaccine = '';
  String? observations;
  String? photoUrl;
  double? latitude;
  double? longitude;
  DateTime vaccinatedAt = DateTime.now();
 
  @Index(type: IndexType.value)
  String sectorId = '';
 
  @Index(type: IndexType.value)
  String vaccinatorId = '';
 
  @Index(type: IndexType.value)
  bool isSynced = false;
 
  DateTime createdAt = DateTime.now();
 
  /// Convierte el modelo Isar a entidad del dominio.
  VaccinationEntity toEntity() => VaccinationEntity(
    id: remoteId,
    localId: localId,
    ownerName: ownerName,
    ownerCedula: ownerCedula,
    ownerPhone: ownerPhone,
    petType: petType,
    petName: petName,
    petAge: petAge,
    petSex: petSex,
    vaccine: vaccine,
    observations: observations,
    photoUrl: photoUrl,
    latitude: latitude,
    longitude: longitude,
    vaccinatedAt: vaccinatedAt,
    sectorId: sectorId,
    vaccinatorId: vaccinatorId,
    isSynced: isSynced,
  );
 
  /// Crea modelo desde JSON de Supabase
  static VaccinationModel fromSupabaseJson(Map<String, dynamic> json) {
    final model = VaccinationModel();
    model.remoteId = json['id'] as String?;
    model.localId = json['local_id'] as String? ?? json['id'] as String? ?? '';
    model.ownerName = json['owner_name'] as String? ?? '';
    model.ownerCedula = json['owner_cedula'] as String? ?? '';
    model.ownerPhone = json['owner_phone'] as String? ?? '';
    model.petType = json['pet_type'] as String? ?? '';
    model.petName = json['pet_name'] as String? ?? '';
    model.petAge = json['pet_age'] as String?;
    model.petSex = json['pet_sex'] as String?;
    model.vaccine = json['vaccine'] as String? ?? '';
    model.observations = json['observations'] as String?;
    model.photoUrl = json['photo_url'] as String?;
    model.latitude = json['latitude'] as double?;
    model.longitude = json['longitude'] as double?;
    model.vaccinatedAt = DateTime.parse(json['vaccinated_at'] as String);
    model.sectorId = json['sector_id'] as String? ?? '';
    model.vaccinatorId = json['vaccinator_id'] as String? ?? '';
    model.isSynced = true;
    return model;
  }
 
  /// Crea modelo desde entidad del dominio (para guardar offline)
  static VaccinationModel fromEntity(VaccinationEntity entity) {
    final model = VaccinationModel();
    model.remoteId = entity.id;
    model.localId = entity.localId ?? '';
    model.ownerName = entity.ownerName;
    model.ownerCedula = entity.ownerCedula;
    model.ownerPhone = entity.ownerPhone;
    model.petType = entity.petType;
    model.petName = entity.petName;
    model.petAge = entity.petAge;
    model.petSex = entity.petSex;
    model.vaccine = entity.vaccine;
    model.observations = entity.observations;
    model.photoUrl = entity.photoUrl;
    model.latitude = entity.latitude;
    model.longitude = entity.longitude;
    model.vaccinatedAt = entity.vaccinatedAt;
    model.sectorId = entity.sectorId;
    model.vaccinatorId = entity.vaccinatorId;
    model.isSynced = entity.isSynced;
    return model;
  }
 
  /// Convierte a JSON para enviar a Supabase
  Map<String, dynamic> toSupabaseJson() => {
    if (remoteId != null) 'id': remoteId,
    'local_id': localId,
    'owner_name': ownerName,
    'owner_cedula': ownerCedula,
    'owner_phone': ownerPhone,
    'pet_type': petType,
    'pet_name': petName,
    'pet_age': petAge,
    'pet_sex': petSex,
    'vaccine': vaccine,
    'observations': observations,
    'photo_url': photoUrl,
    'latitude': latitude,
    'longitude': longitude,
    'vaccinated_at': vaccinatedAt.toIso8601String(),
    'sector_id': sectorId,
    'vaccinator_id': vaccinatorId,
  };
}