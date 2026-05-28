## Purpose

Comportamiento del slider promocional en **`/home`** (anyjobs), uso de **`ngx-vertical-slider`**, fuente de datos (API + mock), layout, navegación, compensaciones de estilo del paquete, y **telemetría con identificación de contexto y actor**.

## ADDED Requirements

### Requirement: Home muestra un slider vertical de medios publicitarios

La aplicación SHALL mostrar en **`/home`** el componente **`ngx-vertical-slider`** (`<media-slider>`) cuando existan slides, permitiendo desplazamiento vertical entre slides según la librería.

#### Scenario: Usuario abre la pantalla de inicio

- **WHEN** el usuario navega a **`/home`**
- **THEN** la vista Home muestra el slider con al menos un slide cuando los datos estén disponibles y no fallen la carga (API o mock de respaldo)

#### Scenario: Navegación entre slides

- **WHEN** el usuario usa gestos o teclas documentadas en la librería sobre el feed
- **THEN** el slide visible cambia sin abandonar **`/home`**

### Requirement: Los slides cumplen el contrato SlideData y pueden incluir id de campaña

El sistema SHALL suministrar al slider elementos que cumplan **`SlideData`** (`type`, `media`, `user`, `avatar`, `caption`, `music`, `counts`, etc., según el paquete). Los objetos MAY incluir un campo adicional **`id`** (string) como identificador de negocio de la campaña o creatividad, coherente entre **`GET /promo-slides`** y el mock de respaldo.

#### Scenario: Slide de imagen

- **WHEN** un slide tiene `type: 'image'`
- **THEN** la interfaz muestra la imagen en `media` con el comportamiento previsto por la librería

#### Scenario: Slide de vídeo

- **WHEN** un slide tiene `type: 'video'`
- **THEN** la interfaz reproduce el vídeo en `media` respetando autoplay/mute según la librería

### Requirement: Fuente de datos API con fallback a mock

La aplicación SHALL intentar cargar los slides desde **`GET /promo-slides`** (mismo origen / proxy en desarrollo). **WHEN** esa petición falla, SHALL cargar **`/mock/home-promo-slides.mock.json`** como respaldo. **WHEN** ambas fallan o la lista es inválida/vacía según implementación, SHALL mostrar estado de error o vacío sin tumbar la aplicación.

#### Scenario: Carga exitosa desde API

- **WHEN** el API devuelve un arreglo válido de slides
- **THEN** Home pasa el arreglo al input **`slides`** del slider

#### Scenario: Fallback a mock

- **WHEN** `GET /promo-slides` falla y el mock está disponible
- **THEN** Home usa los datos del mock para el slider

#### Scenario: Lista vacía o error total

- **WHEN** no hay slides utilizables tras intentos acordados
- **THEN** Home MUST NOT bloquear la app de forma irrecuperable y SHALL mostrar mensaje de estado vacío o error según implementación

### Requirement: Telemetría de interacciones hacia el backend

La aplicación SHALL enviar eventos relevantes del slider al endpoint **`POST /promo-slides/interactions`** con un cuerpo JSON que incluya al menos:

- Identificación del **slider lógico** (`sliderId`).
- **Ruta** de contexto (p. ej. `/home`).
- **Tipo de evento** (`kind`: p. ej. `slideAction`, `slideFollow`, `doubleTap`, `mutedChange`).
- Donde aplique según outputs de la librería: **`slideIndex`**, **`slideMedia`**, **`campaignId`** (cuando el slide tiene **`id`** en los datos cargados).

El cuerpo SHALL fusionarse con el **payload del actor** (ver siguiente requisito). **WHEN** existe sesión autenticada, las peticiones a rutas bajo **`/promo-slides`** SHOULD incluir **`Authorization: Bearer`** según el interceptor de la app.

#### Scenario: Acción en slide con índice

- **WHEN** el usuario dispara un evento que la librería asocia a un índice de slide (p. ej. like o seguir)
- **THEN** el POST incluye `slideIndex`, referencia al medio cuando esté disponible, y `campaignId` si el slide tenía `id`

#### Scenario: Evento sin índice en la librería

- **WHEN** la librería no expone índice de slide para un output (p. ej. doble tap o cambio de mute)
- **THEN** el sistema MAY enviar el evento sin `slideIndex` / `campaignId` hasta que se mejore la integración (**observación documentada**)

### Requirement: Identificación del actor en interacciones

El sistema SHALL incluir en el cuerpo de **`POST /promo-slides/interactions`** información que permita distinguir:

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

- El **backend** en MVP puede limitarse a **aceptar** el POST y **registrar** el body (p. ej. log); la persistencia en BD y la política de auth estricta en `POST /interactions` son extensiones futuras explícitas en **`design.md`**.
