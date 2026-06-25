import 'package:flutter/material.dart';
import 'package:examen1b2_flutter/simple/in_memory_users.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final users = InMemoryUsers.all();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Usuarios')),
      body: users.isEmpty
          ? const Center(child: Text('No hay usuarios registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                final roleLabel = _roleToLabel(user.role);
                final roleColor = _roleToColor(user.role);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.firstName[0]),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text('${user.email} • $roleLabel'),
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          child: const Text('Editar'),
                          onTap: () => _editUser(context, user),
                        ),
                        PopupMenuItem(
                          child: const Text('Eliminar'),
                          onTap: () => _deleteUser(user.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Usuario'),
      ),
    );
  }

  String _roleToLabel(String role) {
    switch (role) {
      case 'coordinator':
        return 'Coordinador de Campaña';
      case 'brigade_coordinator':
        return 'Coordinador de Brigada';
      case 'vaccinator':
        return 'Vacunador';
      default:
        return role;
    }
  }

  Color _roleToColor(String role) {
    switch (role) {
      case 'coordinator':
        return Colors.red;
      case 'brigade_coordinator':
        return Colors.orange;
      case 'vaccinator':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showUserForm(BuildContext context, [UserSimple? user]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: user),
      ),
    ).then((_) => setState(() {}));
  }

  void _editUser(BuildContext context, UserSimple user) {
    _showUserForm(context, user);
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Está seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              InMemoryUsers.remove(userId);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  final UserSimple? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late String _selectedRole;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cedulaCtrl = TextEditingController(text: widget.user?.cedula ?? '');
    _firstNameCtrl = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.user?.lastName ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    _selectedRole = widget.user?.role ?? 'vaccinator';
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final newUser = UserSimple(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cedula: _cedulaCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
      );

      InMemoryUsers.add(newUser);
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cedulaCtrl,
                decoration: const InputDecoration(labelText: 'Cédula *', prefixIcon: Icon(Icons.id_card)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre *', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Apellido *', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico *', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono *', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol *'),
                items: [
                  const DropdownMenuItem(value: 'vaccinator', child: Text('Vacunador')),
                  const DropdownMenuItem(value: 'brigade_coordinator', child: Text('Coordinador de Brigada')),
                  const DropdownMenuItem(value: 'coordinator', child: Text('Coordinador de Campaña')),
                ].toList(),
                onChanged: (v) => setState(() => _selectedRole = v ?? 'vaccinator'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(widget.user == null ? 'Crear Usuario' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
