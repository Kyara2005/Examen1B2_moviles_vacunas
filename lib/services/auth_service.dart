import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService().client;

  // Inicia sesion y obtiene los datos del usuario.
  Future<AppUser> login(String correo, String clave) async {
    final respuesta = await _client.auth.signInWithPassword(
      email: correo,
      password: clave,
    );

    final usuarioAuth = respuesta.user;
    if (usuarioAuth == null) {
      throw Exception('No se pudo iniciar sesion');
    }

    return obtenerUsuarioActual();
  }

  // Obtiene el usuario actual desde la tabla usuarios.
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

  // Cambia la clave del usuario autenticado.
  Future<void> cambiarClave(String nuevaClave) async {
    final usuarioAuth = _client.auth.currentUser;
    if (usuarioAuth == null) return;

    await _client.auth.updateUser(UserAttributes(password: nuevaClave));
    await _client
        .from('usuarios')
        .update({'debe_cambiar_clave': false})
        .eq('id', usuarioAuth.id);
  }

  // Envia el correo para recuperar la contrasena.
  Future<void> recuperarClave(String correo) async {
    await _client.auth.resetPasswordForEmail(correo);
  }

  // Cierra la sesion.
  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }
}
