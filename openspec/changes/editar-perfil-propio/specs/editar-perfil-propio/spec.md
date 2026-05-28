## Purpose

Definir el contrato funcional de **edición del perfil propio** del usuario autenticado: campos editables vs protegidos, endpoint de actualización, validaciones, comportamiento front y criterios de aceptación transversales.

## ADDED Requirements

### Requirement: Catálogo de campos editables y protegidos

El sistema MUST clasificar los campos de perfil en **editables** (actualizables vía flujo «Editar perfil») y **protegidos** (in UI de edición; no aceptados en el DTO de actualización de perfil).

**Editables:**

| Campo API | Etiqueta UI | Notas |
|-----------|-------------|-------|
| `displayName` | Nombre visible | Sustituye a `fullName` en visualización cuando está presente |
| `countryCode` | País | Catálogo CO/AR |
| `city` | Departamento / Provincia | Select dependiente |
| `municipality` | Municipio / Ciudad | Select dependiente |
| `area` | Barrio | Texto libre 2–120 chars |
| `coverageRadiusKm` | Radio de cobertura (km) | Solo rol WORKER |
| `workerCategories` | Categorías de servicio | Solo WORKER; min 1 si se envía |
| `workerHeadline` | Titular / encabezado | Solo WORKER; opcional |
| `workerBio` | Descripción / biografía | Solo WORKER; max 2000 chars |
| `preferredPaymentMethod` | Método de pago preferido | Solo CLIENT |

**Protegidos (MUST NOT ser editables en este flujo):**

`fullName`, `email`, `phoneNumber`, `documentType`, `documentNumber`, `birthDate`, `gender`, `nationality`, `roles`, `status`, `emailVerified`, `phoneVerified`, `userId`, `passwordHash`, `createdAt`, `updatedAt`, y cualquier identificador interno.

#### Scenario: Lista de campos protegidos rechazada en API

- **WHEN** el cliente envía `PATCH /users/me/profile` incluyendo `email` o `fullName` en el body
- **THEN** el sistema MUST responder `400` (validación) sin modificar el usuario

#### Scenario: Nombre legal no editable

- **WHEN** el usuario guarda cambios en «Editar perfil»
- **THEN** el valor persistido en `fullName` MUST permanecer igual al registrado en el alta

### Requirement: Campo displayName para nombre visible

El sistema MUST persistir `displayName` opcional en el usuario. En visualización pública y privada del perfil, el nombre mostrado MUST ser `displayName` si existe y no está vacío; en caso contrario MUST usarse `fullName`.

#### Scenario: Usuario sin displayName

- **WHEN** `displayName` es null o vacío
- **THEN** la cabecera del perfil MUST mostrar `fullName`

#### Scenario: Usuario con displayName personalizado

- **WHEN** el usuario establece `displayName` a «María P.»
- **THEN** el perfil público y propio MUST mostrar «María P.» y MUST NOT alterar `fullName`

### Requirement: Endpoint PATCH /users/me/profile

El sistema MUST aceptar `PATCH /users/me/profile` autenticado con body JSON conteniendo únicamente campos editables del catálogo. El sistema MUST responder `204 No Content` si la actualización es válida. El sistema MUST aplicar validaciones de rol (campos worker/client solo si el usuario tiene el rol correspondiente).

#### Scenario: Actualización parcial exitosa

- **WHEN** el usuario autenticado envía solo `displayName` y `area` válidos
- **THEN** el sistema responde `204` y persiste únicamente esos campos

#### Scenario: Ubicación con catálogo inválido

- **WHEN** el usuario envía `municipality` que no pertenece a la división indicada
- **THEN** el sistema responde `400` con `{ "message": "<texto legible>" }`

#### Scenario: Worker bio excede longitud

- **WHEN** `workerBio` supera 2000 caracteres
- **THEN** el sistema responde `400`

### Requirement: Solo el titular puede editar su perfil

El endpoint MUST operar exclusivamente sobre el usuario de la sesión (`/users/me`). MUST NOT existir endpoint de edición por `:userId` para terceros.

#### Scenario: Sin autenticación

- **WHEN** se invoca `PATCH /users/me/profile` sin Bearer token
- **THEN** el sistema responde `401`

### Requirement: UI Editar perfil en perfil propio

En modo perfil **propio**, la pantalla MUST mostrar un botón visible «Editar perfil». Al activarlo, MUST abrirse un formulario (modal, panel o vista dedicada) con solo campos editables, botones «Guardar cambios» y «Cancelar», indicador de carga al guardar, mensaje de éxito al completar y mensajes de error claros si falla la validación.

#### Scenario: Botón visible en Tu perfil

- **WHEN** el usuario autenticado ve su perfil en `/perfil` o `/usuarios/:id` con id propio
- **THEN** MUST mostrarse el botón «Editar perfil»

#### Scenario: Sin botón en perfil ajeno

- **WHEN** el usuario ve el perfil público de otro `userId`
- **THEN** MUST NOT mostrarse botón ni formulario de edición

#### Scenario: Cancelar sin cambios

- **WHEN** el usuario pulsa «Cancelar»
- **THEN** MUST cerrarse el formulario sin persistir cambios y MUST mostrarse el perfil previo

#### Scenario: Éxito refresca datos

- **WHEN** el guardado responde `204`
- **THEN** la vista de perfil MUST reflejar los datos actualizados (recarga o merge local)

### Requirement: Diseño responsive y coherente

El formulario de edición MUST ser usable en escritorio y mobile y MUST mantener la estética del sistema de diseño actual (tokens, botones, tipografía del perfil).

#### Scenario: Formulario en viewport móvil

- **WHEN** el usuario edita en pantalla estrecha
- **THEN** controles MUST ser accesibles sin scroll horizontal obligatorio

### Requirement: Tests y calidad

El cambio MUST incluir o actualizar tests automatizados en backend (unit + e2e del endpoint y rechazo de campos protegidos) y frontend (componente de perfil / formulario de edición). Linter y tests de ambos proyectos MUST pasar tras la implementación.

#### Scenario: Test e2e rechazo de email en body

- **WHEN** un test e2e envía `email` en `PATCH /users/me/profile`
- **THEN** MUST verificar respuesta `400` y email sin cambios en BD

## Criterios de aceptación (resumen)

- Cambio OpenSpec documentado con campos editables/protegidos definidos.
- Botón «Editar perfil» solo en perfil propio.
- Formulario con campos permitidos; datos sensibles no editables.
- `PATCH /users/me/profile` seguro; payloads maliciosos rechazados.
- `displayName` persiste y se usa en visualización.
- Ubicación con selects CO/AR; barrio texto libre.
- Éxito, error y carga en UI; perfil actualizado tras guardar.
- Tests y linter en front y back en verde.
- Documentación/contratos actualizados.
