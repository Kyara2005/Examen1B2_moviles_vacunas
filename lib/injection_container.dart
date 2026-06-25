// ============================================================
// lib/injection_container.dart
// ============================================================
 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
import 'core/services/connectivity_service.dart';
 
// Providers de infraestructura
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());
 
// Inicialización de dependencias
Future<void> setupInjection(Isar isar) async {
  // La Isar instance se inyecta via ProviderScope override en main.dart
  // Ver: ProviderScope(overrides: [isarProvider.overrideWithValue(isar)])
}