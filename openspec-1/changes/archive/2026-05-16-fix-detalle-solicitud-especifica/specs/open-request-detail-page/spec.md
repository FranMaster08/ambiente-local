## MODIFIED Requirements

### Requirement: Header de detalle con metadatos y CTAs de contacto

El detalle MUST mostrar un header con metadatos (p. ej. título/extracto, ubicación, tags, fecha, presupuesto) y acciones de producto acotadas.

La meta de fecha MUST mostrar antigüedad relativa coherente con la publicación real (p. ej. “Hace 1 día”), usando `publishedAtLabel` del modelo ya recalculado por el API.

El header MUST NOT incluir los CTAs **“Ver perfil”** ni **“Contactar”** en esta entrega. El acceso al perfil del creador MUST concentrarse en la sección **“Publicado por”**. Para visitantes que no son el creador, el header MAY mostrar únicamente **“Postular”** (acción que lleva al módulo de postulación en el sidebar).

#### Scenario: Usuario ve metadatos y CTA de postulación

- **WHEN** la página de detalle está renderizada y el usuario no es el creador
- **THEN** el sistema MUST mostrar metadatos clave y MAY mostrar el CTA “Postular”
- **AND** MUST NOT mostrar “Ver perfil” ni “Contactar” en el header
- **AND** la etiqueta de antigüedad MUST NOT quedar fija en “Recién publicado” para solicitudes antiguas

#### Scenario: Creador no ve CTA Postular en header

- **WHEN** el usuario autenticado es el creador de la solicitud
- **THEN** el header MUST NOT mostrar el CTA “Postular”

### Requirement: Sección “Ofrecido por” con reputación y comentarios

El detalle MUST mostrar una sección de **publicador** (“Publicado por”) con la identidad del usuario creador cuando `ownerUserId` esté disponible, mediante el patrón compartido de enlace a perfil. El nombre visible MUST obtenerse del perfil público del usuario (`GET /users/profile/:userId`, campo `fullName`) cuando la petición tenga éxito. Reputación, cantidad de reseñas y comentarios ficticios del objeto `provider` MUST NOT mostrarse como datos reales cuando correspondan a valores demo del backend.

#### Scenario: Usuario ve nombre real del publicador

- **WHEN** el detalle incluye `ownerUserId` y el perfil público responde con `fullName`
- **THEN** el sistema MUST mostrar ese nombre en el bloque identitario enlazado al perfil
- **AND** MUST NOT mostrar únicamente el texto genérico “Publicador” si el perfil está disponible

#### Scenario: Usuario ve identidad del publicador enlazable

- **WHEN** el detalle incluye `ownerUserId`
- **THEN** el sistema MUST ofrecer navegación a `/usuarios/:userId` desde la sección “Publicado por”
- **AND** MUST NOT mostrar el bloque demo `provider` (p. ej. “Cliente” / “NUEVO”) como sustituto del publicador

#### Scenario: Usuario ve reputación del oferente solo con datos reales

- **WHEN** el detalle tiene datos de reputación verificables del publicador (contrato futuro o señal explícita no demo)
- **THEN** el sistema MAY mostrar rating y reseñas en la card del publicador

#### Scenario: Usuario ve comentarios

- **WHEN** el detalle incluye `providerReviews` con datos reales no demo
- **THEN** el sistema MUST renderizar la lista de comentarios con autor, rating (si existe) y fecha (si existe)

### Requirement: Descripción larga

El detalle MUST mostrar una descripción larga (mínimo 100 caracteres cuando exista) en la sección “Descripción”, usando `description` si está disponible y haciendo fallback a `excerpt`.

La UI MUST NOT mostrar el UUID técnico (`id`) de la solicitud en la sección de descripción ni en el flujo de éxito del detalle.

#### Scenario: Usuario lee descripción sin identificadores internos

- **WHEN** el detalle se renderiza en estado exitoso
- **THEN** la sección Descripción MUST mostrar solo contenido legible para el usuario final
- **AND** MUST NOT incluir una línea `ID: {uuid}`

## ADDED Requirements

### Requirement: Composición responsive del detalle

El layout del detalle (header, galería, cards de contenido, sidebar de postulación) MUST adaptarse sin overflow horizontal ni solapamientos en viewports móvil, tablet y desktop. La columna principal (`main`) MUST usar espaciado vertical consistente entre bloques (p. ej. gap ≥ 16px) de modo que **Descripción** y **Publicado por** se perciban como secciones separadas.

#### Scenario: Vista móvil apilada

- **WHEN** el viewport es estrecho (p. ej. ≤ 640px)
- **THEN** header, galería, contenido y sidebar MUST apilarse en un orden legible
- **AND** los CTAs del header MUST permanecer usables sin desbordar el ancho

#### Scenario: Separación entre Descripción y Publicado por

- **WHEN** el detalle muestra ambas secciones
- **THEN** MUST existir separación visual clara (espacio vertical) entre la card de Descripción y la card de Publicado por

#### Scenario: Vista desktop con sidebar

- **WHEN** el viewport es amplio
- **THEN** el sidebar de postulación MUST mantenerse visible según el patrón sticky existente sin tapar el contenido principal

### Requirement: Visibilidad de postulantes solo para el creador autenticado

El detalle MUST mostrar la sección de postulantes recibidos solo al creador autenticado de la solicitud, únicamente mientras la lista está cargando o se cargó con éxito. MUST NOT mostrar la tarjeta por errores de autenticación/autorización del API de propuestas (p. ej. mensaje “No autenticado.”).

#### Scenario: Visitante no ve postulantes

- **WHEN** el visitante abre `/solicitudes/:id` sin ser el owner
- **THEN** MUST NOT existir bloque “Postulantes” en el DOM renderizado

#### Scenario: Error de autenticación al listar postulaciones

- **WHEN** el creador autenticado en cliente solicita postulaciones y el API responde 401 o 403
- **THEN** MUST NOT renderizarse la tarjeta “Postulantes” con el mensaje de error del API
