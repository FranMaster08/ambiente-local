## Why

Hoy la aplicación no avisa al usuario cuando otro participante responde, se postula o interactúa con sus solicitudes o contenido relacionado. Eso obliga a revisar manualmente listados y detalles, y se pierden eventos relevantes. Se necesita un canal visible y persistente en el header para que el usuario autenticado descubra esas interacciones sin depender de recargas ad hoc ni de lógica solo en frontend.

## What Changes

- **Modelo y persistencia de notificaciones (backend)**: Nueva entidad/tabla `notifications` asociada a un usuario receptor, con campos mínimos (`id`, `recipientId`, `type`, `title`, `message`, `entityType`, `entityId`, `isRead`, `createdAt`, `updatedAt`) y convenciones del proyecto (TypeORM, migración manual).
- **Tipos de notificación iniciales**: Enum o catálogo centralizado para eventos como postulación a solicitud, respuesta a solicitud, interacción relevante y actualizaciones de propuesta/solicitud; extensible para futuros tipos.
- **Creación en backend al producirse interacciones**: Al crear una propuesta (`POST /proposals`) u otros eventos acordados en diseño, generar notificación para el owner de la solicitud; no notificar al actor sobre su propia acción; evitar duplicados por evento; fallo de notificación no debe romper el flujo principal (try/catch o fire-and-forget en capa de servicio).
- **API REST de notificaciones**: Endpoints autenticados para listar (orden `createdAt` DESC), contar no leídas, marcar una como leída y marcar todas como leídas; aislamiento estricto por `recipientId` = usuario de sesión.
- **Campanita en header (frontend)**: Componente en el Shell (`headerTrailing`), visible **solo con sesión**; icono SVG en blanco y negro; badge de no leídas; dropdown con lista (título, mensaje breve, tiempo relativo, estado leído); navegación a recurso vía `entityType` + `entityId`; marcar como leída al seleccionar ítem.
- **Estados de UI**: Carga, vacío (“No tienes notificaciones”), error controlado; visible en desktop, tablet y móvil junto al menú hamburguesa.
- **Retención de leídas**: Las notificaciones marcadas como leídas se eliminan automáticamente tras **24 horas**; las no leídas no expiran.
- **Proxy dev/Docker**: Rutas `/notifications` en `proxy.conf.json` y `proxy.docker.conf.json` para que el front enrute al backend.
- **Sin tiempo real en v1**: Consulta inicial y refresh controlado (p. ej. al abrir dropdown o intervalo opcional); arquitectura preparada para WebSockets/push posterior.
- **Seguridad**: Sin exponer notificaciones ajenas ni datos sensibles en mensajes; validación en backend con `AuthRbacGuard` y permisos acordados.

## Capabilities

### New Capabilities

- `user-notifications`: Modelo, tipos, creación en eventos de dominio, API REST y reglas de seguridad/permisos para notificaciones in-app del usuario autenticado.
- `header-notifications-bell`: UI de campanita en el header global (Shell), badge de no leídas, dropdown de lista, estados de carga/vacío/error y navegación al recurso relacionado.

### Modified Capabilities

- `app-header-responsive-navigation`: Extender requisitos del header para incluir la campanita de notificaciones en desktop y menú compacto/móvil sin romper navegación ni CTA existentes.
- `open-requests-postulations-owner-and-applicants`: Cuando un usuario distinto al owner crea una propuesta válida sobre una solicitud, el owner MUST recibir una notificación persistida (complementa la visibilidad de postulantes en detalle).
- `open-requests-proposals-front-contract`: Contrato front para consumir APIs de notificaciones y deep-links desde notificaciones hacia detalle de solicitud u otros recursos soportados.

## Impact

- **Backend (`anyjobs-back`)**: Nuevo módulo `notifications` (entidad, migración, repositorio, use cases, controller), integración en `CreateProposalUseCase` (y puntos adicionales definidos en design); permisos en catálogo RBAC; posible entrada en `ENDPOINTS_Y_CONTRATOS_API.md`.
- **Frontend (`anyjobs-front`)**: Servicio API de notificaciones, componente campanita/dropdown, integración en `shell` (`headerTrailing`); proxy; rutas de navegación según `entityType`/`entityId`.
- **Base de datos**: Nueva tabla `notifications` vía migración TypeORM.
- **Fuera de alcance v1**: WebSockets, push nativo, módulo de “actividades” (solo placeholder en perfil hoy), notificaciones por email.
- **OpenSpec existente no modificado en requisitos**: `open-requests-engagement-analytics` (telemetría ≠ notificaciones al usuario).
- **Pruebas manuales/E2E**: Flujo usuario A crea solicitud → usuario B postula → A ve badge y lista; B no recibe notificación propia; marcar leída y contador; guest sin campanita privada.
