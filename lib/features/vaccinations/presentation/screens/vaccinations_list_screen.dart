import 'package:flutter/material.dart';

import '../../../..//simple/in_memory_vaccinations.dart';
import '../../../../simple/in_memory_sectors.dart';

class VaccinationsListScreen extends StatefulWidget {
  const VaccinationsListScreen({super.key});

  @override
  State<VaccinationsListScreen> createState() => _VaccinationsListScreenState();
}

class _VaccinationsListScreenState extends State<VaccinationsListScreen> {
  @override
  Widget build(BuildContext context) {
    final items = InMemoryVaccinations.all();
    final sectors = {for (var s in InMemorySectors.all()) s.id: s.name};

    return Scaffold(
      appBar: AppBar(title: const Text('Vacunaciones')),
      body: items.isEmpty
          ? const Center(child: Text('No hay vacunaciones registradas'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final v = items[index];
                return Card(
                  child: ListTile(
                    title: Text(v.petName),
                    subtitle: Text('${v.ownerName} • ${sectors[v.sectorId] ?? '—'}'),
                    trailing: Text(v.vaccine),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/vaccinations/new');
          if (created == true) setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }
}
