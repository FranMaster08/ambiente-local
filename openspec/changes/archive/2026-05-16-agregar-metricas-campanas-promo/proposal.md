## Why

El ranking del feed promocional necesita **agregados por `campaignId`**, no solo eventos crudos en `promo_slide_interactions`. Sin métricas consultables no es posible evaluar retención ni interacción antes de reordenar `GET /promo-slides`.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 1, change 3.

## What Changes

- Agregación on-read (ventana 30 días por defecto): impresiones, vistas completas, `avgWatchMs`, tasa de skip temprano, likes/guardados/compartidos.
- Endpoints protegidos: `GET /promo-slides/metrics` y `GET /promo-slides/metrics/:campaignId` (permiso `promo-slides.metrics.read`).
- Persistencia de interacciones (prerrequisito Fase 0) en tabla `promo_slide_interactions`.
- Spec nueva `promo-campaign-metrics`; delta en `promo-slides-analytics`.

## Capabilities

### New Capabilities

- `promo-campaign-metrics`: métricas agregadas por campaña y ventana temporal.

### Modified Capabilities

- `promo-slides-analytics`: persistencia append-only de eventos (incluye retención).

## Impact

- **Backend:** `anyjobs-back/apps/api/src/modules/promo-slides/*`, migración `20260516120000-promo-slides-analytics-and-campaigns.ts`.
- **Front:** instrumentación de retención en `home.ts` (eventos hacia `POST /interactions`).
