import '../models/vacunaciones.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class SyncService {
  final _client = SupabaseService().client;
  final _connectivityService = ConnectivityService();
  final _localStorageService = LocalStorageService();

  void iniciarSincronizacionAutomatica() {
    _connectivityService.escucharConexion().listen((tieneInternet) async {
      if (tieneInternet) {
        await sincronizarPendientes();
      }
    });
  }

  Future<void> sincronizarPendientes() async {
    final pendientes = await _localStorageService.obtenerPendientes();
    if (pendientes.isEmpty) return;

    for (final Vacunaciones vacunacion in pendientes) {
      await _client.from('vacunaciones').insert({
        ...vacunacion.toMap(),
        'sincronizado': true,
      });
    }

    await _localStorageService.limpiarPendientes();
  }
}
