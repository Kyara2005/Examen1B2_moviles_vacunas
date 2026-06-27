import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> tieneInternet() async {
    final resultados = await _connectivity.checkConnectivity();
    return resultados.any((item) => item != ConnectivityResult.none);
  }

  Stream<bool> escucharConexion() {
    return _connectivity.onConnectivityChanged.map((resultados) {
      return resultados.any((item) => item != ConnectivityResult.none);
    });
  }
}
