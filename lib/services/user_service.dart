import '../constants/app_constants.dart';
import '../models/app_user.dart';
import 'supabase_service.dart';

class UserService {
  final _client = SupabaseService().client;

  // Obtiene usuarios por rol.
  Future<List<AppUser>> obtenerUsuarios({String? rol}) async {
    var consulta = _client.from('usuarios').select();
    if (rol != null) {
      final data = await consulta.eq('rol', rol).order('apellidos');
      return data.map<AppUser>((item) => AppUser.fromMap(item)).toList();
    }

    final data = await consulta.order('apellidos');
    return data.map<AppUser>((item) => AppUser.fromMap(item)).toList();
  }

  // Crea el usuario en Auth y tambien en la tabla usuarios.
  Future<void> crearUsuario({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String rol,
    String? sectorId,
  }) async {
    final respuesta = await _client.auth.signUp(
      email: correo,
      password: AppConstants.claveInicial,
    );

    final usuarioAuth = respuesta.user;
    if (usuarioAuth == null) {
      throw Exception('No se pudo crear el usuario');
    }

    await _client.from('usuarios').insert({
      'id': usuarioAuth.id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'rol': rol,
      'sector_id': sectorId,
      'debe_cambiar_clave': true,
    });
  }

  // Actualiza los datos basicos y el sector del usuario.
  Future<void> actualizarUsuario(AppUser usuario) async {
    await _client.from('usuarios').update(usuario.toMap()).eq('id', usuario.id);
  }

  // Elimina el usuario de la tabla. En Auth se elimina desde Supabase.
  Future<void> eliminarUsuario(String id) async {
    await _client.from('usuarios').delete().eq('id', id);
  }
}
