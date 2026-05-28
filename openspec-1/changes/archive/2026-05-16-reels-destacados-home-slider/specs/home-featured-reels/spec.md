## ADDED Requirements

### Requirement: Endpoint de Reels destacados para Home

El sistema SHALL exponer **`GET /home/featured-reels`** que devuelve un array de slides compatibles con **`SlideData`** para el slider principal de **`/home`**, ordenados por puntuación descendente.

#### Scenario: Reels elegibles disponibles

- **WHEN** existen reels con `moderation_status=approved`, `distribution_status` en `testing` o `scaling`, media `ready` y score calculable
- **THEN** la respuesta SHALL ser un array no vacío ordenado por score efectivo de mayor a menor, limitado a **como máximo 15** ítems (default del endpoint)

#### Scenario: Sin reels elegibles

- **WHEN** no hay reels que cumplan criterios de elegibilidad
- **THEN** la respuesta SHALL ser un array vacío `[]` con HTTP 200

#### Scenario: Reel sin media válida

- **WHEN** un reel referencia un asset inexistente, no listo o sin URL pública resoluble
- **THEN** ese reel MUST NOT aparecer en la respuesta

#### Scenario: Reel eliminado o no público

- **WHEN** un reel está en `draft`, `paused`, `rejected`, `hidden` o `pending` de moderación
- **THEN** ese reel MUST NOT aparecer en la respuesta

### Requirement: Actor opcional para personalización futura

`GET /home/featured-reels` SHALL aceptar **`anonymousId`** en query para visitantes y SHALL considerar **`userId`** de sesión autenticada cuando exista, con la misma semántica de depriorización que `GET /feed/reels` (reels ya vistos después de no vistos con score comparable).

#### Scenario: Usuario autenticado

- **WHEN** la petición incluye JWT válido o identificador de usuario reconocido por el backend
- **THEN** el orden MAY depriorizar reels ya impresionados o vistos por ese usuario

#### Scenario: Visitante anónimo

- **WHEN** se envía `anonymousId` estable en query
- **THEN** el orden MAY depriorizar reels ya asociados a ese `anonymousId`

### Requirement: Contrato de slide para Home

Cada ítem SHALL incluir al menos: **`id`** (reelId), **`type`** (`image`|`video`), **`media`** (URL absoluta), **`creatorUserId`** o equivalente, y **`user`** (nombre del creador) cuando esté disponible. Campos opcionales (`caption`, `avatar`, `music`, `counts`) MAY omitirse sin invalidar el slide.

#### Scenario: Slide de video con caption

- **WHEN** el reel tiene caption y asset de video listo
- **THEN** el objeto incluye `type: 'video'`, `media` reproducible y `caption` opcional para el overlay

### Requirement: Límite de resultados para el slider

El endpoint SHALL devolver **como máximo 15** reels destacados. El parámetro query **`limit`** MAY permitir un valor menor; si se omite, el default SHALL ser **15**. El backend MUST NOT devolver más de 15 ítems en este change.

#### Scenario: Más reels elegibles que el límite

- **WHEN** existen 50 reels elegibles y no se envía `limit` (o `limit=15`)
- **THEN** la respuesta contiene exactamente 15 ítems (o menos si hay menos elegibles), los de mayor score efectivo

#### Scenario: Límite explícito menor

- **WHEN** el cliente envía `limit=5` y hay al menos 5 reels elegibles
- **THEN** la respuesta contiene 5 ítems ordenados por score descendente
