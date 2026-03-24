# Etapa 1 Cierre — conductor + pendientes (proxima etapa)

Documento vivo para dejar **cerrada la primera etapa** (UI/flujo y control básico) y recopilar **pendientes recomendados** para la etapa 2.

## A) Lo que se considera cerrado en Etapa 1

### A.1 Conductor / estado y UI
- Card retraible del viaje: sin texto “Retraer”, solo barrita y flecha; expandir/colapsar consistente (evitar recortes).
- Al expandir nuevamente, el detalle del viaje se vuelve a visualizar (botones de navegación y contenido del viaje).
- Botones de navegación del viaje (`Navegar al origen / Navegar al destino`) abren Google Maps externo (sin key adicional).

### A.2 Control de privacidad y cumplimiento base (Play)
- Permisos ya alineados en manifest/plist para ubicación y notificaciones (local).
- Diálogo de divulgación previo para ubicación en segundo plano antes de escalar permisos (App/Android/iOS según aplique).

### A.3 Registro de conductor (flujo UI completo)
- Flujo de registro de 4 pasos con:
  - Validación por paso (habilita avanzar o muestra error).
  - Error claro cuando falta información obligatoria.
  - Finalización con diálogo y salida hacia login (sin depender todavía de endpoints).

## B) Pendientes recomendados para Etapa 2

### B.1 Notificaciones cuando no hay socket (recomendado: FCM)
- Migrar/crear camino robusto para que `trip:offer` siempre notifique aun cuando el proceso sea suspendido.
- Implementar backend -> FCM (guardar token por `driverId`, invalidar en logout).
- Ajustar documentación y Data safety en Play para “notificaciones”.

### B.2 Navegación in-app “turn-by-turn”
- Hoy: navegación abre Google Maps externo y muestra ruta.
- Si se requiere navegación dentro de la app, evaluar:
  - Google Navigation SDK (licenciamiento/condiciones).
  - Alternativa: mantener externo para evitar riesgo legal/costo/soporte.

### B.3 Seguridad legal de claves (operativo)
- Restringir clave de Google Maps en Google Cloud por `packageName + SHA-1` y APIs habilitadas solo para Maps.
- Rotar claves si se sospecha exposición.

### B.4 Checklist Play Console final
- Política de privacidad y términos publicados y enlazados.
- Completar Data safety con verdad: ubicación precisa + finalidad.
- Video/justificación para permisos sensibles (segundo plano) con el flujo real.

## C) Pruebas que se recomiendan ejecutar al finalizar cada cambio

1. Oferta y switch: aceptas `trip:offer`, activas `online`, verificas sonido/alerta según foreground/background.
2. Viaje completo: `arrived -> started -> completed`, verificar que el switch vuelve a disponible sin re-toggle manual.
3. UX de tarjeta: colapsar/expandir durante `started` y comprobar que no “pierde” contenido.
4. Registro:
   - Validar que cada paso bloquea avanzar si falta info obligatoria.
   - Agregar y eliminar vehículos correctamente.
   - Confirmar que “Finalizar registro” muestra diálogo y retorna a login.

## D) Documentos de apoyo (ubicaciones)
- `docs/GOOGLE-PLAY-CONSOLE-Y-CUMPLIMIENTO.md`
- `docs/FCM-Y-NOTIFICACIONES-CONDUCTOR.md`
- `docs/APP-IMPLEMENTATION-ORDER-CONDUCTOR.md`

