// lib/features/vaccinations/data/datasources/vaccination_local_datasource.dart
// ============================================================
 
class VaccinationLocalDataSource {
  final Isar _isar;
  VaccinationLocalDataSource(this._isar);
 
  Future<void> saveVaccination(VaccinationModel model) async {
    await _isar.writeTxn(() async {
      await _isar.vaccinationModels.put(model);
    });
  }
 
  Future<List<VaccinationModel>> getVaccinationsBySector(String sectorId) async {
    return await _isar.vaccinationModels
        .filter()
        .sectorIdEqualTo(sectorId)
        .sortByVaccinatedAtDesc()
        .findAll();
  }
 
  Future<List<VaccinationModel>> getUnsyncedVaccinations() async {
    return await _isar.vaccinationModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }
 
  Future<void> markAsSynced(int isarId, String remoteId) async {
    await _isar.writeTxn(() async {
      final model = await _isar.vaccinationModels.get(isarId);
      if (model != null) {
        model.isSynced = true;
        model.remoteId = remoteId;
        await _isar.vaccinationModels.put(model);
      }
    });
  }
 
  Future<int> getUnsyncedCount() async {
    return await _isar.vaccinationModels
        .filter()
        .isSyncedEqualTo(false)
        .count();
  }
 
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.vaccinationModels.clear();
    });
  }
}