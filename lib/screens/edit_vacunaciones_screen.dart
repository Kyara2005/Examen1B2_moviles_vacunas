import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/vacunaciones.dart';
import '../services/vaccination_service.dart';

class EditVacunacionesScreen extends StatefulWidget {
  final AppUser usuario;
  final Vacunaciones vacunacion;

  const EditVacunacionesScreen({
    super.key,
    required this.usuario,
    required this.vacunacion,
  });

  @override
  State<EditVacunacionesScreen> createState() => _EditVacunacionesScreenState();
}

class _EditVacunacionesScreenState extends State<EditVacunacionesScreen> {
  late TextEditingController _propietarioController;
  late TextEditingController _telefonoController;
  late TextEditingController _observacionesController;
  late TextEditingController _vacunaController;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _propietarioController = TextEditingController(
      text: widget.vacunacion.propietario,
    );
    _telefonoController = TextEditingController(
      text: widget.vacunacion.telefono,
    );
    _observacionesController = TextEditingController(
      text: widget.vacunacion.observaciones,
    );
    _vacunaController = TextEditingController(text: widget.vacunacion.vacuna);
  }

  @override
  void dispose() {
    _propietarioController.dispose();
    _telefonoController.dispose();
    _observacionesController.dispose();
    _vacunaController.dispose();
    super.dispose();
  }

  // Actualiza.
  Future<void> _actualizar() async {
    setState(() => _cargando = true);

    final actualizada = Vacunaciones.fromMap({
      ...widget.vacunacion.toMap(),
      'propietario': _propietarioController.text,
      'telefono': _telefonoController.text,
      'vacuna': _vacunaController.text,
      'observaciones': _observacionesController.text,
    });

    try {
      await VaccinationService().actualizarVacunacion(actualizada);
      if (mounted) Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Editar vacunacion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mascota: ${widget.vacunacion.nombreMascota}'),
          const SizedBox(height: 12),
          TextField(
            controller: _propietarioController,
            decoration: const InputDecoration(labelText: 'Propietario'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefonoController,
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vacunaController,
            decoration: const InputDecoration(labelText: 'Vacuna'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacionesController,
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _cargando ? null : _actualizar,
            child: _cargando
                ? const CircularProgressIndicator()
                : const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
