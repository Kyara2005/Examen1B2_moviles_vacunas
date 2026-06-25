import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio centralizado para acceso a Supabase.
/// Evita inyectar SupabaseClient en todos lados.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  GotrueClient get auth => client.auth;
  PostgrestClient get db => client.from;

  // Getters de conveniencia
  User? get currentUser => auth.currentUser;
  String? get currentUserId => currentUser?.id;
  String? get currentUserEmail => currentUser?.email;

  bool get isAuthenticated => currentUser != null;

  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateStream => auth.onAuthStateChange;
}
