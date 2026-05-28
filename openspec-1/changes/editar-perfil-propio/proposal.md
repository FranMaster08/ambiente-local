## Why

La pantalla «Tu perfil» (`/perfil`) es solo lectura: el usuario puede ver su información pero no actualizarla después del registro. El backend ya expone `PATCH /users/me/*` (ubicación, perfil worker/cliente, datos personales), pero el front no los consume fuera del wizard de registro. Esto impide que el usuario mantenga datos públicos y de contacto operativos (ubicación, bio, preferencias) sin rehacer el alta ni exponer campos sensibles de identidad.

## What Changes

- **Nuevo flujo «Editar perfil»** visible solo en perfil propio (`visibilityMode === 'private'`): botón «Editar perfil», formulario con campos permitidos, guardar/cancelar, estados de carga, éxito y errores de validación.
- **Campo `displayName` (nombre visible)**: migración y persistencia en backend; el nombre legal de registro (`fullName`) queda protegido. En UI pública y privada se muestra `displayName ?? fullName`.
- **Endpoint unificado `PATCH /users/me/profile`**: DTO acotado con únicamente campos editables; ignora o rechaza campos protegidos aunque el cliente los envíe; solo el usuario autenticado puede actualizar su propio perfil.
- **Campos editables** (según rol):
  - Todos: `displayName`, ubicación estructurada (`countryCode`, `city` como departamento/provincia, `municipality`, `area` como barrio).
  - Worker: además `workerCategories`, `workerHeadline`, `workerBio`, `coverageRadiusKm`.
  - Client: además `preferredPaymentMethod`.
- **Campos protegidos** (no editables desde este flujo ni aceptados en el DTO de actualización): `fullName`, email, teléfono, documento, tipo de documento, nacimiento, género, nacionalidad, roles, estado, verificaciones, identificadores internos.
- **Sin avatar/foto de perfil** en este cambio: el modelo actual no persiste imagen de perfil; se mantiene fallback de iniciales.
- **Perfil público sin cambios de edición**: en `/usuarios/:userId` ajeno no se muestra botón ni formulario de edición.
- **Tests y documentación**: e2e/unit en back, specs de componente en front, deltas OpenSpec y contratos API.

## Capabilities

### New Capabilities

- `editar-perfil-propio`: Edición segura del perfil propio — UI, contrato `PATCH /users/me/profile`, campo `displayName`, reglas de campos editables vs protegidos, validaciones y criterios de aceptación.

### Modified Capabilities

- `vista-perfil-usuario`: Botón «Editar perfil» en modo propio; uso de `displayName` en cabecera; formulario de edición integrado sin romper vista pública.
- `anyjobs-back/user-profile`: Nuevo endpoint y DTO de actualización; lectura de perfil incluye `displayName`; alineación de contrato de ubicación con `municipality` obligatorio.

## Impact

- **Frontend (`anyjobs-front/anyjobs`)**: `profile` (botón, modal o vista de edición), nuevo componente/formulario reutilizando `LocationGeographyService` y patrones de registro, `user.api.ts`, `user-profile.models.ts`, tests de componente.
- **Backend (`anyjobs-back`)**: migración TypeORM (`display_name`), `UserEntity`, DTOs de lectura/escritura, `UpdateProfileUseCase`, controlador `PATCH /users/me/profile`, mapeo en `UserProfileReadService`, tests unitarios y e2e.
- **OpenSpec**: nueva spec `editar-perfil-propio`; deltas en `vista-perfil-usuario` y `anyjobs-back/user-profile`.
- **Sin breaking changes** en rutas existentes; endpoints granulares `/users/me/location|worker-profile|client-profile` se mantienen para registro/onboarding.
