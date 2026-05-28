## 1. Persistencia (Fase 0 — prerrequisito)

- [x] 1.1 Migración `promo_slide_interactions` + entidad TypeORM
- [x] 1.2 `POST /promo-slides/interactions` persiste y responde 204
- [x] 1.3 E2e: POST persiste fila consultable

## 2. Retención en front (Fase 0)

- [x] 2.1 Eventos `slideImpression`, `slideViewStart`/`End`, `watchProgress`, `slideSkipped`
- [x] 2.2 Umbral skip temprano 2000 ms (MutationObserver sobre `is-visible`)

## 3. Métricas (Fase 1)

- [x] 3.1 `PromoCampaignMetricsService` con agregados por campaña
- [x] 3.2 `GET /promo-slides/metrics` y `GET /promo-slides/metrics/:campaignId`
- [x] 3.3 E2e métricas con permiso RBAC
