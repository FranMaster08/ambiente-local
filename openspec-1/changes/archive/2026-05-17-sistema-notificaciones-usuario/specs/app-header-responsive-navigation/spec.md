## ADDED Requirements

### Requirement: Campanita de notificaciones en el header

El header global SHALL incluir un control de campanita de notificaciones para usuarios autenticados, integrado en `headerTrailing` (visible en todos los breakpoints), sin eliminar ni desplazar de forma incorrecta el selector de idioma, el CTA de publicación ni el menú de cuenta.

#### Scenario: Header desktop con sesión

- **WHEN** el usuario está autenticado y el viewport muestra la barra de acciones desktop
- **THEN** la campanita MUST ser visible en `headerTrailing`
- **AND** idioma, CTA y menú de cuenta en `headerActions--desktop` MUST seguir siendo utilizables

#### Scenario: Menú compacto con sesión

- **WHEN** el usuario autenticado usa el viewport ≤900px con menú hamburguesa
- **THEN** la campanita MUST permanecer visible en la barra superior (`headerTrailing`)
- **AND** MUST NOT haber dos menús de cuenta desincronizados

#### Scenario: Sin sesión

- **WHEN** no hay usuario autenticado
- **THEN** la campanita de notificaciones privadas MUST NOT mostrarse

### Requirement: Campanita no regresa funciones existentes del header

La integración de la campanita MUST NOT romper los requisitos existentes de breakpoint, panel móvil, accesibilidad del hamburguesa ni validación de calidad del header.

#### Scenario: Regresión tras añadir campanita

- **WHEN** se valida el header en desktop y mobile tras integrar la campanita
- **THEN** navegación principal, idioma, CTA y menú de usuario MUST comportarse según los requisitos previos de este spec
