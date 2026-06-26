class SimpleValidators {
  // Valida que un campo no este vacio.
  static String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }
}
