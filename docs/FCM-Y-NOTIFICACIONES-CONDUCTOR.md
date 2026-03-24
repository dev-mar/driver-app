# FCM y notificaciones push — conductor (plan recomendado)

Las **notificaciones locales** (`flutter_local_notifications`) solo funcionan si el proceso de la app sigue en memoria. En Android, el sistema puede suspender o matar el proceso; en ese caso **no habrá sonido ni banner** hasta que el usuario abra la app de nuevo.

## Objetivo
Complementar el sistema actual con **Firebase Cloud Messaging (FCM)** para que el **backend** envíe un push cuando exista `trip:offer` (o resumen) y el conductor esté marcado como elegible pero la app no garantice socket activo.

## Requisitos
1. Proyecto Firebase vinculado a la app Android (package name + `google-services.json`).
2. En Play Console: declarar uso de notificaciones y finalidad (avisos operativos del servicio).
3. Backend: endpoint o worker que envíe a FCM con el token del dispositivo del conductor (guardar token asociado a `driverId`, invalidar al logout).

## Eventos sugeridos
- `trip_offer` — datos mínimos: `tripId`, precio, ETA; al tocar la notificación abrir la app en pantalla de ofertas.
- Opcional: `trip_status` solo si hay requisito legal de trazabilidad (evitar spam).

## Privacidad
- Payload FCM: **no** incluir datos innecesarios (dirección exacta del pasajero en claro puede minimizarse).
- El token FCM es identificador de dispositivo: incluirlo en el inventario de datos para Data safety.

## Implementación en Flutter (cuando proceda)
- Dependencias: `firebase_core`, `firebase_messaging`.
- Solicitar permiso en iOS; Android 13+ ya alineado con notificaciones locales.
- En `main.dart`: inicializar Firebase y registrar handlers `onMessage` / `onMessageOpenedApp`.

## Alternativa empresarial
Google también admite notificaciones de alta prioridad solo para casos que cumplen políticas; mantener la categoría **“time-sensitive”** o equivalente alineada con documentación FCM y Play.

---

*Este archivo describe el camino estándar de la industria; el código FCM se añade cuando exista `google-services.json` en el entorno de build.*
