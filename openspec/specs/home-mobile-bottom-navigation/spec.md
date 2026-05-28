## Purpose

Barra de navegación inferior fija en la vista principal (`/home`) en viewport móvil: tres destinos (Solicitudes, Perfil con login condicional, Ver mapa), estado activo por URL, convivencia con header y menú existentes, y reserva de espacio al contenido.

## Requirements

### Requirement: Alcance y visibilidad por viewport

La aplicación SHALL mostrar una barra de navegación inferior en la **vista de página principal** (`/home`) únicamente cuando el viewport se considere **móvil** según el mismo umbral o convención responsive que usa el shell para cabecera compacta (documentado en implementación, p. ej. ancho máximo 900px). Por encima de ese umbral la barra MUST NOT ocupar espacio ni ser visible.

#### Scenario: Usuario en desktop ancho

- **WHEN** el ancho del viewport supera el umbral definido para “no móvil”
- **THEN** la barra inferior de home MUST NOT ser visible
- **AND** el layout de home SHALL equivaler al actual salvo el padding extra descrito solo para móvil

#### Scenario: Usuario en móvil en home

- **WHEN** el usuario visita `/home` con viewport bajo el umbral móvil
- **THEN** la barra inferior SHALL mostrarse fija en el borde inferior del viewport

### Requirement: Composición fija de la barra

La barra SHALL contener exactamente **tres** acciones visibles, en orden: **Solicitudes**, **Perfil**, **Ver mapa**, cada una con icono y etiqueta de texto legible para uso táctil.

#### Scenario: Conteo de ítems

- **WHEN** la barra está visible
- **THEN** MUST NOT aparecer un cuarto ítem principal en la misma barra
- **AND** cada ítem SHALL tener área táctil acorde a buenas prácticas del proyecto (mínimo coherente con botones existentes)

### Requirement: Navegación a Solicitudes

El ítem **Solicitudes** SHALL navegar al listado/landing de solicitudes abiertas usando la **misma ruta y fragmento** (si aplica) que la navegación principal existente para “Solicitudes” (p. ej. `/solicitudes` con el fragmento usado hoy en el shell para anclar la sección correspondiente).

#### Scenario: Toque en Solicitudes

- **WHEN** el usuario toca Solicitudes
- **THEN** el router SHALL navegar al destino válido existente para solicitudes sin error de ruta

### Requirement: Navegación a Ver mapa

El ítem **Ver mapa** SHALL navegar a la vista donde el usuario accede al mapa o bloque de ubicación en el flujo actual, alineado al destino de **Ubicación** en la navegación principal (p. ej. `/solicitudes` con fragmento `ubicacion`).

#### Scenario: Toque en Ver mapa

- **WHEN** el usuario toca Ver mapa
- **THEN** el router SHALL navegar al destino configurado y, si hay fragmento, el comportamiento de scroll al ancla SHALL ser el mismo que tras navegación desde el header

### Requirement: Navegación a Perfil según autenticación

El ítem **Perfil** SHALL llevar al **perfil del usuario** cuando exista sesión válida, usando la **misma regla de destino** que el shell para enlace de perfil (p. ej. ruta pública con `userId` o `/perfil` según implementación actual). Cuando **no** exista sesión, SHALL iniciar el **flujo de login existente** (p. ej. modal de login o query `login=1` procesada por el shell), **sin** duplicar lógica de comprobación de sesión más allá de leer el estado ya expuesto por el servicio/contexto de auth del front.

#### Scenario: Perfil con sesión

- **WHEN** hay usuario autenticado y el usuario toca Perfil
- **THEN** la aplicación SHALL navegar al destino de perfil coherente con el shell

#### Scenario: Perfil sin sesión

- **WHEN** no hay usuario autenticado y el usuario toca Perfil
- **THEN** la aplicación SHALL presentar el login existente (modal o mecanismo equivalente ya implementado)
- **AND** MUST NOT introducir un flujo de credenciales paralelo al existente

### Requirement: Estado activo por ruta

El ítem cuyo destino coincida con la **URL actual** (ruta y, si aplica, **fragmento**) SHALL mostrarse como **activo** de forma claramente distinguible visualmente, usando APIs del router (p. ej. `RouterLinkActive` o `Router.isActive`) en lugar de inferir el ítem activo solo por el texto del label.

#### Scenario: Usuario en solicitudes con fragmento de mapa

- **WHEN** la URL activa corresponde al destino de Ver mapa (incl. fragmento)
- **THEN** solo el ítem Ver mapa (o el que corresponda exactamente a esa URL) SHALL aparecer como activo

#### Scenario: Usuario en home

- **WHEN** la ruta es únicamente `/home` sin coincidencia con los destinos de los tres ítems
- **THEN** ninguno de los tres ítems SHALL mostrarse como activo, o el criterio de “ninguno activo” SHALL documentarse de forma consistente en código

### Requirement: Contenido no oculto bajo la barra

El layout de la página principal en móvil SHALL reservar espacio inferior (padding, margen o contenedor) de modo que el contenido importante de home **no quede permanentemente oculto** detrás de la barra fija, incluyendo respeto razonable a **safe-area** en dispositivos con barra de inicio del SO si el proyecto ya contempla ese patrón.

#### Scenario: Scroll al final de home en móvil

- **WHEN** el usuario llega al final del contenido de home
- **THEN** el último contenido significativo SHALL ser legible sin quedar tapado por la barra inferior

### Requirement: Convivencia con header y menú existentes

La barra inferior MUST NOT impedir el uso del **header**, del **menú hamburguesa** ni de las acciones ya expuestas en el shell (idioma, “Ver más”, cuenta). Los z-index y el área táctil de la barra SHALL evitar capturar interacciones destinadas al header.

#### Scenario: Header y hamburguesa en móvil

- **WHEN** la barra inferior está visible en un viewport móvil
- **THEN** el usuario SHALL poder abrir y usar el menú hamburguesa como antes
- **AND** MUST NOT aparecer un error de rutas o de plantilla atribuible solo a la presencia de la barra

### Requirement: Sin dependencias nuevas innecesarias

La implementación SHALL reutilizar iconos, tokens CSS y componentes ya presentes en el front. **No** se SHALL añadir librerías de iconos o UI nuevas salvo que el repositorio no ofrezca alternativa viable y quede justificado en revisión.

#### Scenario: Revisión de dependencias

- **WHEN** se completa la implementación
- **THEN** el diff del manifiesto de dependencias (`package.json`) SHOULD no incluir paquetes nuevos solo para esta barra
