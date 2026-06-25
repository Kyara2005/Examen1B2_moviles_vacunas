// lib/features/dashboard/domain/entities/dashboard_stats_entity.dart
import 'package:equatable/equatable.dart';
 
class DashboardStatsEntity extends Equatable {
  final int totalVaccinations;
  final int totalDogs;
  final int totalCats;
  final int pendingSync;
  final Map<String, int> bySector;     // sectorName -> count
  final Map<String, int> byVaccinator; // vaccinatorName -> count
 
  const DashboardStatsEntity({
    required this.totalVaccinations,
    required this.totalDogs,
    required this.totalCats,
    required this.pendingSync,
    required this.bySector,
    required this.byVaccinator,
  });
 
  @override
  List<Object?> get props => [totalVaccinations];
}