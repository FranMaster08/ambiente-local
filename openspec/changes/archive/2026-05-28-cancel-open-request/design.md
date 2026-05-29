## Context

Las open requests se persisten en `open_requests` con soft-delete (`deleted_at`) y sin campo de ciclo de vida. El owner ve en **Mis solicitudes** la chip fija «Publicada por ti»; los postulantes ven «Enviada» y acciones activas aunque la oferta ya no deba recibir más interés. Existe `DELETE /open-requests/{id}` (soft-delete, desaparece de lecturas) y el módulo `notifications` con `NotificationDispatchService.notifyProposalReceived` como patrón de fan-out no bloqueante.

Componentes tocados: `OpenRequestEntity`, repositorio TypeORM, `OpenRequestsController`, `CancelOpenRequestUseCase`, `CreateProposalUseCase` (validación), `NotificationDispatchService`, `open-request-detail`, `my-requests-dashboard`, `OpenRequestsService`.

## Goals / Non-Goals

**Goals:**

- Persistir `lifecycleStatus` (`ACTIVE` | `CANCELLED`) con default `ACTIVE` en migración.
- Endpoint `POST /open-requests/{id}/cancel` idempotente para el titular.
- Excluir `CANCELLED` de listados públicos (browse, nearby, relevance) sin borrar el registro.
- Notificar a cada postulante distinto tras cancelación exitosa.
- UI: chips Activo/Cerrado (owner), Cancelada (postulante), acciones ordenadas en `#applyCard` (postulantes con contador, volver, cancelar), modal de confirmación, restricción de acciones en dashboard, layout applied sin thumb.
- Auth opcional en rutas `@Public()` para identificar titular/postulante en `GET /open-requests/{id}`.

**Non-Goals:**

- Reabrir solicitudes canceladas.
- Email/push.
- Cambiar semántica de `DELETE`.
- Estado independiente por propuesta (más allá de reflejar solicitud padre cancelada).
- Editar contenido de solicitud cancelada (PATCH puede rechazarse en v1; ver decisión 6).

## Decisions

### 1. Campo `lifecycleStatus` en columna dedicada (no reutilizar `deleted_at`)

**Decisión:** Columna `lifecycle_status VARCHAR` con valores `ACTIVE` | `CANCELLED`, NOT NULL, default `ACTIVE`. Enum TypeScript `OpenRequestLifecycleStatus` en dominio y DTOs.

**Alternativas:** Solo soft-delete (no distingue “cerrada” vs “borrada”); estado en JSON `provider` (incorrecto semánticamente).

**Rationale:** Cancelar es reversible en producto futuro y distinto de eliminar; los postulantes necesitan historial visible sin exponer la solicitud en el catálogo público.

### 2. Endpoint dedicado `POST /open-requests/:id/cancel`

**Decisión:** Ruta registrada **antes** de rutas paramétricas genéricas si hiciera falta; respuesta `200` con cuerpo mínimo `{ id, lifecycleStatus: 'CANCELLED' }` o detalle completo alineado a `OpenRequestDetailDto`.

**Alternativas:** `PATCH` con `{ lifecycleStatus: 'CANCELLED' }` (menos explícito en auditoría); reutilizar `DELETE` (confunde con borrado).

**Rationale:** Acción de negocio clara, permisos y logs separados; idempotencia: segunda llamada responde `200` sin error si ya está `CANCELLED`.

**Errores:**

| Caso | HTTP |
|------|------|
| Sin token | 401 |
| No titular | 403 |
| No existe o soft-deleted | 404 |
| Ya cancelada | 200 (idempotente) |

### 3. Visibilidad en lecturas HTTP

**Decisión:**

| Endpoint | `ACTIVE` | `CANCELLED` |
|----------|----------|-------------|
| `GET /open-requests`, nearby, relevance | Incluida si no deleted | **Excluida** |
| `GET /open-requests/mine` | Incluida | **Incluida** (historial del owner) |
| `GET /open-requests/{id}` visitante anónimo o no titular/postulante | 200 | **404** (`OPEN_REQUEST.NOT_FOUND`) |
| `GET /open-requests/{id}` titular o usuario con propuesta en esa solicitud | 200 + `lifecycleStatus` | 200 + `lifecycleStatus` |
| `POST /proposals` | Permitido | **400/403** con mensaje claro |

