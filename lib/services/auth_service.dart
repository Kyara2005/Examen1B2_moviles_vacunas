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
      throw Exception('Correo o contraseña incorrectos');
    }

    // Si el usuario existe en Auth pero no en la tabla usuarios, mostramos
    // un mensaje claro de error.
    final data = await _client
        .from('usuarios')
        .select()
        .eq('id', usuarioAuth.id)
        .maybeSingle(); // maybeSingle devuelve null si no encuentra, en vez de lanzar excepcion

    if (data == null) {
      // El usuario existe en Auth pero no tiene fila en la tabla usuarios.
      // Esto pasa cuando se crea el usuario directo en Supabase Auth sin
      // insertar el registro en la tabla. Cerramos sesion para no dejar
      // al usuario en un estado inconsistente.
      await _client.auth.signOut();
      throw Exception(
        'El usuario no tiene perfil en el sistema ya que fue registrado desde Auth.'
        'Pida al coordinador que lo registre correctamente.',
      );
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
    await _client.auth.updateUser(UserAttributes(password: nuevaClave));

    // Solo actualizar debe_cambiar_clave si hay un usuario autenticado
    // con perfil en la tabla (en recuperacion puede no haberlo aun cargado)
    final usuarioAuth = _client.auth.currentUser;
    if (usuarioAuth != null) {
      await _client
          .from('usuarios')
          .update({'debe_cambiar_clave': false})
          .eq('id', usuarioAuth.id);

      // Actualizar la sesion local con debe_cambiar_clave en false
      final usuarioActualizado = await obtenerUsuarioActual();
      await _localStorage.guardarSesion(usuarioActualizado);
    }
  }

  Future<void> recuperarClave(String correo) async {
    await _client.auth.resetPasswordForEmail(
      correo,
      redirectTo: 'vacumesticos://reset-password',
    );
  }

  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
    await _localStorage.borrarSesion();
  }
}
