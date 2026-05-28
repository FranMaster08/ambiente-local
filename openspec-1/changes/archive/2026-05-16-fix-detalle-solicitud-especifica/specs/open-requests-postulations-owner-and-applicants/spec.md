## MODIFIED Requirements

### Requirement: El front-end refleja reglas de negocio y visibilidad para el creador

La interfaz MUST mostrar al creador autenticado de una request la lista (o vista equivalente) de usuarios postulados obtenida del back-end, con indicadores de carga y un estado vacío cuando no haya postulaciones. La acción de postularse MUST estar deshabilitada u oculta cuando el usuario autenticado sea el creador de esa request.

La sección **Postulantes** en el detalle público de una solicitud (`/solicitudes/:id`) MUST renderizarse **únicamente** cuando exista sesión activa, el detalle incluya `ownerUserId` no vacío y ese identificador coincida con el `userId` de la sesión. Visitantes sin sesión y usuarios autenticados que no son el owner MUST NOT ver la sección (ni título, ni estados de carga/vacío/error, ni listado).

#### Scenario: Creador ve postulantes con carga y vacío

- **WHEN** el usuario autenticado es el creador y abre el detalle o vista donde aplica ver postulantes
- **THEN** la UI MUST mostrar estado de carga mientras la petición está en curso
- **AND** si la lista viene vacía, MUST mostrarse un mensaje vacío claro (por ejemplo que aún no hay postulaciones)

#### Scenario: Visitante no ve la sección Postulantes

- **WHEN** un usuario sin sesión o un usuario autenticado distinto del `ownerUserId` abre el detalle de la solicitud
- **THEN** la UI MUST NOT renderizar la sección o tarjeta "Postulantes"
- **AND** MUST NOT invocar el listado privado de postulaciones para esa solicitud

#### Scenario: Fallo de autenticación no expone tarjeta Postulantes

- **WHEN** el cliente del creador recibe 401 o 403 al listar postulaciones de su solicitud en el detalle
- **THEN** la UI MUST NOT mostrar la tarjeta "Postulantes" ni el mensaje de error del API al visitante de la página
- **AND** en 401 SHOULD limpiar la sesión local según el patrón de la aplicación

#### Scenario: Creador no ve acción de postularse en su propia request

- **WHEN** el usuario autenticado es el creador de la request mostrada
- **THEN** el control de “postularse” MUST no estar disponible de la forma primaria prevista para usuarios no creadores (oculto o deshabilitado según patrón del proyecto)

#### Scenario: Error forzado desde el cliente

- **WHEN** el cliente recibe el error del servidor por intento de auto-postulación (p. ej. tras manipulación o condición de carrera)
- **THEN** la UI MUST mostrar un mensaje entendible al usuario, alineado al tratamiento de errores existente

#### Scenario: Identidad del postulante navegable

- **WHEN** el creador visualiza un ítem de postulación con `userId` del postulante y un nombre o avatar visible
- **THEN** la UI MUST permitir abrir el perfil correspondiente mediante la ruta canónica del proyecto
- **AND** el foco MUST ser visible al navegar con teclado

#### Scenario: Avatar como único objetivo visible

- **WHEN** el ítem muestra avatar sin texto enlazado adyacente
- **THEN** el control MUST exponer un nombre accesible que describa el perfil de destino
