## 1. Backend

- [x] 1.1 `OpenRequestsEngagementMetricsService` (agregados por `openRequestId`)
- [x] 1.2 `OpenRequestsRankingService` (score, cold start, depriorización, relación)
- [x] 1.3 `ListOpenRequestsUseCase` + controller (`sort`, `anonymousId`)
- [x] 1.4 E2e: `sort=relevance` altera orden tras interacciones

## 2. Front

- [x] 2.1 Tipos `sort`: `relevance` | `publishedAtDesc` | `date`
- [x] 2.2 Landing usa `sort=relevance` y pasa `anonymousId`

## 3. Verificación

- [x] 3.1 `openspec verify --change ranking-relevancia-solicitudes`
- [x] 3.2 Archivar change
