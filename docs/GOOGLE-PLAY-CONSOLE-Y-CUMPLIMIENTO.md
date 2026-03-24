# Google Play Console, cumplimiento legal y seguridad — App conductor (Texi)

Guía interna para preparar el alta en Play Store y alinear desarrollo con políticas de Google, privacidad y buenas prácticas de seguridad. **No sustituye asesoría legal**; revisar con abogado/lOPD según jurisdicciones (UE, Bolivia, etc.).

---

## 1. Información típica que pedirá Play Console

### 1.1 Ficha de la aplicación
| Campo | Recomendación |
|--------|----------------|
| **Nombre corto** | Marca registrada o nombre comercial acordado (evitar “Uber clone”). |
| **Descripción corta/larga** | Describir solo funciones reales: conexión conductor-pasajero, mapa, disponibilidad, notificaciones de ofertas. Sin promesas de ingresos engañosas. |
| **Categoría** | Maps & navigation / Travel & local (según encaje real). |
| **Icono, capturas, video** | Material original o con licencia; mismo idioma que mercado objetivo. |
| **Sitio web y correo de soporte** | URL pública y emailMonitorizado (obligatorio para apps con cuentas de usuario). |
| **Política de privacidad** | URL **accesible** y actualizada (ver §3). Obligatoria si se recolectan datos personales o ubicación. |

### 1.2 Declaraciones de permisos sensibles (Play)
Para **ubicación en segundo plano** y **notificaciones**, Google exige:

- **Divulgación en la app (in-app disclosure)** *antes* del diálogo del sistema: qué se recopila, por qué y enlace/opción a política de privacidad si aplica.
- **Video o justificación** en Play Console si el permiso es “sensible” (background location): mostrar el flujo real del usuario.
- El uso debe ser **esencial** a la función principal (conductor disponible / viaje activo), no publicidad ni analítica encubierta.

### 1.3 Formulario de seguridad de datos (Data safety)
Declarar con verdad, alineado con el código y el backend:

| Tipo de datos | Uso declarado | ¿Se comparte? | ¿Opcional? |
|-----------------|---------------|----------------|------------|
| **Ubicación precisa** | Asignación de viajes, seguimiento durante servicio, actualización al pasajero | Con backend/infra propia según contrato | No para modo “disponible/viaje” |
| **Identificadores de usuario** | Sesión conductor, autenticación | Igual | No |
| **Datos de vehículo/documentación** (futuro registro) | Verificación operador | Según política interna | Depende del flujo |
| **Audio cámara** | Solo si la app realmente los usa; si no, no declarar | — | — |

**Cifrado en tránsito**: TLS para API/socket. **Cifrado en reposo**: tokens en almacenamiento seguro del dispositivo (`FlutterSecureStorage`).

### 1.4 Clasificación de contenido (PEGI/IMC)
Cuestionario según violencia, compras, ubicación compartida, etc. Apps taxi suelen **PG** con “ubicación compartida” explícita en la descripción.

### 1.5 Políticas de monetización y anuncios
Si no hay anuncios ni compras in-app, declarar “No”. Cualquier comisión del operador debe quedar clara en términos legales (fuera del alcance de Play form pero relevante legalmente).

### 1.6 Firma de la app y Play App Signing
- Usar **Play App Signing** (recomendado).
- Guardar keystore en lugar seguro (no en el repositorio); proceso de recuperación documentado.

### 1.7 Integridad y protección (opcional pero profesional)
- **Play Integrity API**: reducir abuso (cuentas falsas, emuladores en producción si aplica).
- Revisar que no haya **claves API** sin restricción en producción (ver §4).

---

## 2. Relación con el comportamiento actual de la app

### 2.1 Ubicación
- **Primer plano**: mapa, envío de `location:update` al conectar como disponible.
- **Segundo plano** (cuando el SO lo permite): continuidad del stream con permiso **“Todo el tiempo”** en Android y permisos equivalentes en iOS.
- La app incluye flujo de **divulgación** antes de solicitar el escalado a ubicación en segundo plano (**Android e iOS** cuando el permiso queda en “solo en uso”).
- **iOS**: `UIBackgroundModes` incluye `location`; en App Store Connect habrá que justificar el modo en segundo plano ante revisión Apple.

### 2.2 Notificaciones
- **Locales** (`POST_NOTIFICATIONS` en Android 13+): ofertas de viaje cuando la app no está en primer plano y el proceso sigue vivo.
- **Límite**: si el sistema mata el proceso, las notificaciones locales no llegan. Para producción robusta se recomienda **FCM** desde backend (documentar en `FCM-Y-NOTIFICACIONES-CONDUCTOR.md` cuando se implemente).

### 2.3 Biometría / credenciales del dispositivo
- Uso: reforzar “ponerse en línea”. Declarar en Data safety como medida de seguridad local si Google lo categoriza así.

---

## 3. Privacidad y marco legal (orientativo)

- **Política de privacidad** debe describir: responsable del tratamiento, finalidades, base legal (contrato/servicio, consentimiento donde toque), conservación, derechos (acceso, rectificación, supresión), transferencias internacionales (si servidores fuera del país).
- **Términos de uso** para conductores: condiciones del servicio, conductas prohibidas, limitación de responsabilidad (redactar con abogado).
- **Menores**: si no está dirigida a menores, declararlo; no recopilar datos de menores sin bases legales adecuadas.
- Conservar **registro de actividades de tratamiento** (RGPD/ equivalentes locales).

---

## 4. Seguridad técnica

| Riesgo | Mitigación recomendada |
|--------|-------------------------|
| **API Key de Maps** en el APK | Restringir en Google Cloud Console por **package name + SHA-1** de firma; límites de cuota y APIs habilitadas solo las necesarias. Rotar si se filtra. Ideal: no commitear claves de prod en repos públicos. |
| **Tokens JWT / sesión** | Solo `FlutterSecureStorage`; no logs con token completo; HTTPS/WSS. |
| **Socket.IO** | Token de conductor en handshake; no reutilizar token de pasajero. |
| **Logs en producción** | Reducir `debugPrint` con datos personales; usar niveles y ofuscación. |
| **Dependencias** | `flutter pub outdated` / auditoría periódica; SCA en CI si es posible. |

---

## 5. Checklist previo a enviar a revisión

- [ ] Política de privacidad publicada y enlazada en la ficha.
- [ ] Data safety completado y coherente con la app + backend.
- [ ] Video o texto justificando **background location** acorde al flujo real.
- [ ] Divulgación en app **antes** de permisos sensibles (implementado para ubicación).
- [ ] Permisos en manifest: solo los usados; eliminar huérfanos.
- [ ] Pruebas en dispositivo real con Android 13+ (notificaciones) y 10+ (ubicación en segundo plano).
- [ ] Keystore y ficheros de firma fuera del control de versiones.
- [ ] (Opcional) FCM configurado para ofertas cuando el proceso está muerto.

---

## 6. Referencias oficiales (lectura obligatoria del equipo)

- [Política de ubicación en segundo plano](https://support.google.com/googleplay/android-developer/answer/9799150)
- [User Data / Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Permissions and APIs that access sensitive information](https://support.google.com/googleplay/android-developer/answer/9888170)

---

*Última actualización: documento vivo — actualizar cuando cambien permisos, backend o políticas internas.*
