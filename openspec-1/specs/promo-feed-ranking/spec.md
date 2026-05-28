# promo-feed-ranking Specification

## Purpose
TBD - created by archiving change ranking-feed-promocional-home. Update Purpose after archive.
## Requirements
### Requirement: Feed promocional ordenado por score

El sistema SHALL devolver en `GET /promo-slides` solo campañas con `status` `testing` o `scaling`, ordenadas por score de rendimiento cuando hay datos suficientes, con fallback por `priority` y antigüedad en cold start.

#### Scenario: Cold start

- **WHEN** una campaña tiene menos de 10 impresiones en la ventana de métricas
- **THEN** su posición depende principalmente de `priority` y `createdAt`

#### Scenario: Fase testing con cap

- **WHEN** una campaña está en `testing` y superó el cap diario de impresiones
- **THEN** no aparece en la respuesta de `GET /promo-slides` hasta el día siguiente

### Requirement: Personalización mínima por actor

El sistema SHALL aceptar `anonymousId` en query (visitante) o identificar `userId` autenticado y SHALL colocar al final las campañas que el actor ya vio o con las que interactuó.

#### Scenario: Visitante con anonymousId

- **WHEN** `GET /promo-slides?anonymousId=<uuid>` y el actor ya tuvo `slideImpression` en `camp-promo-1`
- **THEN** `camp-promo-1` aparece después de campañas no vistas con score comparable

