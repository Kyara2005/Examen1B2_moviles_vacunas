import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'change_password_screen.dart';
import 'dashboard_screen.dart';
import 'recovery_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  // Inicia sesion con Supabase Auth.
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final usuario = await AuthService().login(
        _correoController.text.trim(),
        _claveController.text,
      );

      if (!mounted) return;
      final pantalla = usuario.debeCambiarClave
          ? ChangePasswordScreen(usuario: usuario)
          : DashboardScreen(usuario: usuario);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pantalla),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pets, size: 70, color: Colors.green),
                const SizedBox(height: 12),
                Text(
                  'Campaña de Vacunación',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese el correo'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _claveController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese la clave'
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const CircularProgressIndicator()
                        : const Text('Ingresar'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecoveryScreen()),
                    );
                  },
                  child: const Text('Recuperar contraseña'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
