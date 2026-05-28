## Why

Las pruebas del flujo **“Intento 3 creación nuevo usuario”** en el onboarding por etapas (MVP) detectaron fallos funcionales en **Cuenta**, **Verificación**, **Ubicación**, **Perfil** y **Personal**: validaciones ocultas o inconsistentes, campos marcados como opcionales que el negocio requiere, avance permitido con datos incompletos, catálogo de tipo de documento incompleto para Colombia, bloqueo de email por drafts obsoletos, jerarquía geográfica incompleta (faltaba municipio), y el mensaje genérico **“Error inesperado”** / **“Revisa los datos del formulario”** sin indicar qué campo falla.

Tras la primera iteración de correcciones, se añadieron mejoras de producto: **persistencia única al final del wizard** (sin crear usuario ni draft en servidor en etapa Cuenta), **cascada País → Departamento/Provincia → Municipio → Barrio (texto libre)**, catálogo geográfico en BD, **mayor de edad (18+)**, **nacionalidad de cualquier país (ISO-3166)** y **resumen de errores por campo** en cada etapa.

## What Changes

### Modelo de registro (nuevo)
- El wizard MUST mantener progreso en **sessionStorage** (`RegistrationDraftService`) hasta completar.
- **Un solo** `POST /auth/register/complete` persiste cuenta, ubicación, perfil y datos personales.
- `GET /auth/email-available` y `phone-available` consultan solo usuarios **definitivos** (`users`), no flows/drafts en servidor.
- Eliminado el bloqueo “este email ya existe” al pulsar Continuar en Cuenta por drafts previos.

### Etapa Cuenta
- Eliminar bloqueos del botón **Continuar** sin feedback visible (validación síncrona, async pending, errores por campo).
- `type="email"` y `type="tel"`; mensaje “Comprobando disponibilidad…”.

### Etapa Verificación
- OTP con teclado numérico en mobile; reglas WORKER (teléfono) / CLIENT (email o teléfono).

### Etapa Ubicación
- Cascada obligatoria: **País** (CO/AR) → **Departamento/Provincia** (`city`) → **Municipio** (combo según catálogo) → **Barrio** (`area`, **texto libre**, mín. 2 caracteres).
- Catálogo en BD (`geo_divisions`, `geo_municipalities`, `geo_neighborhoods` para seed/referencia); API `GET /auth/location-catalog` con divisiones y municipios por división.
- Sin campo ISO de país aparte del select; radio cobertura opcional solo WORKER.

### Etapa Perfil
- WORKER: no avanzar sin categorías; botón acoplado a validez.

### Etapa Personal
- Tipo documento con **CC**; género obligatorio WORKER.
- **Fecha de nacimiento**: obligatoria WORKER y **mayor de edad (≥ 18 años)**.
- **Nacionalidad**: select con países **ISO-3166-1** (cualquier país), no solo CO/AR.
- Payload personal completo en `register/complete` para WORKER.

### Errores y UX
- Bloque **“Corrige lo siguiente:”** con lista de mensajes **por campo** (cliente y API).
- Parser de `fieldErrors` y mensajes Nest/class-validator (`property X should not exist` → campo legible).
- Sin mensaje genérico duplicado si hay errores específicos.

### Backend
- `POST /auth/register/complete`, DTO con `location.municipality`, validación ubicación en cascada.
- `CompleteOnboardingRegistrationUseCase`; enum `CC`; policy mayor de edad y nacionalidad ISO.
- Fix compilación: `resumeFlowId` cookie `null` → `undefined`.
- Catálogo geo: seeder departamentos (CO) y provincias (AR).

## Capabilities

### New Capabilities

- `registro-onboarding-validaciones`: Wizard por etapa, validaciones visibles, geografía en cascada, registro atómico, errores accionables.

### Modified Capabilities

- `registro-usuario-completo`: Finalización única vía `register/complete`; sin cuenta creada hasta DONE; alineación enums y ubicación con municipio.

## Impact

### Frontend
- `registration/*`, `registration-draft.service.ts`, `registration-form-errors.ts`, `registration-error.utils.ts`
- `shared/location/world-countries.data.ts`, `location-geography.service.ts`
- `auth.api.ts` (`completeOnboardingRegistration`, catálogo municipios)

### Backend
- `complete-onboarding-registration.use-case.ts`, `check-email-available`, `check-phone-available`
- `supported-location.catalog.ts`, migraciones geo, `seed-geography.ts`
- `world-countries` validation, `birth-date.ts`, `auth.controller.ts`

### Referencia
- Documento **“Intento 3 creación nuevo usuario”** y sesión de implementación mayo 2026.
