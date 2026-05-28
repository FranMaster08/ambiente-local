## Why

El slider principal de **`/home`** sigue alimentándose de campañas promocionales (`GET /promo-slides`) con fallback a mock (`home-promo-slides.mock.json`), mientras que los Reels de clientes ya existen en backend con ranking, métricas e interacciones (`GET /feed/reels`, `user-reels-feed-ranking`). El producto necesita que ese espacio muestre **Reels reales clasificados**, no contenido de ejemplo, y dejar preparada la evolución de la fórmula de puntuación sin acoplar la Home a reglas definitivas.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — extensión natural tras `feed-reels-ranking-usuario` (change 9); alimenta el slider de `homeSliderPage` / `slide__overlay`.

## What Changes

- Columna **`ranking_score`** en `user_reels` (default `0`) y servicio aislado **`UserReelRankingScoreService`** con score **on-read**; materialización del valor en BD y fórmula avanzada quedan para iteración futura.
- Endpoint **`GET /home/featured-reels`** (público, con actor opcional) que devuelve hasta **15** Reels elegibles ordenados por puntuación descendente (`limit` default 15).
- Reutilización del ranking existente (`UserReelsFeedRankingService`) sin duplicar lógica en el front; la Home solo consume slides ya ordenados.
- **`app-home`**: sustituir carga desde `/promo-slides` + mock por `/home/featured-reels`; telemetría hacia **`POST /feed/reels/interactions`** con `reelId` y `sliderId` `home-featured-reels`.
- Estados de carga, **placeholder visual** en vacío/error, sin romper layout; **sin** mock como fuente principal.
- **No rompe** CRUD de Reels, `GET /feed/reels` ni el módulo `promo-slides` (sigue disponible para otros usos).

## Capabilities

### New Capabilities

- `home-featured-reels`: endpoint, elegibilidad, límite de resultados y contrato `SlideData` para el slider de Home.

### Modified Capabilities

- `home-promotional-slider`: fuente de datos UGC en lugar de promo/mock; telemetría de retención hacia interacciones de reels; mensajes de estado actualizados.
- `user-reels-ranking`: campo persistido `ranking_score` y servicio de cálculo/actualización desacoplado del orden en múltiples consumidores.

## Impact

- **Backend:** migración `user_reels.ranking_score`, `UserReelRankingScoreService`, `HomeFeaturedReelsController` o método en módulo `user-media`, extensión de `UserReelsFeedRankingService` con `listForHome(actor, limit)`.
- **Front:** `anyjobs-front/anyjobs/src/app/features/home/home/home.ts`, `home.html` (textos de estado), proxy/interceptor (`/home/featured-reels`, `/feed/reels`).
- **Specs existentes:** `user-reels-feed` sin cambio de contrato en `/feed/reels`; delta en ranking y Home.
- **Tests:** e2e `home-featured-reels`; regresión Home con 0 / 1 / N slides.
