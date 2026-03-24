# Registro de conductor — contrato de endpoints (app Flutter)

Resumen de lo implementado en `texi_driver_app` para alinear con backend. **Geo y usuarios usan hosts distintos** (no mezclar con Socket.IO ni con otros baseUrl ya usados en tiempo real).

## 1) Geo (árbol país → departamento → localidad)

**Base URL:** `DriverGeoBackendConfig.baseUrl`  
(`http://ec2-3-18-6-233.us-east-2.compute.amazonaws.com:8003`)

| Método | Ruta | Uso |
|--------|------|-----|
| GET | `/api/v1/geo/full-tree` | Lista de países (`code: OK`, `data: [...]`). |
| GET | `/api/v1/geo/full-tree/{countryName}` | Departamentos + localidades. `{countryName}` = nombre exacto del país (ej. `Bolivia`), codificado en URL. |

**Regla de producto:** solo **Bolivia** tiene datos de departamento/localidad por ahora. Si el usuario elige otro país, la app muestra aviso y no permite completar el paso 1 hasta elegir Bolivia.

## 2) Usuarios / registro conductor y vehículo

**Base URL:** `DriverUsersBackendConfig.baseUrl`  
(misma que login: `http://ec2-3-150-198-57.us-east-2.compute.amazonaws.com:8001`)

### 2.1 Datos personales
`POST /api/v1/users/driver/personal-info`

Cuerpo (JSON): `first_name`, `last_name`, `email`, `birth_date` (ISO `YYYY-MM-DD`), `phone_number`, `locality_id` (int de la localidad elegida), `profession` (la app envía siempre `"driver"`), `address`, `gender` (`Male` / `Female` / `Other`), `password`.

**Teléfono:** la app no aplica reglas estrictas por país todavía (enfoque Bolivia + funcionalidad). Solo exige valor no vacío y, si el usuario no escribe `+`, se antepone para coincidir con el flujo de login. La validación dinámica por país quedará para una capa posterior.

Respuesta esperada (estándar): `success`, `data.uuid` guardado para los siguientes pasos.

### 2.2 Documento de identidad + rostro
`POST /api/v1/users/driver/document-info`

- `document_type`: **1** (fijo).
- `uuid`, `document_number`, `front_document`, `back_document`, `face_image`, `expire_date` (ISO fecha).

### 2.3 Licencia (mismo endpoint, otro `document_type`)
`POST /api/v1/users/driver/document-info`

- `document_type`: id de categoría (**2** A, **3** B, **4** C, **7** M, **8** Internacional).
- `document_number`: mismo que en identidad (no se vuelve a pedir en UI).
- `front_document`, `back_document`, `expire_date`. Sin `face_image`.

### 2.4 Activar usuario (antes del login)

`PUT /api/v1/users/driver/update-user`  

**Body (JSON):** `{ "uuid": "<uuid del usuario>" }`  

**Respuesta esperada (ej.):** `success: true`, `code: "USER_STATUS_UPDATED"`, etc.

Tras cargar **licencia**, al pulsar **Activar** la app llama primero a este endpoint para actualizar el estado del usuario y **permitir** el login. Luego `POST /api/v1/auth/login` y se guarda `driver_token` para el alta del vehículo.

### 2.5 Login (ya existente en app)
`POST /api/v1/auth/login` — teléfono + contraseña (`DriverLoginController`). Opcionalmente la app envía `driver_registration_in_progress: true` en el body.

**Resiliencia:** si el login falla con mensaje de registro incompleto pero ya existe token en almacenamiento (respuestas anteriores), se puede continuar; el flujo habitual es **PUT update-user → login**.

**Recomendación backend:** aceptar `driver_registration_in_progress: true` en login si aplica; incluir `token` en respuestas de registro solo si el producto lo requiere.

### 2.6 Vehículo (**solo con sesión**)
`POST /api/v1/users/vehicle`  
Header: **`Authorization: Bearer <driver_token>`** (obligatorio). El token se obtiene con el login **después** de `PUT update-user` y `POST /api/v1/auth/login`.

Cuerpo: `brand`, `model`, `year` (int), `color`, `insurance_policy`, `license_plate`, `tittle_deed` (typo del API), `vin`.

Respuesta: `data.car_uuid`.

### 2.7 Fotos del vehículo (4 lados, **solo con sesión**)
`POST /api/v1/users/vehicle/images-car`  
Header: **`Authorization: Bearer <driver_token>`** (obligatorio).

Cuerpo: `car_id` (uuid string), `cars`: array de `{ image: base64, image_name }` con nombres:
- `front_view.jpg`
- `back_view.jpg`
- `left_side_view.jpg`
- `rigth_side_view.jpg` (typo intencional según contrato backend)

**Cliente:** para las fotos del vehículo se usa recorte/compresión algo más agresiva (ancho máx. ~1400 px, ~750 KB por imagen) para limitar el tamaño del JSON y reducir **timeouts** o **500** por carga en servidor.

**Si falla “Error del servidor” al finalizar:** revisar en consola (modo debug) líneas `[DriverRegistration] submitVehicleImages` con `status` HTTP y cuerpo de respuesta; causas habituales: **500** interno en API, **413** payload demasiado grande, **timeout**, token inválido o `car_id` incorrecto.

## 3) Imágenes

Se usa `image_picker` + Base64 **sin** prefijo `data:image/...` (igual criterio que en pasajero, con límite de tamaño en helper).

## 4) Estrategia de envío y botón «Anterior»

**Cómo funciona hoy (app):** el registro **no espera al final**: en cada etapa se llama al endpoint correspondiente cuando el usuario pulsa **Continuar** / **Activar** / **Finalizar** (datos personales → documentos de identidad → licencia → **PUT update-user** → login → vehículo → fotos). Eso permite validar en servidor por pasos; el token exige login tras activar el usuario.

**¿Por qué no “solo enviar al activar”?** Los endpoints actuales están pensados como **POST por recurso**. Agrupar todo en un único envío al paso “Activar” implicaría **un contrato nuevo** (un solo body grande o cola interna en el cliente) y seguiría necesitando imágenes y token en el orden correcto. No está implementado así.

**Si el usuario vuelve atrás y cambia algo** (ej. teléfono tras ya haber creado usuario): sin **PUT/PATCH** en backend, el servidor puede tener datos viejos o rechazar duplicados. Opciones de producto:

| Enfoque | Notas |
|--------|--------|
| **Backend** | Exponer actualización parcial (`PATCH` usuario / reemplazar documentos) o idempotencia clara en re-`POST`. |
| **Cliente** | Aviso al volver atrás: “Los cambios en pasos ya enviados pueden requerir ayuda si falla el guardado.” |
| **Flujo estricto** | Bloquear retroceso después del paso X (mala UX) o forzar “reiniciar registro”. |

**Recomendación práctica:** mantener el flujo incremental y, si el producto exige edición libre, alinear con el backend **actualizaciones** o **nuevo registro** según reglas de negocio.

## 5) Próximos pasos sugeridos

- Menú **“Mis vehículos”** reutilizando los mismos endpoints para altas adicionales.
- Sustituir lista fija de colores / marcas por endpoints livianos si el backend los expone.
- Endpoints para categorías de licencia en lugar de constantes en app.
- Endpoints `PATCH` o política de reintento si se permite editar pasos ya enviados.
