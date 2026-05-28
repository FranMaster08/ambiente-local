## Why

Con el modelo backend (`modelo-contenido-multimedia`), el perfil debe dejar de mostrar placeholder y permitir subida, grid y reproducción real, derogando el requisito anterior de “próximamente”.

Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 3, change 8.

## What Changes

- Pestaña Multimedia funcional en `profile` (grid 9:16, modal reproductor, subida).
- Cliente `UserMediaApi` + interceptor Bearer en `/user-media` y `/user-reels`.
- Delta `vista-perfil-usuario`: listado y reproducción real.

## Capabilities

### Modified Capabilities

- `vista-perfil-usuario`: multimedia real en lugar de placeholder.

## Impact

- **Front:** `anyjobs-front/anyjobs/src/app/features/auth/profile/*`, `shared/api/user-media.api.ts`.
