# 🔄 Guía de Sincronización Offline-First

Este documento explica cómo implementar y usar el `SyncService` para sincronización offline-first en la app.

## 📌 Concepto: Offline-First

**Offline-First** significa que:
1. ✅ Todos los cambios se guardan **PRIMERO localmente** (en memoria)
2. ✅ La app **siempre responde rápidamente** (sin esperar a Supabase)
3. ✅ Cuando hay conexión, se **sincroniza en background**
4. ✅ Si no hay conexión, los cambios se **guardan en una cola** y se sincronizan después

```
Usuario hace cambio
    ↓
Se guarda INMEDIATAMENTE en memoria (InMemoryVaccinations, etc.)
    ↓
Se agrega a SyncService.pendingSync (cola)
    ↓
¿Hay conexión? → SÍ: Enviar a Supabase
            → NO: Esperar conexión
    ↓
Marcar como "synced"
```

## 🔧 Integración en la App

### Paso 1: Crear SyncService como Singleton Global

**Archivo:** `lib/main.dart`

```dart
import 'services/sync_service.dart';

// Variable global
late final SyncService syncService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase...
  
  // ✨ NUEVO: Crear SyncService
  syncService = SyncService();
  
  // Iniciar sincronización automática cada 30 segundos
  Timer.periodic(Duration(seconds: 30), (_) async {
    await syncService.syncPendingChanges();
  });
  
  runApp(const SimpleApp());
}

class SimpleApp extends StatefulWidget {
  // ... rest del código
}
```

### Paso 2: Agregar Item a la Cola Cuando Guardes

**Ejemplo en:** `lib/features/vaccinations/presentation/screens/vaccination_form_screen_full.dart`

```dart
import 'package:examen1b2_flutter/main.dart'; // Para acceder a syncService

class VaccinationFormScreenFull extends StatefulWidget {
  const VaccinationFormScreenFull({super.key});

  @override
  State<VaccinationFormScreenFull> createState() =>
      _VaccinationFormScreenFullState();
}

class _VaccinationFormScreenFullState extends State<VaccinationFormScreenFull> {
  // ... campos del formulario
  
  void _submit() {
    // 1. Crear objeto VaccinationSimple
    final vaccination = VaccinationSimple(
      id: Uuid().v4(),
      ownerName: _ownerNameController.text,
      ownerCedula: _ownerCedulaController.text,
      // ... otros campos
      createdAt: DateTime.now(),
    );
    
    // 2. Guardar EN MEMORIA (respuesta inmediata)
    InMemoryVaccinations.add(vaccination);
    
    // ✨ 3. NUEVO: Agregar a cola de sincronización
    syncService.addVaccinationToSync(vaccination);
    
    // 4. Navegar de vuelta
    Navigator.pop(context);
    
    // 5. Mostrar feedback al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vacunación registrada (sincronizando...)'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

### Paso 3: Mostrar Estado de Sincronización en UI

**Ejemplo en:** `lib/features/dashboard/presentation/screens/vaccinator_dashboard_simple.dart`

```dart
import 'package:examen1b2_flutter/main.dart';
import 'package:examen1b2_flutter/services/sync_service.dart';

class VaccinatorDashboard extends StatefulWidget {
  const VaccinatorDashboard({super.key});

  @override
  State<VaccinatorDashboard> createState() => _VaccinatorDashboardState();
}

class _VaccinatorDashboardState extends State<VaccinatorDashboard> {
  @override
  void initState() {
    super.initState();
    // Escuchar cambios en sincronización
    syncService.addListener(_onSyncChanged);
  }
  
  @override
  void dispose() {
    syncService.removeListener(_onSyncChanged);
    super.dispose();
  }
  
