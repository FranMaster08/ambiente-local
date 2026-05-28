## Context

- `ngx-vertical-slider@1.2.0` renderiza iconos de acción como texto Unicode en `.action__icon` (`ICONS` en `action-button.component`: ♥, 💬, 🔖, ↪).
- Los slides reciben `avatar` desde API; el front ya normaliza ui-avatars vía `resolveSlideAvatarUrl()` en `user-avatar-placeholder.ts`, pero sigue **generando** URLs a ui-avatars.com.
- El back-end (`user-reels-feed-ranking.service.ts`) construye `avatar` con `https://ui-avatars.com/api/...`.
- Superficies afectadas: `app-home`, `reels-feed`, `reels-desktop-gallery` (todas importan estilos `::ng-deep` sobre `media-action-button`).
- No hay librería de iconos instalada en el front (Lucide/Heroicons); se prefiere **assets SVG propios** para evitar nueva dependencia y licencias ambiguas.

## Goals / Non-Goals

**Goals:**

- Iconografía de acciones reconocible (like, comentar, guardar, compartir) con **SVG alojados en el repo** y licencia documentada (autoría AnyJobs / uso interno).
- Avatares placeholder **sin peticiones HTTP** a terceros: `data:image/svg+xml` con iniciales y tokens `--aj-color-*`.
- Un único partial SCSS + utilidad TS reutilizados en Home, Reels feed y galería desktop.
- Conservar `data-action`, estados `.is-active`, animaciones de color de la librería y telemetría existente.
- Dejar de emitir ui-avatars desde el API de feeds/reels destacados.

**Non-Goals:**

- Fork o nueva versión publicada de `ngx-vertical-slider` (salvo que en implementación se detecte bloqueo insuperable con CSS).
- Sustituir el icono de música (`♪`) o el botón seguir (`+`) en esta change — son ASCII/Unicode genéricos; se pueden abordar después.
- Rediseño de layout, orden de botones o nuevas acciones.
- Subida de fotos de perfil reales (solo placeholder cuando falta avatar).

## Decisions

### 1. Override visual por CSS sobre la librería (sin fork)

**Decisión:** Archivo compartido `shared/media/_media-slider-action-icons.scss` importado desde los SCSS de Home, Reels y galería desktop. Para cada `media-action-button button.action[data-action]`:

- Ocultar el texto del emoji: `font-size: 0`, `color: transparent`, `text-shadow: none`.
- Mostrar icono con `::before` y `mask-image` / `-webkit-mask` apuntando a SVG en `shared/media/icons/` (like, comment, bookmark, share).
- Mantener dimensiones ~28–32px y `filter: drop-shadow` equivalente al estilo actual.

**Alternativa descartada:** `patch-package` sobre `node_modules` — más frágil en CI y upgrades.

**Alternativa descartada:** Nueva dependencia (Lucide Angular) — añade peso y revisión de licencia por icono; SVG propios son suficientes.

### 2. SVG mínimos stroke, licencia explícita

**Decisión:** Cuatro archivos SVG lineales monocromáticos (24×24 viewBox) en `shared/media/icons/`, con comentario de cabecera o `LICENSE` en la carpeta indicando **© AnyJobs — uso en el producto**. Formas inspiradas en convenciones UI estándar (corazón outline, burbuja, marcador, flecha compartir), no copias de assets de TikTok/Instagram.

**Alternativa descartada:** Emojis de sistema con `font-family` — siguen dependiendo de glifos del SO y no resuelven el objetivo de marca propia.

### 3. Avatar placeholder como SVG data URL en el cliente

**Decisión:** Reemplazar `buildUserAvatarPlaceholderUrl()` por `buildUserAvatarPlaceholderDataUrl(displayName, size)` que devuelve `data:image/svg+xml,...` con:

- Círculo fondo `#eef2f3`, texto iniciales `#0ea5a4` (mismos valores que hoy).
- Iniciales: primeras letras de hasta dos palabras del `displayName`.
- `resolveSlideAvatarUrl()` deja de llamar a ui-avatars; si `avatar` es URL externa válida (foto real), se conserva; si vacío o ui-avatars, usa data URL local.

**Alternativa descartada:** Canvas en runtime — más código; SVG string es suficiente.

### 4. Back-end deja de emitir ui-avatars

**Decisión:** En `user-reels-feed-ranking.service.ts`, `avatarUrl()` pasa a devolver `undefined` o cadena vacía cuando no hay foto de perfil persistida; el front siempre aplica `resolveSlideAvatarUrl`. Si en el futuro existe `profileImageUrl` en BD, el mapper la devuelve tal cual.

**Alternativa descartada:** Generar SVG en el back — duplica lógica; el front ya centraliza placeholders.

### 5. Alcance transversal en las tres vistas del slider

**Decisión:** Importar el partial en `home.scss`, `reels-feed.scss` y `reels-desktop-gallery.scss` (mismos selectores `::ng-deep` que ya existen).

**Riesgo:** Actualizar `ngx-vertical-slider` puede cambiar clases DOM — documentar en comentario del SCSS y añadir verificación manual en tasks.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Upgrade de `ngx-vertical-slider` rompe selectores | Comentario en SCSS + checklist manual; tests visuales en tasks |
| Emojis siguen en DOM (accesibilidad/lectores) | `aria-hidden` no disponible sin fork; el botón conserva `data-action` y contador visible en `<small>` |
| Data URL larga en memoria | Solo cuando no hay foto; tamaño SVG pequeño |
| Inconsistencia si algún endpoint sigue enviando ui-avatars | `resolveSlideAvatarUrl` reescribe ui-avatars; back deja de generarlos |

## Migration Plan

1. Añadir assets SVG + partial SCSS + utilidad data URL en front.
2. Importar partial en las tres vistas; verificar estados activos (like rojo, bookmark amarillo).
3. Cambiar mapper back-end; desplegar back y front juntos o back primero (front tolera URLs legacy).
4. Rollback: revertir commits; no migración de datos.

## Open Questions

- ¿Incluir icono de música en un follow-up? **Recomendación:** sí, mismo patrón CSS sobre `.slide__music-icon`.
- ¿Publicar PR upstream a `ngx-vertical-slider` con inputs de icono custom? **Fuera de alcance**; CSS es suficiente para v1.
