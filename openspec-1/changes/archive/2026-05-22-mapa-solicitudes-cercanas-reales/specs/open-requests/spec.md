## ADDED Requirements

### Requirement: Coordenadas opcionales en open requests

El modelo de persistencia de open requests MUST almacenar opcionalmente:

- `location_lat: number | null`
- `location_lng: number | null`

`POST /open-requests` y `PATCH /open-requests/:id` MAY aceptar en el body:

- `locationLat: number` (opcional, -90 a 90)
- `locationLng: number` (opcional, -180 a 180)

Si ambos se envían en creación o actualización, MUST persistirse. Si no se envían, las columnas MUST permanecer o quedar en `NULL`.

#### Scenario: Crear solicitud con coordenadas

- **WHEN** el cliente envía `POST /open-requests` con `locationLat` y `locationLng` válidos
- **THEN** el registro creado MUST tener ambas columnas no nulas
- **AND** `GET /open-requests/nearby` puede incluir esa solicitud si está dentro del radio

#### Scenario: Crear solicitud sin coordenadas

- **WHEN** el cliente envía `POST /open-requests` sin `locationLat` ni `locationLng`
- **THEN** el registro MUST crearse con `location_lat` y `location_lng` nulos
- **AND** `GET /open-requests/nearby` MUST NOT incluir esa solicitud

#### Scenario: Coordenadas inválidas rechazadas

- **WHEN** el cliente envía `locationLat` fuera de rango
- **THEN** el sistema MUST responder `400` sin persistir valores inválidos

## MODIFIED Requirements

### Requirement: List open requests with pagination

El sistema MUST exponer `GET /open-requests` con query params:

- `page: number` (min 1)
- `pageSize: number` (min 1; el front usa 12)
- `sort?: string` (opcional; `relevance`, `date` o `publishedAtDesc`; default interno `publishedAtDesc`)
- `anonymousId?: string` (opcional; personalización para visitantes con `sort=relevance`)

El sistema MUST responder `200` con JSON:

- `items: array` de objetos con:
  - `id: string`
  - `imageUrl: string`
  - `imageAlt: string`
  - `excerpt: string` (si vacío, el front hace fallback)
  - `tags: string[]`
  - `locationLabel: string`
  - `locationLat: number` (opcional; presente solo si persistido)
  - `locationLng: number` (opcional; presente solo si persistido)
  - `publishedAtLabel: string`
  - `budgetLabel: string`
- `nextPage: number | null`
- `hasMore: boolean`

`nextPage` MAY ser `null` siempre que `hasMore` sea consistente.

#### Scenario: List returns paginated structure

- **WHEN** el cliente llama `GET /open-requests?page=1&pageSize=12`
- **THEN** el sistema responde `200` con `items` array, `hasMore` boolean y `nextPage` number o null

#### Scenario: List by relevance

- **WHEN** el cliente llama `GET /open-requests?sort=relevance&page=1&pageSize=12`
- **THEN** el sistema responde `200` con items ordenados por score de relevancia descendente

#### Scenario: List by date explicit

- **WHEN** el cliente llama `GET /open-requests?sort=date`
- **THEN** el orden coincide con `publishedAtDesc` por `publishedAtSort` descendente
