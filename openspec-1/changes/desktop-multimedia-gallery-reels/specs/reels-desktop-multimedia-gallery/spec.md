## ADDED Requirements

### Requirement: Renderizado condicional por breakpoint en la ruta Reels

La ruta `/reels` SHALL presentar dos experiencias mutuamente excluyentes según el ancho del viewport, usando el umbral del proyecto de **900px** (escritorio: viewport > 900px; mobile: viewport ≤ 900px).

#### Scenario: Usuario en escritorio

- **WHEN** el viewport tiene ancho mayor a 900px
- **THEN** la ruta `/reels` MUST mostrar la galería multimedia de escritorio
- **AND** MUST NOT mostrar el feed vertical fullscreen de `media-slider` usado hoy en mobile

#### Scenario: Usuario en mobile

- **WHEN** el viewport tiene ancho menor o igual a 900px
- **THEN** la ruta `/reels` MUST mostrar la vista actual de Reels con `media-slider` sin cambios en layout, scroll, slider, overlays, botones, bottom nav ni interacciones
- **AND** MUST NOT mostrar la galería de escritorio

#### Scenario: Recarga directa en cada dispositivo

- **WHEN** el usuario recarga `/reels` en escritorio o en mobile
- **THEN** MUST renderizarse la experiencia correcta para ese breakpoint sin error de consola ni pantalla en blanco

### Requirement: Galería multimedia de escritorio

En viewport de escritorio, el sistema SHALL mostrar el contenido del feed en una galería visual multi-columna que aproveche el ancho disponible, con varias piezas visibles simultáneamente, espaciado consistente, bordes redondeados y apariencia alineada al look and feel de la aplicación (tokens y patrones existentes, p. ej. grilla de perfil).

#### Scenario: Feed con contenido

- **WHEN** `GET /feed/reels` devuelve uno o más ítems y el viewport es de escritorio
- **THEN** el sistema MUST renderizar tarjetas con preview visual por ítem
- **AND** las tarjetas MUST NOT ocupar el viewport completo como en mobile

#### Scenario: Múltiples columnas

- **WHEN** el viewport es suficientemente ancho (escritorio)
- **THEN** la galería MUST distribuir tarjetas en varias columnas adaptativas al espacio horizontal

#### Scenario: Inspiración visual sin copia de terceros

- **WHEN** se implementa el layout
- **THEN** el diseño MUST ser una galería tipo masonry o grilla flexible propia del producto
- **AND** MUST NOT usar logos, textos, assets ni estilos propietarios de Pinterest

### Requirement: Fuente de datos del feed existente

La galería de escritorio SHALL consumir los mismos datos que el feed actual de Reels (`GET /feed/reels` con los mismos parámetros de actor anónimo/sesión que usa hoy `ReelsFeed`), sin datos hardcodeados de contenido real.

#### Scenario: Carga exitosa

- **WHEN** el endpoint responde con reels elegibles
- **THEN** cada tarjeta MUST reflejar `id`, tipo de media, URL de media y metadatos disponibles en la respuesta (p. ej. caption, creador)

#### Scenario: Sin datos mock

- **WHEN** el feed está vacío o falla
- **THEN** el sistema MUST NOT mostrar tarjetas ficticias como contenido real

### Requirement: Estados de carga, vacío y error en escritorio

La galería de escritorio SHALL manejar los mismos estados semánticos que la vista mobile: cargando, error de carga y feed vacío, con mensajes claros al usuario.

#### Scenario: Cargando

- **WHEN** la petición al feed está en curso
- **THEN** el sistema MUST mostrar indicación de carga accesible (`aria-live` o equivalente)

#### Scenario: Error de red o servidor

- **WHEN** la carga del feed falla
- **THEN** el sistema MUST mostrar mensaje de error sin romper la navegación ni la sesión

#### Scenario: Feed vacío

- **WHEN** el feed devuelve array vacío tras carga exitosa
- **THEN** el sistema MUST mostrar estado vacío coherente con el mensaje actual del feed (p. ej. invitación a publicar desde perfil)

### Requirement: Rendimiento y previews en escritorio

La galería MUST priorizar rendimiento: lazy loading de imágenes cuando el proyecto lo soporte, `preload="metadata"` en vídeos de tarjeta, y MUST NOT reproducir automáticamente todos los vídeos de la grilla simultáneamente.

#### Scenario: Scroll en galería

- **WHEN** el usuario recorre la galería con muchos ítems
- **THEN** las previews MUST cargarse de forma diferida o ligera hasta entrar en viewport razonable
- **AND** MUST NOT iniciar reproducción completa de todos los vídeos en paralelo

### Requirement: Interacción al seleccionar una tarjeta

En escritorio, al activar una tarjeta, el sistema SHALL abrir el detalle del contenido mediante modal, visor o patrón existente del proyecto, permitiendo ver el multimedia seleccionado.

#### Scenario: Apertura de detalle

- **WHEN** el usuario hace clic o activa una tarjeta
- **THEN** el sistema MUST abrir el visor/detalle para ese reel
- **AND** MUST permitir cerrar el visor sin errores

#### Scenario: Acciones existentes

- **WHEN** existen acciones reutilizables del feed (like, comentar, guardar, compartir, seguir) ya disponibles en el stack actual
- **THEN** el visor o flujo asociado MUST respetar autenticación y telemetría existente (`POST /feed/reels/interactions`)
- **AND** MUST NOT exponer acciones que no existan en backend o modelo actual

### Requirement: Aislamiento de estilos y no regresión mobile

Los estilos de la galería de escritorio SHALL estar encapsulados en el componente desktop (o hoja dedicada) y MUST NOT modificar reglas mobile de `reels-feed` ni estilos globales de forma que altere scroll, alturas fullscreen o bottom nav en ≤900px.

#### Scenario: Validación mobile tras el cambio

- **WHEN** el viewport es ≤900px
- **THEN** los estilos y comportamiento de `ReelsFeed` mobile MUST permanecer equivalentes al estado previo al change (slider vertical, safe-area, overflow, nav inferior)

#### Scenario: Cambio de tamaño de ventana

- **WHEN** el usuario redimensiona la ventana cruzando 900px
- **THEN** MUST conmutar entre galería y slider sin errores visuales persistentes, loops de renderizado ni doble reproducción activa

### Requirement: Integridad de navegación y sesión

El change MUST NOT romper rutas protegidas, login, sesión, navegación pública ni enlaces existentes hacia `/reels`.

#### Scenario: Navegación desde header

- **WHEN** el usuario accede a Reels desde la navegación principal
- **THEN** MUST llegar a `/reels` con la experiencia correcta según dispositivo
