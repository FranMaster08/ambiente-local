## MODIFIED Requirements

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
- **AND** MUST mostrar una chip de estado según `lifecycleStatus`: «Activo» si `ACTIVE`, «Cerrado» si `CANCELLED`
- **AND** MUST NOT mostrar la chip fija «Publicada por ti»

#### Scenario: Sesión inactiva oculta las tabs
- **WHEN** el usuario no tiene sesión iniciada y entra a `/mis-solicitudes`
- **THEN** el sistema MUST NOT renderizar las pestañas y MUST mostrar el bloque "Inicia sesión" actual

#### Scenario: Manejo de error en una pestaña
- **WHEN** la carga de cualquiera de las dos listas falla con un error de backend
- **THEN** el sistema MUST mostrar un estado de error dentro de la pestaña afectada con un botón "Reintentar"
- **AND** la otra pestaña MUST seguir funcionando si su carga fue exitosa

## ADDED Requirements

### Requirement: Pestaña "Postulé a estas" refleja solicitud cancelada

Cuando el detalle o datos agregados de la solicitud asociada a una postulación indiquen `lifecycleStatus` = `CANCELLED`, la card en la pestaña «Postulé a estas» MUST reflejar el cierre sin eliminar el ítem del listado.

#### Scenario: Chip Cancelada en lugar de Enviada

- **WHEN** el usuario ve una postulación cuya solicitud padre está `CANCELLED`
- **THEN** la chip de estado MUST mostrar «Cancelada» y MUST NOT mostrar «Enviada»
- **AND** el badge del panel expandido de propuesta MUST ser coherente (p. ej. «Cancelada» en lugar de «Enviada»)

#### Scenario: Acciones ocultas en solicitud cancelada

- **WHEN** la solicitud asociada está `CANCELLED`
- **THEN** la UI MUST NOT mostrar el enlace «Ver detalle»
- **AND** MUST NOT mostrar el botón «Ver mi propuesta» ni «Ocultar mi propuesta»
- **AND** el artículo MUST permanecer visible en la lista como registro histórico

#### Scenario: Postulación activa mantiene acciones habituales

- **WHEN** la solicitud asociada está `ACTIVE`
- **THEN** la UI MUST mantener las acciones «Ver detalle» y «Ver mi propuesta» / «Ocultar mi propuesta» según el comportamiento previo
- **AND** la chip MUST mostrar «Enviada» para la propuesta enviada

#### Scenario: Card applied sin miniatura ocupa ancho completo

- **WHEN** un ítem en «Postulé a estas» no tiene imagen de solicitud en la card
- **THEN** el layout MUST usar una sola columna de contenido (sin reservar columna fija de thumbnail vacía)
- **AND** título, chips y metadatos MUST ser legibles a ancho completo del contenedor
