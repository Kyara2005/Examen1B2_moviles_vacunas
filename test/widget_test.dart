import 'package:examen1b2_flutter/models/vacunaciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Vacunaciones convierte datos a mapa', () {
    final vacunacion = Vacunaciones(
      propietario: 'Maria Lopez',
      cedula: '0102030405',
      telefono: '0999999999',
      tipoMascota: 'Perro',
      nombreMascota: 'Firulais',
      edadAproximada: '2 anos',
      sexo: 'Macho',
      vacuna: 'Antirrabica',
      observaciones: 'Sin novedades',
      fecha: '2026-06-25',
      hora: '10:30',
      usuarioId: 'usuario-1',
      sectorId: 'sector-1',
    );

    final mapa = vacunacion.toMap();

    expect(mapa['propietario'], 'Maria Lopez');
    expect(mapa['tipo_mascota'], 'Perro');
    expect(mapa['sincronizado'], true);
  });
}
