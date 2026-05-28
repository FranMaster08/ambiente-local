## MODIFIED Requirements

### Requirement: Acción de comentarios abre panel en Home

En la ruta **`/home`**, **WHEN** el usuario pulsa el botón de comentarios (acción `comment` del slider), la aplicación SHALL abrir el panel inferior de comentarios definido en `home-slider-comments-panel` además de conservar el comportamiento de telemetría existente hacia **`POST /feed/reels/interactions`**.

#### Scenario: Click en comentarios con slider activo

- **WHEN** el usuario pulsa el botón de comentarios (icono SVG de comentario, acción `comment`) en el slide visible del slider de reels destacados
- **THEN** Home MUST abrir el panel de comentarios asociado al contexto del slide (índice / reel visible)
- **AND** MUST seguir enviando `slideAction` con `action: 'comment'` al endpoint de interacciones cuando corresponda al flujo actual

#### Scenario: Slider sigue operativo con panel cerrado

- **WHEN** el panel de comentarios está cerrado
- **THEN** el desplazamiento vertical entre slides, reproducción de vídeo y demás acciones (like, bookmark, share, seguir) MUST comportarse igual que antes de este cambio

#### Scenario: Slider no bloqueado por overlay cerrado

- **WHEN** el panel no está visible
- **THEN** ningún elemento del panel MUST interceptar clics o gestos del `media-slider`

## ADDED Requirements

### Requirement: Slider de Home cumple iconografía con licencia documentada

La vista Home SHALL aplicar los requisitos de **`media-slider-licensed-visuals`** al `media-slider` de reels destacados, importando los estilos y utilidades compartidas definidos en el diseño del change.

#### Scenario: Carga de reels destacados con acciones visibles

- **WHEN** `GET /home/featured-reels` devuelve slides y Home monta `media-slider`
- **THEN** las acciones y avatares del slide cumplen iconografía SVG propia y placeholders locales sin ui-avatars
