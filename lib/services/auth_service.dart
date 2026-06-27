import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';
import 'local_storage_service.dart';


class AuthService {
  final SupabaseClient _client = SupabaseService().client;
  final _localStorage = LocalStorageService();

  Future<AppUser> login(String correo, String clave) async {
    final respuesta = await _client.auth.signInWithPassword(
      email: correo,
      password: clave,
    );

    final usuarioAuth = respuesta.user;
    if (usuarioAuth == null) {
      throw Exception('No se pudo iniciar sesion');
    }

    final usuario = await obtenerUsuarioActual();

    // Guardar la sesion para funcionar sin internet
    await _localStorage.guardarSesion(usuario);

    return usuario;
  }

  Future<AppUser> obtenerUsuarioActual() async {
    final usuarioAuth = _client.auth.currentUser;
    if (usuarioAuth == null) {
      throw Exception('No existe usuario autenticado');
    }

    final data = await _client
        .from('usuarios')
        .select()
        .eq('id', usuarioAuth.id)
        .single();

    return AppUser.fromMap(data);
  }

  Future<AppUser?> obtenerSesionLocal() async {
    return _localStorage.obtenerSesion();
  }

  Future<void> cambiarClave(String nuevaClave) async {
    final usuarioAuth = _client.auth.currentUser;
    if (usuarioAuth == null) return;

    await _client.auth.updateUser(UserAttributes(password: nuevaClave));
    await _client
        .from('usuarios')
        .update({'debe_cambiar_clave': false})
        .eq('id', usuarioAuth.id);
  }

  Future<void> recuperarClave(String correo) async {
    await _client.auth.resetPasswordForEmail(correo);
  }

  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
    await _localStorage.borrarSesion();
  }
}
