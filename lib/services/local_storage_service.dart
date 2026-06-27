import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vacunaciones.dart';
import '../models/app_user.dart';
import '../models/sector.dart';


class LocalStorageService {
  static const String _clavePendientes = 'vacunaciones_pendientes';
  static const String _claveUsuario = 'usuario_sesion';
  static const String _claveSectores = 'sectores_guardados';

  Future<void> guardarVacunacionPendiente(Vacunaciones vacunacion) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];
    lista.add(jsonEncode(vacunacion.toMap()));
    await prefs.setStringList(_clavePendientes, lista);
  }

  Future<List<Vacunaciones>> obtenerPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clavePendientes) ?? [];
    return lista.map((texto) => Vacunaciones.fromMap(jsonDecode(texto))).toList();
  }

  Future<void> limpiarPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clavePendientes);
  }

  Future<int> contarPendientes() async {
    return (await obtenerPendientes()).length;
  }

  // ─── SESION DE USUARIO ────────────────────────────────────────────────────

  Future<void> guardarSesion(AppUser usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveUsuario, jsonEncode(usuario.toMap()));
  }

  Future<AppUser?> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_claveUsuario);
    if (texto == null) return null;
    return AppUser.fromMap(jsonDecode(texto));
  }

  Future<void> borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveUsuario);
  }

  Future<void> guardarSectores(List<Sector> sectores) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = sectores.map((sector) => jsonEncode(sector.toMap())).toList();
    await prefs.setStringList(_claveSectores, lista);
  }

  Future<List<Sector>> obtenerSectoresGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_claveSectores) ?? [];
    return lista.map((texto) => Sector.fromMap(jsonDecode(texto))).toList();
  }
}