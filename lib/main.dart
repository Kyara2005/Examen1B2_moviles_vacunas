import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_constants.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  // Inicia la sincronizacion automatica cuando vuelve el internet.
  SyncService().iniciarSincronizacionAutomatica();

  // Verificar si hay una sesion guardada localmente antes de mostrar el login
  final usuarioGuardado = await AuthService().obtenerSesionLocal();

  runApp(VacunacionApp(usuarioInicial: usuarioGuardado));
}

class VacunacionApp extends StatelessWidget {
  // Usuario cargado desde el telefono; null si no habia sesion guardada
  // ignore: strict_top_level_inference, prefer_typing_uninitialized_variables
  final usuarioInicial;

  const VacunacionApp({super.key, required this.usuarioInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vacunacion Canina y Felina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: usuarioInicial != null
          ? DashboardScreen(usuario: usuarioInicial)
          : const LoginScreen(),
    );
  }
}
