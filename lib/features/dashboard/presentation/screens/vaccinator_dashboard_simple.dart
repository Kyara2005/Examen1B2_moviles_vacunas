import 'package:flutter/material.dart';
import 'package:examen1b2_flutter/services/auth_service.dart';
import 'package:examen1b2_flutter/simple/in_memory_vaccinations.dart';
import 'package:examen1b2_flutter/simple/in_memory_sectors.dart';

class VaccinatorDashboard extends StatefulWidget {
  const VaccinatorDashboard({super.key});

  @override
  State<VaccinatorDashboard> createState() => _VaccinatorDashboardState();
}

class _VaccinatorDashboardState extends State<VaccinatorDashboard> {
  late final AuthService _authService;
  late final AuthUser? _currentUser;
  int _syncPending = 0;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _currentUser = _authService.currentUser;
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _syncPending = InMemoryVaccinations.all().length; // Simulado: registros pendientes
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vaccinations = InMemoryVaccinations.all();
    final sectors = InMemorySectors.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Panel'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: const Row(children: [Icon(Icons.person, size: 20), SizedBox(width: 8), Text('Perfil')]),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              PopupMenuItem(
                child: const Row(children: [Icon(Icons.logout, size: 20), SizedBox(width: 8), Text('Cerrar sesión')]),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _updateStats();
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjeta de bienvenida
            Card(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido,',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                    Text(
                      _currentUser?.name ?? _currentUser?.email ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vacunador de Campo',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjetas de estadísticas
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Vacunaciones',
                    value: vaccinations.length.toString(),
                    icon: Icons.vaccines,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Sectores',
                    value: sectors.length.toString(),
                    icon: Icons.location_on,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado de sincronización
            if (_syncPending > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_problem, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('$_syncPending registros pendientes de sincronización'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Acciones rápidas
            const Text('Acciones Rápidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Nueva\nVacunación',
                    icon: Icons.add_circle_outline,
                    onTap: () => Navigator.pushNamed(context, '/vaccinations/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Mis\nRegistros',
                    icon: Icons.list_alt,
                    onTap: () => Navigator.pushNamed(context, '/vaccinations'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/vaccinations/new'),
        icon: const Icon(Icons.vaccines),
        label: const Text('Registrar Vacunación'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
