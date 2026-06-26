import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/sector.dart';
import '../services/sector_service.dart';
import '../widgets/app_drawer.dart';

class SectorsScreen extends StatefulWidget {
  final AppUser usuario;

  const SectorsScreen({super.key, required this.usuario});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  late Future<List<Sector>> _sectoresFuture;

  @override
  void initState() {
    super.initState();
    _cargarSectores();
  }

  // Obtiene los sectores desde Supabase.
  void _cargarSectores() {
    _sectoresFuture = SectorService().obtenerSectores();
  }

  // Muestra el formulario para crear o editar un sector.
  Future<void> _mostrarFormulario({Sector? sector}) async {
    final nombreController = TextEditingController(text: sector?.nombre ?? '');
    final descripcionController = TextEditingController(
      text: sector?.descripcion ?? '',
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sector == null ? 'Nuevo sector' : 'Editar sector'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (sector == null) {
                await SectorService().crearSector(
                  nombreController.text,
                  descripcionController.text,
                );
              } else {
                await SectorService().actualizarSector(
                  sector.id,
                  nombreController.text,
                  descripcionController.text,
                  sector.coordinadorId,
                );
              }

              if (mounted) Navigator.pop(context);
              setState(_cargarSectores);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Elimina un sector despues de confirmar.
  Future<void> _eliminarSector(String id) async {
    await SectorService().eliminarSector(id);
    setState(_cargarSectores);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sectores')),
      drawer: AppDrawer(usuario: widget.usuario),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Sector>>(
        future: _sectoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final sectores = snapshot.data!;
          return ListView.builder(
            itemCount: sectores.length,
            itemBuilder: (context, index) {
              final sector = sectores[index];
              return Card(
                child: ListTile(
                  title: Text(sector.nombre),
                  subtitle: Text(sector.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarFormulario(sector: sector),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminarSector(sector.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
