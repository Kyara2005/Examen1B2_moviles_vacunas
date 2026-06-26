import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sectors_screen.dart';
import '../screens/users_screen.dart';
import '../screens/vacunaciones_form_screen.dart';
import '../screens/vacunaciones_screen.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final AppUser usuario;

  const AppDrawer({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario.nombreCompleto),
            accountEmail: Text(usuario.correo),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => _abrir(context, DashboardScreen(usuario: usuario)),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Vacunaciones'),
            onTap: () => _abrir(context, VacunacionesScreen(usuario: usuario)),
          ),
          if (usuario.rol == 'vacunador')
            ListTile(
              leading: const Icon(Icons.add_a_photo),
              title: const Text('Registrar vacunacion'),
              onTap: () =>
                  _abrir(context, VacunacionesFormScreen(usuario: usuario)),
            ),
          if (usuario.rol == 'coordinador_campana')
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Sectores'),
              onTap: () => _abrir(context, SectorsScreen(usuario: usuario)),
            ),
          if (usuario.rol == 'coordinador_campana' ||
              usuario.rol == 'coordinador_brigada')
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Usuarios'),
              onTap: () => _abrir(context, UsersScreen(usuario: usuario)),
            ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            onTap: () => _abrir(context, ProfileScreen(usuario: usuario)),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesion'),
            onTap: () async {
              await AuthService().cerrarSesion();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Abre una pantalla desde el menu lateral.
  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }
}
