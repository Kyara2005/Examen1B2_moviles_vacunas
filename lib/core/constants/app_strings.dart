// ============================================================
// lib/core/constants/app_strings.dart
// ============================================================
class AppStrings {
  AppStrings._();
 
  static const String appName = 'Vacunación Canina y Felina';
  static const String initialPassword = 'Ecuador2026';
 
  // Roles
  static const String roleCampaignCoordinator = 'campaign_coordinator';
  static const String roleBrigadeCoordinator = 'brigade_coordinator';
  static const String roleVaccinator = 'vaccinator';
 
  // Pet types
  static const String dog = 'dog';
  static const String cat = 'cat';
 
  // Mensajes
  static const String noConnection = 'Sin conexión. El registro se guardará localmente.';
  static const String syncSuccess = 'Registros sincronizados correctamente.';
  static const String errorGeneric = 'Ocurrió un error. Intente nuevamente.';
  static const String requiredField = 'Este campo es obligatorio';
}