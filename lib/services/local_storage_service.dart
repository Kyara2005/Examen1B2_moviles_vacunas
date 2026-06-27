import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vacunaciones.dart';
import '../models/app_user.dart';


class LocalStorageService {
  static const String _clavePendientes = 'vacunaciones_pendientes';
  static const String _claveUsuario = 'usuario_sesion';

  // Guarda una vacunacion pendiente en el telefono.
  Future<void> guardarVacunacionPendiente(Vacunaciones vacunacion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];
    lista.add(jsonEncode(vacunacion.toMap()));
    await prefs.setStringList(_clavePendientes, lista);
  }

  // Devuelve todos los registros que aun no se han subido a Supabase.
  Future<List<Vacunaciones>> obtenerPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];
    return lista.map((texto) => Vacunaciones.fromMap(jsonDecode(texto))).toList();
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

  // ─── SESION DE USUARIO ────────────────────────────────────────────────────

  // Guarda los datos del usuario en el telefono despues del login exitoso.
  // Esto permite abrir la app sin internet y no tener que iniciar sesion de nuevo.
  Future<void> guardarSesion(AppUser usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUsuario, jsonEncode(usuario.toMap()));
  }

  // Devuelve el usuario guardado en el telefono, o null si no hay sesion.
  Future<AppUser?> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_claveUsuario);
    if (texto == null) return null;
    return AppUser.fromMap(jsonDecode(texto));
  }

  // Borra la sesion guardada cuando el usuario cierra sesion manualmente.
  Future<void> borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveUsuario);
  }
}