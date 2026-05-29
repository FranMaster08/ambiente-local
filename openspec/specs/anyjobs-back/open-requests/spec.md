## Purpose

Requisitos de persistencia y API del módulo **open-requests** en `anyjobs-back`: ciclo de vida `lifecycleStatus`, cancelación, filtros de listado y auth opcional en rutas públicas.

## Requirements

### Requirement: Persistencia de lifecycleStatus en open_requests

El modelo de persistencia MUST almacenar `lifecycleStatus` en columna `lifecycle_status` de tipo string/varchar con valores permitidos `ACTIVE` y `CANCELLED`, NOT NULL, default `ACTIVE`. Registros existentes MUST migrarse a `ACTIVE`.

#### Scenario: Migración de registros legacy

- **WHEN** se aplica la migración en una base con filas existentes
- **THEN** todas las filas MUST quedar con `lifecycle_status` = `ACTIVE` salvo cancelaciones posteriores

### Requirement: Exposición de lifecycleStatus en DTOs de lectura

`GET /open-requests/{id}`, `GET /open-requests/mine` y respuestas de `POST /open-requests/{id}/cancel` MUST incluir el campo `lifecycleStatus` con valor `ACTIVE` o `CANCELLED`.

#### Scenario: Detalle incluye lifecycleStatus

- **WHEN** el cliente autorizado obtiene detalle de una solicitud no eliminada
- **THEN** el JSON MUST incluir `lifecycleStatus`

#### Scenario: Listado mine incluye canceladas con estado

- **WHEN** el titular lista sus solicitudes y existe una `CANCELLED`
- **THEN** el ítem correspondiente en `items[]` MUST incluir `lifecycleStatus` = `CANCELLED`

### Requirement: Cancel open request endpoint

El sistema MUST exponer `POST /open-requests/{id}/cancel` protegido por autenticación Bearer. Solo el titular (`owner_user_id` = `userId` de sesión) MUST poder ejecutarlo. Debe transicionar `ACTIVE` → `CANCELLED` de forma idempotente.

#### Scenario: Cancelación exitosa

- **WHEN** el titular llama `POST /open-requests/{id}/cancel` sobre solicitud `ACTIVE`
- **THEN** el sistema MUST responder `200`
- **AND** `lifecycle_status` MUST ser `CANCELLED`

#### Scenario: Idempotencia

- **WHEN** el titular llama cancel sobre solicitud ya `CANCELLED`
- **THEN** el sistema MUST responder `200`

### Requirement: Filtro ACTIVE en listados públicos

Las consultas de `GET /open-requests`, `GET /open-requests/nearby` y listados por relevancia documentados como catálogo público MUST filtrar `lifecycle_status = 'ACTIVE'` además de excluir soft-deleted.

#### Scenario: Público no lista canceladas

- **WHEN** existe solicitud `CANCELLED` no eliminada
- **THEN** `GET /open-requests` MUST NOT incluirla en `items`

### Requirement: Detalle cancelado restringido

`GET /open-requests/{id}` para solicitudes `CANCELLED` MUST responder `404` a clientes que no sean el titular ni usuarios con propuesta en esa solicitud. Titular y postulantes autorizados MUST recibir `200` con `lifecycleStatus` = `CANCELLED`.

#### Scenario: Anónimo no ve cancelada

- **WHEN** un cliente sin sesión solicita detalle de solicitud `CANCELLED`
- **THEN** el sistema MUST responder `404`

#### Scenario: Postulante ve cancelada

- **WHEN** un usuario con propuesta en la solicitud `CANCELLED` solicita el detalle autenticado
- **THEN** el sistema MUST responder `200` con `lifecycleStatus` = `CANCELLED`

### Requirement: Mutaciones bloqueadas en solicitudes canceladas

`POST /proposals` MUST rechazar creación cuando la solicitud objetivo esté `CANCELLED`. `PATCH /open-requests/{id}` MUST rechazar actualización cuando la solicitud esté `CANCELLED`.

#### Scenario: PATCH en cancelada rechazado

- **WHEN** el titular envía `PATCH /open-requests/{id}` sobre solicitud `CANCELLED`
- **THEN** el sistema MUST responder con error de negocio sin aplicar cambios

#### Scenario: POST proposal en cancelada rechazado

- **WHEN** un usuario envía `POST /proposals` con `requestId` de solicitud `CANCELLED`
- **THEN** el sistema MUST responder con error sin crear propuesta

### Requirement: Identificación opcional del visitante en rutas públicas

Para handlers marcados `@Public()` (incluido `GET /open-requests/{id}`), si la petición incluye `Authorization: Bearer` válido, `AuthRbacGuard` MUST adjuntar `req.user` con el `userId` de sesión **sin** exigir permisos declarados en el endpoint. Si no hay Bearer, la petición MUST tratarse como anónima. Los use cases MUST seguir aplicando autorización de negocio (p. ej. detalle cancelado).

#### Scenario: Bearer en GET detalle público

- **WHEN** un cliente autenticado llama `GET /open-requests/{id}` con Bearer válido sobre una solicitud `CANCELLED` donde es titular o postulante
- **THEN** `viewerUserId` MUST estar poblado en el use case de detalle
- **AND** la respuesta MUST ser `200` con `lifecycleStatus` = `CANCELLED`

#### Scenario: Público sin Bearer permanece anónimo

- **WHEN** un cliente llama `GET /open-requests/{id}` sin Authorization sobre solicitud `CANCELLED`
- **THEN** `viewerUserId` MUST estar vacío
- **AND** la respuesta MUST ser `404`

#### Scenario: Rutas protegidas no se relajan

- **WHEN** un cliente llama `POST /open-requests/{id}/cancel` sin permisos requeridos
- **THEN** el sistema MUST seguir respondiendo `401` o `403` según las reglas RBAC existentes
