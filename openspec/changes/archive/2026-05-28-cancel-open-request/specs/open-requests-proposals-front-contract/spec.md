## ADDED Requirements

### Requirement: Modelo de solicitud incluye lifecycleStatus

El cliente Angular MUST mapear el campo `lifecycleStatus` (`ACTIVE` | `CANCELLED`) en `OpenRequestDetail` y en ítems de listado propio (`GET /open-requests/mine`) cuando el API lo exponga. Si el campo está ausente en respuestas legacy, el cliente MUST asumir `ACTIVE`.

#### Scenario: Detalle con solicitud cancelada

- **WHEN** `GET /open-requests/{id}` devuelve `lifecycleStatus` = `CANCELLED` para una lectura permitida
- **THEN** el modelo `OpenRequestDetail` del cliente MUST exponer `lifecycleStatus` = `CANCELLED` a los componentes

#### Scenario: Listado mine con solicitud cerrada

- **WHEN** `GET /open-requests/mine` incluye un ítem con `lifecycleStatus` = `CANCELLED`
- **THEN** el normalizador de listado MUST preservar ese valor para la UI de Mis solicitudes

### Requirement: Servicio de cancelación de solicitud

El cliente MUST exponer en `OpenRequestsService` un método `cancelOpenRequest(id: string)` que invoca `POST <apiUrl>/{id}/cancel` con autenticación Bearer y maneja errores con el mismo mecanismo que otras mutaciones del módulo.

#### Scenario: Llamada exitosa

- **WHEN** el titular invoca `cancelOpenRequest(id)` sobre una solicitud activa
- **THEN** el cliente MUST enviar `POST` al path `/cancel` del recurso
- **AND** MUST completar el observable sin error ante `200`

#### Scenario: Error de autorización

- **WHEN** el servidor responde `403` o `404`
- **THEN** el cliente MUST propagar el error para que la UI muestre feedback acorde

### Requirement: Etiquetas UI de lifecycleStatus

El cliente MUST centralizar el mapeo de etiquetas visibles en español según contexto:

- Pestaña «Publicadas por mí»: `ACTIVE` → «Activo», `CANCELLED` → «Cerrado»
- Pestaña «Postulé a estas» (solicitud padre): `CANCELLED` → «Cancelada» en chip de estado de la card; `ACTIVE` mantiene «Enviada» para la propuesta del usuario

#### Scenario: Chip en publicadas

- **WHEN** se renderiza una card en «Publicadas por mí» con `lifecycleStatus` = `ACTIVE`
- **THEN** la chip visible MUST ser «Activo»

#### Scenario: Chip cerrado en publicadas

- **WHEN** se renderiza una card con `lifecycleStatus` = `CANCELLED`
- **THEN** la chip visible MUST ser «Cerrado»

### Requirement: Acciones condicionadas en Mis solicitudes para canceladas

En la pestaña «Postulé a estas», cuando la solicitud asociada a la propuesta tiene `lifecycleStatus` = `CANCELLED`, el cliente MUST ocultar los controles «Ver detalle» y «Ver mi propuesta» / «Ocultar mi propuesta» y MUST mantener el ítem en la lista.

#### Scenario: Sin navegación a detalle desde applied cancelada

- **WHEN** el ítem applied tiene solicitud `CANCELLED`
- **THEN** MUST NOT renderizarse el enlace a `/solicitudes/:id` en acciones de la card

### Requirement: Contador de postulantes en detalle del owner

En `open-request-detail`, cuando el usuario es el owner de la solicitud, el cliente MUST cargar las propuestas de la solicitud (`ProposalsService.listByRequest`) para mostrar el contador en el primer botón del sidebar.

#### Scenario: Etiqueta con contador

- **WHEN** el owner abre el detalle y existen 3 propuestas
- **THEN** el control primario MUST mostrar «Ver postulantes (3)»

#### Scenario: Cero postulantes deshabilitado

- **WHEN** el owner abre el detalle y no hay propuestas
- **THEN** el control primario MUST mostrar «Sin postulantes aún» deshabilitado

#### Scenario: Detalle cancelado con Bearer

- **WHEN** el owner o postulante solicita detalle de solicitud `CANCELLED` con token en el interceptor
- **THEN** `getOpenRequestDetail` MUST recibir `lifecycleStatus` = `CANCELLED` (no error 404 por falta de sesión en ruta pública)
