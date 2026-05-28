## ADDED Requirements

### Requirement: Emit list and navigation telemetry

The open requests browse experience SHALL send engagement events to `POST /open-requests/interactions` without changing list sort order.

#### Scenario: List impression on visible card

- **WHEN** a request card becomes visible in the browse list
- **THEN** the client sends `requestListImpression` with that `openRequestId`

#### Scenario: Card click before navigation

- **WHEN** the user activates a request card to open detail
- **THEN** the client sends `requestCardClick` with that `openRequestId`

#### Scenario: Detail view and dwell time

- **WHEN** the detail page loads successfully for a request
- **THEN** the client sends `requestDetailView`
- **AND WHEN** the user leaves the detail page
- **THEN** the client sends `timeOnDetailMs` with elapsed milliseconds

#### Scenario: Proposal flow started

- **WHEN** the user opens the proposal compose screen for a request
- **THEN** the client sends `proposalStarted`

## MODIFIED Requirements

### Requirement: Carga inicial del listado

La landing MUST solicitar y renderizar un listado de solicitudes abiertas ordenadas por fecha de publicación descendente (más recientes primero). La instrumentación de telemetría (impresiones, clics) MUST NOT impedir que la UI transicione del estado de carga al listado visible cuando la API responde correctamente.

#### Scenario: La landing carga datos correctamente

- **WHEN** la landing se inicializa y `GET /open-requests` responde con éxito
- **THEN** el sistema MUST dejar de mostrar el estado de carga y renderizar el listado (o estado vacío)
- **AND** MUST NOT quedar bloqueado en loading por errores de runtime en hooks de render diferido (`afterNextRender`, etc.)

#### Scenario: El orden por defecto es “más recientes”

- **WHEN** el sistema construye la solicitud de listado sin un orden explícito del usuario
- **THEN** el sistema MUST aplicar un orden por defecto equivalente a “más recientes primero” (`publishedAtDesc` o equivalente)
