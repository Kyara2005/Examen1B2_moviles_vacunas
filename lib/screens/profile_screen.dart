import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser usuario;

  const ProfileScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      drawer: AppDrawer(usuario: usuario),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
          const SizedBox(height: 16),
          ListTile(title: const Text('Cedula'), subtitle: Text(usuario.cedula)),
          ListTile(
            title: const Text('Nombres'),
            subtitle: Text(usuario.nombres),
          ),
          ListTile(
            title: const Text('Apellidos'),
            subtitle: Text(usuario.apellidos),
          ),
          ListTile(
            title: const Text('Telefono'),
            subtitle: Text(usuario.telefono),
          ),
          ListTile(title: const Text('Correo'), subtitle: Text(usuario.correo)),
          ListTile(title: const Text('Rol'), subtitle: Text(usuario.rol)),
        ],
      ),
    );
  }
}
