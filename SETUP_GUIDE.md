# Campaña de Vacunación Canina y Felina - Setup Completo

## 🎯 Estado del Proyecto

✅ **Simplificado a junior-friendly** (sin Riverpod complejo)  
✅ **Integración Supabase lista** (para auth + sincronización)  
✅ **5 pantallas prioritarias implementadas:**
- Login con Supabase Auth
- Cambio obligatorio de contraseña
- Dashboard para vacunador
- Registro de vacunación (con cámara + GPS)
- Gestión de usuarios (CRUD)

✅ **In-memory sync:** Datos locales + Supabase remoto

## 📋 Requisitos Setup

### 1. Credenciales Supabase

Necesitas tus valores de Supabase. Actualiza en `lib/main.dart` o usa variables de entorno:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key-here"
```

### 2. Configurar Supabase Remote

**Crear tabla `users` en Supabase:**

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  cedula TEXT UNIQUE,
  name TEXT,
  role TEXT DEFAULT 'vaccinator',
  must_change_password BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Crear tabla `vaccinations` en Supabase:**

```sql
CREATE TABLE vaccinations (
  id UUID PRIMARY KEY,
  owner_name TEXT,
  owner_cedula TEXT,
  owner_phone TEXT,
  pet_name TEXT,
  pet_type TEXT,
  pet_age TEXT,
  pet_sex TEXT,
  vaccine TEXT,
  sector_id TEXT,
  observations TEXT,
  photo_path TEXT,
  latitude FLOAT,
  longitude FLOAT,
  vaccinator_id UUID,
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. Configurar Permisos

iOS (`ios/Podfile`): Agregar permisos de cámara y ubicación
Android: `android/app/src/main/AndroidManifest.xml` ya tiene permisos

## 🚀 Ejecutar la App

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en desarrollo
flutter run

# 3. Con credenciales (recomendado)
flutter run \
  --dart-define=SUPABASE_URL="tu-url" \
  --dart-define=SUPABASE_ANON_KEY="tu-key"
```

## 📱 Flujo de Usuario

### Primer Acceso
1. **Login** → usuario + contraseña inicial (`Ecuador2026`)
2. **Cambio Obligatorio** → nueva contraseña
3. **Dashboard** → pantalla principal

### Workflow Vacunador
- Ver dashboard con estadísticas
- **Registrar Vacunación** → cámara + GPS automáticos
- Editar/ver registros

### Workflow Usuarios (Coordinadores)
- Listar usuarios
- Crear usuario (asignar rol)
- Editar/eliminar

## 🏗️ Arquitectura

```
lib/
├── main.dart                 # Entrypoint + routing
├── services/
│   ├── supabase_service.dart     # Cliente Supabase
│   └── auth_service.dart          # Auth simplificado
├── simple/                    # In-memory stores
│   ├── in_memory_vaccinations.dart
│   ├── in_memory_sectors.dart
│   └── in_memory_users.dart
├── features/
│   ├── auth/presentation/screens/
│   │   ├── login_screen.dart
│   │   └── change_password_screen.dart
│   ├── dashboard/presentation/screens/
│   │   └── vaccinator_dashboard_simple.dart
│   ├── vaccinations/
│   │   └── presentation/screens/
│   │       ├── vaccination_form_screen_full.dart
│   │       └── vaccinations_list_screen.dart
│   └── users/
│       └── presentation/screens/
│           └── users_management_screen.dart
└── core/constants/
    ├── app_colors.dart
    └── app_strings.dart
```

## 🔧 Próximas Mejoras

- [ ] Sincronización offline-online automática
- [ ] Dashboard Coordinador
- [ ] Gestión de Sectores mejorada
- [ ] Gráficos en dashboard
- [ ] Subida de fotos a Supabase Storage
- [ ] Recuperación de contraseña vía email
- [ ] Validaciones avanzadas
- [ ] Tests unitarios/widget

## 📝 Variables de Entorno

Crear `.env` (opcional):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Usar con:
```bash
flutter pub get flutter_dotenv
# Actualizar main.dart para cargar .env
```

## 🐛 Troubleshooting

**Error: "SupabaseClient not initialized"**
→ Verifica que SUPABASE_URL y SUPABASE_ANON_KEY sean correctos

**Error: "Camera permission denied"**
→ Acepta permisos en configuración del dispositivo

**Error: "GPS not available"**
→ Habilita ubicación en configuración

## 👤 Roles del Sistema

- **`vaccinator`** - Vacunador de campo
- **`brigade_coordinator`** - Coordinador de brigada
- **`coordinator`** - Coordinador de campaña

## 📞 Soporte

Para preguntas, consulta la estructura en `lib/features/` para ejemplos completos.
