class Sector {
  final String id;
  final String nombre;
  final String descripcion;
  final String? coordinadorId;

  Sector({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.coordinadorId,
  });

  factory Sector.fromMap(Map<String, dynamic> map) {
    return Sector(
      id: map['id'].toString(),
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      coordinadorId: map['coordinador_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'coordinador_id': coordinadorId,
    };
  }
}
