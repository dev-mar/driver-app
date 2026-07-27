# Reglas de trabajo — `texi_driver_app`

Documentación canónica del ecosistema: **`../../.cursor/`** (arquitectura, contratos, módulos funcionales).

## Limpieza y control de calidad

Plan maestro con fases 0–6:  
**[texi-driver-app-cleanup-tracker.md](../../.cursor/functional-modules/driver-operations/texi-driver-app-cleanup-tracker.md)**

## Convenciones obligatorias

### i18n

- Textos de UI en `lib/l10n/app_en.arb` y `app_es.arb`; prefijo **`driver*`** para strings de producto conductor.
- No usar `const Text(...)` con strings localizados.
- Tras editar ARB: `dart run tool/verify_l10n.dart`.
- Detectar claves huérfanas: `dart run tool/find_unused_l10n_keys.dart`.

### Errores (login / realtime / registro)

- Controllers publican **`errorCode`** / **`tripErrorCode`**, no mensajes de UI.
- Pantallas mapean códigos → `AppLocalizations`.
- Mensajes del backend solo como fallback.

### HTTP

- Lecturas autenticadas: `buildDriverAuthedDio` + `requestWithRetry` (`core/network/driver_http_resilience.dart`).
- Objetivo: **`DriverApiClient`** único (ver tracker Fase 2).

### Estilo y tokens

- `AppColors`, `AppFoundation`, `AppMotion`, `AppSafeScrolling`.
- Avatares: `TexiCircularAvatar`.
- Área táctil ≥ 48 dp en controles principales.

### Configuración local

Desde `texi_driver_app/`:

```powershell
.\scripts\run-with-maps-key.ps1 -Mode run
.\scripts\run-with-maps-key.ps1 -Mode apk
```

Claves en `.env.local` (ver `.env.local.example`): `GOOGLE_MAPS_API_KEY`, opcional `TEXI_APP_ENV=dev`, `TEXI_BACKEND_BASE_URL=https://api.dev.taxitexi.com`.

### Checklist antes de PR (app conductor)

1. `flutter analyze` en archivos tocados.
2. `dart run tool/verify_l10n.dart` si cambiaste strings.
3. Validar flujo tocado contra checklist humo del tracker (§ Checklist humo E2E).
4. Cambios de contrato REST/WS → actualizar `.cursor/contracts-matrix.md`.

## Referencias

- Registro conductor: `.cursor/functional-modules/driver-onboarding/driver-registration.md` §10
- Online/offline: `.cursor/functional-modules/driver-operations/driver-online-offline-control.md`
- Reglas monorepo: `.cursorrules`
