## Purpose

Contrato del cliente Angular con el backend para **solicitudes abiertas** y **propuestas**: envoltorios de listado, creación de propuestas (usuario desde sesión), multipart para crear/editar solicitudes y documentación alineada.

## Requirements

### Requirement: Proposals list response envelope

El cliente Angular SHALL interpretar las respuestas exitosas de `GET /proposals` como un objeto JSON con al menos `items` (lista de propuestas) y `meta` (metadatos de paginación coherente con el backend, incluyendo información de página siguiente/anterior).

#### Scenario: Listado utiliza items y puede usar meta

- **WHEN** el cliente recibe `200` de `GET /proposals` con cuerpo que incluye `items` y `meta`
- **THEN** el cliente SHALL construir la lista de propuestas a partir de `items` y MAY usar `meta` (p. ej. `nextPage`, `hasNextPage`) para decisiones de paginación o “cargar más”

### Requirement: Proposal creation contract

El cliente SHALL enviar `POST /proposals` con cuerpo JSON compatible con el DTO de creación del backend: `requestId`, `authorName`, `authorSubtitle`, `whoAmI`, `message`, `estimate` (campos requeridos salvo evolución documentada del API). El usuario postulante MUST identificarse mediante la **sesión** (`Authorization: Bearer`); el cuerpo MUST NOT incluir `userId` (el servidor lo deriva del token).

El cliente SHALL aceptar respuesta `201 Created` (y MAY aceptar `200` si el servidor lo devuelve en despliegues legados) con cuerpo que corresponde al modelo de propuesta persistida, incluyendo `author` anidado con `name` y `subtitle` requeridos en el contrato del API.

#### Scenario: Respuesta de creación se mapea al modelo de dominio

- **WHEN** el servidor responde tras crear una propuesta con un cuerpo JSON alineado a `ProposalDto`
- **THEN** el cliente SHALL mapearlo al tipo de dominio `Proposal` sin asumir formatos obsoletos (p. ej. arreglos planos en lugar de objeto de propuesta)

### Requirement: Open request create and patch transport

Para `POST /open-requests` y `PATCH /open-requests/:id`, el cliente SHALL usar peticiones compatibles con el controlador que aplica `FilesInterceptor('files', 6)`:

- contenido multipart (`multipart/form-data`) cuando corresponda publicar o adjuntar imágenes como archivos;
- partes de archivo usando el nombre de campo esperado **`files`** (hasta 6 ficheros por petición según el backend);
- campos escalares y colecciones del DTO enviados de forma que el backend pueda aplicar sus reglas de validación y `@Transform` (incluyendo campos opcionales como `imageUrl` / `imageAlt` / `images` según producto).

#### Scenario: Crear solicitud con archivos adjuntos

- **WHEN** el usuario publica una solicitud incluyendo imágenes locales seleccionadas en el cliente
- **THEN** el cliente SHALL enviar `POST /open-requests` como multipart con esos ficheros en `files` más los campos requeridos del formulario traducidos al contrato del API

#### Scenario: Actualizar solicitud existente con multipart

- **WHEN** un usuario autenticado con permiso de actualización modifica una solicitud abierta existente
- **THEN** el cliente SHALL llamar `PATCH /open-requests/{id}` con payload multipart acorde al DTO parcial esperado por el backend y SHALL mapear la respuesta al modelo `OpenRequestDetail` del front

### Requirement: Detalle de solicitud usa ownerUserId como identidad del publicador

El cliente Angular MUST tratar `ownerUserId` del detalle como la identidad del usuario que publicó la solicitud. La UI del detalle MUST NOT presentar el objeto `provider` del DTO (valores demo como `Cliente` / `NUEVO`) como si fuera el publicador real cuando `ownerUserId` esté disponible.

#### Scenario: Detalle con ownerUserId muestra publicador enlazable

- **WHEN** `GET /open-requests/{id}` devuelve `ownerUserId` no vacío
- **THEN** el detalle MUST mostrar una sección de publicador basada en ese identificador
- **AND** MUST ofrecer navegación al perfil público del usuario (`/usuarios/:userId`) mediante el patrón compartido de identidad

#### Scenario: Nombre del publicador desde perfil público

