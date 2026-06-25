# 🗄️ Guía de Setup - Tablas Supabase

Esta guía te ayuda a crear las tablas necesarias en Supabase para sincronización de datos.

## 📋 Tablas Requeridas

### 1. Tabla `users`
Almacena información de usuarios con roles del sistema.

```sql
-- Crear tabla users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cedula TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL DEFAULT 'vaccinator'
    CHECK (role IN ('coordinator', 'brigade_coordinator', 'vaccinator')),
  must_change_password BOOLEAN DEFAULT TRUE,
  phone_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para búsquedas rápidas
CREATE INDEX idx_users_cedula ON users(cedula);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

### 2. Tabla `sectors`
Define áreas geográficas de vacunación.

```sql
CREATE TABLE sectors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  location_area TEXT, -- "Centro", "Norte", "Sur", etc.
  coordinator_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_sectors_coordinator ON sectors(coordinator_id);
```

### 3. Tabla `vaccinations`
Registro de cada vacunación aplicada.

```sql
CREATE TABLE vaccinations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Información del propietario
  owner_name TEXT NOT NULL,
  owner_cedula TEXT,
  owner_phone TEXT,
  -- Información de la mascota
  pet_name TEXT NOT NULL,
  pet_type TEXT CHECK (pet_type IN ('dog', 'cat')),
  pet_age TEXT,
  pet_sex TEXT CHECK (pet_sex IN ('male', 'female')),
  -- Vacunación
  vaccine TEXT NOT NULL,
  sector_id UUID REFERENCES sectors(id),
  observations TEXT,
  -- Localización y evidencia
  photo_path TEXT, -- URL en storage (opcional)
  latitude FLOAT,
  longitude FLOAT,
  -- Auditoría
  vaccinator_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_vaccinations_vaccinator ON vaccinations(vaccinator_id);
CREATE INDEX idx_vaccinations_sector ON vaccinations(sector_id);
CREATE INDEX idx_vaccinations_created ON vaccinations(created_at);
```

### 4. Tabla `sync_queue` (Opcional - para gestionar sincronización)
Mantiene track de cambios pendientes en caso offline.

```sql
CREATE TABLE sync_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('vaccination', 'user', 'sector')),
  action TEXT NOT NULL CHECK (action IN ('create', 'update', 'delete')),
  entity_id UUID NOT NULL,
  data JSONB, -- Almacena el objeto completo
  user_id UUID REFERENCES users(id),
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_sync_queue_synced ON sync_queue(synced);
CREATE INDEX idx_sync_queue_type ON sync_queue(type);
```

## 🔒 Políticas de Seguridad (RLS)

Habilitar Row Level Security (RLS) para proteger datos.

### RLS para tabla `users`

```sql
-- Habilitar RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Coordinadores ven todos los usuarios
CREATE POLICY "Coordinators can view all users"
  ON users FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'coordinator'
    )
  );

-- Brigadistas ven solo sus vacunadores
CREATE POLICY "Brigade coordinators see their team"
  ON users FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'brigade_coordinator'
    )
  );

-- Cada usuario ve su propio perfil
CREATE POLICY "Users see themselves"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Solo coordinadores pueden crear usuarios
CREATE POLICY "Only coordinators create users"
  ON users FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'coordinator'
    )
  );
```

### RLS para tabla `vaccinations`

```sql
ALTER TABLE vaccinations ENABLE ROW LEVEL SECURITY;

-- Vacunadores ven sus propias vacunaciones
CREATE POLICY "Vaccinators see their own vaccinations"
  ON vaccinations FOR SELECT
  USING (auth.uid() = vaccinator_id);

-- Brigadistas ven vacunaciones de su equipo
CREATE POLICY "Brigade coordinators see team vaccinations"
  ON vaccinations FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'brigade_coordinator'
    )
  );

-- Coordinadores ven todas
CREATE POLICY "Coordinators see all vaccinations"
  ON vaccinations FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'coordinator'
    )
  );

-- Vacunadores pueden crear vacunaciones
CREATE POLICY "Vaccinators create vaccinations"
  ON vaccinations FOR INSERT
  WITH CHECK (auth.uid() = vaccinator_id);

