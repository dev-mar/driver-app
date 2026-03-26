## Plan de implementación – App Conductor

Este documento ordena el trabajo pendiente de Flutter (conductor) según lo ya implementado y lo que falta.

---

### 0) Referencias que NO deben duplicarse

- **Reglas de trabajo (i18n, strings, UX, PRs):** [TEAM-WORKING-RULES.md](TEAM-WORKING-RULES.md)
- Contrato HTTP (REST): `app_texi_WebSocket/docs/API-CONTRACT.md`
- Contrato WebSocket (conductor): `texi_driver_app/docs/DRIVER-REALTIME-BACKEND-CONTRACT.md`
- Play Store / privacidad / seguridad: `texi_driver_app/docs/GOOGLE-PLAY-CONSOLE-Y-CUMPLIMIENTO.md`
- Push FCM (futuro): `texi_driver_app/docs/FCM-Y-NOTIFICACIONES-CONDUCTOR.md`
- Registro conductor (REST + geo): `texi_driver_app/docs/DRIVER-REGISTRATION-BACKEND.md`

---

### 1) Ya tenemos (alineado con backend)

#### 1.1 REST

- Perfil básico: `GET /drivers/me`
- Perfil extendido (nuevo): `GET /drivers/me/profile-extended`
- Viaje activo (nuevo para rehidratación): `GET /drivers/me/active-trip`
- Estado + ubicación:
  - `GET /drivers/me/status`
  - `GET /drivers/me/location`
- Viajes y cambios de estado:
  - `POST /drivers/me/trips/:tripId/accept`
  - `POST /drivers/me/trips/:tripId/reject`
  - `POST /drivers/me/trips/:tripId/arrived`
  - `POST /drivers/me/trips/:tripId/started`
  - `POST /drivers/me/trips/:tripId/completed`
  - `POST /drivers/me/trips/:tripId/cancel`

#### 1.2 WebSocket (conductor)

- Conexión y `connection:ack` (incluye `hasActiveTrip` + `activeTrip`)
- Eventos de oferta:
  - `trip:offer` ya incluye enriquecimiento del pasajero y del trayecto:
    - `passengerName`, `passengerRating` (null), `originAddress`/`destinationAddress` (null),
      `distanceToPickupKm`, `tripDistanceKm`, `etaToDestinationMinutes`
- Ciclo de vida:
  - `trip:accepted`, `trip:status`, `trip:error`

#### 1.3 Disponibilidad al completar

- El backend marca disponibilidad `available` al `trip:completed`.
- Además emite explícitamente `driver:availability_ack` con:
  - `availability: available` y `reason: trip_completed`
- Esto aplica tanto si se completa por WebSocket como por REST.

---

### 2) Falta / tareas por implementar (orden sugerido)

#### 2.1 UI del switch “En línea” sin re-toggle (IMPORTANTE)

- Asegurar que la app escucha:
  - `driver:availability_ack` y, si `availability == 'available'`, setear el switch ON/estado interno a “Disponible”.
- Evitar que el estado quede “cerrado” si el viaje terminó mientras app estuvo en background.

#### 2.2 Rehidratación de viaje activo al reconectar

- Al reconectar socket:
  - Usar `connection:ack.activeTrip` si `hasActiveTrip == true`.
- Plan B recomendado:
  - Usar REST `GET /drivers/me/active-trip` si el socket no trae `activeTrip` o falla.

#### 2.3 Idempotencia al completar offline

- Si el conductor intenta mandar `completed` dos veces o tarde:
  - El backend responde con error por transición inválida (`INVALID_STATUS_TRANSITION` en logs).
- Tarea en app:
  - Tratar esos errores como “ya se completó” si `GET /drivers/me/active-trip` no devuelve el viaje activo.

#### 2.4 Reconocimiento de finalización por evidencia backend

- Hoy el backend finaliza trips solo por eventos (arrived/started/completed) o por lógicas de expiración/cancelación.
- Si el conductor pierde conexión, NO hay auto-completion garantizado.
- Tarea en app:
  - Usar sync REST para restaurar el estado real (via `GET /drivers/me/active-trip`).

---

### 3) Pruebas mínimas recomendadas

1. Aceptar oferta y poner el switch ON.
2. Enviar `started` y luego background app (sin cerrar).
3. Completar viaje y verificar:
   - switch vuelve a disponible sin reactivar manualmente
   - el backend envía `driver:availability_ack`.
4. Cerrar app y volver a abrir:
   - debe rehidratar con `connection:ack` o `GET /drivers/me/active-trip`.

