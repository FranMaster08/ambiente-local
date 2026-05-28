## Context

El perfil de usuario usa un único componente `Profile` para `/perfil` (propio) y `/usuarios/:userId` (público o propio si coincide el id). La distinción se hace con `visibilityMode` y `isOwnProfile`. La lectura privada usa `GET /users/me/profile`; la pública `GET /users/profile/:userId`. El modelo `UserEntity` tiene un solo nombre (`fullName`), sin `displayName` ni avatar persistido.

El backend ya implementa actualizaciones granulares bajo `/users/me/location`, `/users/me/worker-profile`, `/users/me/client-profile` y `/users/me/personal-info`, reutilizadas en el wizard de registro vía `/auth/registration/*`. Ninguna pantalla post-registro las invoca. El catálogo geográfico CO/AR con cascada país → división → municipio + barrio libre ya existe (`LocationGeographyService`, `supported-location.catalog`).

## Goals / Non-Goals

**Goals:**

- Permitir edición segura del perfil propio desde «Tu perfil» con UX clara (botón, formulario, guardar/cancelar, feedback).
- Introducir `displayName` para personalizar el nombre mostrado sin alterar `fullName` (nombre de registro / identidad legal).
- Exponer `PATCH /users/me/profile` con DTO acotado; defensa en profundidad contra campos protegidos.
- Reutilizar validaciones y catálogos existentes (ubicación, worker/client profile).
- Mantener perfil público sin controles de edición; actualizar vista propia tras guardar.

**Non-Goals:**

- Foto/avatar de perfil (no hay columna ni pipeline de almacenamiento).
- Edición de email, teléfono, documento, nacimiento, género, nacionalidad, roles o estado.
- Bloquear `PATCH /users/me/personal-info` en onboarding (sigue usándose en registro; el formulario de edición no lo invoca).
- Username público, pestaña Puntaje, ni reels adicionales.
- Ubicación como texto libre (excepto `area`/barrio).

## Decisions

### 1. Campo `displayName` en persistencia

**Decisión:** Añadir columna nullable `display_name VARCHAR(200)` en `users`. En lectura, exponer `displayName` en DTOs público y privado. En UI, `visibleName = displayName ?? fullName`. Solo `displayName` es editable vía perfil; `fullName` permanece inmutable post-registro.

**Alternativas:** Permitir editar `fullName` (mezcla identidad legal y nombre público); alias `username` (no existe en modelo).

**Rationale:** Cumple el requisito de separación nombre legal vs visible sin migrar datos existentes (`displayName` null → comportamiento actual).

### 2. Endpoint unificado `PATCH /users/me/profile`

**Decisión:** Nuevo endpoint con `UpdateProfileRequestDto` que acepta solo campos editables. El use case `UpdateProfileUseCase` delega internamente a la lógica existente de ubicación/worker/client profile (o reutiliza repositorio con las mismas validaciones) en una transacción.

**Body permitido (todos opcionales en PATCH parcial; validación al enviar sección):**

| Campo | Alcance | Validación |
|-------|---------|------------|
| `displayName` | Todos | string, 2–200 chars, trim |
| `countryCode` | Todos | `CO` \| `AR` |
| `city` | Todos | división válida para país |
| `municipality` | Todos | municipio válido para división |
| `area` | Todos | string 2–120 (barrio) |
| `coverageRadiusKm` | Worker | number ≥ 0, opcional |
| `workerCategories` | Worker | string[], min 1 si se envía bloque worker |
| `workerHeadline` | Worker | string ≤ 200, opcional |
| `workerBio` | Worker | string ≤ 2000, opcional |
| `preferredPaymentMethod` | Client | enum existente |

Campos enviados fuera del schema (p. ej. `email`, `fullName`, `roles`) MUST ser rechazados por validación del DTO (`forbidNonWhitelisted`) o ignorados sin efecto — preferir **rechazo 400** con `ValidationPipe` whitelist.

**Alternativas:** Llamar desde el front a 2–3 PATCH existentes en paralelo (más frágil para UX de un solo «Guardar»); reutilizar solo endpoints viejos sin DTO unificado (expone personal-info al cliente).

**Rationale:** Un guardado, un estado de carga, contrato explícito de campos permitidos.

### 3. UI: panel modal sobre `/perfil`

**Decisión:** Botón «Editar perfil» en el hero del perfil propio abre un modal (o panel full-screen en mobile) con formulario. Reutilizar `LocationGeographyService` y controles en cascada del registro. Botones «Guardar cambios» y «Cancelar». Tras éxito: cerrar modal, `reload()` del perfil, toast/banner de éxito.

**Alternativas:** Ruta `/perfil/editar` (más navegación); inline edit en tabs (rompe layout actual).

**Rationale:** No altera la vista de lectura ni la ruta pública; responsive con patrones existentes del design system.

### 4. Campos mostrados en el formulario

**Decisión:** El formulario incluye **solo campos editables**. Datos protegidos (email, teléfono, documento, etc.) no aparecen en el formulario; permanecen visibles en la pestaña Información en modo solo lectura.

**Rationale:** Evita confusión y envío accidental de campos sensibles.

### 5. Autorización

**Decisión:** `PATCH /users/me/profile` bajo `/users/me/*` con guard JWT + permiso `users.profile.update` (o el permiso ya usado por otros PATCH de perfil). Solo actúa sobre `req.user.userId`; no existe variante por `:userId`.

**Rationale:** Imposible editar perfil ajeno; alineado con endpoints existentes.

### 6. Compatibilidad con endpoints granulares

**Decisión:** Mantener `PATCH /users/me/location|worker-profile|client-profile` sin cambios de contrato para registro. `UpdateProfileUseCase` comparte validadores/repos con los use cases existentes.

## Risks / Trade-offs

- **[Usuario dual CLIENT+WORKER]** → Mostrar secciones worker y client en el mismo formulario si aplica; validar campos según roles presentes.
- **[displayName vacío tras edición]** → Permitir null para volver al fallback `fullName`; validar min length solo si string no vacío.
- **[Intentos de modificar campos protegidos vía API]** → `ValidationPipe` con `whitelist: true, forbidNonWhitelisted: true` en el nuevo DTO; tests e2e con payload malicioso.
- **[Desincronización specs backend legacy]** → Delta en `anyjobs-back/user-profile` documenta `municipality` obligatorio en location y nuevo endpoint.
- **[Sin avatar]** → Usuario puede esperar editar foto; documentar en UI que no está disponible aún (non-goal).

## Migration Plan

1. Migración TypeORM: `ALTER TABLE users ADD display_name VARCHAR(200) NULL`.
2. Desplegar backend (GET incluye `displayName`; PATCH disponible).
3. Desplegar frontend con botón y formulario.
4. Rollback: revertir front; columna `display_name` nullable no rompe lecturas antiguas.

## Open Questions

- Ninguna bloqueante: permiso exacto a reutilizar será el de los PATCH `/users/me/*` existentes en el controlador.
