## ADDED Requirements

### Requirement: Acciones del slider usan iconografía con licencia documentada

En cualquier vista que monte **`ngx-vertical-slider`** (`<media-slider>`), los botones de acción (`like`, `comment`, `bookmark`, `share`) SHALL mostrar iconos **SVG propios del repositorio** (no emojis Unicode ni imágenes de terceros con restricciones de marca). Los archivos SVG MUST estar bajo control de versión del proyecto con licencia o nota de autoría explícita para uso en el producto.

#### Scenario: Usuario ve acciones en Home

- **WHEN** el slider de reels destacados está visible en **`/home`**
- **THEN** cada `media-action-button` muestra un icono SVG (corazón, comentario, marcador, compartir) y MUST NOT mostrar los caracteres ♥, 💬, 🔖 ni ↪ como icono visible principal

#### Scenario: Usuario ve acciones en feed de reels

- **WHEN** el usuario navega a **`/reels`** con el slider vertical activo (mobile)
- **THEN** las mismas acciones usan la misma iconografía SVG que en Home

#### Scenario: Usuario ve acciones en galería desktop de reels

- **WHEN** la galería desktop monta `media-slider` con slides
- **THEN** las acciones del slide usan la misma iconografía SVG compartida

### Requirement: Estados activos de acciones conservan feedback visual

La sustitución de iconos MUST preservar los estados `.is-active` de la librería para `like` y `bookmark` (colores y animación `pop` existentes) y MUST NOT impedir el clic ni la emisión de `slideAction` / `actionToggle`.

#### Scenario: Like activo

- **WHEN** el usuario pulsa like y el botón pasa a estado activo
- **THEN** el icono de like se muestra en color de acento definido por estilos existentes (`#fe2c55` o token equivalente) y el evento de telemetría se dispara igual que antes del cambio

#### Scenario: Bookmark activo

- **WHEN** el usuario activa bookmark
- **THEN** el icono de bookmark refleja estado activo (color `#facc15` o token equivalente) sin regresión funcional

### Requirement: Avatares placeholder sin servicios externos

Cuando un slide no tiene foto de perfil real, el avatar mostrado en `.slide__avatar > img` SHALL provenir de un **placeholder generado en la aplicación** (p. ej. `data:image/svg+xml` con iniciales) y MUST NOT realizar peticiones HTTP a **`ui-avatars.com`** ni dominios equivalentes de generación de avatar de terceros.

#### Scenario: Slide sin avatar en API

- **WHEN** el slide llega sin `avatar` o con `avatar` vacío
- **THEN** la imagen del avatar usa placeholder local con iniciales del nombre del creador y colores de marca del producto

#### Scenario: API legacy con ui-avatars

- **WHEN** el slide incluye `avatar` con URL de `ui-avatars.com`
- **THEN** el cliente MUST sustituirla por el placeholder local antes de asignar `src` al `<img>`

#### Scenario: Avatar con foto real

- **WHEN** el slide incluye `avatar` con URL de media propia o CDN del producto (no ui-avatars)
- **THEN** el cliente MUST usar esa URL sin sustituirla por placeholder

### Requirement: Back-end no genera URLs ui-avatars para feeds de reels

Los servicios que arman slides para **`GET /home/featured-reels`** y **`GET /feed/reels`** MUST NOT incluir en `avatar` URLs de `ui-avatars.com`. Cuando no exista imagen de perfil persistida, el campo `avatar` MAY omitirse o ser vacío para que el cliente aplique el placeholder local.

#### Scenario: Reel sin foto de perfil en ranking

- **WHEN** el mapper construye un slide sin `profileImageUrl` (o equivalente) disponible
- **THEN** la respuesta no contiene URL de ui-avatars en `avatar`
