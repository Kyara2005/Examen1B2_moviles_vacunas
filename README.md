# Campaña de Vacunación Canina y Felina
<p align="center">
    <img width="30%" alt="icon" src="https://github.com/user-attachments/assets/8538e34a-5bec-4c27-93ba-c86b75d3626d" />
</p>

Aplicación móvil desarrollada en Flutter para gestionar campañas de vacunación de perros y gatos en distintos sectores de una ciudad. Usando Supabase como backend para autenticación, base de datos y almacenamiento de fotos.

## Video demostrativo

En el siguiente video se presenta:

* Explicación del código desarrollado.
* Demostración del funcionamiento de la aplicación.
* Recorrido por el contenido del README.

**Video:**
https://youtu.be/dbsKEl0Mnzk

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

--------------------------

# Capturas del funcionamiento

## 🚀 Icono y Splash Screen

<p align="center">
  <img src="https://github.com/user-attachments/assets/29886c4f-15e4-4d5a-84a7-427a18e079c6" width="30%">
  <img src="https://github.com/user-attachments/assets/e1d889d4-b9cf-4374-98eb-84a585ca75b1" width="30%">
</p>

---

## 🔐 Login

<p align="center">
  <img src="https://github.com/user-attachments/assets/5dca1497-1b3e-4923-b0c1-c7c875c07630" width="30%">
</p>

---

## 🔑 Recuperar contraseña

<p align="center">
  <img src="https://github.com/user-attachments/assets/e4efe86d-8df8-43c3-9943-f73a52fed74b" width="30%">
  <img src="https://github.com/user-attachments/assets/1f740cc2-35cc-4a16-87ef-50d8996d6296" width="30%">
</p>

---
# 👤 Rol: Coordinador

### Inicio

<p align="center">
  <img src="https://github.com/user-attachments/assets/e8ea11fb-f0f9-4155-aa88-1e5a2aeedef4" width="23%">
  <img src="https://github.com/user-attachments/assets/3086ff32-f569-4d45-9728-7ecc374508e3" width="23%">
  <img src="https://github.com/user-attachments/assets/84138792-a00c-4d83-989c-1fdc8c016c88" width="23%">
  <img src="https://github.com/user-attachments/assets/7f57fcd1-2d43-49e6-baf2-9223e65e7e94" width="23%">
</p>
### Crear usuarios

<p align="center">
  <img src="https://github.com/user-attachments/assets/05cf5827-da1a-4418-8ab8-8314fde9735b" width="30%">
</p>

### Perfil

<p align="center">
  <img src="https://github.com/user-attachments/assets/bb8c5816-f013-4c89-a335-70ae8f73964f" width="30%">
</p>

---
  # 👷 Rol: Brigada

### Inicio

<p align="center">
  <img src="https://github.com/user-attachments/assets/0236f7c0-28ef-481a-abe5-199ad7cdbcec" width="30%">
</p>

### Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/7582eb21-c0f5-468a-a720-4df6563b1403" width="30%">
</p>

  ### Editor de vacunaciones

<p align="center">
  <img src="https://github.com/user-attachments/assets/4b91f53f-96a1-4a3b-86ee-2eeca4bfb11d" width="30%">
  <img src="https://github.com/user-attachments/assets/e2dc6ab1-69b2-420d-9a29-290b40bdce42" width="30%">
</p>

### Mi sector

<p align="center">
  <img src="https://github.com/user-attachments/assets/c637d3cb-e573-44c6-b753-2fe2ef4b7f50" width="30%">
</p>

  <p align="center">
      <img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/4b91f53f-96a1-4a3b-86ee-2eeca4bfb11d" />
      <img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/e2dc6ab1-69b2-420d-9a29-290b40bdce42" />
  </p>
  Mi sector
  <img width="698" height="1600" alt="image" src="https://github.com/user-attachments/assets/c637d3cb-e573-44c6-b753-2fe2ef4b7f50" />

  ### Usuarios

<p align="center">
  <img src="https://github.com/user-attachments/assets/b8020e31-1422-461f-9331-997533199bf1" width="30%">
</p>

### Crear usuarios

<p align="center">
  <img src="https://github.com/user-attachments/assets/191c6abd-a52a-4491-87d6-359f8efb2828" width="30%">
</p>

  ### Perfil

<p align="center">
  <img src="https://github.com/user-attachments/assets/c849a36e-4982-45ee-ad8b-4b3fc167b7e7" width="30%">
</p>

---

# 💉 Rol: Vacunador

### Inicio

<p align="center">
  <img src="https://github.com/user-attachments/assets/40878d56-6397-42d4-8867-ed169651c820" width="30%">
</p>

### Dashboard

<p align="center">
  <img src="https://github.com/user-attachments/assets/a2f90688-38e2-4142-bee1-497e089c9f7b" width="30%">
</p>

### Vacunaciones

<p align="center">
  <img src="https://github.com/user-attachments/assets/805af621-e3a6-4936-8708-b59ef735d7e3" width="30%">
</p>

### Registro de vacunación

<p align="center">
  <img src="https://github.com/user-attachments/assets/abfb6d4a-4bf5-4d52-983a-fac7e0e2b119" width="30%">
</p>
```

