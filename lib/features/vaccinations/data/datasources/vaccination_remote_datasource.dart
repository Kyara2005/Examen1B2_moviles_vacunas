// lib/features/vaccinations/data/datasources/vaccination_remote_datasource.dart
// ============================================================
 
class VaccinationRemoteDataSource {
  final SupabaseClient _client;
  VaccinationRemoteDataSource(this._client);
 
  Future<List<VaccinationModel>> getVaccinationsBySector(String sectorId) async {
    final response = await _client
        .from('vaccinations')
        .select()
        .eq('sector_id', sectorId)
        .order('vaccinated_at', ascending: false);
 
    return (response as List)
        .map((json) => VaccinationModel.fromSupabaseJson(json))
        .toList();
  }
 
  Future<VaccinationModel> createVaccination(Map<String, dynamic> data) async {
    final response = await _client
        .from('vaccinations')
        .insert(data)
        .select()
        .single();
    return VaccinationModel.fromSupabaseJson(response);
  }
 
  Future<VaccinationModel> updateVaccination(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('vaccinations')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return VaccinationModel.fromSupabaseJson(response);
  }
 
  Future<String> uploadPhoto(String filePath, String vaccinationLocalId) async {
    final file = File(filePath);
    final fileName = 'vaccination_${vaccinationLocalId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
 
    await _client.storage
        .from('vaccination-photos')
        .upload(fileName, file);
 
    return _client.storage
        .from('vaccination-photos')
        .getPublicUrl(fileName);
  }
 
  // Estadísticas para el dashboard
  Future<Map<String, dynamic>> getDashboardStats({String? sectorId}) async {
    var query = _client.from('vaccinations').select('pet_type, sector_id, vaccinator_id');
    if (sectorId != null) {
      query = query.eq('sector_id', sectorId) as dynamic;
    }
    final response = await query;
    return {'data': response};
  }
}