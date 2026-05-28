## Context

Wizard en `anyjobs-front/.../registration/` con etapas `ACCOUNT → VERIFY → LOCATION → ROLE_PROFILE → PERSONAL_INFO → DONE`.

**Modelo actual (post-cambio):**

| Aspecto | Implementación |
|--------|----------------|
| Persistencia | `sessionStorage` vía `RegistrationDraftService`; sin `POST /register` al continuar Cuenta |
| Finalización | `POST /auth/register/complete` con payload completo |
| Email/tel disponible | Solo tabla `users`, no `auth_registration_flows` |
| Ubicación | País → División → Municipio (combo) → Barrio (texto libre) |
| Catálogo geo | Postgres + `GET /auth/location-catalog?countryCode&division` |
| Nacionalidad | ISO-3166 mundial (249 países), labels con `Intl.DisplayNames` |
| Errores | `regErrorSummary` + errores inline; parser Nest whitelist |

Referencia QA: **“Intento 3 creación nuevo usuario”**.

## Goals / Non-Goals

**Goals:**

- Validaciones visibles; botones acoplados a validez (incl. async).
- Ubicación en cascada con municipio y barrio libre.
- Registro atómico al final; email no bloqueado por drafts.
- WORKER: CC, género, nacionalidad mundial, mayor de edad.
- Errores por campo, no genéricos opacos.

**Non-Goals:**

- Países de **residencia** distintos de CO/AR (solo nacionalidad es mundial).
- Lista cerrada de barrios por municipio (barrio es texto libre).
- Rediseño visual del wizard.

## Decisions

### 1. Enum documento: `CC`
- Valor **`CC`** en front y back; labels `doc.cc`.

### 2. Registro atómico (sessionStorage + register/complete)
- **Decisión:** No crear flow en servidor al continuar Cuenta. Draft en `sessionStorage`; un solo `POST /auth/register/complete` al terminar Personal (o CLIENT sin personal).
- **Motivo:** Evitar “email ya existe” por drafts y simplificar consistencia.

### 3. Ubicación: cascada con municipio
- **Decisión:** `countryCode` (CO|AR) → `city` (departamento/provincia) → `municipality` (combo API) → `area` (texto libre, 2–120 chars).
- Catálogo en BD; barrios en seed solo como referencia, no validación cerrada en MVP.

### 4. Nacionalidad mundial
- **Decisión:** Select con todos los códigos ISO-3166-1 alpha-2 (`world-countries.data.ts`); validación `isIsoCountryCode`. Residencia sigue CO/AR.

### 5. Mayor de edad
- **Decisión:** `minimumAgeValidator(18)` en front; `isAdultBirthDate` en back; `max` en input date.

### 6. Errores accionables
- **Decisión:** `collectFormControlMessages` + `regErrorSummary`; `readRegistrationFieldErrors` parsea `details.fieldErrors`, array class-validator y mensajes Nest `location.property X should not exist`; `applyRegistrationApiFieldErrors` en controles.

### 7–9. (heredados) Cuenta async, OTP, Perfil WORKER
- Sin cambios respecto a diseño anterior.

### 10. Fix TypeScript auth.controller
- `resumeFlowId: resumeFlowId ?? undefined` para compilar en Docker.

## Risks / Trade-offs

- **Draft sessionStorage** se pierde al cerrar pestaña — aceptado en MVP.
- **Barrio libre** puede tener typos — aceptado; sin geocoding.
- **Backend desactualizado** sin `municipality` en DTO → mensaje “servidor no reconoce municipio”; mitigación: redeploy.

## Migration Plan

1. `migration:run` + `seed` (geo_divisions, geo_municipalities).
2. Deploy back + front.
3. QA: CO Antioquia → Medellín → barrio libre; WORKER mayor de edad; nacionalidad ES; registro completo.

## Open Questions

- ¿Selector de país con banderas? — fuera de MVP.
- ¿Persistir draft en servidor para retomar en otro dispositivo? — iteración futura.
