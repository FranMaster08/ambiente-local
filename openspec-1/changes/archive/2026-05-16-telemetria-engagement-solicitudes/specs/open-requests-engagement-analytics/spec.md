## ADDED Requirements

### Requirement: Persist open request engagement events

The system SHALL persist each `POST /open-requests/interactions` in `open_request_interactions` with `kind`, `openRequestId`, actor (`subjectType`, `userId`, `anonymousId`), optional `route` / `listPage`, and optional JSON `payload`.

#### Scenario: POST interaction persists row

- **WHEN** the client sends a valid interaction body with `kind` and `openRequestId`
- **THEN** the system responds `204` and a row exists in `open_request_interactions`

### Requirement: Supported engagement event kinds

The client SHALL be able to send `kind` among: `requestListImpression`, `requestCardClick`, `requestDetailView`, `timeOnDetailMs`, `proposalStarted`.

#### Scenario: timeOnDetailMs stores duration

- **WHEN** the client sends `timeOnDetailMs` with `viewDurationMs` in the body or payload
- **THEN** the persisted row includes the duration in `payload`

### Requirement: Public interactions endpoint

`POST /open-requests/interactions` SHALL be reachable without authentication (same as promo slides telemetry).

#### Scenario: Anonymous actor can track

- **WHEN** the client sends `subjectType: anonymous` with `anonymousId`
- **THEN** the system responds `204`

### Requirement: Client defers DOM instrumentation safely (Angular 21)

The client SHALL schedule DOM-dependent telemetry (e.g. `IntersectionObserver` on list cards) only after the list is rendered, using APIs compatibles con el contexto de inyección de Angular (p. ej. `runInInjectionContext` + `afterNextRender`). MUST NOT throw `NG0203` ni bloquear la carga del listado.

#### Scenario: List loads after telemetry hooks are registered

- **WHEN** the browse landing receives list data from the API
- **THEN** the UI shows the list (not an infinite loading state)
- **AND** impression tracking MAY register after the next render without runtime errors
