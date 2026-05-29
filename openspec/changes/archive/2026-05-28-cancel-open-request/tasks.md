## 1. Backend — persistencia y dominio

- [x] 1.1 Crear enum `OpenRequestLifecycleStatus` (`ACTIVE`, `CANCELLED`) en dominio compartido del módulo open-requests
- [x] 1.2 Migración TypeORM: columna `lifecycle_status` VARCHAR NOT NULL DEFAULT `'ACTIVE'` en `open_requests`
- [x] 1.3 Añadir `lifecycleStatus` en `OpenRequestEntity`, mappers y modelos de dominio (`OpenRequestDetail`, list items)
- [x] 1.4 Exponer `lifecycleStatus` en DTOs de lectura (`OpenRequestDetailDto`, ítems de listado/mine) y respuesta de cancel

## 2. Backend — repositorio y filtros de listado

- [x] 2.1 Métodos en repositorio: `findLifecycleStatus(id)`, `setLifecycleStatus(id, CANCELLED)`, `hasProposalForUser(requestId, userId)`
- [x] 2.2 Método para listar `userId` distintos con propuesta en una solicitud (fan-out de notificaciones)
- [x] 2.3 Filtrar `lifecycle_status = 'ACTIVE'` en `GET /open-requests`, nearby y listados de relevancia
- [x] 2.4 Mantener `GET /open-requests/mine` incluyendo `ACTIVE` y `CANCELLED` (solo excluir soft-deleted)

## 3. Backend — use cases y controller

- [x] 3.1 Implementar `CancelOpenRequestUseCase` (titular, idempotente, 403/404 según design)
- [x] 3.2 Registrar `POST /open-requests/:id/cancel` en controller (orden de rutas segura) + Swagger
- [x] 3.3 Ajustar `GetOpenRequestDetailUseCase`: 404 para cancelada si visitante no titular/postulante; 200 con `lifecycleStatus` para titular y postulantes
- [x] 3.4 Rechazar `POST /proposals` si solicitud `CANCELLED` en `CreateProposalUseCase`
- [x] 3.5 Rechazar `PATCH /open-requests/:id` si solicitud `CANCELLED` en `UpdateOpenRequestUseCase` (código `OPEN_REQUEST.CANCELLED`)

## 4. Backend — notificaciones

- [x] 4.1 Añadir `notifyOpenRequestCancelled` en `NotificationDispatchService` (`REQUEST_OR_PROPOSAL_UPDATE`, dedupKey por receptor)
- [x] 4.2 Integrar fan-out en `CancelOpenRequestUseCase` tras persistir (try/catch, no revertir cancel)
- [x] 4.3 Inyectar dependencia de propuestas/repositorio en el módulo si hace falta wiring en `open-requests.module`

## 5. Backend — tests

- [x] 5.1 Unit tests: `CancelOpenRequestUseCase` (éxito, idempotencia, 403)
- [ ] 5.1b Unit test: `CancelOpenRequestUseCase` → 404 solicitud inexistente (pendiente)
- [x] 5.2 Unit tests: `CreateProposalUseCase` rechaza solicitud cancelada
- [x] 5.3 E2E: `POST /open-requests/:id/cancel` por titular → `200` y estado `CANCELLED`
- [x] 5.4 E2E: cancelada excluida de `GET /open-requests` e incluida en `GET /open-requests/mine`
- [x] 5.5 E2E: detalle cancelada → `404` anónimo, `200` titular y `200` postulante con propuesta (Bearer)
- [x] 5.6 E2E: postulante recibe notificación tras cancel

## 6. Frontend — modelos y servicio API

- [x] 6.1 Añadir `lifecycleStatus` a `OpenRequestDetail` y tipos de ítem de `listMyOpenRequests` (default `ACTIVE` si ausente)
- [x] 6.2 Implementar `OpenRequestsService.cancelOpenRequest(id)` → `POST .../cancel`
- [x] 6.3 Helper `openRequestLifecycleLabel(status, 'owner' | 'applicant')` para chips en español

## 7. Frontend — detalle de solicitud (`open-request-detail`)

- [x] 7.1 Acciones owner en `#applyCard` en orden: Ver postulantes (N) / Sin postulantes aún → Volver a Mis solicitudes → Cancelar esta solicitud (solo `ACTIVE`)
- [x] 7.2 Contador `N` vía `ProposalsService.listByRequest`; enlace deshabilitado «Sin postulantes aún» si `N = 0`
- [x] 7.3 Modal de confirmación «¿Desea cancelar esta solicitud?» con Sí / No (`app-modal`)
- [x] 7.4 Flujo Sí: llamar cancel, loading/error, refrescar detalle; cerrada sin botón cancelar
- [x] 7.5 Ocultar CTA de postular para visitantes cuando solicitud `CANCELLED`
- [x] 7.6 Tests `open-request-detail.spec.ts`: contador, Sin postulantes aún, textos de botones, sin cancelar si cerrada
- [ ] 7.7 Test interacción modal + `cancelOpenRequest` exitoso (pendiente, opcional)

## 8. Frontend — Mis solicitudes (`my-requests-dashboard`)

- [x] 8.1 Pestaña «Publicadas por mí»: chips «Activo» / «Cerrado» (reemplazar «Publicada por ti»)
- [x] 8.2 Estilos SCSS: `chip--active`, `chip--closed`, `chip--cancelled`
- [x] 8.3 Pestaña «Postulé a estas»: chip «Cancelada», ocultar acciones si solicitud cancelada
- [x] 8.4 `lifecycleStatus` en applied vía `GET` detalle con Bearer por cada propuesta
- [x] 8.5 `my-requests-dashboard.spec.ts` (chips, applied cancelada sin acciones)
- [x] 8.6 Layout `itemGrid--noThumb` cuando la card no tiene miniatura

## 9. Backend — auth opcional en `@Public()`

- [x] 9.1 `AuthRbacGuard`: `attachUserIfPresent` en rutas `@Public()` con Bearer válido (sin exigir permisos)
- [x] 9.2 Unit tests guard: público + Bearer adjunta `userId`; público sin token permite acceso anónimo

## 10. Documentación y cierre

- [x] 10.1 Documentar `lifecycleStatus` y `POST /open-requests/:id/cancel` en README/Swagger del back
- [ ] 10.2 Sincronizar `ENDPOINTS_Y_CONTRATOS_API.md` (front) con cancel + auth opcional en detalle (pendiente)
- [x] 10.3 Ejecutar tests back relevantes (`cancel-open-request`, `auth-rbac.guard`, e2e open-requests)
- [ ] 10.4 Ejecutar `ng test` / `ng lint` front (requiere Node ≥ 20.19 en entorno local)
