## Purpose

Ranking del feed de reels UGC con fases testing→scaling y personalización mínima.

## Requirements

### Requirement: El feed SHALL ordenar por score cuando hay datos suficientes

Con al menos 10 impresiones en ventana, el orden SHALL basarse en completion, interacciones normalizadas y penalización por skip temprano.

#### Scenario: Cold start

- **WHEN** un reel tiene menos de 10 impresiones
- **THEN** su posición depende principalmente de `published_at` descendente

### Requirement: Reels en testing SHALL respetar cap diario

#### Scenario: Cap superado

- **WHEN** un reel en `distribution_status=testing` superó `testing_daily_impression_cap` impresiones hoy
- **THEN** no aparece en `GET /feed/reels` hasta el día siguiente

### Requirement: Personalización mínima por actor

El sistema SHALL depriorizar reels que el actor ya impresionó o vio (`slideImpression`, `slideViewStart`, `slideAction`).

#### Scenario: Visitante con anonymousId

- **WHEN** `GET /feed/reels?anonymousId=<id>` y el actor ya vio un reel
- **THEN** ese reel aparece después de reels no vistos con score comparable
