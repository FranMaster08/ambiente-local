## Why
La Fase 3 del plan de feed/algoritmo requiere un **modelo de datos y almacenamiento** para contenido multimedia de usuario (reels en perfil y feed futuro). Hoy `vista-perfil-usuario` prohíbe listar o reproducir video real; sin entidades `media_asset` y `user_reel` no hay base para subida, moderación ni ranking.
Ref.: `PLAN-ACCION-FEED-ALGORITMO.md` — Fase 3, change 7.
## What Changes
- Entidades `media_assets` y `user_reels` con estados de moderación y distribución.
- Provider de almacenamiento local para vídeo (MVP), URLs públicas resueltas con `resolvePublicAssetUrl`.
- APIs backend: subida de asset, CRUD de reels propios, listado público de reels aprobados por `userId`.
- RBAC por dueño (`user-media.*`, `user-reels.*`).
- Specs nuevas `user-media-content` y `media-storage`.
## Capabilities
### New Capabilities
- `user-media-content`: modelo `user_reel`, moderación, endpoints CRUD y listado por perfil.
- `media-storage`: persistencia de `media_asset`, límites de tamaño/MIME, almacenamiento local.
### Modified Capabilities
- (ninguna en main specs en este change; `vista-perfil-usuario` se modifica en change 8)
## Impact
- **Backend:** nuevo módulo `anyjobs-back/apps/api/src/modules/user-media/*`, migración `20260516160000-user-media-content.ts`.
- **Infra:** directorio `uploads/user-media/` servido por `/uploads` existente.
- **Front:** sin cambios en este change (change 8 `reels-perfil-subida-reproduccion`).