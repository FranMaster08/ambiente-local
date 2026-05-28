## Why

La ruta `/reels` muestra hoy el mismo feed vertical de `ngx-vertical-slider` en todos los tamaños de pantalla. En escritorio el formato fullscreen vertical no aprovecha el espacio horizontal y ofrece una experiencia peor que una galería visual. En mobile el slider funciona bien y no debe alterarse. Se necesita una experiencia de multimedia exclusiva para escritorio sin regresiones en mobile.

## What Changes

- En viewport **escritorio** (>900px, alineado al breakpoint del shell y de `reels-feed.scss`), `/reels` SHALL mostrar una nueva galería multimedia tipo masonry/grilla inspirada visualmente en Pinterest (sin copiar marca ni comportamiento propietario).
- En viewport **mobile** (≤900px), `/reels` SHALL seguir renderizando el componente actual de Reels (`ReelsFeed` + `media-slider`) sin cambios visuales ni funcionales.
- Renderizado condicional en el contenedor de la ruta: escritorio → nuevo componente de galería; mobile → vista actual intacta.
- Reutilizar `GET /feed/reels` y `POST /feed/reels/interactions` existentes; sin fuente de datos paralela ni endpoints nuevos salvo necesidad estricta futura.
- Nuevo componente desktop con estilos encapsulados; evitar modificar estilos globales o reglas mobile de `reels-feed`.
- Click en tarjeta desktop: abrir detalle/visor/modal con el flujo existente del proyecto (p. ej. patrón de `profile-multimedia` o slider en overlay según design).
- Estados de carga, vacío y error en la galería desktop; lazy loading de previews; sin autoplay masivo de vídeos.
- Mantener acciones ya disponibles (like, comentar, guardar, compartir, seguir) solo si son reutilizables sin inventar backend.

## Capabilities

### New Capabilities

- `reels-desktop-multimedia-gallery`: galería multimedia exclusiva de escritorio en `/reels`, renderizado condicional por breakpoint, interacciones y estados UI.

### Modified Capabilities

- _(ninguna a nivel API)_ — `user-reels-feed` mantiene el contrato de `GET /feed/reels` e interacciones; solo cambia la presentación del cliente en escritorio, cubierta por la capability nueva.

## Impact

- **Frontend:** `features/reels-feed/` (orquestación condicional); nuevo componente p. ej. `reels-desktop-gallery/` o `desktop-multimedia-gallery/`; posible extracción mínima de carga de datos compartida; referencia de patrón en `profile-multimedia` (grilla + modal).
- **Breakpoint:** 900px (`max-width: 900px` mobile), coherente con `shell.ts` (`SHELL_HEADER_COMPACT_MAX_PX`), `reels-feed.scss` y `home-mobile-bottom-nav`.
- **Librería:** `ngx-vertical-slider` solo en mobile; sin cambios en la librería.
- **Backend / API:** ninguno.
- **Estilos globales:** revisar `styles.scss` reglas `app-reels-feed` para que no fuercen layout mobile en desktop gallery.
- **Specs:** nueva `reels-desktop-multimedia-gallery`; sin delta en specs de API.