-- Vacunadores pueden actualizar sus vacunaciones
CREATE POLICY "Vaccinators update their vaccinations"
  ON vaccinations FOR UPDATE
  USING (auth.uid() = vaccinator_id)
  WITH CHECK (auth.uid() = vaccinator_id);
```

### RLS para tabla `sectors`

```sql
ALTER TABLE sectors ENABLE ROW LEVEL SECURITY;

-- Todos pueden ver sectores
CREATE POLICY "All authenticated users see sectors"
  ON sectors FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Solo coordinadores pueden crear sectores
CREATE POLICY "Only coordinators create sectors"
  ON sectors FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT id FROM users WHERE role = 'coordinator'
    )
  );
```

## 📱 Datos de Prueba

Ejecutar esto para agregar datos iniciales:

```sql
-- Insertar usuarios de prueba
INSERT INTO users (cedula, name, email, role, phone_number)
VALUES
  ('1234567890', 'Juan Pérez', 'juan@example.com', 'vaccinator', '0987654321'),
  ('0987654321', 'María García', 'maria@example.com', 'vaccinator', '0987654322'),
  ('1111111111', 'Carlos López', 'carlos@example.com', 'brigade_coordinator', '0987654323'),
  ('2222222222', 'Ana Rodríguez', 'ana@example.com', 'coordinator', '0987654324');

-- Insertar sectores
INSERT INTO sectors (name, description, location_area, coordinator_id)
SELECT
  'Sector Centro', 'Centro de la ciudad', 'Centro',
  id FROM users WHERE email = 'ana@example.com'
UNION ALL
SELECT
  'Sector Norte', 'Zona norte', 'Norte',
  id FROM users WHERE email = 'ana@example.com'
UNION ALL
SELECT
  'Sector Sur', 'Zona sur', 'Sur',
  id FROM users WHERE email = 'ana@example.com';
```

## 🔐 Storage (para fotos de vacunaciones)

Crear bucket para almacenar fotos:

```sql
-- Crear bucket (desde Supabase console)
-- Nombre: vaccination-photos
-- Privado: Sí
-- Habilitar RLS

-- Política para subir fotos (vacunadores)
CREATE POLICY "Vaccinators can upload photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'vaccination-photos'
    AND auth.uid() IS NOT NULL
  );

-- Política para ver fotos
CREATE POLICY "Users can view vaccination photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'vaccination-photos');
```

## 📝 Notas Importantes

- **UUID**: Todas las IDs usan `gen_random_uuid()` para seguridad
- **Timestamps**: `created_at` inmutable, `updated_at` se actualiza automáticamente
- **RLS**: Asegúrate de que `auth.uid()` funcione correctamente
- **Roles**: Solo 3 roles permitidos (no más)
- **Validaciones**: Las restricciones CHECK garantizan integridad

## ✅ Checklist de Setup

- [ ] Crear tabla `users` con índices
- [ ] Crear tabla `sectors` con índices
- [ ] Crear tabla `vaccinations` con índices
- [ ] (Opcional) Crear tabla `sync_queue`
- [ ] Habilitar RLS en todas las tablas
- [ ] Crear políticas RLS
- [ ] Insertar datos de prueba
- [ ] (Opcional) Crear bucket de storage
- [ ] Probar conexión desde app

## 🧪 Verificar Setup

```sql
-- Ver todas las tablas creadas
SELECT tablename FROM pg_catalog.pg_tables 
WHERE schemaname = 'public';

-- Ver políticas RLS
SELECT schemaname, tablename, policyname, qual, with_check
FROM pg_policies
WHERE schemaname = 'public';

-- Ver usuarios
SELECT id, cedula, name, email, role FROM users;

-- Ver vacunaciones totales
SELECT COUNT(*) as total_vaccinations FROM vaccinations;
```

## 🆘 Troubleshooting

**Error: "Auth uid is null"**
- Verifica que el usuario esté autenticado antes de hacer queries

**Error: "Permission denied"**
- Revisa las políticas RLS
- Asegúrate que el usuario tiene el rol correcto

**Error: "Relation not found"**
- Ejecuta el SQL en el editor de Supabase
- Verifica los nombres exactos de las tablas

---

**Próximo paso:** Actualizar `SUPABASE_URL` y `SUPABASE_ANON_KEY` en `lib/main.dart` con tus valores reales.
