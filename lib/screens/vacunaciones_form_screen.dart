import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/sector.dart';
import '../models/vacunaciones.dart';
import '../screens/dashboard_screen.dart';
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
  bool _cargandoSectores = true;
  bool _cargandoGps = true;
  List<Sector> _sectores = [];

  @override
  void initState() {
    super.initState();
    _cargarSectores();
    _obtenerUbicacion();
  }

  @override
  void dispose() {
    _propietarioController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _nombreMascotaController.dispose();
    _edadController.dispose();
    _vacunaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarSectores() async {
    try {
      final sectores = await SectorService().obtenerSectoresAsignados(
        widget.usuario.id,
      );
      if (!mounted) return;
      setState(() {
        _sectores = sectores;
        if (sectores.isNotEmpty) {
          _sectorId = sectores.first.id;
        } else if (widget.usuario.sectorId != null) {
          _sectorId = widget.usuario.sectorId;
        }
        _cargandoSectores = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoSectores = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando sectores: $e')),
      );
    }
  }

  // Obtiene la ubicacion actual del dispositivo.
  Future<void> _obtenerUbicacion() async {
    setState(() => _cargandoGps = true);
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Active el GPS del dispositivo e intente de nuevo'),
          ),
        );
        setState(() => _cargandoGps = false);
        return;
      }
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permiso de ubicacion denegado permanentemente. '
              'Activelo en Configuracion > Aplicaciones.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _cargandoGps = false);
        return;
      }

      if (permiso == LocationPermission.denied) {
        setState(() => _cargandoGps = false);
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
 
      if (!mounted) return;
      setState(() {
        _latitud = posicion.latitude;
        _longitud = posicion.longitude;
        _cargandoGps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoGps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener GPS: $e')),
      );
    }
  }

  // Toma una fotografia.
  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera,imageQuality: 70,);
    if (imagen != null) {
      setState(() => _foto = File(imagen.path));
    }
  }

  // Guarda una vacuna.
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(usuario: widget.usuario),
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

  void _volverAlDashboard() {
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
      appBar: AppBar(title: const Text('Registro de vacunacion'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _volverAlDashboard,
          ),
      ),
      
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
            const SizedBox(height: 12),
            if (_cargandoSectores)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Cargando sectores...'),
                    ],
                  ),
                )
              else if (_sectores.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No tiene sectores asignados. Contacte al coordinador.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else
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
                  validator: (value) =>
                    value == null ? 'Seleccione un sector' : null,
                ),

            // GPS y fotografia
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: _cargandoGps
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _latitud != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _latitud != null ? Colors.green : Colors.grey,
                      ),
                title: Text(
                  _cargandoGps
                      ? 'Obteniendo GPS...'
                      : _latitud == null
                          ? 'GPS no capturado'
                          : 'GPS capturado',
                ),
                subtitle: _latitud != null
                    ? Text(
                        '${_latitud!.toStringAsFixed(6)}, '
                        '${_longitud!.toStringAsFixed(6)}',
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reintentar GPS',
                  onPressed: _cargandoGps ? null : _obtenerUbicacion,
                ),
              ),
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_foto == null ? 'Tomar fotografia' : 'Cambiar foto'),
            ),
            if (_foto != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_foto!, height: 160, fit: BoxFit.cover),
              ),
            ],
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
