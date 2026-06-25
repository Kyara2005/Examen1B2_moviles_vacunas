import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:examen1b2_flutter/simple/in_memory_vaccinations.dart';
import 'package:examen1b2_flutter/simple/in_memory_sectors.dart';

class VaccinationFormScreenFull extends StatefulWidget {
  const VaccinationFormScreenFull({super.key});

  @override
  State<VaccinationFormScreenFull> createState() => _VaccinationFormScreenFullState();
}

class _VaccinationFormScreenFullState extends State<VaccinationFormScreenFull> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameCtrl = TextEditingController();
  final _ownerCedulaCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _petNameCtrl = TextEditingController();
  final _petAgeCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();

  String _petType = 'dog';
  String _petSex = 'male';
  String? _selectedVaccine;
  String? _selectedSectorId;

  File? _selectedPhoto;
  double? _latitude;
  double? _longitude;
  bool _loadingLocation = false;
  bool _isSubmitting = false;

  final _vaccines = [
    'Antirrábica',
    'Parvovirus',
    'Distemper (Moquillo)',
    'Leptospirosis',
    'Hepatitis Canina',
    'Pentavalente Canina',
    'Séxtuple Canina',
    'Leucemia Felina',
    'Calicivirus Felino',
    'Rinotraqueitis Felina',
    'Panleucopenia Felina',
    'Triple Felina',
  ];

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _ownerCedulaCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _petNameCtrl.dispose();
    _petAgeCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() => _selectedPhoto = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar foto: $e')),
        );
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final permission = await Permission.location.request();
      if (permission.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicación capturada: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVaccine == null || _selectedSectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione vacuna y sector')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final vaccination = VaccinationSimple(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerName: _ownerNameCtrl.text.trim(),
      ownerCedula: _ownerCedulaCtrl.text.trim().isEmpty ? null : _ownerCedulaCtrl.text.trim(),
      ownerPhone: _ownerPhoneCtrl.text.trim().isEmpty ? null : _ownerPhoneCtrl.text.trim(),
      petName: _petNameCtrl.text.trim(),
      petType: _petType,
      petAge: _petAgeCtrl.text.trim().isEmpty ? null : _petAgeCtrl.text.trim(),
      petSex: _petSex,
      vaccine: _selectedVaccine!,
      sectorId: _selectedSectorId!,
      observations: _observationsCtrl.text.trim().isEmpty ? null : _observationsCtrl.text.trim(),
      photoPath: _selectedPhoto?.path,
      latitude: _latitude,
      longitude: _longitude,
    );

    InMemoryVaccinations.add(vaccination);

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vacunación registrada correctamente')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final sectors = InMemorySectors.all();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Vacunación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección: Datos del propietario
              const Text('Datos del Propietario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo *', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerCedulaCtrl,
                decoration: const InputDecoration(labelText: 'Cédula', prefixIcon: Icon(Icons.id_card)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Sección: Datos de la mascota
              const Text('Datos de la Mascota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _petNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la mascota *', prefixIcon: Icon(Icons.pets)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _petType,
                decoration: const InputDecoration(labelText: 'Tipo de mascota *'),
                items: [
                  const DropdownMenuItem(value: 'dog', child: Text('Perro')),
                  const DropdownMenuItem(value: 'cat', child: Text('Gato')),
                ].toList(),
                onChanged: (v) => setState(() => _petType = v ?? 'dog'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _petAgeCtrl,
                      decoration: const InputDecoration(labelText: 'Edad aproximada', hintText: 'Ej: 2 años'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _petSex,
                      decoration: const InputDecoration(labelText: 'Sexo'),
                      items: [
                        const DropdownMenuItem(value: 'male', child: Text('Macho')),
                        const DropdownMenuItem(value: 'female', child: Text('Hembra')),
                      ].toList(),
                      onChanged: (v) => setState(() => _petSex = v ?? 'male'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección: Vacunación
              const Text('Vacunación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedVaccine,
                decoration: const InputDecoration(labelText: 'Vacuna *', prefixIcon: Icon(Icons.vaccines)),
                items: _vaccines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _selectedVaccine = v),
                validator: (v) => v == null ? 'Seleccione una vacuna' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSectorId,
                decoration: const InputDecoration(labelText: 'Sector *', prefixIcon: Icon(Icons.location_on)),
                items: sectors.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => _selectedSectorId = v),
                validator: (v) => v == null ? 'Seleccione un sector' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationsCtrl,
                decoration: const InputDecoration(labelText: 'Observaciones', prefixIcon: Icon(Icons.notes)),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Sección: Foto y ubicación
              const Text('Foto y Ubicación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_selectedPhoto != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(_selectedPhoto!), fit: BoxFit.cover),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () => setState(() => _selectedPhoto = null),
                    ),
                  ),
                ),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capturar Foto'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitude != null ? 'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}' : 'No capturada',
                      style: TextStyle(color: _latitude != null ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _loadingLocation ? null : _getLocation,
                  icon: _loadingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.location_services),
                  label: const Text('Capturar Ubicación'),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de envío
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Registrar Vacunación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
