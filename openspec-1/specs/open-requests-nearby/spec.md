## Purpose

Contrato del endpoint `GET /open-requests/nearby` para consultar solicitudes abiertas cercanas por coordenadas, con distancia calculada en servidor.

## Requirements

### Requirement: Nearby open requests API base path

El sistema MUST exponer `GET /open-requests/nearby` bajo el mismo prefijo `/open-requests` que el resto de la sub-API.

#### Scenario: Ruta alcanzable

- **WHEN** el cliente construye la URL como `<host>/open-requests/nearby`
- **THEN** el endpoint responde según este spec

### Requirement: Consulta por proximidad con límite máximo 100

El endpoint MUST aceptar query params:

- `lat: number` (obligatorio, -90 a 90)
- `lng: number` (obligatorio, -180 a 180)
- `limit: number` (opcional; default 100; máximo 100)
- `radiusKm: number` (opcional; default razonable documentado en implementación, p. ej. 50)

El sistema MUST responder `200` con JSON:

- `items: array` de objetos con al menos:
  - `id: string`
  - `excerpt: string`
  - `tags: string[]`
  - `locationLabel: string`
  - `locationLat: number`
  - `locationLng: number`
  - `distanceKm: number`
  - `publishedAtLabel: string`
  - `budgetLabel: string`
  - `imageUrl: string`
  - `imageAlt: string`

Los ítems MUST estar ordenados por `distanceKm` ascendente.

#### Scenario: Consulta válida devuelve hasta 100 cercanas

- **WHEN** el cliente llama `GET /open-requests/nearby?lat=-34.6&lng=-58.4&limit=100`
- **THEN** el sistema responde `200`
- **AND** `items.length` es menor o igual a 100
- **AND** cada ítem incluye `distanceKm` calculado respecto a `lat`/`lng` del query

#### Scenario: Límite superior acotado

- **WHEN** el cliente llama con `limit=500`
- **THEN** el sistema MUST devolver como máximo 100 ítems

#### Scenario: Parámetros de ubicación inválidos

- **WHEN** `lat` o `lng` están ausentes o fuera de rango
- **THEN** el sistema MUST responder `400` con el contrato de error global

### Requirement: Solo solicitudes abiertas y con coordenadas válidas

El endpoint MUST incluir únicamente registros de open requests que:

- No estén eliminados (`deleted_at` nulo).
- Tengan `location_lat` y `location_lng` no nulos en persistencia.

El endpoint MUST NOT devolver solicitudes sin coordenadas persistidas ni registros soft-deleted.

#### Scenario: Solicitud sin coordenadas excluida

- **WHEN** existe una solicitud abierta con `location_lat` nulo
- **THEN** esa solicitud MUST NOT aparecer en `items`

#### Scenario: Solicitud eliminada excluida

- **WHEN** existe una solicitud con `deleted_at` definido
- **THEN** esa solicitud MUST NOT aparecer en `items`

### Requirement: Distancia calculada en servidor

`distanceKm` MUST calcularse en el backend (p. ej. Haversine) y MUST NOT delegarse al cliente para ordenar o filtrar el conjunto base.

#### Scenario: Orden por cercanía

- **WHEN** la consulta devuelve más de un ítem
- **THEN** para todo par consecutivo `i`, `i+1` en `items`, `items[i].distanceKm <= items[i+1].distanceKm`
