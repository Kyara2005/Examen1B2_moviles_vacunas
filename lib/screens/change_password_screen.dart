import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final AppUser usuario;

  const ChangePasswordScreen({super.key, required this.usuario});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _claveController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _claveController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  // Cambia la contrasena
  Future<void> _cambiarClave() async {
    if (_claveController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La clave debe tener minimo 6 caracteres'),
        ),
      );
      return;
    }

    if (_claveController.text != _confirmarController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Las claves no coinciden')));
      return;
    }

    setState(() => _cargando = true);
    await AuthService().cambiarClave(_claveController.text);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(usuario: widget.usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambio de contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Debe cambiar la contraseña inicial Ecuador2026.'),
            const SizedBox(height: 16),
            TextField(
              controller: _claveController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmarController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _cargando ? null : _cambiarClave,
              child: _cargando
                  ? const CircularProgressIndicator()
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
