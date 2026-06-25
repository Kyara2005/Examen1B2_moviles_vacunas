// lib/features/vaccinations/domain/repositories/vaccination_repository.dart
// ============================================================
 
abstract class VaccinationRepository {
  Future<Either<Failure, List<VaccinationEntity>>> getVaccinationsBySector(String sectorId);
  Future<Either<Failure, VaccinationEntity>> createVaccination(VaccinationEntity vaccination);
  Future<Either<Failure, VaccinationEntity>> updateVaccination(VaccinationEntity vaccination);
  Future<Either<Failure, int>> syncPendingVaccinations();
  Future<Either<Failure, int>> getUnsyncedCount();
}