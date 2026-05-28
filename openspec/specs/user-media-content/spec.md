## Purpose

Modelo y APIs de **reels de usuario** (`user_reel`): publicación, moderación, listado en perfil público y gestión por el dueño.

## Requirements

### Requirement: El sistema SHALL persistir reels vinculados a un media asset del mismo dueño

Cada `user_reel` SHALL referenciar un `media_asset` existente cuyo `owner_user_id` coincida con el creador del reel.

#### Scenario: Crear reel con asset propio

- **WHEN** un usuario autenticado envía `POST /user-reels` con `mediaAssetId` de un asset que le pertenece
- **THEN** el sistema SHALL crear el reel en estado `moderation_status=pending` y `distribution_status=draft` y SHALL devolver el identificador del reel

#### Scenario: Crear reel con asset ajeno

- **WHEN** el `mediaAssetId` pertenece a otro usuario
- **THEN** el sistema SHALL responder con error de autorización o recurso no encontrado sin revelar existencia del asset ajeno

### Requirement: El dueño SHALL gestionar sus reels

El titular SHALL poder listar todos sus reels (`GET /user-reels/me`), actualizar caption/estados permitidos y eliminar reels propios.

#### Scenario: Listar reels propios

- **WHEN** el dueño solicita `GET /user-reels/me` autenticado
- **THEN** la respuesta SHALL incluir reels en cualquier estado de moderación o distribución que posea

#### Scenario: Eliminar reel propio

- **WHEN** el dueño envía `DELETE /user-reels/:reelId` de un reel suyo
- **THEN** el sistema SHALL eliminar el reel y MAY conservar el asset para auditoría o eliminarlo según política documentada en design

### Requirement: El perfil público SHALL listar solo reels aprobados

`GET /users/:userId/reels` SHALL ser accesible sin autenticación y SHALL devolver únicamente reels con `moderation_status=approved` y que no estén en `distribution_status=draft`.

#### Scenario: Visitante consulta reels de un perfil

- **WHEN** un cliente solicita `GET /users/:userId/reels`
- **THEN** cada ítem SHALL incluir URL de reproducción pública, caption si existe, y metadatos de duración/ratio cuando estén disponibles
- **AND** SHALL NOT incluir reels pendientes, rechazados u ocultos

### Requirement: Publicar un reel SHALL transicionar estados de forma explícita

La acción de publicación (p. ej. `PATCH` con `publish: true`) SHALL establecer `moderation_status=approved` en MVP automático tras validación de asset, y SHALL fijar `published_at` cuando pase a estado visible.

#### Scenario: Publicar reel válido

- **WHEN** el dueño publica un reel cuyo asset está `ready`
- **THEN** el reel SHALL quedar visible en el listado público del perfil tras la transición aprobada
