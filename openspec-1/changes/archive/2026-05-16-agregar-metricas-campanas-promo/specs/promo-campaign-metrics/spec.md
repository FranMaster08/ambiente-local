## ADDED Requirements

### Requirement: Métricas agregadas por campaña

El sistema SHALL exponer métricas por `campaignId` para una ventana temporal configurable (default 30 días), incluyendo: `impressions`, `completeViews`, `avgWatchMs`, `earlySkipRate`, `likes`, `saves`, `shares`, `completionRate`.

#### Scenario: Consulta global de métricas

- **WHEN** un cliente autorizado con `promo-slides.metrics.read` llama `GET /promo-slides/metrics`
- **THEN** recibe un arreglo de objetos con `campaignId` y los campos agregados

#### Scenario: Consulta por campaña

- **WHEN** un cliente autorizado llama `GET /promo-slides/metrics/:campaignId`
- **THEN** recibe las métricas de esa campaña o null si no hay datos
