// ============================================================
// lib/features/sectors/presentation/screens/sectors_list_screen.dart
// ============================================================
 
import 'package:flutter/material.dart';

import '../../../../simple/in_memory_sectors.dart';

class SectorsListScreen extends StatefulWidget {
  const SectorsListScreen({super.key});

  @override
  State<SectorsListScreen> createState() => _SectorsListScreenState();
}

class _SectorsListScreenState extends State<SectorsListScreen> {
  @override
  Widget build(BuildContext context) {
    final sectors = InMemorySectors.all();

    return Scaffold(
      appBar: AppBar(title: const Text('Sectores')),
      body: sectors.isEmpty
          ? const Center(child: Text('No hay sectores registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sectors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sector = sectors[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(sector.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: sector.description != null ? Text(sector.description!) : null,
                    trailing: Text(sector.isActive ? 'Activo' : 'Inactivo'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/sectors/new');
          if (created == true) setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Sector'),
      ),
    );
  }
}