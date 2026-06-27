import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/vacunaciones.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

class VaccinationService {
  final SupabaseClient _client = SupabaseService().client;
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<Vacunaciones>> obtenerVacunaciones(AppUser usuario) async {
    var consulta = _client.from('vacunaciones').select();

    if (usuario.rol == 'vacunador') {
      final data = await consulta
          .eq('usuario_id', usuario.id)
          .order('fecha', ascending: false);
      return data
          .map<Vacunaciones>((item) => Vacunaciones.fromMap(item))
          .toList();
    }

    if (usuario.rol == 'coordinador_brigada' && usuario.sectorId != null) {
      final data = await consulta
          .eq('sector_id', usuario.sectorId!)
          .order('fecha', ascending: false);
      return data
          .map<Vacunaciones>((item) => Vacunaciones.fromMap(item))
          .toList();
    }

    final data = await consulta.order('fecha', ascending: false);
    return data.map<Vacunaciones>((item) => Vacunaciones.fromMap(item)).toList();
  }

  Future<void> guardarVacunacion(Vacunaciones vacunacion, File? foto) async {
    final tieneInternet = await _connectivityService.tieneInternet();

    if (!tieneInternet) {
      await _localStorageService.guardarVacunacionPendiente(
        Vacunaciones.fromMap({...vacunacion.toMap(), 'sincronizado': false}),
      );
      return;
    }

    String? imagenUrl = vacunacion.imagenUrl;
    if (foto != null) {
      imagenUrl = await subirFotografia(foto);
    }

    await _client.from('vacunaciones').insert({
      ...vacunacion.toMap(),
      'imagen_url': imagenUrl,
      'sincronizado': true,
    });
  }

  Future<void> actualizarVacunacion(Vacunaciones vacunacion) async {
    await _client
        .from('vacunaciones')
        .update(vacunacion.toMap())
        .eq('id', vacunacion.id!);
  }

  Future<void> eliminarVacunacion(String id) async {
    await _client.from('vacunaciones').delete().eq('id', id);
  }

  Future<String> subirFotografia(File foto) async {
    final nombreArchivo = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage
        .from(AppConstants.bucketVacunaciones)
        .upload(nombreArchivo, foto);

    return _client.storage
        .from(AppConstants.bucketVacunaciones)
        .getPublicUrl(nombreArchivo);
  }
}
