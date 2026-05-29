## Purpose

Ciclo de vida de solicitudes abiertas (`ACTIVE` / `CANCELLED`), cancelación por el titular, visibilidad en listados públicos vs historial autenticado, y notificaciones a postulantes afectados.

## Requirements

### Requirement: Ciclo de vida ACTIVE y CANCELLED en open requests

El sistema MUST persistir en cada open request un campo `lifecycleStatus` con valores `ACTIVE` o `CANCELLED`. Los registros existentes MUST tratarse como `ACTIVE` tras la migración. El campo MUST exponerse en lecturas autorizadas según las reglas de visibilidad de este spec.

#### Scenario: Registro legacy tras migración

- **WHEN** existe una solicitud creada antes de introducir `lifecycleStatus`
- **THEN** su valor persistido MUST ser `ACTIVE`
- **AND** las lecturas MUST comportarse como solicitud activa salvo cancelación explícita posterior

#### Scenario: Solicitud recién creada

- **WHEN** el cliente crea una solicitud con `POST /open-requests` exitoso
- **THEN** el registro MUST persistirse con `lifecycleStatus` = `ACTIVE`

### Requirement: Cancelar solicitud por el titular

El sistema MUST exponer `POST /open-requests/{id}/cancel` autenticado. Solo el usuario cuyo `userId` coincide con `ownerUserId` de la solicitud MUST poder cancelarla. La operación MUST transicionar `lifecycleStatus` de `ACTIVE` a `CANCELLED`. Si la solicitud ya está `CANCELLED`, la operación MUST ser idempotente y responder éxito sin error.

#### Scenario: Titular cancela solicitud activa

- **WHEN** el titular autenticado llama `POST /open-requests/{id}/cancel` sobre una solicitud `ACTIVE` no eliminada
- **THEN** el sistema MUST responder `200`
- **AND** `lifecycleStatus` MUST quedar en `CANCELLED`

#### Scenario: Segunda cancelación idempotente

- **WHEN** el titular llama `POST /open-requests/{id}/cancel` y la solicitud ya está `CANCELLED`
- **THEN** el sistema MUST responder `200`
- **AND** MUST NOT lanzar error de conflicto por estado ya cancelado

#### Scenario: Usuario no titular no puede cancelar

- **WHEN** un usuario autenticado distinto del `ownerUserId` llama `POST /open-requests/{id}/cancel`
- **THEN** el sistema MUST responder `403 Forbidden`

#### Scenario: Solicitud inexistente o eliminada

- **WHEN** se llama cancel sobre un id inexistente o con `deleted_at` poblado
- **THEN** el sistema MUST responder `404` con código de error acorde al proyecto

#### Scenario: Sin autenticación

- **WHEN** se llama cancel sin Bearer token válido
- **THEN** el sistema MUST responder `401 Unauthorized`

### Requirement: Solicitudes canceladas excluidas del descubrimiento público

Los listados y consultas de descubrimiento público (`GET /open-requests`, `GET /open-requests/nearby`, orden por relevancia u otros listados documentados como catálogo público) MUST incluir únicamente solicitudes con `lifecycleStatus` = `ACTIVE` y sin soft-delete.

#### Scenario: Listado público omite canceladas

- **WHEN** existe una solicitud `CANCELLED` no eliminada
- **AND** un cliente llama `GET /open-requests`
- **THEN** esa solicitud MUST NOT aparecer en `items`

#### Scenario: Nearby omite canceladas

- **WHEN** una solicitud cancelada tenía coordenadas dentro de un radio nearby
- **THEN** `GET /open-requests/nearby` MUST NOT incluir esa solicitud

### Requirement: Historial del titular incluye canceladas

`GET /open-requests/mine` MUST devolver solicitudes del titular con `lifecycleStatus` `ACTIVE` y `CANCELLED`, excluyendo solo soft-deleted.

#### Scenario: Mine incluye cerradas

