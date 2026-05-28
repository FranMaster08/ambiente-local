## ADDED Requirements

### Requirement: Campanita visible solo para usuarios autenticados

El header global de la aplicación SHALL mostrar un control de campanita de notificaciones únicamente cuando exista sesión de usuario autenticada. Los visitantes sin sesión MUST NOT ver notificaciones privadas ni el indicador de no leídas.

#### Scenario: Usuario autenticado ve la campanita

- **WHEN** el usuario tiene sesión activa en el shell
- **THEN** el header MUST mostrar el control de campanita en `headerTrailing` (barra sticky, junto al menú hamburguesa en vista compacta)

#### Scenario: Visitante no ve campanita privada

- **WHEN** no hay sesión activa
- **THEN** el control de campanita MUST NOT mostrarse (o MUST NOT cargar datos privados)

### Requirement: Indicador de notificaciones no leídas

Cuando el usuario autenticado tiene notificaciones con `isRead` = false, la campanita MUST mostrar un indicador visual (badge numérico o punto) coherente con el diseño del header. Si el conteo es cero, el indicador MUST NOT mostrarse.

#### Scenario: Hay notificaciones nuevas

- **WHEN** el servicio de notificaciones reporta un conteo mayor que cero
- **THEN** la campanita MUST mostrar el indicador de no leídas
- **AND** si se usa badge numérico, MUST reflejar el conteo (con convención de tope p. ej. 99+ si aplica)

#### Scenario: Todas leídas

- **WHEN** el conteo de no leídas es cero
- **THEN** el indicador MUST NOT ser visible

### Requirement: Panel desplegable con lista de notificaciones

Al activar la campanita, la UI MUST mostrar un panel (dropdown o equivalente) con la lista de notificaciones del usuario. Cada ítem MUST mostrar al menos: título, descripción breve (`message`), fecha o tiempo relativo y distinción visual leído/no leído.

#### Scenario: Abrir campanita con notificaciones

- **WHEN** el usuario hace clic en la campanita
- **THEN** el panel MUST abrirse
- **AND** MUST listar las notificaciones obtenidas del backend ordenadas de más reciente a más antigua

#### Scenario: Lista vacía

- **WHEN** el usuario abre la campanita y no tiene notificaciones
- **THEN** el panel MUST mostrar un mensaje claro equivalente a “No tienes notificaciones”

### Requirement: Estados de carga y error en el panel

Mientras se cargan las notificaciones, el panel MUST mostrar un estado de carga. Si la petición falla, MUST mostrar un estado de error controlado sin romper el header ni la navegación.

#### Scenario: Carga en curso

- **WHEN** el usuario abre el panel y la petición está pendiente
- **THEN** el panel MUST indicar que se están cargando las notificaciones

#### Scenario: Error de red o servidor

- **WHEN** falla la carga de notificaciones
- **THEN** el panel MUST mostrar un mensaje de error comprensible
- **AND** el usuario MUST poder cerrar el panel y seguir usando la aplicación

### Requirement: Navegación al recurso relacionado

Al seleccionar una notificación que incluya `entityType` y `entityId` soportados, la aplicación MUST navegar a la ruta correspondiente. Para `entityType` = `open_request`, MUST navegar al detalle de solicitud (`/solicitudes/:id` o ruta canónica del proyecto).

#### Scenario: Click en notificación de solicitud

- **WHEN** el usuario selecciona una notificación con `entityType` open_request y `entityId` válido
- **THEN** el router MUST navegar al detalle de esa solicitud
- **AND** el panel SHOULD cerrarse tras la navegación

### Requirement: Marcar como leída al interactuar

Al abrir el panel o al seleccionar una notificación no leída, la aplicación MUST marcar como leída según el comportamiento definido en implementación (mínimo: al seleccionar un ítem; MAY marcar al abrir el panel si el producto lo define). Tras marcar, el contador de no leídas MUST actualizarse.

#### Scenario: Seleccionar notificación no leída

- **WHEN** el usuario hace clic en una notificación con `isRead` = false
- **THEN** el cliente MUST invocar el endpoint de marcar como leída
- **AND** el indicador de no leídas MUST reflejar el nuevo conteo

### Requirement: Marcar todas como leídas desde el panel

El panel MUST ofrecer una acción para marcar todas las notificaciones como leídas. Al usarla, el contador MUST pasar a cero y los ítems MUST reflejar estado leído.

#### Scenario: Marcar todas

- **WHEN** el usuario activa “marcar todas como leídas”
- **THEN** el cliente MUST invocar el endpoint correspondiente
- **AND** el badge de no leídas MUST desaparecer o mostrar cero

### Requirement: Icono de campanita en blanco y negro

El control de campanita MUST usar un icono vectorial (SVG) monocromático coherente con el header (`currentColor` / color ink), no un emoji ni asset colorido ajeno al sistema de diseño.

#### Scenario: Apariencia del icono

- **WHEN** el usuario autenticado ve la campanita
- **THEN** el icono MUST renderizarse como trazo SVG en color del texto del header
- **AND** MUST ser legible en desktop y móvil

### Requirement: Funcionamiento responsive en header

La campanita MUST integrarse en `headerTrailing` del shell y MUST ser visible en desktop, tablet y móvil (≤900px) para usuarios autenticados, sin romper idioma, CTA “publicar” ni menú de cuenta.

#### Scenario: Vista desktop

- **WHEN** el viewport está por encima del breakpoint de navegación expandida (~900px)
- **THEN** la campanita MUST aparecer en `headerTrailing` a la derecha del contenido principal del header

#### Scenario: Vista compacta

- **WHEN** el viewport usa menú hamburguesa
- **THEN** la campanita MUST permanecer visible en la barra superior junto al botón hamburguesa
- **AND** MUST NOT quedar oculta solo dentro del drawer móvil

### Requirement: Actualización sin tiempo real obligatorio

En esta versión, el cliente MAY actualizar notificaciones al abrir el panel y mediante refresh controlado (p. ej. al recuperar foco de ventana). No se exige WebSocket ni SSE.

#### Scenario: Refresh al abrir

- **WHEN** el usuario abre la campanita
- **THEN** el cliente MUST solicitar lista y conteo actualizados al backend
