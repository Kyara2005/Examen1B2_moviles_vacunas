import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/dashboard_service.dart';
import '../services/sync_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  final AppUser usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _datosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Carga los datos principales del dashboard.
  void _cargarDatos() {
    _datosFuture = DashboardService().obtenerDatos(widget.usuario);
  }

  // Sincroniza registros pendientes de forma manual.
  Future<void> _sincronizar() async {
    await SyncService().sincronizarPendientes();
    setState(_cargarDatos);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronizacion finalizada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _sincronizar,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      drawer: AppDrawer(usuario: widget.usuario),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _datosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final datos = snapshot.data!;
          final porSector = datos['porSector'] as Map<String, int>;
          final porVacunador = datos['porVacunador'] as Map<String, int>;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              StatCard(
                titulo: 'Total de vacunaciones',
                valor: datos['total'].toString(),
                icono: Icons.vaccines,
              ),
              StatCard(
                titulo: 'Perros vacunados',
                valor: datos['perros'].toString(),
                icono: Icons.pets,
              ),
              StatCard(
                titulo: 'Gatos vacunados',
                valor: datos['gatos'].toString(),
                icono: Icons.pets,
              ),
              StatCard(
                titulo: 'Pendientes de sincronizacion',
                valor: datos['pendientes'].toString(),
                icono: Icons.cloud_off,
              ),
              const SizedBox(height: 12),
              Text(
                'Vacunaciones por sector',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...porSector.entries.map((item) {
                return ListTile(
                  leading: const Icon(Icons.map),
                  title: Text('Sector ${item.key}'),
                  trailing: Text(item.value.toString()),
                );
              }),
              const SizedBox(height: 12),
              Text(
                'Vacunaciones por vacunador',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...porVacunador.entries.map((item) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Usuario ${item.key}'),
                  trailing: Text(item.value.toString()),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
