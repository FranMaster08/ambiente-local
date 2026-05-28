## Context

- **Ruta:** `app.routes.ts` → `path: 'reels'` → lazy `ReelsFeed` (`features/reels-feed/reels-feed/`).
- **Vista actual:** `reels-feed.html` monta `<media-slider>` con datos de `GET /feed/reels?anonymousId=…`, telemetría vía `POST /feed/reels/interactions`, playback con `MediaPlaybackService` y `bootstrapSliderPlayback`.
- **Breakpoint del proyecto:** 900px — mobile `max-width: 900px` en `reels-feed.scss`; shell usa `SHELL_HEADER_COMPACT_MAX_PX = 900`.
- **Referencia interna:** `profile-multimedia` ya implementa grilla (`multimediaGrid`), preview con `preload="metadata"`, modal de reproducción (`ModalComponent` + `playerReel`) — patrón reutilizable para desktop sin duplicar lógica de upload/gestión de perfil.
- **Referencia externa (solo inspiración):** galería Pinterest de vídeos — columnas, tarjetas con preview, espaciado; sin copiar assets, textos ni UX propietaria.

## Goals / Non-Goals

**Goals:**

- Separar responsabilidades: mobile = `ReelsFeed` actual sin tocar comportamiento; desktop = nuevo componente de galería.
- Misma fuente de datos (`GET /feed/reels`) y normalización de slides existente.
- Breakpoint único y consistente (900px) vía CSS + detección en componente contenedor (`matchMedia` o clase host) para evitar mostrar ambas vistas a la vez.
- Galería multi-columna en desktop, lazy loading de imágenes/vídeo preview, estados loading/empty/error.
- Click en tarjeta → visor/detalle (modal con media o reutilización acotada del slider en overlay — ver decisión 4).
- Estilos scoped al componente desktop; no alterar reglas mobile de `reels-feed.scss`.

**Non-Goals:**

- Cambiar layout, scroll, slider, overlays, bottom nav ni interacciones en mobile.
- Nuevos endpoints, modelos backend o acciones sociales no existentes.
- Reemplazar Reels en mobile o eliminar `ReelsFeed`.
- Copiar Pinterest (marca, layout pixel-perfect, infinite scroll propietario).
- Cambiar Home (`/home`) ni el slider promocional de featured reels.
- Masonry con librería nueva si CSS grid + `grid-auto-rows` o columnas flex alcanzan el resultado.

## Decisions

### 1. Orquestación en contenedor de ruta (`ReelsFeed` o wrapper delgado)

**Decisión:** Mantener `ReelsFeed` como punto de entrada de `/reels`. Añadir lógica de ramificación:

- `≤900px`: template actual (`reels-feed.html` + `reels-feed.scss` sin cambios funcionales).
- `>900px`: renderizar `<app-reels-desktop-gallery>` (nombre provisional).

**Alternativa descartada:** Ruta separada `/reels/desktop` — rompe enlaces y navegación existente.

**Alternativa descartada:** Duplicar ruta en router — innecesario; una ruta con bifurcación interna.

### 2. Extracción mínima del fetch de feed

**Decisión:** Extraer servicio o función compartida `loadFeedReels(anonymousId)` que devuelva `ReelSlide[]` normalizado, consumida por mobile (refactor mínimo en `ReelsFeed`) y por desktop gallery. Mobile conserva el resto de efectos (playback, retention, avatar nav) solo en su rama.

**Alternativa descartada:** Duplicar HTTP en desktop — dos puntos de mantenimiento.

### 3. Detección responsive

**Decisión:** Usar el umbral **901px** (`min-width: 901px`) alineado a `shell.ts` y `reels-feed.scss` (`max-width: 900px` mobile). Implementar con `matchMedia('(min-width: 901px)')` + listener en el contenedor, y/o clases host duplicando el mismo media query en SCSS para ocultar la rama no activa (`display: none` en la rama inactiva) y evitar doble montaje de sliders.

**Mitigación hidratación/SSR:** Si la app es CSR puro, render inicial puede asumir mobile y corregir en `afterNextRender`; documentar en tasks. Evitar montar `media-slider` en desktop.

### 4. Visor al hacer click en tarjeta (desktop)

**Decisión:** Reutilizar patrón de `profile-multimedia`: modal (`ModalComponent`) con vídeo/imagen del reel seleccionado y metadatos (caption, usuario). Si se requieren acciones del slider (like, share), enlazar solo las ya expuestas por API/interactions existentes; no inventar UI de acciones sin backend.

**Alternativa:** Overlay con `media-slider` filtrado a un slide — más pesado; reservar si el modal no cubre acciones obligatorias.

### 5. Layout de galería

**Decisión:** CSS multi-columna (p. ej. `column-count` o CSS Grid con `grid-template-columns: repeat(auto-fill, minmax(220px, 1fr))`) con tarjetas de altura variable según aspect ratio si hay `width`/`height` en payload; si no, altura mínima fija y `object-fit: cover`. Bordes redondeados y tokens `--aj-*` del tema.

**Alternativa descartada:** Dependencia `masonry-layout` — evitar salvo bloqueo técnico.

### 6. Previews y rendimiento

**Decisión:** `<img loading="lazy">` / `<video preload="metadata" muted>` en tarjetas; sin autoplay en grilla. Reproducción solo en visor/modal al abrir.

### 7. Estilos y shell

**Decisión:** Revisar `styles.scss` y `shell.scss` selectores `:has(app-reels-feed)` que fuerzan layout fullscreen — acotar reglas al slider mobile o al host cuando la rama mobile está activa, para no aplastar la galería desktop.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Montar slider + galería simultáneamente al redimensionar | Una sola rama visible; destruir listeners del slider al salir de mobile |
| Reglas globales `app-reels-feed` afectan galería | Scoped styles en desktop component; ajustar selectores globales |
| Resize 900↔901 parpadea o duplica fetch | Servicio compartido con cache opcional en memoria del contenedor |
| Hidratación mismatch | CSR: actualizar vista tras `matchMedia`; no renderizar slider en SSR desktop si aplica |
| Acciones sociales incompletas en modal vs slider | Documentar en tasks; usar slider overlay solo si gap crítico |
| `HomeMobileBottomNav` visible en desktop en `/reels` | Ya condicionado por CSS en bottom nav; galería desktop no lo requiere en >900px |

## Migration Plan

Despliegue solo frontend. Sin migraciones de BD. Rollback: revertir bifurcación en `ReelsFeed` y eliminar componente desktop.

## Open Questions

- ¿El visor desktop debe incluir barra de acciones idéntica al slider (like, comment, bookmark, share) en v1? **Recomendación:** sí solo las ya cableadas en feed interactions; si no es viable en modal, abrir overlay con `media-slider` de un solo slide.
- ¿Reutilizar estilos de `.multimediaGrid` del perfil vía mixin/clase compartida? **Recomendación:** extraer tokens SCSS compartidos en implementación, no bloquear el change.
