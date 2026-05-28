## Why

La pantalla de inicio (`/home`) debe presentar campañas u ofertas con un **slider vertical de medios** (feed estilo stories), reutilizando la librería publicada **`ngx-vertical-slider`** (`MediaSliderComponent`, `<media-slider>`) para no duplicar UI ni comportamiento de vídeo/imagen.

Las interacciones (like, seguir, comentario, etc.) deben poder **enviarse al backend** con **identificación explícita** del slider, del slide (incluido id de negocio/campaña cuando exista) y del **actor** (usuario autenticado o anónimo estable) para analítica y futuras acciones de negocio.

## What Changes

- Vista **Home** (`features/home/home/`) con `<media-slider>` alimentado por `SlideData[]`; datos vía **`HttpClient`** desde **`GET /promo-slides`** con **fallback** a **`/mock/home-promo-slides.mock.json`** si el API falla.
- **Telemetría:** **`POST /promo-slides/interactions`** con cuerpo que fusiona **payload del actor** (`subjectType`, `userId` o `null`, `anonymousId`, `userRoles`, `emittedAt`) y del evento (`sliderId`, `route`, `kind`, `slideIndex`, `slideMedia`, **`campaignId`** cuando el slide trae `id` en el GET, etc.). El **JWT** se envía en cabecera en rutas bajo `/promo-slides` cuando hay sesión (**interceptor**).
- **Backend (MVP):** módulo **`PromoSlides`** — **`GET /promo-slides`** devuelve slides alineados con `SlideData` más campo opcional **`id`** por campaña; **`POST /promo-slides/interactions`** público que registra el body (log); sin persistencia en BD en esta entrega.
- **Proxy:** **`/promo-slides`** en `proxy.conf.json` / `proxy.docker.conf.json` hacia el API.
- **Navegación:** enlaces **Inicio** (nav y footer), **marca (logo)** y redirección raíz → **`/home`**.
- **Layout:** shell en columna flex (`min-height: 100dvh`); **`router-outlet` con `display: contents`** y estilos globales sobre **`main.app-main app-home`**; contenedor con alto **`calc(100dvh - header)`**; en escritorio (**≥900px**) el bloque del slider usa **`width: 70%`** del contenido centrado.
- **Compatibilidad con la librería:** override del **`max-width: 420px`** del host de `<media-slider>` desde **700px**.
- **Docker (desarrollo):** el servicio **`anyjobs-front`** ejecuta **`npm install`** antes de **`ng serve`** para sincronizar **`node_modules`** del volumen.
- Sin cambios **BREAKING** en registro/login; el resto de rutas del shell se mantienen.

## Capabilities

### New Capabilities

- `home-promotional-slider`: Slider en `/home`, datos API + mock de respaldo, estados vacío/error/carga, layout, navegación, overrides de estilo, **telemetría hacia API** con **identificación de slider, slide y actor**.

### Modified Capabilities

- _(Ninguno)_ — `registro-usuario-completo` sin cambios de requisitos.

## Impact

- **Código:** `anyjobs-front/anyjobs` — `features/home/home/*`, `shared/api/auth-bearer.interceptor.ts`, `shell/shell/*`, `styles.scss`, `proxy*.json`, `public/mock/home-promo-slides.mock.json`.
- **Backend:** `anyjobs-back/apps/api` — `PromoSlidesModule`, controlador, `app.module.ts`.
- **Dependencias:** `ngx-vertical-slider` en `package.json` / `package-lock.json`.
- **Infra:** `docker-compose.yml` (raíz).

## Observaciones (para revisión / siguientes entregas)

- **`doubleTap`** y **`mutedChange`** de `ngx-vertical-slider` **no exponen índice de slide** en los outputs; esos eventos no llevan `slideIndex` / `campaignId` hasta envolver la librería, parchearla o añadir un canal de “slide activo”.
- **Persistencia** de interacciones y **validación JWT** opcional en `POST /interactions` quedan fuera del MVP descrito arriba.
- **Producción:** si front y API no comparten origen, configurar **reverse proxy** o **CORS** acorde.
