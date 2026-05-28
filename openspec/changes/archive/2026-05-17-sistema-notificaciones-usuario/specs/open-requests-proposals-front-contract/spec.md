## ADDED Requirements

### Requirement: Contrato del cliente para API de notificaciones

El cliente Angular SHALL consumir los endpoints de notificaciones del backend con autenticación Bearer, interpretando respuestas alineadas al resto del API (`items` + `meta` en listados, DTO de notificación con campos `id`, `type`, `title`, `message`, `entityType`, `entityId`, `isRead`, `createdAt`).

#### Scenario: Listar notificaciones

- **WHEN** el cliente invoca `GET /notifications` con sesión válida
- **THEN** SHALL mapear `items` a un modelo de dominio `Notification` o equivalente
- **AND** SHALL preservar `entityType` y `entityId` para navegación

#### Scenario: Conteo de no leídas

- **WHEN** el cliente invoca `GET /notifications/unread-count`
- **THEN** SHALL actualizar el estado del badge de la campanita con el valor devuelto

#### Scenario: Marcar leída y marcar todas

- **WHEN** el cliente invoca `PATCH /notifications/:id/read` o `PATCH /notifications/read-all`
- **THEN** SHALL refrescar el conteo de no leídas tras éxito

### Requirement: Deep-link desde notificación a solicitud abierta

Cuando una notificación tenga `entityType` compatible con solicitud abierta y `entityId` de solicitud, el cliente MUST navegar a la ruta de detalle de solicitudes del proyecto (`/solicitudes/:id` o equivalente documentado).

#### Scenario: Navegación desde campanita

- **WHEN** el usuario selecciona una notificación con `entityType` = `open_request`
- **THEN** el router MUST navegar a `/solicitudes/{entityId}` (o ruta canónica)
- **AND** MUST haber marcado la notificación como leída según el flujo de la campanita

### Requirement: Interceptor Bearer incluye notificaciones

El interceptor de autenticación del front MUST adjuntar `Authorization: Bearer` a las peticiones hacia `/notifications` con la misma política que `/proposals` y `/open-requests`.

#### Scenario: Petición autenticada a notificaciones

- **WHEN** el usuario tiene token en sesión y el cliente llama a `/notifications`
- **THEN** la petición MUST incluir el header Bearer

### Requirement: Proxy de desarrollo enruta notificaciones al backend

Los archivos de proxy del front (`proxy.conf.json` y `proxy.docker.conf.json`) MUST incluir la ruta `/notifications` apuntando al backend, de modo que las peticiones del cliente no reciban `index.html` del dev server.

#### Scenario: Listado en entorno local o Docker

- **WHEN** el cliente invoca `GET /notifications` contra el origin del front en desarrollo
- **THEN** la petición MUST proxificarse al API de notificaciones del backend
- **AND** la respuesta MUST ser JSON (`items` + `meta` o `{ count }`), no HTML
