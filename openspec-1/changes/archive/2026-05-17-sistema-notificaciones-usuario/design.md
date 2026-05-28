## Context

La aplicación (monolito NestJS + Angular) no persiste ni expone notificaciones in-app. El header global vive en `shell.ts` / `shell.html` con acciones de idioma, CTA y menú de cuenta; no hay campanita. Las interacciones relevantes para el usuario hoy ocurren principalmente vía **propuestas** (`POST /proposals` → owner en `open_requests.owner_user_id`). Existe telemetría (`open_request_interactions`) pero es analítica, no aviso al usuario. Auth: Bearer + `AuthRbacGuard` con `req.user.userId`. No hay módulo de “actividades” en backend (solo placeholder en perfil).

## Goals / Non-Goals

**Goals:**

- Tabla y módulo `notifications` con tipos extensibles.
- Creación automática en backend al postular (v1) sin bloquear el flujo principal.
- API REST: listar, contar no leídas, marcar una/todas leídas; aislamiento por receptor.
- Campanita en header (desktop + menú compacto) con badge, dropdown y deep-links.
- Arquitectura preparada para tiempo real posterior (puerto/servicio inyectable).

**Non-Goals:**

- WebSockets, SSE, push móvil o email.
- Notificaciones por interacciones de analytics (`open_request_interactions`).
- Módulo de actividades del perfil (hasta existir dominio).
- Notificar al actor sobre su propia acción.
- Hardcodear datos de prueba en producción.

## Decisions

### 1. Módulo backend `notifications`

**Decisión:** Nuevo módulo Nest bajo `apps/api/src/modules/notifications/` siguiendo el patrón existente: entidad TypeORM, repositorio (port + adapter TypeORM + in-memory para tests), use cases, controller `@Controller('notifications')`.

**Tabla `notifications`:**

| Columna (DB) | Tipo | Notas |
|--------------|------|-------|
| `id` | uuid PK | |
| `recipient_id` | uuid FK → users | Índice |
| `type` | varchar(64) | Valor del enum |
| `title` | varchar(255) | |
| `message` | text | Sin datos sensibles |
| `entity_type` | varchar(64) | p. ej. `open_request`, `proposal` |
| `entity_id` | uuid | Recurso de navegación |
| `actor_user_id` | uuid nullable | Quién generó el evento (para dedup y futuro UI) |
| `dedup_key` | varchar(128) nullable | UNIQUE parcial o índice único `(recipient_id, dedup_key)` |
| `is_read` | boolean default false | |
| `created_at`, `updated_at` | timestamp | |

**Rationale:** `dedup_key` evita duplicados si el mismo evento se reintenta (p. ej. `proposal:{proposalId}` o `proposal:{requestId}:{actorUserId}`). `actor_user_id` facilita mensajes y auditoría sin join extra en v1.

**Alternativa descartada:** Reutilizar `open_request_interactions` — semántica distinta (telemetría anónima/agregada).

### 2. Enum de tipos (`NotificationType`)

**Decisión:** Enum TypeScript compartido en dominio del módulo:

- `PROPOSAL_RECEIVED` — nueva postulación en solicitud del receptor
- `REQUEST_RESPONSE` — reservado para respuestas/comentarios futuros
- `ACTIVITY_INTERACTION` — reservado cuando exista dominio de actividades
- `REQUEST_OR_PROPOSAL_UPDATE` — cambios de estado relevantes (futuro)

v1 implementa creación solo para `PROPOSAL_RECEIVED`.

### 3. Creación al crear propuesta

**Decisión:** Tras `proposalsRepo.create` exitoso en `CreateProposalUseCase`, invocar `NotificationService.notifyProposalReceived(...)` envuelto en try/catch; errores se loguean y no propagan.

**Reglas:**

- `recipientId` = `ownerUserId` de la solicitud.
- No crear si `actorUserId === recipientId` (ya cubierto por regla de negocio existente).
- `dedupKey` = `proposal:{proposalId}` (o `proposal:{requestId}:{actorUserId}` si el id de propuesta no está disponible antes de persistir — usar el id devuelto por `create`).
- `entityType` = `open_request`, `entityId` = `requestId`.
- `title` / `message` genéricos en español (i18n del mensaje en front en iteración posterior).

**Alternativa descartada:** Event bus entre microservicios — el monolito actual no publica eventos de dominio; inyección directa del servicio es más simple y alineada al MVP.

### 4. API REST

**Decisión:** Endpoints bajo `/notifications` (sin prefijo `/api` en servidor; el proxy del front puede normalizar):

| Método | Ruta | Permiso | Comportamiento |
|--------|------|---------|----------------|
| GET | `/notifications` | `notifications.read.own` | Lista del usuario sesión, `createdAt` DESC, paginación opcional `page`/`pageSize` (default razonable p. ej. 20) |
| GET | `/notifications/unread-count` | `notifications.read.own` | `{ count: number }` |
| PATCH | `/notifications/:id/read` | `notifications.update.own` | Marca una; 404 si no existe o no es del usuario |
| PATCH | `/notifications/read-all` | `notifications.update.own` | Marca todas del usuario |

