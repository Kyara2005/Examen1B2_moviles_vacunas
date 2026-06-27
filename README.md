# Campaña de Vacunación Canina y Felina

Aplicación móvil desarrollada en Flutter para gestionar campañas de vacunación de perros y gatos en distintos sectores de una ciudad. Usando Supabase como backend para autenticación, base de datos y almacenamiento de fotos.

## Link del video

```text
VIDEO FALTA
```

---

## Tecnologías utilizadas

| Paquete | Uso |
|---|---|
| `supabase_flutter` | Autenticación, base de datos y storage |
| `shared_preferences` | Sesión local y registros offline |
| `image_picker` | Captura de fotografías con la cámara |
| `geolocator` | Obtención de coordenadas GPS |
| `connectivity_plus` | Detección de conexión a internet |
| `flutter_native_splash` | Pantalla de splash al iniciar la app |
| `flutter_launcher_icons` | Ícono de la app |

---

## Roles y funcionalidades

La app maneja tres roles con permisos distintos. Los usuarios no se autoregistran; son creados por el rol superior. En este caso, el rol superior (coordinador_campaña) tiene las siguientes credenciales:
correo: kyaramaltamirano@gmail.com
contraseña: Ecuador2026
nota: no se creo el cambio de contraseña para este rol por ser el coordinador de campaña por default.

### Coordinador de campaña
Es el administrador general del sistema. Puede:
- Crear, editar y eliminar **sectores** de la ciudad.
- Asignar un **coordinador de brigada** a cada sector directamente desde el formulario de edición del sector.
- Crear **coordinadores de brigada** y asignarles su sector.
- Ver el **dashboard general** con estadísticas de toda la campaña: total de vacunaciones, perros, gatos, vacunaciones por sector y por vacunador.

### Coordinador de brigada
Gestiona su sector asignado. Puede:
- Ver el **sector que le fue asignado** con sus permisos detallados.
- Crear **vacunadores** y asignarlos o reasignarlos a sectores.
- Ver y **corregir cualquier registro de vacunación** de su sector.
- Ver el **dashboard filtrado** por su sector.

### Vacunador
Realiza el trabajo de campo. Puede:
- Ver únicamente los **sectores que tiene asignados**.
- **Registrar vacunaciones** con todos los datos requeridos: foto, GPS, propietario, mascota, vacuna aplicada, fecha y hora automáticas.
- **Editar sus propios registros** (no los de otros vacunadores).
- Registrar vacunaciones **sin internet** — se guardan en el teléfono y se sincronizan automáticamente cuando vuelve la conexión.

---

## Gestión de usuarios

- Los usuarios **no se autoregistran**; los crea el rol superior desde la pantalla de Usuarios.
- Al crear un usuario, la contraseña inicial es `Ecuador2026`.
- En el **primer inicio de sesión**, la app detecta el campo `debe_cambiar_clave` y redirige obligatoriamente a la pantalla de cambio de contraseña.
- La recuperación de contraseña se realiza por **correo electrónico** usando Supabase Auth.
- Datos obligatorios al crear un usuario: cédula, nombres, apellidos, teléfono y correo.

---

## Registro de vacunación

Cada vacunación guarda los siguientes datos:

| Campo | Descripción |
|---|---|
| Propietario | Nombre del dueño de la mascota |
| Cédula | Cédula del propietario |
| Teléfono | Contacto del propietario |
| Tipo de mascota | Perro o Gato |
| Nombre de la mascota | Nombre del animal |
| Edad aproximada | Edad estimada del animal |
| Sexo | Macho o Hembra |
| Vacuna aplicada | Nombre de la vacuna (por defecto: Antirrábica) |
| Observaciones | Notas adicionales del vacunador |
| Fotografía | Tomada con la cámara, subida a Supabase Storage |
| Latitud y longitud | Capturadas automáticamente con GPS al abrir el formulario |
| Fecha y hora | Generadas automáticamente al guardar |
| Sector | Sector asignado al vacunador |

---

## Funcionamiento offline

La app está diseñada para que el vacunador pueda trabajar en campo sin internet:

1. **Sesión persistente:** al iniciar sesión con internet, los datos del usuario se guardan en `SharedPreferences`. La próxima vez que se abra la app sin internet, `main.dart` detecta la sesión guardada y va directo al Dashboard sin pedir login.

2. **Sectores en caché:** la primera vez que el vacunador abre el formulario con internet, los sectores asignados se guardan localmente. Sin internet, el dropdown de sector carga desde el teléfono.

3. **Registro offline:** si no hay internet al guardar una vacunación, el registro se serializa a JSON y se guarda en `SharedPreferences` como pendiente.

4. **Sincronización automática:** `SyncService` escucha los cambios de conectividad en segundo plano. En cuanto detecta que volvió el internet, sube automáticamente todos los registros pendientes a Supabase y los elimina del almacenamiento local. El Dashboard muestra cuántos registros están pendientes de sincronización.

---

## Dashboard

Muestra estadísticas en tiempo real filtradas según el rol:

- **Total de vacunaciones** registradas
- **Perros** vacunados
- **Gatos** vacunados
- **Pendientes de sincronización** (registros guardados sin internet)
- **Vacunaciones por sector** — con nombre real del sector
- **Vacunaciones por vacunador** — con nombre completo del vacunador

El coordinador de campaña ve datos globales. El coordinador de brigada ve solo su sector. El vacunador ve solo sus propios registros.

---

## Estructura del proyecto

```
lib/
├── main.dart                        
├── constants/
│   └── app_constants.dart           
├── models/
│   ├── app_user.dart                
│   ├── sector.dart                  
│   └── vacunaciones.dart            
├── screens/
│   ├── login_screen.dart            
│   ├── change_password_screen.dart  
│   ├── recovery_screen.dart         
│   ├── dashboard_screen.dart        
│   ├── sectors_screen.dart          
│   ├── misector_screen.dart         
│   ├── users_screen.dart            
│   ├── vacunaciones_screen.dart     
│   ├── vacunaciones_form_screen.dart
│   ├── edit_vacunaciones_screen.dart
│   └── profile_screen.dart          
├── services/
│   ├── auth_service.dart            
│   ├── sector_service.dart          
│   ├── user_service.dart            
│   ├── vaccination_service.dart     
│   ├── dashboard_service.dart       
│   ├── local_storage_service.dart   
│   ├── sync_service.dart            
│   ├── connectivity_service.dart    
│   └── supabase_service.dart        
├── widgets/
│   ├── app_drawer.dart              
│   └── stat_card.dart               
└── utils/
    └── simple_validators.dart       
```

---

## Configuración inicial

### 1. Crear el proyecto en Supabase
Para el funcionamiento del sistema se necesita crear las tablas `usuarios`, `sectores` y `vacunaciones`. (Ya fueron creadas)

### 2. Configurar las credenciales
En `lib/constants/app_constants.dart` hay que colocar la URL y la anon_key del proyecto Supabase:

```dart
static const String supabaseUrl = 'TU_URL';
static const String supabaseAnonKey = 'TU_ANON_KEY';
```

### 3. Crear el primer usuario
El primer coordinador de campaña debe crearse manualmente:
- Se debe crear el usuario en **Supabase Auth** con correo y contraseña `Ecuador2026`.
- Luego asignarlo en la tabla `usuarios` con `rol = 'coordinador_campana'`.

### 4. Ejecutar la app
```bash
flutter pub get
flutter run
```

---

## Capturas de pantallas

*(agregar capturas aquí)*
