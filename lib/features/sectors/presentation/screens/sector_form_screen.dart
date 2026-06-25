// ============================================================
// lib/features/sectors/presentation/screens/sector_form_screen.dart
// ============================================================
 
import 'package:flutter/material.dart';

import '../../../../simple/in_memory_sectors.dart';

class SectorFormScreen extends StatefulWidget {
  const SectorFormScreen({super.key});

  @override
  State<SectorFormScreen> createState() => _SectorFormScreenState();
}

class _SectorFormScreenState extends State<SectorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    InMemorySectors.add(
      SectorSimple(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameCtrl.text.trim(), description: _descCtrl.text.trim()),
    );

    setState(() => _isLoading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Sector')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del sector *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  hintText: 'Ej: Barrio Norte, Sector Sur',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Crear Sector'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}