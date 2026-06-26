class Vacunaciones {
  final String? id;
  final String propietario;
  final String cedula;
  final String telefono;
  final String tipoMascota;
  final String nombreMascota;
  final String edadAproximada;
  final String sexo;
  final String vacuna;
  final String observaciones;
  final String? imagenUrl;
  final double? latitud;
  final double? longitud;
  final String fecha;
  final String hora;
  final String usuarioId;
  final String sectorId;
  final bool sincronizado;

  Vacunaciones({
    this.id,
    required this.propietario,
    required this.cedula,
    required this.telefono,
    required this.tipoMascota,
    required this.nombreMascota,
    required this.edadAproximada,
    required this.sexo,
    required this.vacuna,
    required this.observaciones,
    this.imagenUrl,
    this.latitud,
    this.longitud,
    required this.fecha,
    required this.hora,
    required this.usuarioId,
    required this.sectorId,
    this.sincronizado = true,
  });

  factory Vacunaciones.fromMap(Map<String, dynamic> map) {
    return Vacunaciones(
      id: map['id']?.toString(),
      propietario: map['propietario'] ?? '',
      cedula: map['cedula'] ?? '',
      telefono: map['telefono'] ?? '',
      tipoMascota: map['tipo_mascota'] ?? '',
      nombreMascota: map['nombre_mascota'] ?? '',
      edadAproximada: map['edad_aproximada'] ?? '',
      sexo: map['sexo'] ?? '',
      vacuna: map['vacuna'] ?? '',
      observaciones: map['observaciones'] ?? '',
      imagenUrl: map['imagen_url'],
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      fecha: map['fecha'] ?? '',
      hora: map['hora'] ?? '',
      usuarioId: map['usuario_id'].toString(),
      sectorId: map['sector_id'].toString(),
      sincronizado: map['sincronizado'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'propietario': propietario,
      'cedula': cedula,
      'telefono': telefono,
      'tipo_mascota': tipoMascota,
      'nombre_mascota': nombreMascota,
      'edad_aproximada': edadAproximada,
      'sexo': sexo,
      'vacuna': vacuna,
      'observaciones': observaciones,
      'imagen_url': imagenUrl,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha,
      'hora': hora,
      'usuario_id': usuarioId,
      'sector_id': sectorId,
      'sincronizado': sincronizado,
    };
  }
}
