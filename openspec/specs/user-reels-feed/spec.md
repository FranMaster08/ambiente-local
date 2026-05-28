## Purpose

Feed vertical de reels de usuario consumible en la app (`GET /feed/reels`).

## Requirements

### Requirement: El feed SHALL devolver slides reproducibles

`GET /feed/reels` SHALL devolver un array de objetos con `id` (reelId), `type` (`image`|`video`), `media` (URL absoluta), `caption` opcional y `creatorUserId`.

#### Scenario: Feed con reels elegibles

- **WHEN** existen reels aprobados en fase testing o scaling
- **THEN** la respuesta SHALL ser un array ordenado por el servicio de ranking y cada ítem SHALL incluir URL de media válida

#### Scenario: Sin contenido elegible

- **WHEN** no hay reels que cumplan criterios de distribución
- **THEN** la respuesta SHALL ser un array vacío

### Requirement: El cliente SHALL registrar interacciones de retención

`POST /feed/reels/interactions` SHALL aceptar los mismos `kind` que el slider promocional (`slideImpression`, `watchProgress`, `slideSkipped`, etc.) con `reelId` en lugar de `campaignId`.

#### Scenario: Persistir watchProgress

- **WHEN** el cliente envía `watchProgress` con `reelId` y `completionRate`
- **THEN** el sistema SHALL persistir el evento append-only
