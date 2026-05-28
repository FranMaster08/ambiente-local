## ADDED Requirements

### Requirement: Identidad del usuario autenticado fuera del formulario es navegable

Si la pantalla “Publicar solicitud” (`/solicitudes/nueva`) muestra explícitamente nombre, avatar o username del usuario autenticado fuera de los campos editables del formulario (p. ej. cabecera contextual o barra superior de identidad), ese bloque MUST permitir navegar al perfil propio según la convención del proyecto y MUST ser accesible por teclado con foco visible.

#### Scenario: Bloque identitario con sesión activa

- **WHEN** la pantalla renderiza un bloque con datos de la sesión que incluyen `userId`
- **THEN** el bloque MUST actuar como enlace o botón de navegación al perfil propio
- **AND** MUST incluir soporte de teclado equivalente a otras referencias de usuario

#### Scenario: Sin bloque identitario

- **WHEN** la pantalla no muestra identidad fuera del formulario
- **THEN** este requisito no impone nuevos elementos de UI
