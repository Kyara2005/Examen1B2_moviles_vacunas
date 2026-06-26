import '../models/app_user.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class DashboardService {
  final _client = SupabaseService().client;
  final _localStorageService = LocalStorageService();

  // Calcula los datos del dashboard de forma sencilla.
  Future<Map<String, dynamic>> obtenerDatos(AppUser usuario) async {
    var consulta = _client.from('vacunaciones').select();

    if (usuario.rol == 'vacunador') {
      consulta = consulta.eq('usuario_id', usuario.id);
    }

    if (usuario.rol == 'coordinador_brigada' && usuario.sectorId != null) {
      consulta = consulta.eq('sector_id', usuario.sectorId!);
    }

    final data = await consulta;
    final pendientes = await _localStorageService.contarPendientes();

    final perros = data.where((item) => item['tipo_mascota'] == 'Perro').length;
    final gatos = data.where((item) => item['tipo_mascota'] == 'Gato').length;

    final porSector = <String, int>{};
    final porVacunador = <String, int>{};

    for (final item in data) {
      final sector = item['sector_id'].toString();
      final vacunador = item['usuario_id'].toString();
      porSector[sector] = (porSector[sector] ?? 0) + 1;
      porVacunador[vacunador] = (porVacunador[vacunador] ?? 0) + 1;
    }

    return {
      'total': data.length,
      'perros': perros,
      'gatos': gatos,
      'porSector': porSector,
      'porVacunador': porVacunador,
      'pendientes': pendientes,
    };
  }
}
