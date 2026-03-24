## Contrato tiempo real (WebSocket) – App de Conductor

Documento para alinear cómo la app de **conductor** se conecta al backend por Socket.IO, qué eventos **envía**, qué eventos **recibe**, y qué se espera que haga la app con cada uno.

---

## 1. Conexión Socket.IO

- **URL Socket.IO**: ver `DriverRealtimeConfig.socketUrl` en la app.
- **Path**: `/socket.io/`
  - **Importante**: este path va en la **raíz del host** de websockets.
  - **No** usar `/api/v1/socket.io/` para Socket.IO en este proyecto.
  - `/api/v1` aplica a endpoints REST/auth (ej. login), no al canal realtime Socket.IO.
- **Autenticación**:
  - Header `Authorization: Bearer <driver_token>`
  - El token viene del login `POST /api/v1/auth/login`.
  - El backend valida que el `uuid` del token exista como conductor activo (`type_user_id = 10`).

Al conectar correctamente, el backend:

- Marca al conductor como conectado (`realtime.driver_status.is_online = true`).
- Responde por WebSocket con el evento `connection:ack`.

---

## 2. Evento `connection:ack` (Server → Conductor)

Se envía cuando el Socket se conecta correctamente.

**Canal**: `connection:ack`

**Payload (resumen):**

```json
{
  "ok": true,
  "serverTime": "2026-03-17T01:00:00.000Z",
  "profile": {
    "driverId": 117,
    "uuid": "0b1a193f-2f40-444d-a322-8d39eb98bac4",
    "userName": "+5917xxxxxxx",
    "userStatus": "active",
    "fullName": "Juan Pérez",
    "vehicle": {
      "id": 10,
      "brand": "Toyota",
      "model": "Corolla",
      "licensePlate": "ABC-1234",
      "serviceTypeId": 1
    }
  },
  "status": {
    "isOnline": true,
    "availability": "available",
    "lastPing": "2026-03-17T01:00:00.000Z"
  },
  "wallet": {
    "balance": 100.5,
    "currency": "BOB",
    "isActive": true
  },
  "hasActiveTrip": false,
  "activeTrip": null
}
```

La app de conductor debe usar este payload para:

- Inicializar la UI de Home (nombre, vehículo, estado).
- Saber si hay un `activeTrip` pendiente al reconectar (mostrar directamente la pantalla de viaje activo).

---

## 3. Eventos que ENVÍA el conductor

### 3.1 `location:update`

- **Uso**: enviar la ubicación GPS periódicamente cuando el conductor está “en línea”.
- **Emisor**: app de conductor.
- **Payload**:

```json
{
  "lat": -17.39,
  "lng": -66.15,
  "bearing": 0.0,   // opcional
  "speed": 5.5      // opcional (m/s)
}
```

El backend:

- Actualiza Redis (posición en tiempo real).
- El worker persiste en `realtime.driver_status.current_location`.
- Si hay un viaje activo con un pasajero, envía `trip:driver_location` al pasajero asociado.

### 3.2 `driver:setAvailability`

- **Uso**: cambiar el estado de disponibilidad del conductor.
- **Valores permitidos**: `available`, `busy`, `on_break`.
- **Payload**:

```json
{
  "availability": "available"
}
```

El backend:

- Actualiza `realtime.driver_status.availability`.
- Responde con:
  - `driver:availability_ack` en caso de éxito.
  - `driver:availability_error` en caso de error de validación.

### 3.3 Eventos de ciclo de vida del viaje

- `trip:accept` – aceptar oferta (desde app, alternativa al REST).
- `trip:reject` – rechazar oferta.
- `trip:arrived` – marcar llegada al punto de recogida.
- `trip:started` – iniciar viaje (pasajero a bordo).
- `trip:completed` – finalizar viaje.

**Formato mínimo**:

```json
{
  "tripId": "uuid-del-viaje"
}
```

El backend:

- Ejecuta la misma lógica que los endpoints REST equivalentes.
- Emite eventos al propio conductor y al pasajero (ver sección 4).

---

## 4. Eventos que RECIBE el conductor

### 4.1 `trip:offer`

Se envía cuando hay una nueva oferta de viaje para este conductor.

**Payload típico:**

```json
{
  "tripId": "uuid",
  "offeredPrice": 15.5,
  "etaMinutes": 3,
  "distanceToPickupKm": 1.2,
  "passengerName": "Ana López",
  "passengerRating": 4.8,
  "originAddress": "Av. Busch 123, Cochabamba",
  "destinationAddress": "Plaza 14 de Septiembre",
  "tripDistanceKm": 5.2,
  "etaToDestinationMinutes": 18
}
```

