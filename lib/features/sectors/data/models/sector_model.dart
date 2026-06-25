// lib/features/sectors/data/models/sector_model.dart (Isar)
import 'package:isar/isar.dart';
part 'sector_model.g.dart';
 
@Collection()
class SectorModel {
  Id isarId = Isar.autoIncrement;
 
  @Index(type: IndexType.value)
  String? remoteId;
 
  String name = '';
  String? description;
  bool isActive = true;
  String createdBy = '';
  DateTime? createdAt;
 
  SectorEntity toEntity() => SectorEntity(
    id: remoteId,
    name: name,
    description: description,
    isActive: isActive,
    createdBy: createdBy,
    createdAt: createdAt,
  );
 
  static SectorModel fromJson(Map<String, dynamic> json) {
    final model = SectorModel();
    model.remoteId = json['id'] as String?;
    model.name = json['name'] as String? ?? '';
    model.description = json['description'] as String?;
    model.isActive = json['is_active'] as bool? ?? true;
    model.createdBy = json['created_by'] as String? ?? '';
    model.createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
    return model;
  }
}