**Alternativas:** 200 público con banner “cerrada” (expone IDs en URLs compartidas); ocultar también en `mine` (pierde historial del owner).

**Rationale:** Alineado a la proposal: fuera del catálogo, visible en Mis solicitudes y para quien ya postuló.

**Implementación:** Repositorio expone `findLifecycleStatus(id)` y `hasProposalForUser(requestId, userId)`; el use case de detalle aplica la política. El controller pasa `viewerUserId` desde `req.user` (sesión Bearer) o `x-user-id` en tests. Listados públicos añaden `AND lifecycle_status = 'ACTIVE'`.

**Prerrequisito HTTP:** `GET /open-requests/{id}` es `@Public()`. El `AuthRbacGuard` MUST adjuntar `req.user` cuando hay Bearer válido sin exigir permisos del endpoint; si no, `viewerUserId` queda vacío y las canceladas devuelven `404` también al titular/postulante.

### 4. Notificaciones: fan-out en `CancelOpenRequestUseCase`

**Decisión:** Tras persistir `CANCELLED`, consultar `proposals` por `request_id` agrupando `userId` distintos (excluir `ownerUserId`). Por cada receptor, `NotificationDispatchService.notifyOpenRequestCancelled({ recipientId, requestId, requestTitle, actorUserId })` con:

- `type`: `REQUEST_OR_PROPOSAL_UPDATE`
- `title`: «Solicitud cancelada»
- `message`: «La solicitud «{title}» fue cancelada por quien la publicó.»
- `entityType`: `open_request`, `entityId`: request id
- `dedupKey`: `open_request_cancelled:{requestId}:{recipientId}`

**Alternativas:** Tipo nuevo `OPEN_REQUEST_CANCELLED` (más limpio para filtros futuros; se puede añadir en v1.1); notificar también al owner (innecesario).

**Rationale:** Reutiliza catálogo existente; dedup evita duplicados en reintentos idempotentes del cancel.

### 5. Frontend: modal de confirmación reutilizando `app-modal`

**Decisión:** En `open-request-detail`, estado `cancelConfirmOpen` + `app-modal` con título/copy «¿Desea cancelar esta solicitud?», botones **Sí** (primario/destructivo según tokens) y **No**. Sí → `OpenRequestsService.cancelOpenRequest(id)` → refresh detalle + toast/error existente.

**Alternativas:** `window.confirm` (peor UX/accesibilidad); página dedicada (exceso).

**Rationale:** Ya existe `app-modal` en el mismo componente (galería).

### 6. `PATCH` y nuevas postulaciones sobre canceladas

**Decisión v1:** `CreateProposalUseCase` verifica `lifecycleStatus === ACTIVE` antes de crear. `UpdateOpenRequestUseCase` rechaza `PATCH` si `CANCELLED` con `400` o `403` y código de negocio documentado (`OPEN_REQUEST.CANCELLED`).

**Rationale:** Evita reactivación indirecta; reabrir queda fuera de alcance.

### 7. Chips y clases CSS

**Decisión:** Mapeo central en helper `openRequestLifecycleLabel(status, context: 'owner' | 'applicant')`:

| status | owner (`published` tab) | applicant (`applied` tab) |
|--------|---------------------------|---------------------------|
| ACTIVE | Activo (`chip--active`) | Enviada (sin cambio) |
| CANCELLED | Cerrado (`chip--closed`) | Cancelada (`chip--cancelled`) |

Reemplazar `chip--owned` por `chip--active` / `chip--closed`. En applied cancelada: `*ngIf` sobre `itemActions` y panel expandido.

### 8. Acciones del owner en `#applyCard` (orden y contador)

**Decisión:** Para el creador autenticado, acciones en este orden vertical:

| # | Control | Comportamiento |
|---|---------|----------------|
| 1 | Ver postulantes | Si `N ≥ 1`: enlace «Ver postulantes (N)» a `/mis-solicitudes?postulantes={id}`. Si `N = 0`: botón deshabilitado «Sin postulantes aún». `N` desde `ProposalsService.listByRequest(id)`. |
| 2 | Volver a Mis solicitudes | Enlace `/mis-solicitudes`. |
| 3 | Cancelar esta solicitud | Solo si `ACTIVE`; abre modal; llama `POST .../cancel`. |

Textos finales: «Cancelar esta solicitud» (no «Cancelar solicitud»); «Volver a Mis solicitudes» (no «Ir a Mis solicitudes»).

**Decisión complementaria — solicitud cerrada:** Copy «Esta solicitud está cerrada.»; sin botón cancelar; filas 1–2 siguen según `N`.

### 9. Auth opcional en rutas `@Public()`

**Decisión:** En `AuthRbacGuard`, si el handler tiene `@Public()` y la petición incluye Bearer válido (token en `AuthTokenRegistry` o `x-user-id` en entorno de prueba), adjuntar `req.user` y continuar **sin** comprobar `@RequirePermissions`. Si no hay Bearer, la ruta sigue siendo anónima.

**Alternativas:** Endpoint de detalle no público (rompe visitantes anónimos en activas); confiar solo en cabecera `x-user-id` en producción (inseguro).

**Rationale:** Patrón estándar de autenticación opcional; la autorización fina permanece en use cases (`GetOpenRequestDetailUseCase` para canceladas).

**Seguridad:** No concede permisos de mutación; un handler `@Public()` que expusiera datos solo por `req.user` sin checks propios seguiría siendo un riesgo de diseño — cada use case MUST validar rol/relación.

### 10. Layout «Postulé a estas» sin miniatura

**Decisión:** Clase `itemGrid--noThumb` (`grid-template-columns: 1fr`) cuando la card no tiene imagen, para evitar que `itemMain` quede en columna de 88px.

## Risks / Trade-offs

- **[GET detalle 404 para visitantes con URL guardada]** → Comportamiento esperado; mensaje 404 genérico del detalle actual.
- **[Listado applied sin `lifecycleStatus` en propuesta]** → Al cargar applied, el front hace `GET` detalle por request con Bearer; sin auth opcional en `@Public()`, `request` queda `null`, chip «Enviada» y botones visibles por error — mitigado con decisión 9.
- **[Handlers `@Public()` que asumen anónimo]** → Revisar que no devuelvan datos extra solo por `req.user`; hoy el impacto principal es personalización de listado y visibilidad de detalle cancelado.
- **[Cancel sin postulantes]** → No crea notificaciones; cancel sigue siendo válido.
- **[Race: postular mientras cancela]** → Validación en `CreateProposalUseCase` tras leer estado; transacción opcional si volumen lo exige (v1: lectura + check suficiente).

## Migration Plan

1. Migración TypeORM: `ALTER TABLE open_requests ADD lifecycle_status VARCHAR NOT NULL DEFAULT 'ACTIVE'`.
2. Desplegar backend (lecturas filtran ACTIVE en público; cancel endpoint disponible).
3. Desplegar frontend (lee `lifecycleStatus`, UI condicional).
4. Rollback: revertir front; columna puede quedarse con default ACTIVE (sin pérdida de datos).

## Open Questions

- ¿Añadir `OPEN_REQUEST_CANCELLED` al enum de tipos en lugar de `REQUEST_OR_PROPOSAL_UPDATE`? *Recomendación: mantener `REQUEST_OR_PROPOSAL_UPDATE` en v1; evaluar tipo dedicado si el producto filtra por tipo en UI.*
- ¿Deep-link desde notificación a detalle para postulante cancelado? *v1: con sesión y propuesta, `GET /open-requests/{id}` → 200; CTA postular oculto.*
- ¿Desactivar `x-user-id` en producción? *Recomendación futura: solo `userId` del token en `attachUserIfPresent`; mantener cabecera solo en e2e.*
