import 'package:examen1b2_flutter/simple/in_memory_vaccinations.dart';
import 'package:examen1b2_flutter/simple/in_memory_users.dart';
import 'package:examen1b2_flutter/simple/in_memory_sectors.dart';
import 'package:examen1b2_flutter/services/supabase_service.dart';
import 'package:flutter/foundation.dart';

/// Servicio de sincronización offline-first
/// 
/// Mantiene una cola de cambios locales y sincroniza con Supabase cuando hay conexión.
/// 
/// Flujo:
/// 1. Usuario realiza cambios (nuevas vacunaciones, usuarios, etc.) → se guardan INMEDIATAMENTE en memoria
/// 2. SyncService detecta cambios nuevos (sin sincronizar)
/// 3. Cuando hay conexión, envía cambios a Supabase
/// 4. Marca cambios como "synced" en servidor
/// 5. Descarga cambios remotos (para otros usuarios que editaron desde app web, etc.)
class SyncService extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  
  // Cola de cambios pendientes
  final List<SyncItem> _pendingSync = [];
  
  // Estados
  bool _isSyncing = false;
  bool _hasConnection = true;
  int _pendingCount = 0;
  
  // Getters
  bool get isSyncing => _isSyncing;
  bool get hasConnection => _hasConnection;
  int get pendingCount => _pendingCount;
  bool get hasPendingChanges => _pendingSync.isNotEmpty;
  
  SyncService() {
    _initializeSync();
  }
  
  void _initializeSync() {
    // Aquí puede ir lógica para cargar items pendientes de persistencia
    // Por ahora, simplemente iniciamos vacío
  }
  
  /// Agregar una vacunación a la cola de sincronización
  void addVaccinationToSync(VaccinationSimple vaccination) {
    _pendingSync.add(
      SyncItem(
        type: 'vaccination',
        action: 'create',
        id: vaccination.id,
        data: vaccination.toJson(),
        createdAt: DateTime.now(),
      ),
    );
    _updatePendingCount();
    notifyListeners();
  }
  
  /// Agregar un usuario a la cola de sincronización
  void addUserToSync(UserSimple user) {
    _pendingSync.add(
      SyncItem(
        type: 'user',
        action: 'create',
        id: user.id,
        data: user.toJson(),
        createdAt: DateTime.now(),
      ),
    );
    _updatePendingCount();
    notifyListeners();
  }
  
  /// Marcar usuario como eliminado (soft delete)
  void deleteUserFromSync(String userId) {
    _pendingSync.add(
      SyncItem(
        type: 'user',
        action: 'delete',
        id: userId,
        data: {},
        createdAt: DateTime.now(),
      ),
    );
    _updatePendingCount();
    notifyListeners();
  }
  
  /// Intentar sincronizar todos los cambios pendientes
  Future<void> syncPendingChanges() async {
    if (_isSyncing || _pendingSync.isEmpty) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      for (final item in _pendingSync) {
        await _syncItem(item);
      }
      
      // Si llegamos aquí, todo sincronizó correctamente
      _pendingSync.clear();
      _updatePendingCount();
    } catch (e) {
      debugPrint('Error durante sincronización: $e');
      // Los items permanecen en la cola para reintentar
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Sincronizar un item individual
  Future<void> _syncItem(SyncItem item) async {
    try {
      switch (item.type) {
        case 'vaccination':
          await _syncVaccination(item);
          break;
        case 'user':
          await _syncUser(item);
          break;
        case 'sector':
          await _syncSector(item);
          break;
      }
    } catch (e) {
      debugPrint('Error sincronizando ${item.type}: $e');
      rethrow;
    }
  }
  
  /// Sincronizar vacunación a Supabase
  Future<void> _syncVaccination(SyncItem item) async {
    final db = _supabaseService.db;
    
    switch (item.action) {
      case 'create':
        // Insertar si no existe, actualizar si existe
        await db.from('vaccinations').upsert([item.data]);
        break;
      case 'update':
        await db.from('vaccinations').update(item.data).eq('id', item.id);
        break;
      case 'delete':
        await db.from('vaccinations').delete().eq('id', item.id);
        break;
    }
    
    debugPrint('✅ Sincronizada vacunación: ${item.id}');
  }
  
  /// Sincronizar usuario a Supabase
  Future<void> _syncUser(SyncItem item) async {
    final db = _supabaseService.db;
    
    switch (item.action) {
      case 'create':
        await db.from('users').upsert([item.data]);
        break;
      case 'update':
        await db.from('users').update(item.data).eq('id', item.id);
        break;
      case 'delete':
        await db.from('users').delete().eq('id', item.id);
        break;
    }
    
    debugPrint('✅ Sincronizado usuario: ${item.id}');
  }
  
  /// Sincronizar sector a Supabase
  Future<void> _syncSector(SyncItem item) async {
    final db = _supabaseService.db;
    
    switch (item.action) {
      case 'create':
        await db.from('sectors').upsert([item.data]);
        break;
      case 'update':
        await db.from('sectors').update(item.data).eq('id', item.id);
        break;
      case 'delete':
        await db.from('sectors').delete().eq('id', item.id);
        break;
    }
    
    debugPrint('✅ Sincronizado sector: ${item.id}');
  }
  
  /// Descargar datos remotos (sincronización en reversa)
  Future<void> pullRemoteData() async {
    try {
      final db = _supabaseService.db;
      
      // Descargar vacunaciones
      final vaccinationsData = await db.from('vaccinations').select();
      for (final vac in vaccinationsData) {
        final vaccination = VaccinationSimple.fromJson(vac);
        InMemoryVaccinations.add(vaccination);
      }
      
      // Descargar usuarios
      final usersData = await db.from('users').select();
      for (final user in usersData) {
        final userObj = UserSimple.fromJson(user);
        InMemoryUsers.add(userObj);
      }
      
      // Descargar sectores
      final sectorsData = await db.from('sectors').select();
      for (final sector in sectorsData) {
        final sectorObj = SectorSimple.fromJson(sector);
        InMemorySectors.add(sectorObj);
      }
      
      debugPrint('✅ Datos remotos descargados');
      notifyListeners();
    } catch (e) {
      debugPrint('Error descargando datos remotos: $e');
    }
  }
  
  /// Sincronización bidireccional completa
  Future<void> fullSync() async {
    await syncPendingChanges(); // Enviar cambios locales
    await pullRemoteData();     // Traer cambios remotos
  }
  
  void _updatePendingCount() {
    _pendingCount = _pendingSync.length;
  }
  
  /// Limpiar toda la cola (usar con cuidado)
  void clearPendingSync() {
    _pendingSync.clear();
    _updatePendingCount();
    notifyListeners();
  }
}

/// Modelo para item de sincronización
class SyncItem {
  final String type; // 'vaccination', 'user', 'sector'
  final String action; // 'create', 'update', 'delete'
  final String id;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  
  SyncItem({
    required this.type,
    required this.action,
    required this.id,
    required this.data,
    required this.createdAt,
  });
}
