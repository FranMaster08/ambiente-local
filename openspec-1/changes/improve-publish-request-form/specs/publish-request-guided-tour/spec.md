## ADDED Requirements

### Requirement: Botón de ayuda visible en el encabezado

La pantalla "Publicar solicitud" MUST mostrar un botón de ayuda accesible cerca del encabezado del formulario (junto al título o subtítulo), visible solo cuando el usuario está autenticado y el formulario está renderizado.

#### Scenario: Usuario autenticado ve el botón de ayuda

- **WHEN** un usuario con sesión activa accede a `/solicitudes/nueva`
- **THEN** el sistema MUST mostrar un control "Ayuda" o equivalente con icono/texto claro
- **AND** el control MUST ser accesible por teclado con foco visible

#### Scenario: Usuario sin sesión no ve el botón de ayuda

- **WHEN** un usuario sin sesión accede a `/solicitudes/nueva`
- **THEN** el sistema MUST NOT mostrar el botón de ayuda del tour (solo el bloque no-auth)

### Requirement: Tour guiado explica los campos del formulario

Al activar el botón de ayuda, el sistema MUST iniciar un tour guiado paso a paso que explique como mínimo: título, resumen corto, descripción, etiquetas, ubicación estructurada, presupuesto, imágenes opcionales y acción de publicar.

#### Scenario: Inicio del tour

- **WHEN** el usuario pulsa el botón de ayuda
- **THEN** el sistema MUST mostrar el primer paso del tour anclado al campo o sección correspondiente
- **AND** MUST permitir avanzar, retroceder y cerrar el tour

#### Scenario: Cerrar tour no altera el formulario

- **WHEN** el usuario cierra el tour en cualquier paso
- **THEN** el sistema MUST detener el tour
- **AND** MUST NOT enviar ni modificar los valores ya escritos en el formulario

#### Scenario: Tour no dispara envío

- **WHEN** el tour está activo
- **THEN** el sistema MUST NOT emitir `POST /open-requests` ni marcar el formulario como enviado

### Requirement: Tour usa librería liviana compatible con el stack

La implementación del tour MUST usar una librería de tours guiados liviana (p. ej. `driver.js`) integrada en el componente standalone, sin modificar estilos globales del design system más allá de los estilos propios del tour.

#### Scenario: Estilos acotados al feature

- **WHEN** el tour se renderiza
- **THEN** los estilos del overlay/popover MUST NOT redefinir tokens globales (`--aj-*`) ni clases base `.btn` fuera del scope del componente de creación
