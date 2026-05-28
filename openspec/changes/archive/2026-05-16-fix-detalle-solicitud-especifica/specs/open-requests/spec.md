## ADDED Requirements

### Requirement: publishedAtLabel derivado de publishedAtSort en lecturas

En respuestas de listado y detalle de open requests, el sistema MUST calcular `publishedAtLabel` a partir de `publishedAtSort` (epoch en milisegundos almacenado en persistencia) usando reglas de antigüedad relativa en español. El valor persistido en columna `publishedAtLabel` MAY conservarse para compatibilidad pero MUST NOT ser la fuente de verdad en respuestas HTTP de lectura.

#### Scenario: Detalle devuelve antigüedad coherente

- **WHEN** el cliente llama `GET /open-requests/{id}` para un registro con `publishedAtSort` de hace 30 días
- **THEN** el body MUST incluir `publishedAtLabel` que refleje aproximadamente “Hace 1 mes” (según umbrales del helper)
- **AND** MUST NOT devolver únicamente el texto fijado al momento de creación si este contradice la antigüedad real

#### Scenario: Listado paginado usa la misma regla

- **WHEN** el cliente llama `GET /open-requests` o `GET /open-requests/mine`
- **THEN** cada ítem en `items[]` MUST incluir `publishedAtLabel` calculado con la misma función que el detalle

## MODIFIED Requirements

### Requirement: Get open request detail by id

El sistema MUST exponer `GET /open-requests/{id}` y responder `200` con JSON que incluya al menos:

- `id: string`
- `title: string`
- `excerpt: string`
- `description: string`
- `tags: string[]`
- `locationLabel: string`
- `publishedAtLabel: string` (derivado de `publishedAtSort` en tiempo de respuesta)
- `budgetLabel: string`
- `ownerUserId: string` (cuando exista en persistencia; requerido para UI de publicador)
- `provider: object` con:
  - `name: string`
  - `badge: string`
  - `subtitle: string`
- `reputation: number` (rango esperado 0.0–5.0)
- `reviewsCount: number`
- `providerReviews: array` de objetos con:
  - `author: string`
  - `rating: number`
  - `dateLabel: string`
  - `text: string`
- `contactPhone: string`
- `contactEmail: string`
- `images: array` de objetos `{ url: string, alt: string }`

El campo `images` MUST existir y MUST ser un array (aunque sea `[]`).

#### Scenario: Detail always returns images array

- **WHEN** el cliente llama `GET /open-requests/{id}` para un id existente
- **THEN** el sistema responde `200` y el body incluye `images` como array

#### Scenario: Detail includes owner for publisher UI

- **WHEN** el registro tiene `ownerUserId` en base de datos
- **THEN** la respuesta MUST incluir `ownerUserId` en el JSON de detalle