- **WHEN** el detalle tiene `ownerUserId` y `GET /users/profile/:userId` responde con `fullName`
- **THEN** el cliente MUST mostrar `fullName` como nombre del publicador en la UI
- **AND** MUST NOT depender del objeto `provider` del open-request para el nombre cuando el perfil está disponible

#### Scenario: Detalle sin ownerUserId no inventa publicador demo

- **WHEN** la respuesta no incluye `ownerUserId` utilizable
- **THEN** el cliente MUST NOT mostrar datos demo de `provider` como identidad verídica del publicador
- **AND** MUST mostrar un estado degradado documentado (p. ej. publicador no disponible)

### Requirement: Open request read endpoints alignment

El cliente SHALL seguir consumiendo `GET /open-requests` (público), `GET /open-requests/mine` (autenticado) y `GET /open-requests/{id}` (público) con los parámetros de query soportados por el backend (`page`, `pageSize`, `sort` donde aplique), y SHALL normalizar las respuestas de listado y detalle a los modelos de dominio existentes del front sin perder campos requeridos por la UI (p. ej. `images` como arreglo, `ownerUserId` cuando el API lo exponga).

El campo `publishedAtLabel` recibido en listado y detalle MUST interpretarse como etiqueta de antigüedad relativa calculada por el servidor a partir de la fecha real de publicación, no como texto estático de creación.

#### Scenario: Detalle por id

- **WHEN** el cliente solicita el detalle de una solicitud por id
- **THEN** el cliente SHALL interpretar la respuesta como `OpenRequestDetailDto` compatible y SHALL producir un `OpenRequestDetail` con reglas de fallback documentadas en implementación (títulos, excerpt, imágenes)
- **AND** MUST preservar `ownerUserId` para la sección de publicador

#### Scenario: Listado muestra antigüedad coherente

- **WHEN** el cliente renderiza cards de listado con `publishedAtLabel`
- **THEN** la etiqueta MUST reflejar la antigüedad relativa coherente con la fecha de publicación de cada ítem

### Requirement: Navegación a perfil desde vistas que consumen propuestas y solicitudes abiertas

El cliente Angular MUST, en las vistas de listado y detalle relacionadas con solicitudes abiertas y propuestas, renderizar como **navegación al perfil** (según la convención de rutas del proyecto) el nombre, avatar o bloque identitario de todo usuario cuyo `userId` esté disponible en el modelo de presentación (incluyendo objetos anidados como `author` o equivalentes documentados). La implementación MUST reutilizar el patrón compartido de identidad de usuario cuando exista y MUST NOT exponer datos privados adicionales obtenidos fuera del contrato público.

En el detalle de solicitud abierta, el bloque de publicador MUST usar `ownerUserId` del detalle, no el nombre del objeto `provider`.

#### Scenario: Listado de propuestas con autor identificable

- **WHEN** un ítem de propuesta incluye `userId` del autor o postulante en el modelo del cliente
- **THEN** la UI MUST ofrecer un control que navegue al perfil de ese `userId` al activarlo
- **AND** la interactividad MUST ser perceptible sin depender exclusivamente del color

#### Scenario: Detalle de solicitud con owner u otros usuarios visibles

- **WHEN** el detalle de una solicitud abierta muestra identidad del owner u otros participantes con `userId` en el modelo
- **THEN** la UI MUST permitir la misma navegación coherente al perfil
- **AND** el teclado MUST poder activar la navegación con foco visible

#### Scenario: Modelo sin userId

- **WHEN** el modelo no incluye `userId` para una fila que muestra solo texto libre de autor
- **THEN** el equipo MUST registrar la brecha en el inventario de tareas y MUST ampliar el contrato API o el mapeo del cliente antes de simular un enlace con datos insuficientes

### Requirement: Documentación de contratos en el front

El proyecto del front SHALL mantener documentación actualizada (p. ej. `anyjobs-front/anyjobs/docs/ENDPOINTS_Y_CONTRATOS_API.md`) que refleje los envoltorios reales (`items`+`meta` para propuestas, multipart para creación/edición de open requests, códigos HTTP de creación, filtro `requestId` en listados de propuestas solo para el dueño) para que implementaciones futuras no reintroduzcan contratos obsoletos.

#### Scenario: Payloads reflejan el API actual

- **WHEN** un desarrollador consulta la documentación de contratos del front
- **THEN** la documentación SHALL describir la forma de las peticiones y respuestas alineada con el backend descrito en este cambio

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

