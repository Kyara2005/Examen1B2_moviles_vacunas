import '../models/sector.dart';
import 'supabase_service.dart';

class SectorService {
  final _client = SupabaseService().client;

  // Obtiene todos los sectores.
  Future<List<Sector>> obtenerSectores() async {
    final data = await _client.from('sectores').select().order('nombre');
    return data.map<Sector>((item) => Sector.fromMap(item)).toList();
  }

  // Obtiene solo los sectores asignados al usuario.
  Future<List<Sector>> obtenerSectoresAsignados(String usuarioId) async {
    final usuario = await _client
        .from('usuarios')
        .select('sector_id')
        .eq('id', usuarioId)
        .single();

    final sectorId = usuario['sector_id'];
    if (sectorId == null) return [];

    final data = await _client.from('sectores').select().eq('id', sectorId);
    return data.map<Sector>((item) => Sector.fromMap(item)).toList();
  }

  // Crea un nuevo sector.
  Future<void> crearSector(String nombre, String descripcion) async {
    await _client.from('sectores').insert({
      'nombre': nombre,
      'descripcion': descripcion,
    });
  }

  // Actualiza un sector.
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

  // Elimina un sector.
  Future<void> eliminarSector(String id) async {
    await _client.from('sectores').delete().eq('id', id);
  }
}
