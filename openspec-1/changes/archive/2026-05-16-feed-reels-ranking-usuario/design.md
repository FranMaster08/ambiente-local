## Decisiones

- **Interacciones:** tabla `user_reel_interactions` (misma forma que promo: `kind`, `reelId`, actor, `payload` JSON).
- **Métricas:** agregación on-read ventana 30 días por `reel_id`.
- **Score:** `completion×0.5 + saves×0.15 + shares×0.15 + likes×0.1 − earlySkip×0.2` (normalizado por impresiones).
- **Elegibilidad:** `moderation_status=approved`, `distribution_status` ∈ `testing`|`scaling`; cap diario si `testing` (default 200, columna `testing_daily_impression_cap`).
- **Cold start:** < 10 impresiones → orden por `published_at` desc.
- **Actor:** query `anonymousId` o `userId` de sesión; depriorizar reels ya vistos.
- **Front:** ruta `/reels`, sliderId `user-reels-feed`, reutiliza patrones de `home.ts`.

## Endpoints

| Método | Ruta | Auth |
|--------|------|------|
| GET | `/feed/reels` | `@Public` |
| POST | `/feed/reels/interactions` | `@Public` |

## Non-goals

- Modelo social seguidores (MVP: sin boost por relación).
- Transcodificación o ML.
