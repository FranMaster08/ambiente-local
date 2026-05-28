## ADDED Requirements

### Requirement: Identidad de usuario navegable en el dashboard de mis solicitudes

La pantalla `my-requests-dashboard` MUST, en cualquier pestaña o lista donde se muestre identidad de usuario (nombre, avatar, username o iniciales) y exista `userId` en el modelo (incluyendo la pestaña “Postulé a estas” y cualquier card que muestre owner o proveedor identificable), proporcionar navegación al perfil correspondiente siguiendo la convención de rutas del proyecto. Los controles MUST cumplir los mismos requisitos de accesibilidad que el patrón compartido de identidad de usuario.

#### Scenario: Pestaña “Publicadas por mí” sin terceros

- **WHEN** la pestaña solo muestra solicitudes del propio usuario sin bloques identitarios de terceros
- **THEN** no se exige mostrar enlaces a perfiles ajenos en esa vista más allá de las acciones ya definidas (p. ej. “Ver detalle”)

#### Scenario: Pestaña “Postulé a estas” con owner o autor identificable

- **WHEN** una fila o card muestra datos de un usuario distinto con `userId` disponible
- **THEN** la UI MUST permitir abrir el perfil de ese usuario mediante navegación activable
- **AND** si el `userId` corresponde al usuario autenticado, la navegación MUST respetar la experiencia de perfil propio

#### Scenario: Accesibilidad en cards

- **WHEN** la identidad se representa principalmente con avatar
- **THEN** el control MUST incluir nombre accesible y foco visible

#### Scenario: CTA explícito “Ver perfil” en postulaciones del dashboard

- **WHEN** el creador expande postulantes en “Publicadas por mí” o el detalle de propuesta en “Postulé a estas” y existe `userId` en la propuesta
- **THEN** la UI MUST ofrecer un enlace visible “Ver perfil” hacia `/usuarios/:userId` además del bloque identitario navegable, sin anidar enlaces
