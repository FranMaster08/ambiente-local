## ADDED Requirements

### Requirement: Breakpoint y transición entre barra horizontal y menú compacto

La cabecera SHALL mostrar la navegación principal en disposición horizontal cuando el viewport supere el umbral acordado con el sistema de diseño del proyecto, y SHALL conmutar a un patrón menú hamburguesa por debajo de ese umbral, sin romper el layout actual en desktop.

#### Scenario: Viewport ancho (desktop)

- **WHEN** el ancho del viewport está por encima del breakpoint definido para navegación expandida
- **THEN** la cabecera SHALL presentar la navegación principal de forma horizontal como hoy
- **AND** el control de menú hamburguesa MUST NOT ser la única forma de acceder a los enlaces principales (debe permanecer la barra visible o el patrón actual equivalente)

#### Scenario: Viewport estrecho (mobile/tablet)

- **WHEN** el ancho del viewport está por debajo del breakpoint definido
- **THEN** los enlaces principales que no caben en la barra SHALL estar disponibles dentro del panel asociado al menú hamburguesa
- **AND** SHALL existir un control de menú visible y alineado dentro de la cabecera

### Requirement: Contenido del panel móvil alineado a desktop

El panel del menú compacto SHALL incluir las mismas rutas de navegación principal que en desktop: Inicio, Solicitudes, Ubicación y Contacto, en un orden lógico, sin cambiar rutas ni nombres de las entradas respecto al comportamiento actual de la aplicación.

#### Scenario: Usuario abre el menú en vista compacta

- **WHEN** el usuario abre el menú hamburguesa
- **THEN** el panel SHALL listar las cuatro secciones de navegación principal con los mismos destinos que en desktop

#### Scenario: Acciones adicionales del header

- **WHEN** el selector de idioma, la acción “Ver más” o el menú de usuario forman parte del header en el flujo responsive actual
- **THEN** el panel o la cabecera compacta SHALL seguir permitiendo acceder a esas acciones sin duplicar incorrectamente la misma acción en dos lugares simultáneamente visibles de forma confusa (p. ej. dos menús de usuario independientes con estado desincronizado)

### Requirement: Coherencia visual con el sistema de diseño

El panel desplegable del menú hamburguesa SHALL usar colores, bordes, radios de borde, sombras, espaciados y tipografía coherentes con los componentes y tokens ya empleados en la aplicación, de modo que se perciba como extensión natural de la cabecera.

#### Scenario: Usuario compara header y panel

- **WHEN** el panel está abierto
- **THEN** la apariencia del panel MUST NOT parecer un estilo improvisado claramente distinto al resto de la UI (contraste, jerarquía tipográfica y espaciado alineados al tema)

### Requirement: Interacción de apertura y cierre

El menú SHALL abrirse y cerrarse de forma fiable. SHALL cerrarse al seleccionar una opción de navegación. SHOULD cerrarse al activar interacción fuera del panel si el stack tecnológico y el patrón de componentes del proyecto lo permiten sin efectos secundarios.

#### Scenario: Navegación desde el panel

- **WHEN** el usuario elige un enlace de navegación dentro del panel
- **THEN** el panel SHALL cerrarse (o dejar de estar visible) antes o al completar la navegación, según el router o framework

#### Scenario: Clic fuera (si aplica)

- **WHEN** el panel está abierto y el usuario hace clic fuera del área del menú
- **THEN** el panel SHALL cerrarse si existe un manejador compatible con la arquitectura actual; si no es viable, el comportamiento SHALL documentarse en implementación y al menos cumplir cierre por selección de ítem y por el control hamburguesa

### Requirement: Usabilidad en dispositivos táctiles y sin solapamientos incorrectos

El menú compacto SHALL ser usable en mobile y tablet (áreas táctiles adecuadas, scroll interno si el contenido excede la altura visible). El panel MUST NOT quedar oculto detrás de controles críticos ni cubrir de forma incorrecta el contenido de forma que impida cerrar o navegar (salvo overlay intencional con fondo semitransparente alineado al diseño existente).

#### Scenario: Lista larga en viewport bajo

- **WHEN** el contenido del panel supera la altura visible
- **THEN** el usuario SHALL poder desplazarse dentro del panel o el contenedor SHALL comportarse como otros menús largos del proyecto

### Requirement: Accesibilidad del control hamburguesa

El botón que abre el menú SHALL tener un `aria-label` descriptivo (o texto visible equivalente) en el idioma de la UI. El estado abierto/cerrado SHALL reflejarse con atributos accesibles apropiados (p. ej. `aria-expanded`) cuando el elemento nativo lo soporte. Los estados interactivos MUST NOT depender únicamente del color para ser distinguibles (p. ej. foco visible, icono o texto de estado).

#### Scenario: Lector de pantalla y teclado

- **WHEN** un usuario de tecnología asistiva enfoca el botón de menú
- **THEN** el nombre y el estado del control SHALL ser anunciados de forma coherente con el patrón del proyecto
- **WHEN** el usuario navega con teclado dentro del panel
- **THEN** el orden de foco SHALL ser lógico y los elementos interactivos SHALL ser enfocables, respetando las limitaciones del marco de trabajo actual

### Requirement: Sin regresiones en funciones existentes del header

Los cambios MUST NOT romper el menú de usuario, el selector de idioma ni la acción “Ver más” en los tamaños donde hoy funcionan. MUST NOT introducir errores de consola atribuibles al nuevo comportamiento del header.

#### Scenario: Regresión visual o funcional

- **WHEN** se valida en desktop, tablet y mobile
- **THEN** idioma, “Ver más” y menú de usuario SHALL comportarse como antes salvo mejoras intencionales de integración visual en el ámbito del header compacto

### Requirement: Validación de calidad de código

Tras la implementación, el contribuidor SHALL ejecutar los comandos de lint, typecheck, build y test definidos en el proyecto para el front afectado, y SHALL corregir fallos introducidos por el cambio.

#### Scenario: CI local o scripts del repo

- **WHEN** se ejecutan los scripts estándar del paquete de front
- **THEN** los comandos SHALL completar sin errores nuevos atribuibles a este cambio
