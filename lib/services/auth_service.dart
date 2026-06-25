import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Modelo de usuario simplificado para mantener en memoria
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String role; // 'coordinator', 'brigade_coordinator', 'vaccinator'
  final bool mustChangePassword;

  AuthUser({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.mustChangePassword = false,
  });

  factory AuthUser.fromSupabaseUser(User user, {String role = 'vaccinator', bool mustChangePassword = false}) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      role: role,
      mustChangePassword: mustChangePassword,
    );
  }
}

/// Servicio de autenticación simplificado
class AuthService {
  final SupabaseService _supabase = SupabaseService();
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get userRole => _currentUser?.role;

  Future<void> init() async {
    final user = _supabase.currentUser;
    if (user != null) {
      await _loadUserMetadata(user);
    }
  }

  /// Carga metadata del usuario desde Supabase (rol, etc.)
  Future<void> _loadUserMetadata(User user) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select('role, must_change_password')
          .eq('id', user.id)
          .single();

      _currentUser = AuthUser(
        id: user.id,
        email: user.email ?? '',
        name: response['name'] as String?,
        role: response['role'] as String? ?? 'vaccinator',
        mustChangePassword: response['must_change_password'] as bool? ?? false,
      );
    } catch (e) {
      // Si no existe el registro, asignar rol por defecto
      _currentUser = AuthUser(
        id: user.id,
        email: user.email ?? '',
        role: 'vaccinator',
        mustChangePassword: true,
      );
    }
  }

  /// Login con email y contraseña
  Future<AuthUser?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserMetadata(response.user!);
        return _currentUser;
      }
      return null;
    } on AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    }
  }

  /// Cambio de contraseña
  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (_currentUser != null) {
        _currentUser = AuthUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          name: _currentUser!.name,
          role: _currentUser!.role,
          mustChangePassword: false,
        );
      }
    } on AuthException catch (e) {
      throw Exception('Error al cambiar contraseña: ${e.message}');
    }
  }

  /// Recuperación de contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Error al enviar enlace de recuperación: ${e.message}');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  /// Stream de cambios de autenticación
  Stream<AuthUser?> get authStateStream {
    return _supabase.authStateStream.asyncMap((state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
        await _loadUserMetadata(state.session!.user);
        return _currentUser;
      } else if (state.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        return null;
      }
      return _currentUser;
    });
  }
}
