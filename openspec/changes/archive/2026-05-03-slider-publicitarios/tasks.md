## 1. Dependencias y tipos

- [x] 1.1 Añadir `ngx-vertical-slider` a `anyjobs-front/anyjobs/package.json` e instalar dependencias (`npm install` en ese proyecto).
- [x] 1.2 Verificar que la versión instalada expone `MediaSliderComponent` y el tipo `SlideData` según el README del paquete.

## 2. Datos del slider

- [x] 2.1 Crear fuente mock en `public/mock/home-promo-slides.mock.json` con elementos válidos `SlideData` (incl. **`id`** de campaña alineado con el API).
- [x] 2.2 Cargar slides con **`GET /promo-slides`** y fallback al mock en fallo de red/API.
- [x] 2.3 Exponer los slides al componente Home mediante `signal` según el estilo del proyecto.

## 3. Vista Home

- [x] 3.1 Importar `MediaSliderComponent` en `features/home/home/home.ts` y usar `<media-slider [slides]="slides()" />`.
- [x] 3.2 Ajustar estilos en `home.scss` (altura viewport, overrides `max-width` librería, `::ng-deep` para acciones si aplica).
- [x] 3.3 Estados: carga, vacío, error y mensajes sin errores en runtime.

## 4. Telemetría e identificación

- [x] 4.1 Implementar **`POST /promo-slides/interactions`** desde el cliente con **`sliderId`**, **`route`**, **`kind`**, y datos de slide (`slideIndex`, `slideMedia`, **`campaignId`** cuando el slide tiene **`id`**).
- [x] 4.2 Inyectar **`AuthSessionService`** y construir **`actorPayload()`** (`subjectType`, `userId`/`anonymousId`, `userRoles`, `emittedAt`); persistir **`anonymousId`** en `localStorage`.
- [x] 4.3 Asegurar que el **interceptor** envía **Bearer** en rutas `/promo-slides` con sesión.
- [x] 4.4 Conectar outputs `(slideAction)`, `(slideFollow)`, `(doubleTap)`, `(mutedChange)` a `trackInteraction` (con **observación**: sin índice de slide en doubleTap/mutedChange por limitación de la librería).

## 5. Backend y proxy

- [x] 5.1 Exponer **`GET /promo-slides`** y **`POST /promo-slides/interactions`** (MVP: log del body en POST).
- [x] 5.2 Incluir **`id`** por slide en la respuesta estática del GET para alinear con mock y `campaignId` en telemetría.
- [x] 5.3 Proxy dev: **`/promo-slides`** → API en `proxy.conf.json` y `proxy.docker.conf.json`.

## 6. Layout shell y estilos globales

- [x] 6.1 Shell: columna flex `min-height: 100dvh`; `.app-main` flexible.
- [x] 6.2 `styles.scss`: `router-outlet { display: contents }` bajo `main.app-main` y reglas para `app-home`.
- [x] 6.3 Anular `max-width: 420px` del slider desde 700px; escritorio ≥900px: contenedor **70%** de ancho del main.

## 7. Navegación y Docker

- [x] 7.1 Enlaces **Inicio** (nav + footer) y **marca** → `routerLink="/home"` en `shell/shell/shell.html`.
- [x] 7.2 `docker-compose.yml`: comando `npm install && npm run start …` en **`anyjobs-front`**.

## 8. Seguimiento (opcional / fuera del MVP actual)

- [ ] 8.1 Persistir interacciones en BD y DTOs tipados en Nest.
- [ ] 8.2 Política de auth en `POST /interactions` (JWT obligatorio vs público con rate limit).
- [ ] 8.3 Enriquecer **`doubleTap`** / **`mutedChange`** con slide activo (wrapper o cambio en librería).
