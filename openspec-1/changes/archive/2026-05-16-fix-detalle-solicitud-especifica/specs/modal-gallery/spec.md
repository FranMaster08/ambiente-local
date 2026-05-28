## MODIFIED Requirements

### Requirement: Navegación dentro del modal (siguiente/anterior)

Si la solicitud tiene múltiples imágenes, el modal de galería MUST permitir navegar entre imágenes (p. ej. “siguiente/anterior”).

Los controles de navegación MUST usar una presentación visual clara: botones iconográficos con área táctil adecuada (mínimo ~44×44px), contador de posición legible (p. ej. `1 / 5`) y contraste suficiente sobre el fondo del modal. MUST NOT depender únicamente de botones de texto plano en una sola fila comprimida.

#### Scenario: Usuario navega a la siguiente imagen

- **WHEN** el modal está abierto y el usuario activa la acción “siguiente”
- **THEN** el sistema MUST mostrar la siguiente imagen de la colección

#### Scenario: Usuario navega con teclado

- **WHEN** el modal está abierto y el usuario presiona flecha derecha o izquierda
- **THEN** el sistema MUST avanzar o retroceder entre imágenes cuando existan múltiples imágenes

#### Scenario: Una sola imagen

- **WHEN** la solicitud tiene una sola imagen
- **THEN** los controles de anterior/siguiente MUST estar deshabilitados u ocultos de forma coherente
- **AND** el contador MUST reflejar `1 / 1`

## ADDED Requirements

### Requirement: Barra de navegación del modal accesible

La barra superior del modal de galería en el detalle MUST exponer nombres accesibles en los controles de navegación (p. ej. `aria-label` “Imagen anterior”, “Imagen siguiente”) y MUST mantener el foco visible al tabular.

#### Scenario: Usuario navega con lector de pantalla

- **WHEN** el modal está abierto
- **THEN** los botones de navegación MUST tener etiquetas accesibles que describan la acción
- **AND** el contador actual MUST ser anunciado en contexto (p. ej. texto visible asociado a la imagen activa)
