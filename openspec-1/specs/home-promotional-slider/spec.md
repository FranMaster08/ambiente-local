## Purpose

Comportamiento del slider en **`/home`** (anyjobs), uso de **`ngx-vertical-slider`**, fuente de datos (**Reels destacados** desde API), layout, navegación, compensaciones de estilo del paquete, control de reproducción de vídeo, y **telemetría con identificación de contexto y actor**.

## Requirements

### Requirement: Home muestra un slider vertical de medios publicitarios

La aplicación SHALL mostrar en **`/home`** el componente **`ngx-vertical-slider`** (`<media-slider>`) cuando existan slides de **Reels destacados** cargados desde el API, permitiendo desplazamiento vertical entre slides según la librería.

#### Scenario: Usuario abre la pantalla de inicio

- **WHEN** el usuario navega a **`/home`**
- **THEN** la vista Home muestra el slider con al menos un slide cuando **`GET /home/featured-reels`** devuelve datos y la carga no falló

#### Scenario: Navegación entre slides

- **WHEN** el usuario usa gestos o teclas documentadas en la librería sobre el feed
- **THEN** el slide visible cambia sin abandonar **`/home`**

### Requirement: Los slides cumplen el contrato SlideData y pueden incluir id de campaña

El sistema SHALL suministrar al slider elementos que cumplan **`SlideData`** (`type`, `media`, `user`, `avatar`, `caption`, `music`, `counts`, etc., según el paquete). Los objetos SHALL incluir **`id`** como identificador del **reel** (`reelId`), coherente entre **`GET /home/featured-reels`** y la telemetría de interacciones.

#### Scenario: Slide de imagen

- **WHEN** un slide tiene `type: 'image'`
- **THEN** la interfaz muestra la imagen en `media` con el comportamiento previsto por la librería

#### Scenario: Slide de vídeo

- **WHEN** un slide tiene `type: 'video'`
- **THEN** la interfaz reproduce el vídeo en `media` respetando autoplay/mute según la librería

### Requirement: Fuente de datos API con fallback a mock

La aplicación SHALL cargar los slides desde **`GET /home/featured-reels`**, incluyendo el query param **`anonymousId`** del actor anónimo estable. **WHEN** la petición falla o devuelve lista inválida, SHALL mostrar estado de error sin tumbar la aplicación. **WHEN** la respuesta es un arreglo vacío válido, SHALL mostrar estado vacío. La aplicación MUST NOT usar **`/mock/home-promo-slides.mock.json`** ni contenido promocional de ejemplo como fuente principal cuando el API está disponible.

#### Scenario: Carga exitosa desde API

- **WHEN** el API devuelve un arreglo válido de reels destacados
- **THEN** Home pasa el arreglo al input **`slides`** del slider en el orden devuelto por el API (ya ordenado por puntuación)

#### Scenario: Sin reels disponibles

- **WHEN** el API devuelve `[]`
- **THEN** Home muestra un **placeholder visual** en el área del slider (altura coherente con `homeSliderWrap`) y no monta `media-slider` con datos ficticios de campaña

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

### Requirement: Estados de carga, vacío y error en Home

La vista Home SHALL mostrar indicador de carga mientras se obtienen los reels destacados. **WHEN** no hay reels o falla la petición, SHALL mostrar un **placeholder visual** en el área reservada al slider (misma región que `homeSliderWrap`), sin romper el layout ni la navegación inferior.

#### Scenario: Carga en curso

- **WHEN** el usuario entra a `/home` y la petición aún no terminó
- **THEN** se muestra estado de carga accesible (`aria-live`) y el slider no se monta con datos incompletos

#### Scenario: Error de red o servidor

- **WHEN** `GET /home/featured-reels` falla
- **THEN** se muestra placeholder visual con mensaje de error y no se presentan slides mock como contenido real

#### Scenario: Placeholder visual sin contenido

- **WHEN** el API devuelve lista vacía válida
- **THEN** el área del slider muestra placeholder visual (p. ej. mensaje «Aún no hay reels destacados») manteniendo dimensiones razonables del bloque, sin `media-slider` activo

