import '../models/app_user.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class DashboardService {
  final _client = SupabaseService().client;
  final _localStorageService = LocalStorageService();

  // Calcula los datos del dashboard con nombres reales
  Future<Map<String, dynamic>> obtenerDatos(AppUser usuario) async {
    var consulta = _client.from('vacunaciones').select();

    if (usuario.rol == 'vacunador') {
      consulta = consulta.eq('usuario_id', usuario.id);
    }

    if (usuario.rol == 'coordinador_brigada' && usuario.sectorId != null) {
      consulta = consulta.eq('sector_id', usuario.sectorId!);
    }

    final vacunaciones = await consulta;
    // Paso 2: obtener los nombres de todos los sectores en un solo llamado
    final sectoresData = await _client.from('sectores').select('id, nombre');

    // Convertir la lista de sectores a un mapa id -> nombre para buscar rapido
    final nombresSectores = <String, String>{
      for (final s in sectoresData) s['id'].toString(): s['nombre'] as String,
    };
    // Paso 3: obtener los nombres de todos los usuarios en un solo llamado
    final usuariosData = await _client
        .from('usuarios')
        .select('id, nombres, apellidos');

    // Convertir la lista de usuarios a un mapa id -> nombre completo
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
      // Usar el nombre del sector; si no se encuentra, mostrar "Sector desconocido"
      final nombreSector =
          nombresSectores[sectorId] ?? 'Sector desconocido';

      // Usar el nombre del vacunador; si no se encuentra, mostrar "Usuario desconocido"
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
