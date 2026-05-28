## ADDED Requirements

### Requirement: Persistencia de notificaciones por usuario receptor

El sistema SHALL persistir notificaciones in-app en una tabla o almacén dedicado (`notifications`), asociadas a un único usuario receptor (`recipientId`). Cada registro MUST incluir como mínimo: `id`, `recipientId`, `type`, `title`, `message`, `entityType`, `entityId`, `isRead`, `createdAt`, `updatedAt`. El sistema MAY incluir `actorUserId` y `dedupKey` para deduplicación y trazabilidad.

#### Scenario: Registro válido persistido

- **WHEN** el backend crea una notificación con todos los campos obligatorios
- **THEN** el registro MUST quedar almacenado con `isRead` en `false` por defecto
- **AND** `recipientId` MUST referenciar al usuario que debe ver la notificación

### Requirement: Tipos de notificación centralizados

El sistema SHALL definir tipos de notificación mediante un catálogo centralizado (enum o constante única en backend), incluyendo al menos: postulación recibida en solicitud (`PROPOSAL_RECEIVED`), respuesta a solicitud (`REQUEST_RESPONSE`), interacción con actividad (`ACTIVITY_INTERACTION`) y actualización relevante de solicitud o propuesta (`REQUEST_OR_PROPOSAL_UPDATE`). El código MUST NOT usar strings literales duplicados dispersos para el mismo tipo.

#### Scenario: Tipo conocido en creación

- **WHEN** se emite una notificación por nueva postulación
- **THEN** el campo `type` MUST ser `PROPOSAL_RECEIVED` del catálogo centralizado

### Requirement: Notificación al owner cuando otro usuario postula

Cuando un usuario autenticado distinto del owner crea exitosamente una propuesta/postulación sobre una solicitud abierta, el sistema MUST crear una notificación para el `recipientId` igual al `ownerUserId` de esa solicitud, con `entityType` que permita navegar al recurso (p. ej. `open_request`) y `entityId` igual al identificador de la solicitud.

#### Scenario: Postulación exitosa notifica al owner

- **WHEN** el usuario B crea una propuesta válida sobre una solicitud cuyo owner es el usuario A
- **THEN** el sistema MUST persistir una notificación con `recipientId` = A y `type` = `PROPOSAL_RECEIVED`
- **AND** `entityId` MUST identificar la solicitud postulada

#### Scenario: Auto-postulación no genera notificación

- **WHEN** el usuario intenta postular a su propia solicitud
- **THEN** la operación MUST fallar según reglas existentes
- **AND** MUST NOT crearse notificación para ese intento

#### Scenario: Actor no recibe notificación por su propia acción

- **WHEN** el usuario B postula a una solicitud de A
- **THEN** MUST NOT crearse notificación con `recipientId` = B para ese evento

### Requirement: Creación de notificación no bloquea el flujo principal

Si la persistencia de la notificación falla después de que la acción de negocio principal (p. ej. crear propuesta) haya tenido éxito, el sistema MUST completar la respuesta exitosa de la acción principal y MUST NOT revertir la propuesta creada por ese fallo. Los errores de notificación MUST registrarse para diagnóstico.

#### Scenario: Fallo al guardar notificación

- **WHEN** la propuesta se crea correctamente pero falla el guardado de la notificación
- **THEN** el cliente MUST recibir la respuesta exitosa de creación de propuesta
- **AND** el error de notificación MUST quedar registrado en logs del servidor

### Requirement: Deduplicación de notificaciones por evento

El sistema MUST evitar notificaciones duplicadas para el mismo evento lógico (p. ej. misma propuesta o misma combinación solicitud + actor). La implementación MUST usar un mecanismo determinista (`dedupKey` o restricción única equivalente).

#### Scenario: Reintento no duplica

- **WHEN** se intenta crear una segunda notificación con el mismo `dedupKey` para el mismo receptor
- **THEN** el sistema MUST mantener una sola notificación para ese evento (ignorar insert duplicado o actualizar según diseño)