La app debe:

- Mostrar una tarjeta de oferta con:
  - Precio ofrecido.
  - ETA estimado.
  - Distancia al punto de recogida.
- Permitir **Aceptar** (`trip:accept`) o **Rechazar** (`trip:reject`).

### 4.2 `trip:accepted` (para el conductor)

Confirmación de que el viaje fue aceptado correctamente.

**Payload**: el mismo objeto que devuelve el backend en REST `POST /drivers/me/trips/{tripId}/accept`, incluyendo:

```json
{
  "tripId": "uuid",
  "passengerId": "107",
  "driverId": 117,
  "status": "accepted",
  "estimatedPrice": 15.5,
  "createdAt": "2026-03-13T22:20:51.725Z",
  "updatedAt": "2026-03-13T22:21:29.476Z",
  "origin": { "lat": -17.3895, "lng": -66.1534 },
  "destination": { "lat": -17.3712, "lng": -66.1501 },
  "passengerName": "Ana López",
  "passengerRating": 4.8,
  "originAddress": "Av. Busch 123, Cochabamba",
  "destinationAddress": "Plaza 14 de Septiembre",
  "tripDistanceKm": 5.2,
  "etaToDestinationMinutes": 18
}
```

La app debe:

- Cambiar a pantalla de viaje activo.
- Mostrar ruta desde el conductor al origen y luego origen→destino (usando `origin`/`destination`).

### 4.3 `trip:status`

Actualizaciones de estado del viaje (`arrived`, `started`, `completed`, `cancelled`, `expired`).

**Payload típico:**

```json
{
  "tripId": "uuid",
  "status": "arrived",
  "driverId": 117,
  "updatedAt": "2026-03-13T22:25:00.000Z",
  "isFinal": false,
  "endedReason": null
}
```

Cuando el viaje termina (por ejemplo en `completed`, `cancelled`, `expired`), se envía:

```json
{
  "tripId": "uuid",
  "status": "completed",
  "driverId": 117,
  "updatedAt": "2026-03-13T22:30:00.000Z",
  "isFinal": true,
  "endedReason": "completed"
}
```

La app debe:

- Actualizar la UI según el estado:
  - `arrived` → mostrar “Has llegado al punto de recogida”.
  - `started` → “Viaje en curso”.
  - `completed` → finalizar flujo y volver a estado disponible.

### 4.4 `trip:error`

Errores relacionados con ofertas o cambios de estado enviados desde el backend.

**Payload:**

```json
{
  "code": "OFFER_EXPIRED",
  "message": "La oferta ha expirado"
}
```

La app debe:

- Mostrar un mensaje de error claro.
- Actualizar la UI acorde (por ejemplo, cerrar la tarjeta de oferta si ya expiró).

### 4.5 `driver:availability_ack` / `driver:availability_error`

Respuestas a `driver:setAvailability`.

- `driver:availability_ack`:

```json
{
  "ok": true,
  "availability": "available"
}
```

- `driver:availability_error`:

```json
{
  "ok": false,
  "code": "INVALID_AVAILABILITY",
  "message": "Valor de availability no permitido"
}
```

La app debe:

- Actualizar el switch “En línea” según `availability`.
- Mostrar errores claros si no se pudo cambiar la disponibilidad.

---

## 5. Resumen para el equipo de conductor

- **Conexión**:
  - Usar el token del login como `Bearer` para conectar vía Socket.IO.
  - Al conectarse, usar `connection:ack` para inicializar perfil, estado y viaje activo.
- **Ubicación y disponibilidad**:
  - Mientras el switch “En línea” esté activo:
    - Enviar `location:update` periódicamente con `lat`/`lng`.
    - Mantener `availability = 'available'` para recibir ofertas.
- **Ofertas y ciclo de vida del viaje**:
  - Escuchar `trip:offer` → mostrar oferta → responder con `trip:accept` o `trip:reject`.
  - Escuchar `trip:accepted`, `trip:status` → actualizar la pantalla de viaje activo.
  - Usar `trip:arrived`, `trip:started`, `trip:completed` para avanzar el estado desde la app.

Este documento, junto con `app_texi_WebSocket/docs/API-CONTRACT.md`, define el contrato completo entre la app de conductor y el backend (REST + WebSocket).+
