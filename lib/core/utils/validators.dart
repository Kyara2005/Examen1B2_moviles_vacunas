// ============================================================
// lib/core/utils/validators.dart
// ============================================================
import '../constants/app_strings.dart';

class Validators {
  Validators._();
 
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }
 
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }
 
  static String? cedula(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (value.length != 10) return 'La cédula debe tener 10 dígitos';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Solo se permiten números';
    return null;
  }
 
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Teléfono inválido (10 dígitos)';
    return null;
  }
 
  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.requiredField;
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe contener al menos una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe contener al menos un número';
    return null;
  }
}