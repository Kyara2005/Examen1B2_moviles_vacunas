import 'package:flutter/material.dart';

import '../../../../simple/in_memory_users.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  Widget build(BuildContext context) {
    final users = InMemoryUsers.all();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: users.isEmpty
          ? const Center(child: Text('No hay usuarios registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user.firstName.substring(0, 1).toUpperCase())),
                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/users/new');
          if (created == true) setState(() {});
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo Usuario'),
      ),
    );
  }
}