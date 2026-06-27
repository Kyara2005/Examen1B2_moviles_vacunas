import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/sector.dart';
import '../services/sector_service.dart';
import '../widgets/app_drawer.dart';

// Coordinador de brigada.
class MySectorScreen extends StatefulWidget {
  final AppUser usuario;

  const MySectorScreen({super.key, required this.usuario});

  @override
  State<MySectorScreen> createState() => _MySectorScreenState();
}

class _MySectorScreenState extends State<MySectorScreen> {
  late Future<Sector?> _sectorFuture;

  @override
  void initState() {
    super.initState();
    _cargarSector();
  }

  void _cargarSector() {
    _sectorFuture = _obtenerMiSector();
  }

  Future<Sector?> _obtenerMiSector() async {
    if (widget.usuario.sectorId == null) return null;

    final sectores = await SectorService().obtenerSectoresAsignados(
      widget.usuario.id,
    );

    return sectores.isNotEmpty ? sectores.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi sector')),
      drawer: AppDrawer(usuario: widget.usuario),
      body: FutureBuilder<Sector?>(
        future: _sectorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sector = snapshot.data;

          // Sin sector asignado
          if (sector == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No tienes un sector asignado.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Contacta al coordinador de campana para que te asigne uno.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Mostrar la informacion del sector
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map, size: 32, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sector.nombre,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Descripcion del sector
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Descripcion'),
                        subtitle: Text(
                          sector.descripcion.isNotEmpty
                              ? sector.descripcion
                              : 'Sin descripcion',
                        ),
                      ),
                      // ID del sector (util para soporte)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.tag),
                        title: const Text('ID del sector'),
                        subtitle: Text(sector.id),
                      ),
                      // Tu rol en este sector
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Tu rol'),
                        subtitle: const Text('Coordinador de brigada'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Mensaje informativo sobre permisos
              Card(
                color: Colors.green.shade50,
                child: const ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text('Permisos en este sector'),
                  subtitle: Text(
                    '• Ver y corregir todas las vacunaciones del sector\n'
                    '• Crear y asignar vacunadores\n'
                    '• Ver el dashboard de tu sector',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
