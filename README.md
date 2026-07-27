# texi_driver_app

App Flutter para conductores Texi.

## Documentación

| Tema | Ubicación |
|------|-----------|
| **Plan de limpieza / control (fases 0–6)** | [`.cursor/functional-modules/driver-operations/texi-driver-app-cleanup-tracker.md`](../.cursor/functional-modules/driver-operations/texi-driver-app-cleanup-tracker.md) |
| Reglas de trabajo (i18n, errores, PR) | [`docs/TEAM-WORKING-RULES.md`](docs/TEAM-WORKING-RULES.md) |
| Onboarding conductor | `.cursor/functional-modules/driver-onboarding/` |
| Operaciones conductor | `.cursor/functional-modules/driver-operations/` |
| Contratos API | `.cursor/contracts-matrix.md` |

## Arranque local (pre-prod)

Desde `texi_driver_app/` — **usar el script** (resuelve Maps key, entorno y backend):

```powershell
# Requiere GOOGLE_MAPS_API_KEY en .env.local o variable de entorno
.\scripts\run-with-maps-key.ps1 -Mode run

# APK dev (default: TEXI_APP_ENV=dev + api.dev.taxitexi.com)
.\scripts\run-with-maps-key.ps1 -Mode apk
# Salida: build/app/outputs/flutter-apk/app-dev-release.apk
# Package: com.taxitexi.texi_driver_app.dev · label «Texi Conductor DEV»

# Build prod store (AAB Play Store)
.\scripts\run-with-maps-key.ps1 -Mode appbundle -Environment prod -BackendBaseUrl "https://HOST_API_PROD"
# Salida: build/app/outputs/bundle/prodRelease/app-prod-release.aab
# Requiere android/key.properties con upload keystore (ver key.properties.example)
```

Copiar `.env.local.example` → `.env.local`:

```env
GOOGLE_MAPS_API_KEY=TU_KEY
TEXI_APP_ENV=dev
TEXI_BACKEND_BASE_URL=https://api.dev.taxitexi.com
```

| Parámetro script | Default dev | Prod (store) |
|------------------|-------------|--------------|
| `-Environment` | `dev` | `prod` |
| `-BackendBaseUrl` | `https://api.dev.taxitexi.com` | **obligatorio** |
| `-MapsApiKey` | `.env.local` / env | idem |
| `-Flavor` | auto (`dev`/`prod` según `-Environment`) | `prod` |

Build prod (cuando exista host API prod):

```powershell
.\scripts\run-with-maps-key.ps1 -Mode apk -Environment prod -BackendBaseUrl "https://HOST_API_PROD"
```

## Estructura (`lib/`)

| Área | Ruta | Rol |
|------|------|-----|
| Router | `core/router/app_router.dart` | GoRouter + guards de sesión |
| Config | `core/config/` | Backend URL, Maps, Socket, locale |
| Login / home / viajes | `features/login/` | Realtime, mapa activo, historial |
| Registro | `features/registration/` | KYC + vehículo |
| Perfil / ingresos | `features/profile/`, `features/earnings/` | |
| Providers | Riverpod en controllers + `driver_operational_profile.dart` | |

## Rutas

| Path | Requiere token |
|------|----------------|
| `/login` | No |
| `/register` | Opcional (reanudar) |
| `/home`, `/profile`, `/my-vehicles`, `/settings`, `/earnings-credits`, `/trip-history` | Sí |
| `/registered-images` | Sí + teléfono QA (`10011`) |

## Calidad

```bash
flutter analyze
dart run tool/verify_l10n.dart
dart run tool/find_unused_l10n_keys.dart
```

## Getting Started (Flutter)

Ver [documentación Flutter](https://docs.flutter.dev/).
