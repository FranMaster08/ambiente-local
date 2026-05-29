## Why

Hoy el publicador de una solicitud abierta no puede **cerrarla de forma explícita** sin borrarla del sistema (`DELETE` con soft-delete), y las vistas de **Mis solicitudes** no comunican el ciclo de vida real: la pestaña «Publicadas por mí» muestra siempre la badge fija «Publicada por ti», y quien postuló sigue viendo acciones y el estado «Enviada» aunque la solicitud ya no esté disponible. Eso genera postulaciones sobre ofertas cerradas, confusión en el dashboard y ausencia de aviso a los postulantes afectados. Se necesita un flujo de **cancelación** con estado persistido, confirmación en UI y notificaciones in-app reutilizando el módulo de notificaciones existente.

## What Changes

### Estado de vida de la solicitud (backend + contrato API)

- Introducir campo persistido `lifecycleStatus` en open requests con valores al menos **`ACTIVE`** y **`CANCELLED`** (default `ACTIVE` para registros existentes vía migración).
- Exponer `lifecycleStatus` en respuestas de lectura relevantes: `GET /open-requests/{id}`, `GET /open-requests/mine`, listados que alimenten «Mis solicitudes» y agregados usados en la pestaña «Postulé a estas» cuando incluyan datos de la solicitud.
- Las solicitudes **`CANCELLED`** MUST dejar de aparecer en descubrimiento público (`GET /open-requests`, nearby, ranking, etc.) pero MUST seguir siendo consultables por el owner y por postulantes en contextos autenticados de historial (detalle con restricciones de acciones, listado «Postulé a estas»).
- Nuevo endpoint dedicado **`POST /open-requests/{id}/cancel`** (autenticado, solo titular): transición idempotente `ACTIVE` → `CANCELLED`; idempotente si ya está cancelada; no sustituir el `DELETE` existente.
- **`GET /open-requests/{id}`** es `@Public()` pero MUST resolver al visitante autenticado cuando envía **Bearer válido** (auth opcional en el guard), para aplicar visibilidad de canceladas (titular/postulante → `200`; resto → `404`).

### UI — pestaña «Publicadas por mí» (`my-requests-dashboard`)

- Reemplazar la chip fija **«Publicada por ti»** por chips de estado según `lifecycleStatus`:
  - **`ACTIVE`** → «Activo»
  - **`CANCELLED`** → «Cerrado»
- Mantener acciones actuales (p. ej. «Ver detalle», «Ver postulantes» en la card).

### UI — detalle de solicitud (`open-request-detail`, bloque `#applyCard`)

- Cuando el usuario autenticado es el **creador**, las acciones en `#applyCard` MUST mostrarse en este orden:
  1. **«Ver postulantes (N)»** — enlace a `/mis-solicitudes?postulantes={id}` si `N ≥ 1` (N = propuestas de la solicitud vía `GET /proposals?requestId=…`).
  2. **«Volver a Mis solicitudes»** — enlace a `/mis-solicitudes`.
  3. **«Cancelar esta solicitud»** — solo si `lifecycleStatus` = `ACTIVE`; abre modal «¿Desea cancelar esta solicitud?» con **Sí** / **No**.
- Si **`N = 0`**, el primer control MUST ser un botón **deshabilitado** con texto **«Sin postulantes aún»** (sin enlace).
- Si la solicitud ya está **`CANCELLED`**, MUST NOT mostrarse «Cancelar esta solicitud»; copy «Esta solicitud está cerrada.»; siguen disponibles ver postulantes (si `N ≥ 1`) y volver a Mis solicitudes.

### Notificaciones a postulantes

- Tras cancelación exitosa, el backend MUST crear una notificación in-app para **cada usuario distinto** con propuesta sobre esa solicitud (excluir al owner/cancelador).
- Mensaje: título «Solicitud cancelada» y cuerpo **«La solicitud «{título}» fue cancelada por quien la publicó.»**
- Tipo: `REQUEST_OR_PROPOSAL_UPDATE`; `entityType` = `open_request`; fallo de notificación MUST NOT revertir la cancelación.

### UI — pestaña «Postulé a estas» (`my-requests-dashboard`)

- Cuando la solicitud asociada está **`CANCELLED`** (vía `GET /open-requests/{id}` con Bearer):
  - Chip **«Cancelada»** en lugar de **«Enviada»**.
  - **Ocultar** «Ver detalle» y «Ver mi propuesta» / «Ocultar mi propuesta».
  - El ítem MUST permanecer visible.
- Layout de cards sin miniatura: grid de una columna (`itemGrid--noThumb`) para evitar contenido comprimido cuando no hay imagen o falla la carga del detalle.

### Seguridad — auth opcional en rutas `@Public()`

- En endpoints `@Public()`, si el cliente envía **Bearer válido**, el guard MUST adjuntar `req.user` **sin exigir permisos RBAC** del endpoint.
- La autorización de datos sensibles MUST seguir en use cases (p. ej. detalle cancelado solo titular/postulante).
- Rutas protegidas (`@RequirePermissions`) no cambian: siguen exigiendo token + permisos.

### Fuera de alcance (v1)

- Reabrir una solicitud cancelada.
- Notificaciones por email o push nativo.
- Cambiar el comportamiento del `DELETE /open-requests/{id}` existente.
- Nuevos estados de propuesta individual más allá de reflejar la cancelación de la solicitud padre.

## Capabilities

### New Capabilities

- `open-request-cancel`: Ciclo de vida `ACTIVE`/`CANCELLED`, endpoint de cancelación, reglas de visibilidad en listados públicos vs historial autenticado, auth opcional en lecturas públicas, y notificaciones a postulantes.

### Modified Capabilities

- `mis-solicitudes-publicadas`: Chips Activo/Cerrado; applied cancelada (chip, acciones ocultas, layout sin thumb).
- `open-requests-postulations-owner-and-applicants`: Acciones ordenadas en `#applyCard`, contador de postulantes, cancelación con modal.
- `user-notifications`: Notificación al cancelar con postulantes.
- `open-requests-proposals-front-contract`: `lifecycleStatus`, `cancelOpenRequest`, etiquetas UI, carga de contador de postulantes en detalle.
- `anyjobs-back/open-requests`: Persistencia, cancel, filtros, detalle restringido, `AuthRbacGuard` con auth opcional en `@Public()`.

## Impact

- **Backend (`anyjobs-back`)**: migración `lifecycle_status`; `CancelOpenRequestUseCase`; `POST .../cancel`; filtros en listados públicos; `GetOpenRequestDetailUseCase`; `NotificationDispatchService.notifyOpenRequestCancelled`; **`AuthRbacGuard.attachUserIfPresent`** en rutas `@Public()`; tests unitarios y e2e (incl. postulante con Bearer en detalle cancelado).
- **Frontend (`anyjobs-front/anyjobs`)**: `my-requests-dashboard` (chips, applied, `itemGrid--noThumb`); `open-request-detail` (orden de botones, contador postulantes, modal cancelar); `open-requests.service` + `open-request-lifecycle-labels.ts`; README back para endpoint cancel.
- **OpenSpec**: deltas actualizados en todas las capacidades del change.
- **Compatibilidad**: campo `lifecycleStatus` añadido; listados públicos excluyen canceladas (comportamiento documentado).
