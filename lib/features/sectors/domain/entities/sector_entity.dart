// lib/features/sectors/domain/entities/sector_entity.dart
import 'package:equatable/equatable.dart';
 
class SectorEntity extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;
 
  const SectorEntity({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
  });
 
  @override
  List<Object?> get props => [id, name];
}