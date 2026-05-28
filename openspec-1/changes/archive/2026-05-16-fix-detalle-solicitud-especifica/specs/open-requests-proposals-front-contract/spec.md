## ADDED Requirements

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

## MODIFIED Requirements

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
