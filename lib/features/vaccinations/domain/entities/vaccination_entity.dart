// --- lib/features/vaccinations/domain/entities/vaccination_entity.dart ---
 
import 'package:equatable/equatable.dart';
 
class VaccinationEntity extends Equatable {
  final String? id;
  final String? localId;
  final String ownerName;
  final String ownerCedula;
  final String ownerPhone;
  final String petType;       // 'dog' | 'cat'
  final String petName;
  final String? petAge;
  final String? petSex;       // 'male' | 'female'
  final String vaccine;
  final String? observations;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime vaccinatedAt;
  final String sectorId;
  final String vaccinatorId;
  final bool isSynced;
 
  const VaccinationEntity({
    this.id,
    this.localId,
    required this.ownerName,
    required this.ownerCedula,
    required this.ownerPhone,
    required this.petType,
    required this.petName,
    this.petAge,
    this.petSex,
    required this.vaccine,
    this.observations,
    this.photoUrl,
    this.latitude,
    this.longitude,
    required this.vaccinatedAt,
    required this.sectorId,
    required this.vaccinatorId,
    this.isSynced = false,
  });
 
  bool get isDog => petType == 'dog';
  bool get isCat => petType == 'cat';
 
  @override
  List<Object?> get props => [id, localId, ownerCedula, petName];
}