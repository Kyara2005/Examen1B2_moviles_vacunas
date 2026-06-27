import '../models/sector.dart';
import 'supabase_service.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';

class SectorService {
  final _client = SupabaseService().client;
  final _localStorage = LocalStorageService();
  final _connectivity = ConnectivityService();

  Future<List<Sector>> obtenerSectores() async {
    final data = await _client.from('sectores').select().order('nombre');
    return data.map<Sector>((item) => Sector.fromMap(item)).toList();
  }

  Future<List<Sector>> obtenerSectoresAsignados(String usuarioId) async {
    final hayInternet = await _connectivity.tieneInternet();

    if (!hayInternet) {
      final sectoresGuardados = await _localStorage.obtenerSectoresGuardados();
      return sectoresGuardados;
    }

    final usuario = await _client
        .from('usuarios')
        .select('sector_id')
        .eq('id', usuarioId)
        .single();

    final sectorId = usuario['sector_id'];
    if (sectorId == null) return [];

    final data = await _client.from('sectores').select().eq('id', sectorId);
    final sectores = data.map<Sector>((item) => Sector.fromMap(item)).toList();

    await _localStorage.guardarSectores(sectores);

    return sectores;
  }

  Future<void> crearSector(String nombre, String descripcion) async {
    await _client.from('sectores').insert({
      'nombre': nombre,
      'descripcion': descripcion,
    });
  }

  Future<void> actualizarSector(
    String id,
    String nombre,
    String descripcion,
    String? coordinadorId,
  ) async {
    await _client
        .from('sectores')
        .update({
          'nombre': nombre,
          'descripcion': descripcion,
          'coordinador_id': coordinadorId,
        })
        .eq('id', id);
  }

  Future<void> eliminarSector(String id) async {
    await _client.from('sectores').delete().eq('id', id);
  }
}