### Requirement: Control de reproducción al cambiar slide o navegar

La aplicación SHALL garantizar que solo el slide visible reproduce audio y que al navegar fuera de Home o `/reels` ningún vídeo del slider sigue sonando.

#### Scenario: Cambio de reel en el slider

- **WHEN** el usuario desplaza al siguiente reel
- **THEN** el vídeo del reel anterior queda en pausa y solo el slide visible reproduce (con sonido según estado de mute del slider)

#### Scenario: Navegación a otra ruta

- **WHEN** el usuario abandona `/home` o `/reels` mediante el router
- **THEN** todos los elementos `<video>` de la página quedan pausados y sin fuente activa antes de que se desmonte el slider

### Requirement: Identificación del actor en interacciones

El sistema SHALL incluir en el cuerpo de **`POST /feed/reels/interactions`** (Home destacados) y, donde aplique, **`POST /promo-slides/interactions`** información que permita distinguir:

- **`subjectType`**: usuario autenticado vs anónimo.
- **`anonymousId`**: identificador estable almacenado en cliente para visitantes sin login.
- **WHEN** hay usuario autenticado: **`userId`** y **`userRoles`** según la sesión.
- **`emittedAt`**: marca temporal ISO del envío.

El cuerpo MUST NOT incluir datos personales innecesarios (p. ej. email) solo para telemetría.

#### Scenario: Usuario logueado

- **WHEN** existe sesión válida
- **THEN** el payload del actor refleja `subjectType` de usuario y identificadores de usuario; el JWT puede ir en cabecera

#### Scenario: Visitante anónimo

- **WHEN** no hay sesión
- **THEN** el payload del actor usa tipo anónimo y `anonymousId` persistente; `userId` MAY ser null u omitirse según contrato implementado

### Requirement: Área del slider y ancho en escritorio

El sistema SHALL dar al bloque del slider una altura coherente con el viewport bajo el header (p. ej. **`calc(100dvh - altura del header)**) y, en ventanas **anchas (implementación: desde ~900px de ancho)**, el contenedor del feed SHALL ocupar aproximadamente el **70% del ancho** del área principal (**`<main>`**), centrado.

#### Scenario: Altura usable

- **WHEN** el usuario ve **`/home`** en un viewport típico de escritorio o móvil
- **THEN** el contenedor del slider tiene altura suficiente para el scroll vertical del feed (sin quedar artificialmente limitado solo por la caja del **`router-outlet`** cuando aplique el diseño acordado)

#### Scenario: Ancho en escritorio

- **WHEN** el viewport supera el umbral de escritorio definido en estilos
- **THEN** la columna del slider ocupa el porcentaje de ancho acordado (**70%** del contenido) y el componente **`media-slider`** puede usar ese ancho sin quedar forzado al **`max-width`** por defecto que imponga la librería en ciertos breakpoints

### Requirement: Enlaces «Inicio» y marca apuntan al home con slider

La aplicación SHALL hacer que el usuario pueda llegar a **`/home`** desde la navegación principal del shell: enlace de texto **Inicio** (header y footer) y enlace de la **marca (logo)** SHALL navegar a **`/home`** (no solo a una sección por fragmento de otra ruta).

#### Scenario: Navegación desde el menú

- **WHEN** el usuario activa el ítem **Inicio** del nav o del footer, o el logo de marca
- **THEN** la ruta activa es **`/home`** y se muestra el slider cuando corresponda

### Requirement: Integración sin romper el resto de rutas

Los cambios en shell y estilos globales MUST NOT impedir el uso normal de **registro**, **login**, **solicitudes** u otras rutas ya existentes.

#### Scenario: Otras rutas accesibles

- **WHEN** el usuario navega fuera de **`/home`**
- **THEN** las vistas existentes siguen cargándose; el slider solo aplica a **`/home`**

## Observaciones

- El módulo **`promo-slides`** permanece para otros consumidores; Home usa Reels UGC vía **`GET /home/featured-reels`**.
- La persistencia completa de interacciones en BD es extensión futura explícita.
