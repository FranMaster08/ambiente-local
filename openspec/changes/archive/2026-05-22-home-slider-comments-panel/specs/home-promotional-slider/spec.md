## ADDED Requirements

### Requirement: Acción de comentarios abre panel en Home

En la ruta **`/home`**, **WHEN** el usuario pulsa el botón de comentarios (acción `comment` del slider), la aplicación SHALL abrir el panel inferior de comentarios definido en `home-slider-comments-panel` además de conservar el comportamiento de telemetría existente hacia **`POST /feed/reels/interactions`**.

#### Scenario: Click en comentarios con slider activo

- **WHEN** el usuario pulsa el botón 💬 en el slide visible del slider de reels destacados
- **THEN** Home MUST abrir el panel de comentarios asociado al contexto del slide (índice / reel visible)
- **AND** MUST seguir enviando `slideAction` con `action: 'comment'` al endpoint de interacciones cuando corresponda al flujo actual

#### Scenario: Slider sigue operativo con panel cerrado

- **WHEN** el panel de comentarios está cerrado
- **THEN** el desplazamiento vertical entre slides, reproducción de vídeo y demás acciones (like, bookmark, share, seguir) MUST comportarse igual que antes de este cambio

#### Scenario: Slider no bloqueado por overlay cerrado

- **WHEN** el panel no está visible
- **THEN** ningún elemento del panel MUST interceptar clics o gestos del `media-slider`

## MODIFIED Requirements

### Requirement: Telemetría de interacciones hacia el backend

La aplicación SHALL enviar eventos relevantes del slider al endpoint **`POST /feed/reels/interactions`** con un cuerpo JSON que incluya al menos:

- Identificación del **slider lógico** (`sliderId`, valor acordado p. ej. `home-featured-reels`).
- **Ruta** de contexto (p. ej. `/home`).
- **Tipo de evento** (`kind`: p. ej. `slideAction`, `slideFollow`, `doubleTap`, `mutedChange`, `slideImpression`, `watchProgress`, `slideSkipped`).
- Donde aplique: **`slideIndex`**, **`slideMedia`**, **`reelId`** (desde `id` del slide cargado).

El cuerpo SHALL fusionarse con el **payload del actor** (ver requisito de identificación del actor). **WHEN** existe sesión autenticada, las peticiones a rutas bajo **`/feed/reels`** SHOULD incluir **`Authorization: Bearer`** según el interceptor de la app.

**WHEN** el usuario abre comentarios desde Home, el evento `slideAction` con `action: 'comment'` MUST seguir registrándose con el índice y `reelId` del slide activo, independientemente de que el panel visual esté abierto.

#### Scenario: Acción en slide con índice

- **WHEN** el usuario dispara un evento que la librería asocia a un índice de slide (p. ej. like, comentarios o seguir)
- **THEN** el POST incluye `slideIndex`, referencia al medio cuando esté disponible, y `reelId` si el slide tenía `id`

#### Scenario: Evento sin índice en la librería

- **WHEN** la librería no expone índice de slide para un output (p. ej. doble tap o cambio de mute)
- **THEN** el sistema MAY enviar el evento sin `slideIndex` / `reelId` hasta que se mejore la integración (**observación documentada**)

#### Scenario: Comentarios abre panel y registra telemetría

- **WHEN** el usuario pulsa comentarios en un slide del slider de Home
- **THEN** el sistema MUST registrar `slideAction` con `action: 'comment'` en telemetría
- **AND** MUST abrir el panel de comentarios en la misma interacción
