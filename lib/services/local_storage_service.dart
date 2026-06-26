import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vacunaciones.dart';

class LocalStorageService {
  static const String _clavePendientes = 'vacunaciones_pendientes';

  // Guarda una vacunacion pendiente en el telefono.
  Future<void> guardarVacunacionPendiente(Vacunaciones vacunacion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];
    lista.add(jsonEncode(vacunacion.toMap()));
    await prefs.setStringList(_clavePendientes, lista);
  }

  // Obtiene los registros pendientes de sincronizar.
  Future<List<Vacunaciones>> obtenerPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];

    return lista.map((texto) {
      return Vacunaciones.fromMap(jsonDecode(texto));
    }).toList();
  }

  // Limpia los registros pendientes cuando ya se subieron.
  Future<void> limpiarPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clavePendientes);
  }

  // Cuenta cuantos registros faltan por sincronizar.
  Future<int> contarPendientes() async {
    final pendientes = await obtenerPendientes();
    return pendientes.length;
  }
}
