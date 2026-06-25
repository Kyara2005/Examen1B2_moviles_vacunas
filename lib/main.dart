import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/dashboard/presentation/screens/vaccinator_dashboard_simple.dart';
import 'features/dashboard/presentation/screens/brigade_coordinator_dashboard.dart';
import 'features/dashboard/presentation/screens/campaign_coordinator_dashboard.dart';
import 'features/vaccinations/presentation/screens/vaccination_form_screen_full.dart';
import 'features/vaccinations/presentation/screens/vaccinations_list_screen.dart';
import 'features/users/presentation/screens/users_management_screen.dart';
import 'features/sectors/presentation/screens/sectors_list_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  // IMPORTANTE: Actualiza con tus credenciales
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://your-supabase-url.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'your-anon-key'),
    );
  } catch (e) {
    debugPrint('Error inicializando Supabase: $e');
    // Continuar de todas formas con modo sin conexión
  }

  // Inicializar servicio de auth
  final authService = AuthService();
  await authService.init();

  runApp(const SimpleApp());
}

class SimpleApp extends StatefulWidget {
  const SimpleApp({super.key});

  @override
  State<SimpleApp> createState() => _SimpleAppState();
}

class _SimpleAppState extends State<SimpleApp> {
  late final AuthService _authService;
  late final Stream<AuthUser?> _authStream;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _authStream = _authService.authStateStream;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campaña de Vacunación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: StreamBuilder<AuthUser?>(
        stream: _authStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }

          if (user.mustChangePassword) {
            return const ChangePasswordScreen();
          }

          return const AppNavigator();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/dashboard': (context) => const VaccinatorDashboard(),
        '/vaccinations': (context) => const VaccinationsListScreen(),
        '/vaccinations/new': (context) => const VaccinationFormScreenFull(),
        '/users': (context) => const UsersManagementScreen(),
        '/sectors': (context) => const SectorsListScreen(),
      },
    );
  }
}

/// Navegador principal después de autenticación
/// Dirige al usuario al dashboard según su rol
class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    // Dirigir a dashboard según rol
    switch (user?.role) {
      case 'vaccinator':
        return const VaccinatorDashboard();
      case 'brigade_coordinator':
        return const BrigadeCoordinatorDashboard();
      case 'coordinator':
        return const CampaignCoordinatorDashboard();
      default:
        // Por defecto, dashboard de vacunador
        return const VaccinatorDashboard();
    }
  }
}