## ADDED Requirements

### Requirement: Update own profile (unified)

El sistema MUST aceptar `PATCH /users/me/profile` con body JSON conteniendo únicamente campos editables:

- `displayName?: string` (2–200 caracteres si presente)
- `countryCode?: "CO" | "AR"`
- `city?: string` (departamento/provincia válido para el país)
- `municipality?: string` (municipio válido para la división)
- `area?: string` (barrio, 2–120 caracteres)
- `coverageRadiusKm?: number` (≥ 0; solo aplicable si el usuario tiene rol WORKER)
- `workerCategories?: string[]` (min 1 elemento si se envía; solo WORKER)
- `workerHeadline?: string` (max 200)
- `workerBio?: string` (max 2000)
- `preferredPaymentMethod?: "CARD" | "TRANSFER" | "CASH" | "WALLET"` (solo CLIENT)

El sistema MUST rechazar propiedades no listadas en el body (`forbidNonWhitelisted`). El sistema MUST responder `204 No Content` si el request es válido.

#### Scenario: Update profile displayName succeeds

- **WHEN** el usuario autenticado envía `PATCH /users/me/profile` con `displayName` válido
- **THEN** el sistema responde `204` y persiste `displayName` sin modificar `fullName`

#### Scenario: Protected field in body rejected

- **WHEN** el cliente incluye `email` o `roles` en el body
- **THEN** el sistema responde `400` sin cambios en el usuario

### Requirement: Profile read includes displayName

Las respuestas de `GET /users/me/profile` y `GET /users/profile/:userId` MUST incluir `displayName` cuando exista en persistencia.

#### Scenario: Public profile exposes displayName

- **WHEN** un cliente solicita perfil público de un usuario con `displayName` definido
- **THEN** la respuesta JSON MUST incluir `displayName` y MUST NOT incluir `fullName` como campo editable ni datos sensibles adicionales

## MODIFIED Requirements

### Requirement: Update location

El sistema MUST aceptar `PATCH /users/me/location` con body JSON:

- `city: string` (requerido) — departamento/provincia
- `municipality: string` (requerido)
- `area: string` (requerido, barrio 2–120)
- `countryCode: "CO" | "AR"` (requerido)
- `coverageRadiusKm?: number`

El sistema MUST validar país, división y municipio contra el catálogo soportado. El sistema MUST responder `204 No Content` si el request es válido.

#### Scenario: Update location succeeds

- **WHEN** el usuario autenticado envía `PATCH /users/me/location` con `countryCode`, `city`, `municipality` y `area` válidos
- **THEN** el sistema responde `204`

#### Scenario: Invalid municipality for division

- **WHEN** `municipality` no pertenece a `city` en el catálogo del país
- **THEN** el sistema responde `400` con `{ "message": "<texto>" }`
