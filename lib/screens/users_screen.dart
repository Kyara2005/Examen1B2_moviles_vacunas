import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/sector.dart';
import '../services/sector_service.dart';
import '../services/user_service.dart';
import '../widgets/app_drawer.dart';

class UsersScreen extends StatefulWidget {
  final AppUser usuario;

  const UsersScreen({super.key, required this.usuario});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<AppUser>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  // Carga usuarios segun el rol del usuario actual.
  void _cargarUsuarios() {
    final rolAFiltrar =
        widget.usuario.rol == 'coordinador_brigada' ? 'vacunador' : null;
    _usuariosFuture = UserService().obtenerUsuarios(rol: rolAFiltrar);
  }

  // Abre el formulario para crear usuarios.
  Future<void> _mostrarFormulario() async {
    final cedulaController = TextEditingController();
    final nombresController = TextEditingController();
    final apellidosController = TextEditingController();
    final telefonoController = TextEditingController();
    final correoController = TextEditingController();
    String rol = widget.usuario.rol == 'coordinador_brigada'
        ? 'vacunador'
        : 'coordinador_brigada';
    String? sectorId = widget.usuario.sectorId;
    final sectores = await SectorService().obtenerSectores();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Nuevo usuario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _campo(cedulaController, 'Cedula'),
                  _campo(nombresController, 'Nombres'),
                  _campo(apellidosController, 'Apellidos'),
                  _campo(telefonoController, 'Telefono'),
                  _campo(correoController, 'Correo'),
                  DropdownButtonFormField<String>(
                    initialValue: rol,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(
                        value: 'coordinador_brigada',
                        child: Text('Coordinador de brigada'),
                      ),
                      DropdownMenuItem(
                        value: 'vacunador',
                        child: Text('Vacunador'),
                      ),
                    ],
                    onChanged: widget.usuario.rol == 'coordinador_brigada'
                        ? null
                        : (value) => setDialogState(() => rol = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: sectorId,
                    decoration: const InputDecoration(labelText: 'Sector'),
                    items: sectores.map((Sector sector) {
                      return DropdownMenuItem(
                        value: sector.id,
                        child: Text(sector.nombre),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => sectorId = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  await UserService().crearUsuario(
                    cedula: cedulaController.text,
                    nombres: nombresController.text,
                    apellidos: apellidosController.text,
                    telefono: telefonoController.text,
                    correo: correoController.text,
                    rol: rol,
                    sectorId: sectorId,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  setState(_cargarUsuarios);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Abre el dialogo para reasignar el sector de un usuario existente.
  Future<void> _mostrarFormularioReasignar(AppUser usuarioAEditar) async {
    String? sectorId = usuarioAEditar.sectorId;
    final sectores = await SectorService().obtenerSectores();
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text('Reasignar sector a ${usuarioAEditar.nombres}'),
            content: DropdownButtonFormField<String>(
              initialValue: sectorId,
              decoration: const InputDecoration(labelText: 'Sector'),
              items: sectores.map((Sector sector) {
                return DropdownMenuItem(
                  value: sector.id,
                  child: Text(sector.nombre),
                );
              }).toList(),
              onChanged: (value) =>
                  setDialogState(() => sectorId = value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  // Crear una copia del usuario con el nuevo sector
                  final usuarioActualizado = AppUser(
                    id: usuarioAEditar.id,
                    cedula: usuarioAEditar.cedula,
                    nombres: usuarioAEditar.nombres,
                    apellidos: usuarioAEditar.apellidos,
                    telefono: usuarioAEditar.telefono,
                    correo: usuarioAEditar.correo,
                    rol: usuarioAEditar.rol,
                    sectorId: sectorId,
                    debeCambiarClave: usuarioAEditar.debeCambiarClave,
                  );
                  await UserService().actualizarUsuario(usuarioActualizado);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  setState(_cargarUsuarios);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Elimina un usuario de la tabla usuarios.
  Future<void> _eliminarUsuario(String id) async {
    // Confirmar antes de eliminar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('Esta accion no se puede deshacer. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await UserService().eliminarUsuario(id);
      setState(_cargarUsuarios);
    }
  }

  Widget _campo(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios y vacunadores')),
      drawer: AppDrawer(usuario: widget.usuario),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final usuarios = snapshot.data!;

          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final u = usuarios[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(u.nombreCompleto),
                  subtitle: Text('${u.rol} · ${u.correo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Boton para reasignar sector
                      IconButton(
                        icon: const Icon(Icons.edit_location_alt),
                        tooltip: 'Reasignar sector',
                        onPressed: () => _mostrarFormularioReasignar(u),
                      ),
                      // Boton para eliminar usuario
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar usuario',
                        onPressed: () => _eliminarUsuario(u.id),
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
