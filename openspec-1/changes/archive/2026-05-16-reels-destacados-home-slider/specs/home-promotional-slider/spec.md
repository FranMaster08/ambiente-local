## MODIFIED Requirements

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

### Requirement: Telemetría de interacciones hacia el backend

La aplicación SHALL enviar eventos relevantes del slider al endpoint **`POST /feed/reels/interactions`** con un cuerpo JSON que incluya al menos:

- Identificación del **slider lógico** (`sliderId`, valor acordado p. ej. `home-featured-reels`).
- **Ruta** de contexto (p. ej. `/home`).
- **Tipo de evento** (`kind`: p. ej. `slideAction`, `slideFollow`, `doubleTap`, `mutedChange`, `slideImpression`, `watchProgress`, `slideSkipped`).
- Donde aplique: **`slideIndex`**, **`slideMedia`**, **`reelId`** (desde `id` del slide cargado).

El cuerpo SHALL fusionarse con el **payload del actor** (ver requisito de identificación del actor). **WHEN** existe sesión autenticada, las peticiones a rutas bajo **`/feed/reels`** SHOULD incluir **`Authorization: Bearer`** según el interceptor de la app.

#### Scenario: Acción en slide con índice

- **WHEN** el usuario dispara un evento que la librería asocia a un índice de slide (p. ej. like o seguir)
- **THEN** el POST incluye `slideIndex`, referencia al medio cuando esté disponible, y `reelId` si el slide tenía `id`

#### Scenario: Evento sin índice en la librería

- **WHEN** la librería no expone índice de slide para un output (p. ej. doble tap o cambio de mute)
- **THEN** el sistema MAY enviar el evento sin `slideIndex` / `reelId` hasta que se mejore la integración (**observación documentada**)

## ADDED Requirements

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
