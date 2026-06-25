// ============================================================
// lib/core/network/connectivity_service.dart
// ============================================================
 
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
/// Provider que expone el estado de conectividad en tiempo real.
/// Explicación para sustentación:
/// Usamos StreamProvider para que Riverpod observe automáticamente
/// los cambios de conectividad y actualice la UI reactivamente.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
});
 
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
    data: (isOnline) => isOnline,
    orElse: () => false,
  );
});
 
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
 
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
 
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((results) => results.any((r) => r != ConnectivityResult.none));
  }
}