import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/sector.dart';
import '../models/vacunaciones.dart';
import '../services/sector_service.dart';
import '../services/vaccination_service.dart';

class VacunacionesFormScreen extends StatefulWidget {
  final AppUser usuario;

  const VacunacionesFormScreen({super.key, required this.usuario});

  @override
  State<VacunacionesFormScreen> createState() => _VacunacionesFormScreenState();
}

class _VacunacionesFormScreenState extends State<VacunacionesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propietarioController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _nombreMascotaController = TextEditingController();
  final _edadController = TextEditingController();
  final _vacunaController = TextEditingController(text: 'Antirrabica');
  final _observacionesController = TextEditingController();

  String _tipoMascota = 'Perro';
  String _sexo = 'Macho';
  String? _sectorId;
  File? _foto;
  double? _latitud;
  double? _longitud;
  bool _cargando = false;
  List<Sector> _sectores = [];

  @override
  void initState() {
    super.initState();
    _cargarSectores();
    _obtenerUbicacion();
  }

  // Obtiene los sectores asignados al vacunador.
  Future<void> _cargarSectores() async {
    final sectores = await SectorService().obtenerSectoresAsignados(
      widget.usuario.id,
    );
    setState(() {
      _sectores = sectores;
      _sectorId = sectores.isNotEmpty
          ? sectores.first.id
          : widget.usuario.sectorId;
    });
  }

  // Obtiene la ubicacion actual del dispositivo.
  Future<void> _obtenerUbicacion() async {
    final permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return;
    }

    final posicion = await Geolocator.getCurrentPosition();
    setState(() {
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
    });
  }

  // Toma una fotografia con la camara.
  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);
    if (imagen != null) {
      setState(() => _foto = File(imagen.path));
    }
  }

  // Guarda una nueva vacunacion.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sectorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un sector')));
      return;
    }

    setState(() => _cargando = true);

    final ahora = DateTime.now();
    final vacunacion = Vacunaciones(
      propietario: _propietarioController.text,
      cedula: _cedulaController.text,
      telefono: _telefonoController.text,
      tipoMascota: _tipoMascota,
      nombreMascota: _nombreMascotaController.text,
      edadAproximada: _edadController.text,
      sexo: _sexo,
      vacuna: _vacunaController.text,
      observaciones: _observacionesController.text,
      latitud: _latitud,
      longitud: _longitud,
      fecha: ahora.toIso8601String().substring(0, 10),
      hora: '${ahora.hour}:${ahora.minute.toString().padLeft(2, '0')}',
      usuarioId: widget.usuario.id,
      sectorId: _sectorId!,
    );

    try {
      await VaccinationService().guardarVacunacion(vacunacion, _foto);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registro guardado')));
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Registro de vacunacion')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campo(_propietarioController, 'Nombre del propietario'),
            _campo(_cedulaController, 'Cedula'),
            _campo(_telefonoController, 'Telefono'),
            DropdownButtonFormField<String>(
              initialValue: _tipoMascota,
              decoration: const InputDecoration(labelText: 'Tipo de mascota'),
              items: const [
                DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                DropdownMenuItem(value: 'Gato', child: Text('Gato')),
              ],
              onChanged: (value) => setState(() => _tipoMascota = value!),
            ),
            const SizedBox(height: 12),
            _campo(_nombreMascotaController, 'Nombre de la mascota'),
            _campo(_edadController, 'Edad aproximada'),
            DropdownButtonFormField<String>(
              initialValue: _sexo,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const [
                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
              ],
              onChanged: (value) => setState(() => _sexo = value!),
            ),
            const SizedBox(height: 12),
            _campo(_vacunaController, 'Vacuna aplicada'),
            _campo(_observacionesController, 'Observaciones', requerido: false),
            DropdownButtonFormField<String>(
              initialValue: _sectorId,
              decoration: const InputDecoration(labelText: 'Sector'),
              items: _sectores.map((sector) {
                return DropdownMenuItem(
                  value: sector.id,
                  child: Text(sector.nombre),
                );
              }).toList(),
              onChanged: (value) => setState(() => _sectorId = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(
                _latitud == null
                    ? 'GPS no capturado'
                    : 'GPS: $_latitud, $_longitud',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _obtenerUbicacion,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_foto == null ? 'Tomar fotografia' : 'Cambiar foto'),
            ),
            if (_foto != null) Image.file(_foto!, height: 160),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _cargando ? null : _guardar,
              child: _cargando
                  ? const CircularProgressIndicator()
                  : const Text('Guardar vacunacion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    bool requerido = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (requerido && (value == null || value.isEmpty)) {
            return 'Campo requerido';
          }
          return null;
        },
      ),
    );
  }
}
