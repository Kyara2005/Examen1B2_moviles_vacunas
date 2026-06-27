import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/vacunaciones.dart';
import 'edit_vacunaciones_screen.dart';
import 'vacunaciones_form_screen.dart';
import '../services/vaccination_service.dart';
import '../widgets/app_drawer.dart';

class VacunacionesScreen extends StatefulWidget {
  final AppUser usuario;

  const VacunacionesScreen({super.key, required this.usuario});

  @override
  State<VacunacionesScreen> createState() => _VacunacionesScreenState();
}

class _VacunacionesScreenState extends State<VacunacionesScreen> {
  late Future<List<Vacunaciones>> _vacunacionesFuture;

  @override
  void initState() {
    super.initState();
    _cargarVacunaciones();
  }

  void _cargarVacunaciones() {
    _vacunacionesFuture = VaccinationService().obtenerVacunaciones(
      widget.usuario,
    );
  }

  bool _puedeEditar(Vacunaciones vacunacion) {
    if (widget.usuario.rol == 'coordinador_campana') return true;
    if (widget.usuario.rol == 'coordinador_brigada' &&
        widget.usuario.sectorId == vacunacion.sectorId) {
      return true;
    }
    return widget.usuario.rol == 'vacunador' &&
        widget.usuario.id == vacunacion.usuarioId;
  }

  Future<void> _editar(Vacunaciones vacunacion) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditVacunacionesScreen(
          usuario: widget.usuario,
          vacunacion: vacunacion,
        ),
      ),
    );
    setState(_cargarVacunaciones);
  }

  Future<void> _eliminar(String id) async {
    await VaccinationService().eliminarVacunacion(id);
    setState(_cargarVacunaciones);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacunaciones')),
      drawer: AppDrawer(usuario: widget.usuario),
      floatingActionButton: widget.usuario.rol == 'vacunador'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VacunacionesFormScreen(usuario: widget.usuario),
                  ),
                );
                setState(_cargarVacunaciones);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: FutureBuilder<List<Vacunaciones>>(
        future: _vacunacionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vacunaciones = snapshot.data!;
          if (vacunaciones.isEmpty) {
            return const Center(child: Text('No hay registros'));
          }

          return ListView.builder(
            itemCount: vacunaciones.length,
            itemBuilder: (context, index) {
              final item = vacunaciones[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    item.tipoMascota == 'Gato' ? Icons.pets : Icons.vaccines,
                  ),
                  title: Text(item.nombreMascota),
                  subtitle: Text('${item.propietario} - ${item.fecha}'),
                  trailing: _puedeEditar(item)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editar(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: item.id == null
                                  ? null
                                  : () => _eliminar(item.id!),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
