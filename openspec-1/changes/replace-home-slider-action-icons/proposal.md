## Why

El slider de reels (`ngx-vertical-slider`) muestra hoy **emojis Unicode** (♥, 💬, 🔖, ↪) como iconografía de acciones y **avatares generados por ui-avatars.com** cuando no hay foto real. Eso implica dependencia de un servicio externo, apariencia inconsistente entre plataformas y riesgo percibido de **derechos de autor / marca** al usar símbolos que imitan productos de terceros. Se necesita una capa visual propia, con licencia clara y sin llamadas a dominios de avatar de terceros.

## What Changes

- Sustituir la iconografía visible de las acciones del slider (like, comment, bookmark, share) por **SVG propios** (assets en el repo o generados en build), aplicados mediante estilos compartidos sobre `media-action-button` sin fork de la librería en esta iteración.
- Reemplazar URLs `ui-avatars.com` por **placeholders locales** (SVG con iniciales y colores de marca) en front y back.
- Aplicar el mismo tratamiento en **todas las superficies** que montan `ngx-vertical-slider`: `/home`, `/reels` (mobile) y galería desktop de reels.
- Mantener contratos de eventos (`slideAction`, `data-action`, telemetría) sin cambios funcionales.
- Actualizar specs de slider y feeds para exigir ausencia de ui-avatars y uso de iconos con licencia documentada.

## Capabilities

### New Capabilities

- `media-slider-licensed-visuals`: Requisitos de iconografía de acciones y avatares placeholder para cualquier vista que use `ngx-vertical-slider`, incluyendo licencia, accesibilidad y prohibición de servicios externos de avatar.

### Modified Capabilities

- `home-promotional-slider`: Los escenarios y requisitos de UI del slider MUST referir iconos propios (no emojis) y avatares sin ui-avatars.
- `home-featured-reels`: El contrato de slide MUST NOT devolver `avatar` apuntando a ui-avatars; el cliente resuelve placeholder local.
- `user-reels-feed`: Los slides del feed MUST NOT incluir `avatar` de ui-avatars; mismo resolver que Home.

## Impact

- **Front-end:** `anyjobs-front/anyjobs/` — `user-avatar-placeholder.ts`, estilos en `home.scss`, `reels-feed.scss`, `reels-desktop-gallery.scss`, nuevo partial/assets en `shared/media/`.
- **Back-end:** `user-reels-feed-ranking.service.ts` (y cualquier mapper que emita ui-avatars).
- **Librería:** `ngx-vertical-slider@1.2.0` — sin fork; overrides CSS/documentados.
- **Sin cambios** en endpoints de telemetría, panel de comentarios ni ranking.
