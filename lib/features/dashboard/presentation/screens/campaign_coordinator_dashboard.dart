import 'package:flutter/material.dart';
import 'package:examen1b2_flutter/services/auth_service.dart';
import 'package:examen1b2_flutter/simple/in_memory_vaccinations.dart';
import 'package:examen1b2_flutter/simple/in_memory_users.dart';
import 'package:examen1b2_flutter/simple/in_memory_sectors.dart';

/// Dashboard para Coordinador de Campaña
/// 
/// Vista general de toda la campaña:
/// - Total de vacunaciones
/// - Total de usuarios (todos los roles)
/// - Total de sectores
/// - Gestión completa de brigadas, vacunadores, sectores
/// - Reportes generales
class CampaignCoordinatorDashboard extends StatefulWidget {
  const CampaignCoordinatorDashboard({super.key});

  @override
  State<CampaignCoordinatorDashboard> createState() =>
      _CampaignCoordinatorDashboardState();
}

class _CampaignCoordinatorDashboardState
    extends State<CampaignCoordinatorDashboard> {
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
    final allVaccinations = InMemoryVaccinations.all();
    final allUsers = InMemoryUsers.all();
    final coordinators = InMemoryUsers.byRole('coordinator');
    final brigadeCoordinators = InMemoryUsers.byRole('brigade_coordinator');
    final vaccinators = InMemoryUsers.byRole('vaccinator');
    final sectors = InMemorySectors.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinador de Campaña'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Perfil'),
                onTap: () => _showProfile(),
              ),
              PopupMenuItem(
                child: const Text('Generar Reporte'),
                onTap: () => _generateReport(
                  allVaccinations.length,
                  allUsers.length,
                  sectors.length,
                ),
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
                    colors: [Colors.red[700]!, Colors.red[500]!],
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
                      'Coordinador de Campaña',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vista general de la campaña de vacunación',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Estadísticas principales
              Text(
                'Estadísticas Generales',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    title: 'Vacunaciones',
                    value: allVaccinations.length.toString(),
                    icon: Icons.pets,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Total Usuarios',
                    value: allUsers.length.toString(),
                    icon: Icons.group,
                    color: Colors.purple,
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
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Pendiente Sync',
                    value: '0', // TODO: Conectar con SyncService
                    icon: Icons.cloud_sync,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Desglose de personal
              Text(
                'Personal por Rol',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _RoleRow(
                      role: '👨‍💼 Coordinadores de Campaña',
                      count: coordinators.length,
                      color: Colors.red,
                    ),
                    const Divider(),
                    _RoleRow(
                      role: '👨‍💻 Coordinadores de Brigada',
                      count: brigadeCoordinators.length,
                      color: Colors.orange,
                    ),
                    const Divider(),
                    _RoleRow(
                      role: '💉 Vacunadores',
                      count: vaccinators.length,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gestión rápida
              Text(
                'Gestión Rápida',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionButton(
                    label: 'Gestionar Usuarios',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/users'),
                  ),
                  _ActionButton(
                    label: 'Ver Sectores',
                    icon: Icons.location_on,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/sectors'),
                  ),
                  _ActionButton(
                    label: 'Ver Vacunaciones',
                    icon: Icons.pets,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/vaccinations'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Últimas vacunaciones
              Text(
                'Últimas Vacunaciones Registradas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (allVaccinations.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.pets, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay vacunaciones registradas aún',
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
                  itemCount: allVaccinations.take(10).length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final vac = allVaccinations[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          vac.petType == 'dog' ? Icons.pets : Icons.favorite,
                          color: Colors.blue,
                        ),
                        title: Text('${vac.petName} (${vac.vaccine})'),
                        subtitle: Text(
                          '${vac.ownerName}\n${vac.sector ?? 'Sin sector'}',
                        ),
                        isThreeLine: true,
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
            Text('Rol: Coordinador de Campaña'),
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

  void _generateReport(int vaccinations, int users, int sectors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte General'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Resumen de Campaña:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('• Total Vacunaciones: $vaccinations'),
            Text('• Total Usuarios: $users'),
            Text('• Total Sectores: $sectors'),
            const SizedBox(height: 12),
            const Text('✅ Reporte generado correctamente.'),
            const Text('Próximas fases: exportar a PDF/Excel'),
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

class _RoleRow extends StatelessWidget {
  final String role;
  final int count;
  final Color color;

  const _RoleRow({
    required this.role,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(role),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
