## Why

Ordenar campañas del slider de `/home` por **rendimiento** (retención e interacción), con fases **testing → scaling** y personalización mínima por actor, adaptando ideas del algoritmo de Reels a AnyJobs.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 1, change 4.

## What Changes

- Tabla `promo_campaigns` (`id`, `status`, `priority`, `slide_data`, `testing_daily_impression_cap`).
- `GET /promo-slides` devuelve slides ordenados por score; query `anonymousId` para visitantes.
- Score: `(completionRate×0.5) + saves/shares/likes normalizados − (earlySkipRate×0.2)`; cold start por `priority` + fecha.
- Campañas `testing` respetan cap diario de impresiones.
- Depriorizar campañas ya vistas/interactuadas por el actor.
- Spec nueva `promo-feed-ranking`; delta en `home-promotional-slider`.

## Capabilities

### New Capabilities

- `promo-feed-ranking`: orden del feed y reglas testing/scaling.

### Modified Capabilities

- `home-promotional-slider`: `GET /promo-slides` ordenado por API; front pasa `anonymousId`.

## Impact

- **Backend:** `PromoFeedRankingService`, seed en migración.
- **Front:** query `anonymousId` en carga de slides; sin cambio de contrato `SlideData`.
