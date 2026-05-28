## 1. Modelo de campaña

- [x] 1.1 Tabla `promo_campaigns` + seed `camp-promo-1` (scaling), `camp-promo-2` (testing)
- [x] 1.2 Estados `draft` | `testing` | `scaling` | `paused`

## 2. Ranking

- [x] 2.1 `PromoFeedRankingService` con score y cold start
- [x] 2.2 Cap diario para campañas `testing`
- [x] 2.3 Depriorización por historial del actor
- [x] 2.4 `GET /promo-slides` usa ranking

## 3. Front

- [x] 3.1 `GET /promo-slides?anonymousId=…` en Home
- [x] 3.2 Sin cambios en contrato `SlideData` del slider
