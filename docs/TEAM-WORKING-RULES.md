# Reglas de trabajo — app Conductor (Texi)

Documento vivo para el equipo. Prioridad: **textos internacionalizables** y consistencia al sumar pantallas y features.

---

## 1. Strings e internacionalización (i18n) — regla base

### 1.1 Qué sí debe ir a `l10n`

Todo texto **visible al usuario** debe salir de `AppLocalizations`, no de literales en código:

- Títulos, subtítulos, párrafos, hints de formularios, labels, placeholders “de UI”.
- Mensajes de `SnackBar`, `Dialog`, `AlertDialog`, `BottomSheet`, tooltips, botones.
- Mensajes de validación de formularios (`validator:`).
- Textos de estados vacíos, errores mostrados en pantalla, CTAs (“Continuar”, “Cancelar”, etc.).
- Copy de flujos demo o onboarding si se muestra al usuario.

**Archivos fuente:** `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` (mantener ambos alineados en claves).

**En código:** `AppLocalizations.of(context)` o el `l10n` que ya tengas en scope. Tras cambiar ARB:

```bash
flutter gen-l10n
```

### 1.2 Qué puede quedar como literal en código

- **Datos del backend** (nombres de país, direcciones, mensajes de API “tal cual”, etc.).
- Identificadores técnicos, rutas, keys internas.
- Formatos que no son copy (p. ej. patrón de fecha acordado con el API, si no se muestra como frase al usuario).

Si un dato del servidor debe mostrarse traducido (p. ej. nombre de país), la traducción debería venir del **backend** o de un **mapeo local documentado**, no hardcodear frases sueltas.

### 1.3 Convención de nombres de claves (ARB)

- Prefijo por área: `driverLogin*`, `driverReg*`, `driverHome*`, `driverTrip*`, `driverProfile*`, `common*`, etc.
- Una clave = una frase o patrón con placeholders.
- Placeholders con nombre claro: `{amount}`, `{minutes}`, `{seconds}`, `{maxKb}`, etc., y bloque `@clave` con `placeholders` como exige Flutter.

Ejemplo:

```json
"driverRegStepCounter": "Paso {current} de {total}",
"@driverRegStepCounter": {
  "placeholders": {
    "current": { "type": "String" },
    "total": { "type": "String" }
  }
}
```

### 1.4 Anti-patrones

- `Text('...')` / `SnackBar(content: Text('...'))` con copy de producto.
- Duplicar la misma frase en muchas claves; mejor reutilizar una clave común (`commonCancel`, etc.).
- Añadir solo `app_es.arb` y olvidar `app_en.arb` (o al revés).

### 1.5 Checklist rápido en cada PR (revisor)

- [ ] Nuevos textos de usuario están en `app_es.arb` **y** `app_en.arb`.
- [ ] Se ejecutó `flutter gen-l10n` si tocaste ARB (o CI lo hace).
- [ ] No hay strings de UI “colados” en widgets sin pasar por `l10n`.

---

## 2. UX y tema (alineado al crecimiento del proyecto)

- **Tema global:** `lib/core/theme/app_theme.dart` — botones, inputs, cards, snackbars; preferir estilos del tema antes de inventar decoraciones duplicadas.
- **Tokens:** `lib/core/theme/app_foundation.dart` — radios y espaciados consistentes.
- **Estados reutilizables:** `lib/core/ui/driver_ui_states.dart` — errores inline y estados vacíos cuando aplique.
- Las nuevas pantallas deberían **encajar** en esta línea visual para no fragmentar la app.

---

## 3. Backend y contratos

- Contratos WebSocket / REST: documentar cambios en `docs/DRIVER-REALTIME-BACKEND-CONTRACT.md` y referencias en `BACKEND-REFERENCES.md` cuando afecte al conductor.
- No commitear secretos (`.env`, claves AWS, tokens). Rotar credenciales si se filtran.

---

## 4. Calidad antes de merge

- `flutter analyze` sin errores en los archivos tocados (idealmente en el proyecto).
- Probar al menos un cambio de idioma (ES/EN) si el PR toca copy o flujos con mucho texto.

---

## 5. Evolución del documento

A medida que crezca la app:

- Añadir aquí **prefijos nuevos** si aparecen módulos (p. ej. `driverWallet*`).
- Si un flujo grande concentra muchas claves, se puede enlazar un doc de producto, pero **la regla de la sección 1 sigue obligatoria**.

---

*Última orientación: no hace falta perseguir “cero comillas en todo `lib/`”; sí hace falta **cero copy de producto fuera de `l10n`** en código nuevo y en pantallas que se toquen.*
