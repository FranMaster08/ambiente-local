## ADDED Requirements

### Requirement: Panel inferior de comentarios en Home

La vista Home SHALL mostrar un panel superpuesto anclado al borde inferior de la ventana cuando el usuario solicite ver comentarios desde el slider de reels destacados. El panel SHALL ocupar aproximadamente el **50%** de la altura del viewport (`~50vh`, con tope razonable en desktop). El fondo de la página SHALL permanecer visible mediante un overlay semitransparente que indique capa modal sin ocultar por completo el slider.

#### Scenario: Apertura del panel

- **WHEN** Home recibe un evento de acción de slide con `action: 'comment'`
- **THEN** el sistema MUST mostrar el overlay y el panel con animación de aparición desde abajo hacia arriba
- **AND** el panel MUST incluir un encabezado con título accesible «Comentarios»

#### Scenario: Dimensiones y posición

- **WHEN** el panel está abierto en cualquier breakpoint soportado por Home
- **THEN** el panel MUST estar fijado al borde inferior, con ancho completo del viewport en móvil
- **AND** la altura MUST ser aproximadamente `50vh` (o equivalente acotado por CSS del proyecto)

### Requirement: Contenido placeholder y área de lista futura

El panel SHALL reservar un área principal scrollable para la futura lista de comentarios. **WHEN** no existen comentarios reales conectados, el sistema SHALL mostrar un estado vacío con mensaje explícito, por ejemplo: «Aquí se mostrarán los comentarios de esta publicación.»

#### Scenario: Estado vacío

- **WHEN** el panel está abierto y no hay datos de comentarios del backend
- **THEN** el sistema MUST mostrar el título «Comentarios» y el texto placeholder de estado vacío
- **AND** MUST NOT mostrar datos ficticios como si fueran comentarios reales de usuarios

#### Scenario: Área preparada para lista

- **WHEN** el panel está abierto
- **THEN** el sistema MUST renderizar un contenedor dedicado (p. ej. región con scroll) donde en el futuro se insertará la lista de comentarios sin reestructurar el layout del encabezado

### Requirement: Cierre del panel

El usuario SHALL poder cerrar el panel de forma explícita. El cierre MUST eliminar overlay y panel de la interacción sin errores en consola.

#### Scenario: Cerrar con botón X

- **WHEN** el usuario activa el control de cierre en el encabezado del panel
- **THEN** el panel y el overlay MUST ocultarse

#### Scenario: Cerrar con clic fuera

- **WHEN** el usuario hace clic en el overlay fuera del panel
- **THEN** el panel MUST cerrarse (mismo comportamiento que patrones de overlay del proyecto)

#### Scenario: Cerrar con Escape

- **WHEN** el panel está abierto y el usuario pulsa la tecla Escape
- **THEN** el panel MUST cerrarse

#### Scenario: Animación de salida

- **WHEN** el panel se cierra
- **THEN** la transición MUST ser perceptiblemente limpia (reversión de la animación de entrada o desmontaje tras transición CSS)

### Requirement: Accesibilidad mínima del panel

El panel MUST exponer semántica de diálogo modal: `role="dialog"`, `aria-modal="true"`, etiqueta o título asociado, y botón de cierre con `aria-label` descriptivo (p. ej. «Cerrar comentarios»).

#### Scenario: Lector de pantalla

- **WHEN** el panel se abre
- **THEN** el contenedor del panel MUST ser identificable como diálogo modal con nombre «Comentarios»
