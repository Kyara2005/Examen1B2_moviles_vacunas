// ============================================================
// lib/features/auth/data/datasources/auth_remote_datasource.dart
// ============================================================
 
import 'package:supabase_flutter/supabase_flutter.dart';
 
class AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSource(this._client);
 
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
 
      if (response.user == null) {
        throw const AuthException(message: 'Credenciales incorrectas');
      }
 
      // Obtener perfil de app_users
      final profile = await _client
          .from('app_users')
          .select()
          .eq('auth_user_id', response.user!.id)
          .single();
 
      return UserModel.fromJson(profile);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
 
  Future<void> logout() async {
    await _client.auth.signOut();
  }
 
  Future<void> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
 
      // Marcar que ya no debe cambiar contraseña
      final userId = _client.auth.currentUser!.id;
      await _client
          .from('app_users')
          .update({'must_change_password': false})
          .eq('auth_user_id', userId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
 
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.vacunacioncanina://login-callback',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
 
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
 
    final profile = await _client
        .from('app_users')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();
 
    if (profile == null) return null;
    return UserModel.fromJson(profile);
  }
}