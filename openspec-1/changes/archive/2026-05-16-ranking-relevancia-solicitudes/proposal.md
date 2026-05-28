## Why

Mejorar el descubrimiento de solicitudes en el marketplace ordenando el listado por **relevancia** (engagement, frescura, relación previa con el publicador), reutilizando telemetría ya persistida en `open_request_interactions`.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 2, change 6.

## What Changes

- `GET /open-requests?sort=relevance` devuelve páginas ordenadas por score; `sort=date` / `publishedAtDesc` mantiene orden por fecha.
- Query opcional `anonymousId` para visitantes; `userId` desde JWT / `x-user-id` en dev.
- Agregados de engagement por `openRequestId` (ventana 30 días).
- Score: frescura + engagement + relación + afinidad de tags − depriorización por vistas previas del actor.
- Cold start: orden por `publishedAtSort` cuando impresiones &lt; 5.
- Front `/solicitudes` usa `sort=relevance` por defecto en el listado público.

## Capabilities

### New Capabilities

- `open-requests-ranking`: score, señales y reglas de orden.

### Modified Capabilities

- `open-requests` (back): parámetro `sort` y actor en listado.
- `open-requests-browse` (front): consumo de `sort=relevance`.

## Impact

- **Backend:** `OpenRequestsEngagementMetricsService`, `OpenRequestsRankingService`, `ListOpenRequestsUseCase`.
- **Front:** `open-requests-landing`, tipos `sort`.
- **Tests:** e2e `sort=relevance` con interacciones semilla.
