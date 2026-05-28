## MODIFIED Requirements

### Requirement: Las acciones principales SHALL depender del modo de visibilidad

En modo **propio**, la interfaz SHALL ofrecer al menos el enlace a **Mis solicitudes** en el pie de acciones del hero cuando el producto lo mantenga, y SHALL ofrecer además un control **«Editar perfil»** que abre el flujo de edición del perfil propio. **SHALL NOT** exigir que logout o “ver solicitudes abiertas” estén duplicados en el perfil si ya existen en la navegación global. En modo **público**, SHALL ofrecerse acciones no invasivas alineadas al dominio (p. ej. ver solicitudes abiertas, inicio) según existan; SHALL NOT mostrarse controles de edición del perfil ajeno.

#### Scenario: Modo propio con editar perfil

- **WHEN** el usuario está en modo perfil **propio**
- **THEN** el sistema SHALL mostrar el botón «Editar perfil» junto a las acciones del hero

#### Scenario: Modo propio sin duplicar logout en el pie

- **WHEN** el usuario está en modo perfil **propio**
- **THEN** el sistema MAY omitir el botón de logout en el pie del perfil **si** el cierre de sesión sigue disponible en el menú de cuenta / header

#### Scenario: Modo público sin permiso de edición

- **WHEN** el modo es público
- **THEN** el sistema SHALL NOT renderizar botones o enlaces que modifiquen datos del usuario titular, incluido «Editar perfil»

### Requirement: La cabecera del perfil SHALL presentar identidad con fallbacks seguros

La cabecera SHALL incluir avatar o iniciales derivadas del **nombre visible** (`displayName` si existe, si no `fullName`), nombre visible, identificador público (username u homólogo) si existe en el modelo, ubicación si existe, y bio o descripción corta si existe. Si falta imagen, SHALL usarse iniciales u otro fallback visual consistente con el sistema de diseño.

#### Scenario: Nombre visible con displayName

- **WHEN** el perfil incluye `displayName` no vacío
- **THEN** la cabecera SHALL mostrar `displayName` como título principal y las iniciales SHALL derivarse de ese valor

#### Scenario: Usuario sin imagen de avatar

- **WHEN** el perfil no incluye URL o recurso de avatar
- **THEN** el sistema SHALL mostrar iniciales u placeholder aprobado por diseño sin dejar un hueco roto

#### Scenario: Usuario sin bio

- **WHEN** el perfil no incluye bio o descripción
- **THEN** el sistema SHALL mostrar un placeholder textual neutro (p. ej. indicación de que no hay descripción) sin inventar contenido

#### Scenario: Usuario sin username público

- **WHEN** no existe username en los datos del perfil
- **THEN** el sistema SHALL omitir o sustituir el bloque de username sin romper el layout
