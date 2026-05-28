## Decisiones

- **Almacenamiento MVP:** filesystem local en `uploads/user-media/`, mismo patrón que `open-request-images`. URLs relativas `/uploads/user-media/{storageKey}` resueltas con `PUBLIC_BASE_URL` en respuestas API.
- **Entidades:**
  - `media_assets`: binario subido (`owner_user_id`, `storage_key`, `mime_type`, `media_kind` image|video, `width`, `height`, `duration_ms`, `file_size_bytes`, `status` uploading|ready|failed).
  - `user_reels`: pieza publicable (`media_asset_id`, `caption`, `moderation_status` pending|approved|rejected|hidden, `distribution_status` draft|testing|scaling|paused, `published_at`).
- **Moderación MVP:** auto-`approved` al publicar si pasa validación de archivo (sin cola humana). Campo `moderation_status` preparado para flujo manual posterior.
- **Límites:** vídeo máx. 50 MB; MIME permitidos `video/mp4`, `video/webm`, `image/jpeg`, `image/png`, `image/webp`. Ratio recomendado 9:16 documentado en spec (no validado estrictamente en MVP).
- **RBAC:** permisos `user-media.upload`, `user-media.read.own`, `user-reels.manage.own`; listado público `@Public` solo reels `moderation_status=approved` y `distribution_status` ≠ draft.

## Endpoints

| Método | Ruta | Auth |
|--------|------|------|
| POST | `/user-media/assets` | `user-media.upload` (multipart `file`) |
| GET | `/user-media/assets/:assetId` | `user-media.read.own` o público si asset ligado a reel aprobado |
| POST | `/user-reels` | `user-reels.manage.own` |
| GET | `/user-reels/me` | `user-reels.manage.own` |
| PATCH | `/user-reels/:reelId` | `user-reels.manage.own` (dueño) |
| DELETE | `/user-reels/:reelId` | `user-reels.manage.own` |
| GET | `/users/:userId/reels` | `@Public` — solo aprobados |

## Non-goals

- UI de perfil (change 8).
- Feed global `GET /feed/reels` y ranking (change 9).
- S3, CDN, transcodificación, ML moderación.
- Telemetría de retención en reels (reutiliza patrones en change 9).