  void _onSyncChanged() {
    setState(() {
      // Actualizar UI cuando cambien pendingChanges
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Vacunador'),
        actions: [
          // ✨ Mostrar indicador de sincronización
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _SyncIndicator(
                pending: syncService.pendingCount,
                isSyncing: syncService.isSyncing,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de sincronización pendiente
          if (syncService.hasPendingChanges)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_sync, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sincronizando ${syncService.pendingCount} cambios...',
                    ),
                  ),
                  if (syncService.isSyncing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          // ... resto del dashboard
        ],
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  final int pending;
  final bool isSyncing;

  const _SyncIndicator({
    required this.pending,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return Tooltip(
        message: 'Sincronizando $pending cambios...',
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (pending > 0) {
      return Tooltip(
        message: '$pending cambios sin sincronizar',
        child: Badge(
          label: Text(pending.toString()),
          child: Icon(Icons.cloud_off),
        ),
      );
    }

    return Tooltip(
      message: 'Sincronizado',
      child: Icon(Icons.cloud_done, color: Colors.green),
    );
  }
}
```

## 🎯 Casos de Uso Completos

### Caso 1: Registrar Vacunación Sin Conexión

```dart
// Usuario llena formulario SIN conexión
// 1. Click "Guardar"
// 2. Se guarda en InMemoryVaccinations
// 3. Se agrega a SyncService.pendingSync
// 4. App muestra "Guardado (pendiente sincronización)"

// Después, cuando hay conexión:
// 1. Timer dispara syncPendingChanges()
// 2. SyncService envía a Supabase
// 3. Dashboard muestra ✅ sincronizado
```

### Caso 2: Crear Usuario Desde App

```dart
// En UsersManagementScreen:

void _submitForm() {
  final user = UserSimple(
    id: Uuid().v4(),
    cedula: _cedulaController.text,
    firstName: _firstNameController.text,
    // ... otros campos
  );
  
  // Guardar en memoria
  InMemoryUsers.add(user);
  
  // ✨ Agregar a cola de sincronización
  syncService.addUserToSync(user);
  
  // UI muestra estado pendiente
  setState(() {});
}
```

### Caso 3: Sincronización Manual

```dart
// En un botón "Sincronizar Ahora":

ElevatedButton(
  onPressed: () async {
    // Ejecutar sincronización completa
    await syncService.fullSync(); // Enviar + recibir cambios
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Sincronización completada')),
    );
    
    setState(() {}); // Actualizar UI
  },
  child: const Text('Sincronizar Ahora'),
),
```

## 🔌 Monitorear Conexión de Red

**Opción 1: Usar `connectivity_plus` (recomendado)**

```bash
flutter pub add connectivity_plus
```

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class _VaccinatorDashboardState extends State<VaccinatorDashboard> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    
    // Monitorear conexión
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Hay conexión, sincronizar
        syncService.syncPendingChanges();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
```

**Opción 2: Usar intento de conexión periódico**

```dart
Timer.periodic(Duration(seconds: 30), (_) async {
  try {
    // Intentar conectar a Supabase
    await Supabase.instance.client.auth.refreshSession();
    // Si no falla, hay conexión
    await syncService.syncPendingChanges();
  } catch (e) {
    // Sin conexión, continuar later
  }
});
```

## 📊 Monitorear SyncService

**Ver estado en tiempo real:**

```dart
class _SyncDebugWidget extends StatefulWidget {
  @override
  State<_SyncDebugWidget> createState() => _SyncDebugWidgetState();
}

class _SyncDebugWidgetState extends State<_SyncDebugWidget> {
  @override
  void initState() {
    super.initState();
    syncService.addListener(_update);
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pending: ${syncService.pendingCount}'),
        Text('Syncing: ${syncService.isSyncing}'),
        Text('Has Connection: ${syncService.hasConnection}'),
        ElevatedButton(
          onPressed: () => syncService.fullSync(),
          child: Text('Sincronizar Manualmente'),
        ),
      ],
    );
  }
}
```

## 🆘 Troubleshooting

**P: ¿Qué pasa si Supabase falla?**  
R: El item permanece en `pendingSync` y se reintenta automáticamente cada 30 segundos.

**P: ¿Qué pasa si la app se cierra?**  
R: Los cambios se pierden de la cola (solución: guardar `pendingSync` en Isar/SQLite para persistencia).

**P: ¿Cómo limpio los cambios sincronizados?**  
R: `syncService.clearPendingSync()` - pero úsalo con cuidado (solo para testing).

**P: ¿Cómo priorizo cambios?**  
R: Modifica `SyncService._syncItem()` para procesar por tipo (vaccinations antes que users).

## 🚀 Próximos Pasos

1. Agregar persistencia local (guardar `pendingSync` en Isar)
2. Implementar deduplicación (no enviar el mismo cambio 2 veces)
3. Agregar reintentos con backoff exponencial
4. Implementar conflicto resolution (si datos cambiaron remotamente)
5. Agregar compresión para cambios grandes
6. Crear UI de historial de sincronización

---

**Implementación estimada:** 1-2 horas para integración completa en todas las pantallas.
