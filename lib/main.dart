import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_constants.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'services/sync_service.dart';
import 'screens/change_password_screen.dart';

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

class VacunacionApp extends StatefulWidget {
  final usuarioInicial;

  const VacunacionApp({super.key, required this.usuarioInicial});

  @override
  State<VacunacionApp> createState() => _VacunacionAppState();
}

class _VacunacionAppState extends State<VacunacionApp> {
  @override
  void initState() {
    super.initState();
    _escucharDeepLinks();
  }

  // Escucha cuando Supabase completa la autenticacion desde el deep link.
  void _escucharDeepLinks() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final evento = data.event;

      if (evento == AuthChangeEvent.passwordRecovery) {
        // El usuario llego desde el link de recuperacion del correo.
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ChangePasswordScreen(usuarioRecuperacion: true),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vacunacion Canina y Felina',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // Si hay sesion guardada vamos al Dashboard; si no, al Login
      home: widget.usuarioInicial != null
          ? DashboardScreen(usuario: widget.usuarioInicial)
          : const LoginScreen(),
    );
  }
}

// Clave global para navegar desde fuera del contexto del widget tree
final navigatorKey = GlobalKey<NavigatorState>();

