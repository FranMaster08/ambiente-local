## 1. Backend — modelo y migración

- [x] 1.1 Crear entidad TypeORM `NotificationEntity` y enum `NotificationType` en `modules/notifications/`.
- [x] 1.2 Crear migración `20260517120000-notifications.ts` con tabla `notifications`, índices en `recipient_id`, `created_at` y único `(recipient_id, dedup_key)` cuando `dedup_key` no sea null.
- [x] 1.3 Implementar `NotificationsRepositoryPort` + adapter TypeORM + adapter in-memory para tests.
- [x] 1.4 Registrar `NotificationsModule` en `AppModule`.

## 2. Backend — casos de uso y API

- [x] 2.1 Implementar `CreateNotificationUseCase` con soporte de `dedupKey` (ignorar duplicado).
- [x] 2.2 Implementar `ListNotificationsUseCase`, `GetUnreadCountUseCase`, `MarkNotificationReadUseCase`, `MarkAllNotificationsReadUseCase` filtrando por `req.user.userId`.
- [x] 2.3 Crear `NotificationsController` con rutas `GET /notifications`, `GET /notifications/unread-count`, `PATCH /notifications/read-all`, `PATCH /notifications/:id/read`.
- [x] 2.4 Añadir permisos `notifications.read.own` y `notifications.update.own` con `@RequirePermissions`.
- [x] 2.5 Crear DTOs de respuesta y documentar en Swagger.

## 3. Backend — emisión al postular

- [x] 3.1 Crear `NotificationDispatchService.notifyProposalReceived`.
- [x] 3.2 Integrar en `CreateProposalUseCase` tras `create` exitoso: try/catch, log en error, no propagar.
- [x] 3.3 Tests unitarios: postulación, dedup, fallo de notificación no rompe create.

## 4. Backend — retención de leídas (24 h)

- [x] 4.1 Constante `READ_NOTIFICATION_RETENTION_MS` y `readNotificationRetentionCutoff()`.
- [x] 4.2 `purgeReadOlderThan` en repositorio TypeORM e in-memory.
- [x] 4.3 `PurgeExpiredReadNotificationsUseCase` invocado en listado y conteo de no leídas.
- [x] 4.4 `markAllRead` actualiza `updatedAt` en bulk update.
- [x] 4.5 Tests: purga leídas >24h; conserva leídas recientes y no leídas.

## 5. Frontend — API y modelos

- [x] 5.1 Crear `notifications.models.ts` y `notifications.api.ts`.
- [x] 5.2 Añadir `/notifications` al `auth-bearer.interceptor.ts`.
- [x] 5.3 Crear `NotificationsService` con signals y métodos refresh/markRead/markAllRead.
- [x] 5.4 Añadir `/notifications` en `proxy.conf.json` y `proxy.docker.conf.json`.

## 6. Frontend — campanita en header

- [x] 6.1 `HeaderNotificationsBellComponent` con icono SVG B/N, `aria-label`, `aria-expanded`.
- [x] 6.2 Integrar en `headerTrailing` del shell; visible solo si `authVm().isLoggedIn`.
- [x] 6.3 Visible en desktop, tablet y móvil (junto a menú hamburguesa).
- [x] 6.4 Badge, estados carga/vacío/error.
- [x] 6.5 Lista, tiempo relativo, “Marcar todas como leídas”.
- [x] 6.6 Click → marcar leída + navegar a `/solicitudes/:id`; cerrar panel.
- [x] 6.7 Refresh al abrir dropdown; conteo al login y `visibilitychange`.

## 7. Tests y validación manual

- [x] 7.1 Tests back: aislamiento, purge, create-proposal + notificación.
- [x] 7.2 Tests front: campanita (badge, vacío, navegación).
- [ ] 7.3 Validación manual: A crea solicitud → B postula → A ve badge y lista.
- [ ] 7.4 Validación manual: marcar leída/todas; leídas >24h desaparecen al reabrir.
- [ ] 7.5 Validación manual: visitante sin campanita; regresión header mobile/desktop.

## 8. Documentación

- [x] 8.1 `ENDPOINTS_Y_CONTRATOS_API.md`: contrato `/notifications` y retención de leídas.
