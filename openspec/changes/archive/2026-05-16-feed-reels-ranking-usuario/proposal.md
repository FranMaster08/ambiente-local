## Why

Con reels en perfil y telemetría de retención del slider, el producto necesita un **feed vertical de UGC** ordenado por rendimiento (estilo fases testing→scaling), no solo listado por usuario.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 3, change 9.

## What Changes

- `user_reel_interactions` + `POST /feed/reels/interactions`.
- `GET /feed/reels` con ranking (retención, likes/guardados/compartidos, skip temprano, cap testing).
- Ruta front `/reels` con `MediaSliderComponent` e instrumentación de retención.
- Specs `user-reels-feed`, `user-reels-ranking`.

## Capabilities

### New Capabilities

- `user-reels-feed`: endpoint de feed y contrato de slide.
- `user-reels-ranking`: scoring, caps y personalización mínima.

## Impact

- **Backend:** módulo `user-media` ampliado.
- **Front:** `features/reels-feed/`, ruta `/reels`, interceptor `/feed`.