Todas las consultas filtran `recipient_id = req.user.userId`. Respuesta de lista: envoltorio `{ items, meta }` coherente con `GET /proposals`.

**Interceptor front:** Añadir `/notifications` al prefijo del `auth-bearer.interceptor.ts`.

**Proxy dev/Docker:** Añadir entrada `/notifications` en `proxy.conf.json` y `proxy.docker.conf.json` (sin proxy, Angular devuelve `index.html` y el cliente falla al parsear JSON).

### 5. Permisos RBAC

**Decisión:** Registrar en catálogo de permisos:

- `notifications.read.own`
- `notifications.update.own`

Asignar al rol/usuario autenticado estándar del MVP (mismo patrón que `proposals.read`).

### 6. Frontend — componente y Shell

**Decisión:**

- Componente standalone `HeaderNotificationsBellComponent` en `shell/header-notifications-bell/`.
- Servicio `NotificationsApi` / `NotificationsService` con signals para `items`, `unreadCount`, `loading`, `error`.
- Integrar en `shell.html` dentro de `headerTrailing` (junto al `menuToggle`), visible solo si `authVm().isLoggedIn`. Visible en **todos los breakpoints** (desktop, tablet, móvil) en la barra sticky del header.
- Icono: SVG de campana con `stroke="currentColor"` en color ink (blanco y negro respecto al tema); badge ink/surface.
- Badge: número si `unreadCount > 0` (cap 99+).
- Dropdown: lista con título, mensaje, tiempo relativo (`createdAt`), estilo leído/no leído.
- Al abrir dropdown: `GET /notifications` + refresh de contador.
- Al click en ítem: `PATCH .../read` (si no leída), navegar según `entityType`/`entityId` (v1: `open_request` → `/solicitudes/:id`).
- Botón “Marcar todas como leídas” en footer del panel.
- Refresh: al abrir panel + opcional `visibilitychange` o intervalo largo (60s) — no polling agresivo.

**Alternativa descartada:** Estado global NgRx — el proyecto usa signals/servicios en features similares.

### 7. Tiempo real (preparación)

**Decisión:** `NotificationsRepositoryPort` + servicio de aplicación sin acoplar a transporte. Un comentario/TODO y método `refresh()` en el servicio front permiten enchufar WebSocket después sin cambiar contratos REST.

### 8. Seguridad y privacidad

- Mensajes sin email, tokens ni texto completo de propuestas privadas.
- No exponer `recipientId` de otros usuarios.
- Validación server-side en cada use case (no confiar en query params de userId).

### 9. Retención de notificaciones leídas

**Decisión:** Las notificaciones con `isRead = true` se eliminan cuando `updatedAt` es anterior a **24 horas** respecto al momento de la consulta. Las no leídas no se purgan por este mecanismo.

**Implementación:**

- Constante `READ_NOTIFICATION_RETENTION_MS` en `notification-retention.ts`.
- `PurgeExpiredReadNotificationsUseCase` invoca `purgeReadOlderThan(recipientId, cutoff)`.
- Se ejecuta de forma lazy al listar (`GET /notifications`) y al consultar conteo (`GET /notifications/unread-count`).
- Al marcar leída (una o todas), `updatedAt` MUST actualizarse (incluye `markAllRead` con `updatedAt` explícito en bulk update).

**Rationale:** Reduce ruido en el historial sin borrar avisos pendientes; no requiere cron en v1.

## Risks / Trade-offs

- **[Riesgo]** Contador desactualizado entre pestañas. **Mitigación:** refresh al abrir dropdown; intervalo opcional.
- **[Riesgo]** Duplicados en reintentos de red. **Mitigación:** `dedup_key` único por receptor.
- **[Riesgo]** Fallo silencioso de notificación. **Mitigación:** log estructurado en catch; monitoreo futuro.
- **[Trade-off]** Sin tiempo real en v1 — el usuario puede ver retraso hasta refresh.
- **[Trade-off]** Solo `PROPOSAL_RECEIVED` en v1 — otros tipos quedan en enum sin emisor.
- **[Riesgo]** Proxy sin `/notifications` devuelve HTML → error genérico en UI. **Mitigación:** proxy.conf + proxy.docker.conf actualizados.

## Migration Plan

1. Ejecutar migración `YYYYMMDDHHMMSS-notifications.ts` en entornos con PostgreSQL.
2. Desplegar backend con módulo registrado en `AppModule`.
3. Desplegar front con campanita (feature flag no requerida; oculta si no hay sesión).
4. Rollback: revert migración; quitar componente del shell (header sigue funcional).

## Open Questions

- _(ninguna bloqueante)_ — i18n de textos de notificación en servidor vs cliente: v1 mensajes fijos en español en backend; front puede mostrar `title`/`message` tal cual.
