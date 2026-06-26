class AppUser {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String rol;
  final String? sectorId;
  final bool debeCambiarClave;

  AppUser({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    this.sectorId,
    required this.debeCambiarClave,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'].toString(),
      cedula: map['cedula'] ?? '',
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      telefono: map['telefono'] ?? '',
      correo: map['correo'] ?? '',
      rol: map['rol'] ?? 'vacunador',
      sectorId: map['sector_id']?.toString(),
      debeCambiarClave: map['debe_cambiar_clave'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'rol': rol,
      'sector_id': sectorId,
      'debe_cambiar_clave': debeCambiarClave,
    };
  }
}
