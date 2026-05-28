## ADDED Requirements

### Requirement: Login modal MUST link to password recovery

When the login modal is open and the user is not authenticated, the system MUST display a visible link or action such as «¿Olvidaste tu contraseña?» that navigates to `/recuperar-contrasena` (without a token query parameter).

#### Scenario: User navigates from login to recovery
- **WHEN** the user opens the login modal and activates the forgot-password link
- **THEN** the application MUST navigate to `/recuperar-contrasena` and MUST close or leave the modal according to existing shell navigation patterns
