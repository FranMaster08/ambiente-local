## Purpose

Definir el comportamiento y los requisitos para que un usuario autenticado pueda consultar las solicitudes abiertas que él mismo publicó, separadas de las solicitudes a las que postuló. Cubre el nuevo endpoint backend `GET /open-requests/mine`, el método de servicio en el front, y la integración mediante tabs en la pantalla `my-requests-dashboard`.

## Requirements

### Requirement: Endpoint `GET /open-requests/mine`
El backend MUST exponer un endpoint `GET /open-requests/mine` autenticado que devuelva, paginadas, únicamente las solicitudes abiertas cuyo `ownerUserId` coincida con el `userId` del usuario en sesión.

#### Scenario: Usuario autenticado obtiene sus solicitudes
- **WHEN** un usuario autenticado realiza `GET /open-requests/mine`
- **THEN** el sistema MUST responder `200 OK`
- **AND** el body MUST seguir el contrato `OpenRequestsListResponseDto` (`items[]`, `meta`, `nextPage`, `hasMore`)
- **AND** `items[]` MUST contener solo solicitudes con `ownerUserId === req.user.userId` que no estén soft-deleted

#### Scenario: Usuario sin autenticación
- **WHEN** un cliente sin Bearer token realiza `GET /open-requests/mine`
- **THEN** el sistema MUST responder `401 Unauthorized`

#### Scenario: Usuario sin solicitudes propias
- **WHEN** el usuario autenticado no ha publicado ninguna solicitud
- **THEN** el sistema MUST responder `200 OK` con `items: []`, `meta.totalItems: 0` y `hasMore: false`

#### Scenario: Paginación respetada
- **WHEN** el usuario realiza `GET /open-requests/mine?page=1&pageSize=20`
- **THEN** el sistema MUST aplicar la misma normalización de `PageRequest` (límites por config) que el endpoint público `GET /open-requests`
- **AND** el orden MUST ser por `publishedAtSort DESC` y, ante empate, por `id ASC`

#### Scenario: Endpoint distinto del detalle por id
- **WHEN** la ruta solicitada es `GET /open-requests/mine`
- **THEN** el sistema MUST resolverla con el handler "list mine" y NO MUST tratarla como `GET /open-requests/:id` con `id="mine"`

### Requirement: El endpoint propio NO MUST exponer datos de otros usuarios
El handler de `GET /open-requests/mine` MUST filtrar siempre en el repositorio por `ownerUserId === req.user.userId`, ignorando cualquier query string que intente sobreescribir ese filtro.

#### Scenario: Intento de override por query param
- **WHEN** un usuario autenticado realiza `GET /open-requests/mine?ownerUserId=<otro-id>`
- **THEN** el sistema MUST devolver únicamente las solicitudes del usuario en sesión, ignorando el query param

### Requirement: `OpenRequestsService.listMyOpenRequests`
El frontend MUST exponer en `OpenRequestsService` un método `listMyOpenRequests(params): Observable<OpenRequestsListResponse>` que consume `GET /open-requests/mine` y normaliza los items con la misma lógica que `listOpenRequests`.

#### Scenario: Llamada al endpoint correcto
- **WHEN** el componente invoca `listMyOpenRequests({ page: 1, pageSize: 20 })`
- **THEN** el sistema MUST realizar `GET <apiUrl>/mine` con los query params `page` y `pageSize`
- **AND** el sistema MUST devolver el `OpenRequestsListResponse` resultante con los `items` normalizados con `normalizeListItem`

#### Scenario: Modo mock no soporta listado propio
- **WHEN** la URL del API apunta a un mock local (`/mock/`)
- **THEN** el sistema MUST emitir un error con mensaje claro indicando que el listado propio no está disponible en modo mock y NO MUST emitir `GET`

### Requirement: Tab "Publicadas por mí" en `my-requests-dashboard`
La pantalla `my-requests-dashboard` MUST exponer dos pestañas accesibles para el usuario autenticado: "Publicadas por mí" y "Postulé a estas". La pestaña activa por defecto MUST ser "Publicadas por mí" para visibilizar inmediatamente las creaciones del usuario.

