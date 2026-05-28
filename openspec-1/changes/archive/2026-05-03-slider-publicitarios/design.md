## Context

**Anyjobs** (`anyjobs-front/anyjobs`), Angular 21, rutas hijas del **shell**. La ruta **`/home`** carga **`features/home/home/`** con `<media-slider>`.

**`ngx-vertical-slider`:** `MediaSliderComponent`, inputs/outputs por signals. Estilos internos incluyen **`max-width: 420px`** en el host desde **700px**; la app lo anula en **`.homeSliderWrap`** para respetir el ancho del contenedor.

**Backend:** Nest en `anyjobs-back/apps/api`; en desarrollo el front usa **proxy** para **`/promo-slides`** → mismo host que `ng serve`.

## Goals / Non-Goals

**Goals:**

- Slider operativo en `/home` con datos de **`GET /promo-slides`** y fallback a mock estático.
- **Identificación en telemetría:** instancia lógica del slider (`sliderId`), slide (`slideIndex`, `slideMedia`, **`campaignId`** derivado del campo **`id`** del slide si el JSON lo incluye), **actor** (usuario logueado vs anónimo con `anonymousId` persistente).
- **`POST /promo-slides/interactions`** desde el cliente; body fusionado con **`actorPayload()`**; cabecera **Bearer** cuando hay sesión (interceptor).
- Enlaces **Inicio** + marca → **`/home`**; layout shell + overrides de librería según ya documentado.
- Docker dev: **`npm install &&`** antes del start del front.

**Non-Goals (MVP actual):**

- CMS o editor de campañas.
- Persistencia en base de datos de interacciones (solo log en servidor en MVP).
- Resolver índice de slide para **`doubleTap`** / **`mutedChange`** sin cambiar la librería o el wrapper.

## Decisions

1. **Datos:** `HttpClient.get('/promo-slides')`; en error, segundo `get` a **`/mock/home-promo-slides.mock.json`**; signals `slides`, `loaded`, `loadFailed`.

2. **Contrato de slide:** compatible con **`SlideData`**; el backend (y el mock) pueden incluir **`id`** string por slide (**campaña / creatividad**). El front envía **`campaignId`** en interacciones cuando existe.

3. **Actor:** `AuthSessionService` para sesión; **`anonymousId`** en `localStorage` (`anyjobs.promo.actor.anonymousId`) para usuarios sin login; **`subjectType`**: `'user'` | `'anonymous'`; **`userId`**, **`userRoles`** si aplica; **`emittedAt`** ISO; **sin email** en el body (PII).

4. **Slider lógico:** constante **`sliderId = 'home-promotional'`** para distinguir futuros sliders en la app.

5. **API interactions:** URL **`/promo-slides/interactions`**; método **`trackInteraction`** hace **merge** `actorPayload()` + payload del evento; errores de red ignorados en cliente (no bloquear UX).

6. **Auth HTTP:** prefijos en interceptor incluyen **`/promo-slides`** para adjuntar **`Authorization: Bearer`** en GET/POST cuando hay token.

7. **Shell / layout / overrides librería / navegación / Docker / Node ≥20.19:** sin cambio de criterio respecto a la versión anterior de este diseño (ver historial del repo).

## Risks / Trade-offs

- **`display: contents` en `router-outlet`:** vigilar foco/accesibilidad en upgrades del router.
- **`!important` en estilos del slider:** reverificar al actualizar **ngx-vertical-slider**.
- **Telemetría sin slide en doubleTap/mute:** datos incompletos para esos dos tipos de evento (**observación operativa**).
- **POST público:** cualquier cliente puede enviar interacciones hasta que se añada auth obligatoria o rate limiting.

## Migration Plan

Deploy habitual del front y del API; variables de entorno / proxy en cada entorno.

## Open Questions / Observaciones

| Tema | Observación |
|------|-------------|
| Slide activo sin índice | Para **`doubleTap`** y **`mutedChange`**, valorar fork PR a la librería, wrapper que exponga índice vía `ViewChildren`, o estado interno duplicado si la librería añade output. |
| Persistencia | Modelar tabla de eventos (incl. `sliderId`, `campaignId`, `anonymousId`, `userId` nullable, `kind`, payload JSON). |
| Seguridad | Validar JWT en `POST /interactions` cuando el producto exija acciones solo para usuarios logueados; idempotencia / anti-spam. |
| Origen único | En prod, servir API y front bajo el mismo origen vía gateway o documentar CORS. |
