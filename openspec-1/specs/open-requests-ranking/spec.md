# open-requests-ranking Specification

## Purpose

Ordenar solicitudes abiertas por relevancia para cada actor usando telemetría de engagement.

## Requirements

### Requirement: Listado por relevancia

El sistema SHALL exponer `GET /open-requests?sort=relevance` devolviendo solicitudes ordenadas por score descendente, con paginación compatible (`items`, `meta`, `nextPage`, `hasMore`).

#### Scenario: Orden por engagement

- **WHEN** una solicitud A tiene más clics y vistas de detalle que B en la ventana de métricas
- **THEN** A aparece antes que B con `sort=relevance` (salvo depriorización por historial del actor)

#### Scenario: Fallback por fecha

- **WHEN** `sort=date` o `sort=publishedAtDesc`
- **THEN** el orden es exclusivamente por `publishedAtSort` descendente

#### Scenario: Cold start

- **WHEN** una solicitud tiene menos de 5 impresiones agregadas
- **THEN** su score usa solo el componente de frescura (peso parcial, no 1.0)

### Requirement: Personalización mínima

El sistema SHALL depriorizar solicitudes ya impresionadas o vistas en detalle por el mismo actor (`userId` o `anonymousId`).

#### Scenario: Actor anónimo

- **WHEN** `anonymousId` se envía en query y en eventos previos
- **THEN** las solicitudes ya impresionadas por ese `anonymousId` van al final

### Requirement: Relación con publicador

Para usuarios autenticados, el sistema SHALL aumentar el score si el actor postuló antes a otra solicitud del mismo `owner_user_id`.

#### Scenario: Postulación previa

- **WHEN** el usuario envió `proposalStarted` en otra solicitud del mismo dueño
- **THEN** las solicitudes de ese dueño reciben mayor `relationshipBoost`
