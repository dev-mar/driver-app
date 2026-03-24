## Referencias de backend para la app de conductor

Este documento indica **qué archivos del backend** debe usar el equipo de Flutter (conductor) como referencia al implementar o ajustar funcionalidades.

---

### 1. Contrato HTTP (REST)

- **Fuente de verdad del contrato de la API REST**:
  - `app_texi_WebSocket/docs/API-CONTRACT.md`

Endoints relevantes para la app de conductor:

- Autenticación (otro servicio, ya configurado en la app):
  - `POST /api/v1/auth/login`
- Perfil y datos del conductor:
  - `GET /drivers/me`
  - `GET /drivers/me/profile-extended`
- Estado y ubicación:
  - `GET /drivers/me/status`
  - `GET /drivers/me/location`
- Billetera:
  - `GET /drivers/me/wallet`
- Viajes:
  - `GET /drivers/me/trips`
  - `POST /drivers/me/trips/{tripId}/accept`
  - `POST /drivers/me/trips/{tripId}/reject`
  - `POST /drivers/me/trips/{tripId}/arrived`
  - `POST /drivers/me/trips/{tripId}/started`
  - `POST /drivers/me/trips/{tripId}/completed`
  - `POST /drivers/me/trips/{tripId}/cancel`

Todas estas rutas usan el **mismo formato estándar de respuesta** definido en `API-CONTRACT.md`:

```json
{
  "success": true,
  "status_code": 200,
  "code": "ALGUN_CODIGO",
  "message": "Texto legible",
  "data": { ... }
}
```

y, en caso de error:

```json
{
  "success": false,
  "status_code": 400,
  "code": "ALGUN_ERROR",
  "message": "Descripción del error",
  "error": { "message": "detalle opcional" }
}
```

---

### 2. Contrato tiempo real (WebSocket) – Conductor

> Pendiente de documentar en un archivo propio (similar al contrato de pasajero).

Se recomienda crear `texi_driver_app/docs/DRIVER-REALTIME-BACKEND-CONTRACT.md` con:

- Eventos **que envía** el conductor:
  - `location:update`
  - `driver:setAvailability`
  - `trip:accept`
  - `trip:reject`
  - `trip:arrived`
  - `trip:started`
  - `trip:completed`
- Eventos **que recibe** el conductor:
  - `connection:ack`
  - `trip:offer`
  - `trip:accepted`
  - `trip:status`
  - `trip:error`
  - `driver:availability_ack` / `driver:availability_error`

Y para cada evento:

- Estructura del payload.
- Qué debe hacer la UI (ej. mostrar oferta, actualizar estado del viaje, etc.).

---

### 3. Documentos complementarios del backend útiles

- `app_texi_WebSocket/docs/PRODUCTION-TEST-GUIDE.md`
  - Para entender el flujo de pruebas end‑to‑end, especialmente conductor + pasajero + ofertas.
- `app_texi_WebSocket/docs/LOCATION-ZONE-VALIDATION.md`
  - Para diagnosticar problemas de cobertura / asignación de zonas al conductor.

---

### 4. Resumen para el equipo de conductor

Al implementar o modificar funcionalidades:

- **Para llamadas HTTP** (perfil, viajes, billetera, etc.):
  - Revisar siempre `app_texi_WebSocket/docs/API-CONTRACT.md`.
- **Para tiempo real (Socket.IO)**:
  - Usar, cuando exista, `texi_driver_app/docs/DRIVER-REALTIME-BACKEND-CONTRACT.md` como contrato de referencia.

Estos documentos centralizan la información necesaria para que la app de conductor se mantenga alineada con el backend.+