#### Scenario: Render inicial muestra ambas pestañas
- **WHEN** un usuario autenticado entra a `/mis-solicitudes`
- **THEN** el sistema MUST renderizar dos tabs visibles ("Publicadas por mí" y "Postulé a estas")
- **AND** la tab "Publicadas por mí" MUST estar activa por defecto

#### Scenario: Cambiar de pestaña
- **WHEN** el usuario activa la pestaña "Postulé a estas"
- **THEN** el sistema MUST mostrar la lista basada en propuestas (comportamiento previo) y MUST mantener la lista de "Publicadas por mí" cargada para alternar instantáneamente

#### Scenario: Cargas independientes por pestaña
- **WHEN** la pantalla se inicializa
- **THEN** el sistema MUST disparar en paralelo la carga de "Publicadas por mí" (`listMyOpenRequests`) y la de "Postulé a estas" (proposals + detalles)
- **AND** cada lista MUST mantener su propio estado UX (`loading`/`success`/`error`) sin bloquear a la otra

#### Scenario: Empty state de "Publicadas por mí"
- **WHEN** el usuario autenticado no tiene solicitudes publicadas
- **THEN** el sistema MUST mostrar un empty state en esa pestaña con un CTA "Publicar solicitud" que navega a `/solicitudes/nueva`

#### Scenario: Item card "publicada"
- **WHEN** la pestaña "Publicadas por mí" tiene al menos una solicitud
- **THEN** cada card MUST mostrar `title`, `excerpt`, `locationLabel`, `budgetLabel`, `publishedAtLabel` (cuando estén presentes)
- **AND** MUST exponer una acción "Ver detalle" que navega a `/solicitudes/<id>`
- **AND** MUST mostrar una badge visual ("Publicada por ti" o equivalente) para diferenciarse de los items de la pestaña "Postulé a estas"

#### Scenario: Sesión inactiva oculta las tabs
- **WHEN** el usuario no tiene sesión iniciada y entra a `/mis-solicitudes`
- **THEN** el sistema MUST NOT renderizar las pestañas y MUST mostrar el bloque "Inicia sesión" actual

#### Scenario: Manejo de error en una pestaña
- **WHEN** la carga de cualquiera de las dos listas falla con un error de backend
- **THEN** el sistema MUST mostrar un estado de error dentro de la pestaña afectada con un botón "Reintentar"
- **AND** la otra pestaña MUST seguir funcionando si su carga fue exitosa

### Requirement: Identidad de usuario navegable en el dashboard de mis solicitudes

La pantalla `my-requests-dashboard` MUST, en cualquier pestaña o lista donde se muestre identidad de usuario (nombre, avatar, username o iniciales) y exista `userId` en el modelo (incluyendo la pestaña “Postulé a estas” y cualquier card que muestre owner o proveedor identificable), proporcionar navegación al perfil correspondiente siguiendo la convención de rutas del proyecto. Los controles MUST cumplir los mismos requisitos de accesibilidad que el patrón compartido de identidad de usuario.

#### Scenario: Pestaña “Publicadas por mí” sin terceros

- **WHEN** la pestaña solo muestra solicitudes del propio usuario sin bloques identitarios de terceros
- **THEN** no se exige mostrar enlaces a perfiles ajenos en esa vista más allá de las acciones ya definidas (p. ej. “Ver detalle”)

#### Scenario: Pestaña “Postulé a estas” con owner o autor identificable

- **WHEN** una fila o card muestra datos de un usuario distinto con `userId` disponible
- **THEN** la UI MUST permitir abrir el perfil de ese usuario mediante navegación activable
- **AND** si el `userId` corresponde al usuario autenticado, la navegación MUST respetar la experiencia de perfil propio

#### Scenario: Accesibilidad en cards

- **WHEN** la identidad se representa principalmente con avatar
- **THEN** el control MUST incluir nombre accesible y foco visible

#### Scenario: CTA explícito “Ver perfil” en postulaciones del dashboard

- **WHEN** el creador expande postulantes en “Publicadas por mí” o el detalle de propuesta en “Postulé a estas” y existe `userId` en la propuesta
- **THEN** la UI MUST ofrecer un enlace visible “Ver perfil” hacia `/usuarios/:userId` además del bloque identitario navegable, sin anidar enlaces