### Requirement: API de listado de notificaciones propias

El sistema SHALL exponer `GET /notifications` autenticado que devuelve solo las notificaciones del usuario de sesión, ordenadas por `createdAt` descendente. La respuesta MUST seguir el envoltorio de colección del proyecto (`items` + `meta` cuando aplique paginación).

#### Scenario: Usuario autenticado lista sus notificaciones

- **WHEN** el usuario A solicita `GET /notifications` con sesión válida
- **THEN** la respuesta MUST contener únicamente notificaciones con `recipientId` = A
- **AND** los ítems MUST estar ordenados de más reciente a más antigua

#### Scenario: Usuario sin sesión

- **WHEN** se llama `GET /notifications` sin autenticación válida
- **THEN** el sistema MUST responder con error de autenticación según convención del proyecto

### Requirement: API de conteo de no leídas

El sistema SHALL exponer `GET /notifications/unread-count` autenticado que devuelve el número de notificaciones con `isRead` = false del usuario de sesión.

#### Scenario: Conteo correcto

- **WHEN** el usuario A tiene 3 notificaciones no leídas
- **THEN** `GET /notifications/unread-count` MUST devolver un conteo igual a 3

### Requirement: API para marcar una notificación como leída

El sistema SHALL exponer `PATCH /notifications/:id/read` autenticado. Solo el receptor de la notificación MUST poder marcarla como leída.

#### Scenario: Marcar propia notificación

- **WHEN** el usuario A marca como leída una notificación cuyo `recipientId` es A
- **THEN** `isRead` MUST pasar a `true`
- **AND** el conteo de no leídas MUST disminuir en consultas posteriores

#### Scenario: Marcar notificación ajena

- **WHEN** el usuario B intenta marcar como leída una notificación de A
- **THEN** el sistema MUST denegar la operación (404 u error de autorización según política del proyecto)

### Requirement: API para marcar todas como leídas

El sistema SHALL exponer `PATCH /notifications/read-all` autenticado que marca `isRead` = true en todas las notificaciones no leídas del usuario de sesión.

#### Scenario: Marcar todas

- **WHEN** el usuario A invoca marcar todas como leídas teniendo notificaciones pendientes
- **THEN** todas sus notificaciones MUST quedar con `isRead` = true
- **AND** el conteo de no leídas MUST ser 0

### Requirement: Mensajes sin datos sensibles

Los campos `title` y `message` de una notificación MUST NOT incluir credenciales, tokens, contraseñas ni contenido privado completo de propuestas o mensajes directos. MUST limitarse a texto breve orientado a la acción del usuario.

#### Scenario: Payload de notificación seguro

- **WHEN** se crea una notificación por nueva postulación
- **THEN** el mensaje MUST describir el evento de forma genérica (p. ej. que hay una nueva postulación en su solicitud)
- **AND** MUST NOT incluir el cuerpo completo del mensaje de la propuesta

### Requirement: Retención de notificaciones leídas

Las notificaciones con `isRead` = true MUST eliminarse del almacén cuando hayan transcurrido **24 horas** desde su `updatedAt` (momento en que se marcaron como leídas). Las notificaciones no leídas MUST NOT eliminarse por este mecanismo.

#### Scenario: Notificación leída antigua se purga

- **WHEN** una notificación del usuario A tiene `isRead` = true y `updatedAt` anterior a 24 horas
- **AND** el usuario A lista notificaciones o consulta el conteo de no leídas
- **THEN** esa notificación MUST eliminarse de la persistencia
- **AND** MUST NOT aparecer en listados posteriores

#### Scenario: Notificación leída reciente permanece

- **WHEN** una notificación fue marcada como leída hace menos de 24 horas
- **THEN** MUST permanecer disponible en el listado hasta que expire el plazo

#### Scenario: Notificación no leída no expira por retención

- **WHEN** una notificación tiene `isRead` = false sin importar su antigüedad
- **THEN** MUST NOT eliminarse por la política de retención de leídas
