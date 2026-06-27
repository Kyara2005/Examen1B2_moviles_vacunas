# Campaña de vacunación canina y felina

Proyecto Flutter sencillo para gestionar una campaña de vacunación de perros y gatos usando Supabase.

## Link del video:

```text
VIDEO FALTA
```

## Tecnologias

- Flutter
- Supabase Auth, Database y Storage
- SharedPreferences para registros pendientes offline
- image_picker para fotografias
- geolocator para GPS
- connectivity_plus para detectar internet

## Estructura principal

```text
lib/
├── main.dart
├── constants/
├── database/
├── models/
├── screens/
├── services/
├── utils/
└── widgets/
```

## Configuracion

1. Crear el proyecto en Supabase.
2. Crear un usuario inicial en Supabase Auth.
3. Insertar ese usuario en la tabla `usuarios` con rol `coordinador_campana`.
4. Ejecutar la app con las credenciales:

La contrasena inicial para usuarios creados desde la app es:

```text
Ecuador2026
```

## Pantallas

- Login: ingreso con correo y contrasena usando Supabase Auth.
- Cambio de contrasena: aparece si el usuario tiene `debe_cambiar_clave`.
- Recuperacion de contraseña: envia correo desde Supabase Auth.
- Dashboard: muestra totales, perros, gatos, vacunaciones por sector, por vacunador y pendientes offline.
- Sectores: permite crear, editar y eliminar sectores para el coordinador de campana.
- Usuarios: permite crear coordinadores de brigada y vacunadores segun el rol.
- Vacunaciones: lista registros y aplica permisos de edicion.
- Registro de vacunacion: guarda datos, foto, GPS, fecha, hora, usuario y sector.
- Editar vacunacion: permite actualizar datos basicos segun permisos.
- Perfil: muestra datos del usuario actual.

## Servicios

- `AuthService`: login, cambio de clave, recuperacion y cierre de sesion.
- `SectorService`: CRUD de sectores.
- `UserService`: creacion y consulta de usuarios.
- `VaccinationService`: CRUD de vacunaciones y subida de fotos.
- `LocalStorageService`: guarda vacunaciones pendientes en SharedPreferences.
- `SyncService`: sincroniza pendientes cuando vuelve internet.
- `DashboardService`: calcula datos simples para el dashboard.

## Offline

Cuando no hay internet, el registro se guarda en SharedPreferences como pendiente. Cuando vuelve la conexion, `SyncService` envia esos registros a Supabase y limpia la lista local.

## Capturas de las pantallas
