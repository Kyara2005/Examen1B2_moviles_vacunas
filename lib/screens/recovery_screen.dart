import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _correoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  // Envia el correo de recuperacion.
  Future<void> _recuperarClave() async {
    setState(() => _cargando = true);
    try {
      await AuthService().recuperarClave(_correoController.text.trim());
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Correo enviado'),
            content: Text('Revise su correo para cambiar la contraseña.'),
          ),
        );
      }
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
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _cargando ? null : _recuperarClave,
              child: _cargando
                  ? const CircularProgressIndicator()
                  : const Text('Enviar correo'),
            ),
          ],
        ),
      ),
    );
  }
}
