import 'package:flutter/material.dart';
import 'package:examen1b2_flutter/services/auth_service.dart';
import 'package:examen1b2_flutter/simple/in_memory_vaccinations.dart';
import 'package:examen1b2_flutter/simple/in_memory_users.dart';
import 'package:examen1b2_flutter/simple/in_memory_sectors.dart';

/// Dashboard para Coordinador de Brigada
/// 
/// Puede ver:
/// - Vacunaciones en su brigada/sector
/// - Vacunadores asignados
/// - Estadísticas de su equipo
/// - Gestión de usuarios (vacunadores)
class BrigadeCoordinatorDashboard extends StatefulWidget {
  const BrigadeCoordinatorDashboard({super.key});

  @override
  State<BrigadeCoordinatorDashboard> createState() =>
      _BrigadeCoordinatorDashboardState();
}

class _BrigadeCoordinatorDashboardState
    extends State<BrigadeCoordinatorDashboard> {
  late final AuthService _authService;
  late final AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _currentUser = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final vaccinations = InMemoryVaccinations.all();
    final vaccinators =
        InMemoryUsers.byRole('vaccinator'); // Sus vacunadores asignados
    final sectors = InMemorySectors.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinador de Brigada'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Perfil'),
                onTap: () => _showProfile(),
              ),
              PopupMenuItem(
                child: const Text('Cerrar sesión'),
                onTap: () => _logout(),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de bienvenida
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[700]!, Colors.orange[500]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${_currentUser?.name ?? 'Coordinador'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coordinador de Brigada',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Estadísticas
              Text(
                'Estadísticas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    title: 'Vacunaciones',
                    value: vaccinations.length.toString(),
                    icon: Icons.pets,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Vacunadores',
                    value: vaccinators.length.toString(),
                    icon: Icons.group,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    title: 'Sectores',
                    value: sectors.length.toString(),
                    icon: Icons.location_on,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Pendiente Sync',
                    value: '0', // TODO: Conectar con SyncService
                    icon: Icons.cloud_sync,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mi equipo (Vacunadores)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mi Equipo de Vacunadores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    onPressed: () => Navigator.pushNamed(context, '/users'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (vaccinators.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.group_add, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes vacunadores asignados',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vaccinators.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final vaccinator = vaccinators[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[200],
                        child: Text(
                          vaccinator.firstName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      title: Text(
                        '${vaccinator.firstName} ${vaccinator.lastName}',
                      ),
                      subtitle: Text(vaccinator.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/users'),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Vacunaciones recientes
              Text(
                'Vacunaciones Recientes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (vaccinations.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.pets, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay vacunaciones registradas',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vaccinations.take(5).length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final vac = vaccinations[index];
                    return ListTile(
                      leading: Icon(
                        vac.petType == 'dog' ? Icons.pets : Icons.favorite,
                        color: Colors.blue,
                      ),
                      title: Text('${vac.petName} (${vac.vaccine})'),
                      subtitle: Text(
                        '${vac.ownerName} • ${vac.sector ?? 'Sin sector'}',
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mi Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${_currentUser?.name}'),
            Text('Email: ${_currentUser?.email}'),
            Text('Rol: Coordinador de Brigada'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
