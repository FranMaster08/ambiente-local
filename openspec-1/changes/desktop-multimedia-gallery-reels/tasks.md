## 1. Análisis y preparación

- [x] 1.1 Revisar `ReelsFeed` (`reels-feed.ts/html/scss`), `app.routes.ts` y reglas globales en `styles.scss` / `shell.scss` que afectan `app-reels-feed`
- [x] 1.2 Confirmar umbral 900px (901px desktop) alineado a `SHELL_HEADER_COMPACT_MAX_PX` y documentar en el contenedor
- [x] 1.3 Revisar patrón de grilla y modal en `profile-multimedia` para reutilizar enfoque visual y de visor

## 2. Datos compartidos

- [x] 2.1 Extraer carga/normalización de `GET /feed/reels` a servicio o util compartida (p. ej. `FeedReelsDataService`)
- [x] 2.2 Refactor mínimo de `ReelsFeed` mobile para consumir el servicio sin cambiar comportamiento observable en ≤900px

## 3. Componente galería desktop

- [x] 3.1 Crear `ReelsDesktopGalleryComponent` (nombre provisional) con template de grilla multi-columna y estilos scoped
- [x] 3.2 Implementar tarjetas con preview (`loading="lazy"`, video `preload="metadata"`, sin autoplay en grilla)
- [x] 3.3 Estados: cargando, error, vacío (mensajes alineados al feed actual)
- [x] 3.4 Click en tarjeta → modal/visor (reutilizar `ModalComponent` o patrón de `profile-multimedia`)

## 4. Orquestación en `/reels`

- [x] 4.1 Añadir bifurcación en `ReelsFeed`: `matchMedia('(min-width: 901px)')` + plantillas condicionales
- [x] 4.2 Mobile: mantener `reels-feed.html` / slider / bottom nav / telemetría sin cambios funcionales
- [x] 4.3 Desktop: renderizar solo galería; no montar `media-slider` ni `bootstrapSliderPlayback` en escritorio
- [x] 4.4 Asegurar una sola rama activa al redimensionar (destruir listeners del slider al pasar a desktop)

## 5. Estilos y shell

- [x] 5.1 Encapsular SCSS de galería desktop; no editar reglas mobile de `reels-feed.scss` salvo extracción neutra
- [x] 5.2 Ajustar selectores globales `:has(app-reels-feed)` si comprimen la galería en desktop
- [x] 5.3 Verificar que `HomeMobileBottomNav` no aparece o no rompe layout en desktop (>900px)

## 6. Interacciones y acciones

- [x] 6.1 Conectar visor desktop con datos del reel seleccionado
- [x] 6.2 Reutilizar `POST /feed/reels/interactions` donde aplique (p. ej. al abrir/reproducir) sin inventar `kind` nuevos
- [x] 6.3 Respetar flujo de login para acciones que requieran sesión (mismo comportamiento que slider)

## 7. Verificación manual obligatoria

- [x] 7.1 Desktop (>900px): `/reels` muestra galería; no aparece slider vertical fullscreen
- [x] 7.2 Mobile (≤900px): `/reels` idéntico a antes (scroll, slider, overlays, botones, bottom nav, reproducción)
- [x] 7.3 Mobile: la galería desktop no aparece en ningún caso
- [x] 7.4 Resize 900↔901: conmutación limpia sin doble audio ni errores de consola
- [x] 7.5 Recarga directa `/reels` en desktop y mobile
- [x] 7.6 Click tarjeta desktop abre visor; cierre correcto
- [x] 7.7 Rutas, login y navegación pública sin regresiones
- [x] 7.8 `openspec verify --change desktop-multimedia-gallery-reels` (si CLI disponible)