### Requirement: Modelo de solicitud incluye lifecycleStatus

El cliente Angular MUST mapear el campo `lifecycleStatus` (`ACTIVE` | `CANCELLED`) en `OpenRequestDetail` y en ítems de listado propio (`GET /open-requests/mine`) cuando el API lo exponga. Si el campo está ausente en respuestas legacy, el cliente MUST asumir `ACTIVE`.

#### Scenario: Detalle con solicitud cancelada

- **WHEN** `GET /open-requests/{id}` devuelve `lifecycleStatus` = `CANCELLED` para una lectura permitida
- **THEN** el modelo `OpenRequestDetail` del cliente MUST exponer `lifecycleStatus` = `CANCELLED` a los componentes

#### Scenario: Listado mine con solicitud cerrada

- **WHEN** `GET /open-requests/mine` incluye un ítem con `lifecycleStatus` = `CANCELLED`
- **THEN** el normalizador de listado MUST preservar ese valor para la UI de Mis solicitudes

### Requirement: Servicio de cancelación de solicitud

El cliente MUST exponer en `OpenRequestsService` un método `cancelOpenRequest(id: string)` que invoca `POST <apiUrl>/{id}/cancel` con autenticación Bearer y maneja errores con el mismo mecanismo que otras mutaciones del módulo.

#### Scenario: Llamada exitosa

- **WHEN** el titular invoca `cancelOpenRequest(id)` sobre una solicitud activa
- **THEN** el cliente MUST enviar `POST` al path `/cancel` del recurso
- **AND** MUST completar el observable sin error ante `200`

#### Scenario: Error de autorización

- **WHEN** el servidor responde `403` o `404`
- **THEN** el cliente MUST propagar el error para que la UI muestre feedback acorde

### Requirement: Etiquetas UI de lifecycleStatus

El cliente MUST centralizar el mapeo de etiquetas visibles en español según contexto:

- Pestaña «Publicadas por mí»: `ACTIVE` → «Activo», `CANCELLED` → «Cerrado»
- Pestaña «Postulé a estas» (solicitud padre): `CANCELLED` → «Cancelada» en chip de estado de la card; `ACTIVE` mantiene «Enviada» para la propuesta del usuario

#### Scenario: Chip en publicadas

- **WHEN** se renderiza una card en «Publicadas por mí» con `lifecycleStatus` = `ACTIVE`
- **THEN** la chip visible MUST ser «Activo»

#### Scenario: Chip cerrado en publicadas

- **WHEN** se renderiza una card con `lifecycleStatus` = `CANCELLED`
- **THEN** la chip visible MUST ser «Cerrado»

### Requirement: Acciones condicionadas en Mis solicitudes para canceladas

En la pestaña «Postulé a estas», cuando la solicitud asociada a la propuesta tiene `lifecycleStatus` = `CANCELLED`, el cliente MUST ocultar los controles «Ver detalle» y «Ver mi propuesta» / «Ocultar mi propuesta» y MUST mantener el ítem en la lista.

#### Scenario: Sin navegación a detalle desde applied cancelada

- **WHEN** el ítem applied tiene solicitud `CANCELLED`
- **THEN** MUST NOT renderizarse el enlace a `/solicitudes/:id` en acciones de la card

### Requirement: Contador de postulantes en detalle del owner

En `open-request-detail`, cuando el usuario es el owner de la solicitud, el cliente MUST cargar las propuestas de la solicitud (`ProposalsService.listByRequest`) para mostrar el contador en el primer botón del sidebar.

#### Scenario: Etiqueta con contador

- **WHEN** el owner abre el detalle y existen 3 propuestas
- **THEN** el control primario MUST mostrar «Ver postulantes (3)»

#### Scenario: Cero postulantes deshabilitado

- **WHEN** el owner abre el detalle y no hay propuestas
- **THEN** el control primario MUST mostrar «Sin postulantes aún» deshabilitado

#### Scenario: Detalle cancelado con Bearer

- **WHEN** el owner o postulante solicita detalle de solicitud `CANCELLED` con token en el interceptor
- **THEN** `getOpenRequestDetail` MUST recibir `lifecycleStatus` = `CANCELLED` (no error 404 por falta de sesión en ruta pública)
