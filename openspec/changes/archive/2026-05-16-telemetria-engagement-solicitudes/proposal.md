## Why

El ranking de relevancia de solicitudes (Fase 2, change 6) necesita señales de engagement por `openRequestId`. Hoy no hay persistencia de impresiones, clics, tiempo en detalle ni inicio de postulación.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 2, change 5.

## What Changes

- Tabla append-only `open_request_interactions` y `POST /open-requests/interactions` (204, público).
- Eventos: `requestListImpression`, `requestCardClick`, `requestDetailView`, `timeOnDetailMs`, `proposalStarted`.
- Instrumentación en `open-requests-landing`, `open-request-detail`, `open-request-proposal-compose` y card del listado.
- Servicio compartido `OpenRequestsAnalyticsService` con `anonymousId` en `localStorage`.
- Sin alterar el orden de `GET /open-requests`.
- Corrección Angular 21: `afterNextRender` solo vía `runInInjectionContext` (evita NG0203 y listado colgado en loading).

## Capabilities

### New Capabilities

- `open-requests-engagement-analytics`: persistencia y contrato de telemetría de engagement.

### Modified Capabilities

- `open-requests` (back): endpoint de interacciones documentado.
- `open-requests-browse` (front): emisión de eventos desde listado y detalle; la carga inicial MUST completar aunque exista telemetría.

## Impact

- **Backend:** `anyjobs-back/apps/api/src/modules/open-requests/*`, migración `20260516140000-open-request-interactions.ts`.
- **Front:** `anyjobs-front/anyjobs/src/app/features/open-requests/*`, `open-request-card`, `home.ts` (mismo patrón NG0203 que promo).
- **Specs sincronizables:** `openspec/specs/open-requests-engagement-analytics/spec.md` (raíz).

## Estado

Implementación completa y verificada manualmente (listado visible, eventos en BD). Pendiente: `openspec verify` + archivar change.
