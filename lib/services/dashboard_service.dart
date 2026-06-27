import '../models/app_user.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class DashboardService {
  final _client = SupabaseService().client;
  final _localStorageService = LocalStorageService();

  Future<Map<String, dynamic>> obtenerDatos(AppUser usuario) async {
    var consulta = _client.from('vacunaciones').select();

    if (usuario.rol == 'vacunador') {
      consulta = consulta.eq('usuario_id', usuario.id);
    }

    if (usuario.rol == 'coordinador_brigada' && usuario.sectorId != null) {
      consulta = consulta.eq('sector_id', usuario.sectorId!);
    }

    final vacunaciones = await consulta;
    final sectoresData = await _client.from('sectores').select('id, nombre');

    final nombresSectores = <String, String>{
      for (final s in sectoresData) s['id'].toString(): s['nombre'] as String,
    };
    final usuariosData = await _client
        .from('usuarios')
        .select('id, nombres, apellidos');

    final nombresUsuarios = <String, String>{
      for (final u in usuariosData)
        u['id'].toString(): '${u['nombres']} ${u['apellidos']}',
    };


    final pendientes = await _localStorageService.contarPendientes();

    final perros = vacunaciones.where((item) => item['tipo_mascota'] == 'Perro').length;
    final gatos = vacunaciones.where((item) => item['tipo_mascota'] == 'Gato').length;

    final porSector = <String, int>{};
    final porVacunador = <String, int>{};

    for (final item in vacunaciones) {
      final sectorId = item['sector_id'].toString();
      final vacunadorId = item['usuario_id'].toString();
      final nombreSector =
          nombresSectores[sectorId] ?? 'Sector desconocido';

      final nombreVacunador =
          nombresUsuarios[vacunadorId] ?? 'Usuario desconocido';

      porSector[nombreSector] = (porSector[nombreSector] ?? 0) + 1;
      porVacunador[nombreVacunador] =
          (porVacunador[nombreVacunador] ?? 0) + 1;
    }

    return {
      'total': vacunaciones.length,
      'perros': perros,
      'gatos': gatos,
      'porSector': porSector,
      'porVacunador': porVacunador,
      'pendientes': pendientes,
    };
  }
}