- **WHEN** el titular tiene una solicitud `CANCELLED`
- **AND** llama `GET /open-requests/mine`
- **THEN** la solicitud MUST aparecer en `items` con `lifecycleStatus` = `CANCELLED`

### Requirement: Detalle por id según rol y estado

`GET /open-requests/{id}` MUST devolver `lifecycleStatus` en el cuerpo cuando la lectura está permitida. Para solicitudes `CANCELLED`, la lectura MUST permitirse al titular y a usuarios autenticados que tengan al menos una propuesta asociada a esa solicitud. Para el resto de clientes (incluidos anónimos), MUST responder `404` como si la solicitud no existiera en catálogo público.

El endpoint MAY ser `@Public()` a nivel HTTP; cuando el cliente envía **Authorization: Bearer** válido, el sistema MUST resolver `viewerUserId` de la sesión antes de aplicar esta política (auth opcional en el guard, sin sustituir las reglas del use case).

#### Scenario: Titular lee solicitud cancelada

- **WHEN** el titular solicita `GET /open-requests/{id}` de su solicitud `CANCELLED` con Bearer válido
- **THEN** el sistema MUST responder `200` con `lifecycleStatus` = `CANCELLED`

#### Scenario: Postulante lee solicitud cancelada

- **WHEN** el usuario B tiene una propuesta sobre la solicitud `R` en estado `CANCELLED`
- **AND** B solicita `GET /open-requests/{id}` de `R` con Bearer válido
- **THEN** el sistema MUST responder `200` con `lifecycleStatus` = `CANCELLED`

#### Scenario: Visitante no accede a cancelada

- **WHEN** un cliente sin propuesta ni titularidad solicita `GET /open-requests/{id}` de una solicitud `CANCELLED` (sin sesión o sin relación)
- **THEN** el sistema MUST responder `404`

#### Scenario: Titular sin Bearer no ve cancelada

- **WHEN** el titular solicita `GET /open-requests/{id}` de su solicitud `CANCELLED` sin identificación de sesión
- **THEN** el sistema MUST responder `404`
- **AND** MUST NOT exponer el detalle como si fuera catálogo público

### Requirement: No se aceptan nuevas postulaciones en solicitudes canceladas

El sistema MUST rechazar `POST /proposals` cuando la solicitud objetivo tenga `lifecycleStatus` = `CANCELLED`, con error de negocio consumible por el cliente.

#### Scenario: Postulación a solicitud cancelada

- **WHEN** un usuario intenta crear una propuesta sobre una solicitud `CANCELLED`
- **THEN** la operación MUST fallar sin crear propuesta
- **AND** la respuesta MUST indicar que la solicitud ya no acepta postulaciones

### Requirement: Notificación a postulantes al cancelar

Tras una cancelación exitosa (`ACTIVE` → `CANCELLED`), el sistema MUST crear una notificación in-app para cada `userId` distinto que tenga propuesta en esa solicitud, excluyendo al titular que cancela. El fallo al crear una notificación MUST NOT revertir la cancelación.

#### Scenario: Dos postulantes reciben notificación

- **WHEN** la solicitud `R` tiene propuestas de los usuarios B y C
- **AND** el titular A cancela `R` exitosamente
- **THEN** MUST existir una notificación para B y otra para C asociadas a `R`
- **AND** A MUST NOT recibir notificación de cancelación como receptor por su propia acción

#### Scenario: Sin postulantes no falla cancel

- **WHEN** la solicitud no tiene propuestas
- **AND** el titular cancela
- **THEN** la cancelación MUST completarse con `200`
- **AND** MUST NOT crearse notificaciones

#### Scenario: Fallo de notificación no revierte cancel

- **WHEN** la cancelación se persiste correctamente
- **AND** falla la creación de una notificación
- **THEN** la respuesta de cancel MUST seguir siendo exitosa
- **AND** el error MUST registrarse en logs
