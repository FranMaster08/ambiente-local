## MODIFIED Requirements

### Requirement: El front-end refleja reglas de negocio y visibilidad para el creador

La interfaz MUST mostrar al creador autenticado de una request la lista (o vista equivalente) de usuarios postulados obtenida del back-end, con indicadores de carga y un estado vacío cuando no haya postulaciones. La acción de postularse MUST estar deshabilitada u oculta cuando el usuario autenticado sea el creador de esa request.

La sección **Postulantes** en el detalle público de una solicitud (`/solicitudes/:id`) MUST renderizarse **únicamente** cuando exista sesión activa, el detalle incluya `ownerUserId` no vacío y ese identificador coincida con el `userId` de la sesión. Visitantes sin sesión y usuarios autenticados que no son el owner MUST NOT ver la sección (ni título, ni estados de carga/vacío/error, ni listado).

Cuando el contrato de listado incluya el identificador del postulante (`userId` u homónimo documentado), el nombre visible, el avatar (si existe) y el bloque identitario principal de cada postulación MUST permitir la navegación al perfil del usuario referenciado usando la convención de rutas del proyecto, con el mismo criterio de perfil propio frente a público que el resto de la aplicación. Los elementos interactivos MUST ser accesibles por teclado y, si el objetivo clickeable es solo el avatar, MUST incluir un nombre accesible (p. ej. `aria-label`).

En la tarjeta lateral «Tu solicitud» (`#applyCard`) del detalle, cuando el usuario autenticado es el owner, las acciones MUST mostrarse en este orden:

1. **Ver postulantes (N)** — enlace a `/mis-solicitudes?postulantes={id}` si `N ≥ 1`, donde `N` es el número de propuestas de la solicitud obtenido del API de propuestas.
2. **Sin postulantes aún** — botón deshabilitado si `N = 0`.
3. **Volver a Mis solicitudes** — enlace a `/mis-solicitudes`.
4. **Cancelar esta solicitud** — solo si `lifecycleStatus` = `ACTIVE`; abre diálogo «¿Desea cancelar esta solicitud?» con **Sí** / **No**; **Sí** MUST invocar `POST /open-requests/{id}/cancel` y refrescar el detalle al éxito.

Cuando `lifecycleStatus` = `CANCELLED`, MUST NOT mostrarse «Cancelar esta solicitud» y MUST mostrarse copy que indique que la solicitud está cerrada; los controles 1–3 MUST seguir las reglas de `N` y navegación anteriores.

La acción de postularse MUST estar deshabilitada u oculta para visitantes no creadores cuando la solicitud esté `CANCELLED`, además de las reglas existentes para el creador.

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

#### Scenario: Owner ve contador de postulantes

- **WHEN** el owner abre el detalle de su solicitud con 12 propuestas en el API
- **THEN** el primer control MUST mostrar el texto «Ver postulantes (12)»
- **AND** MUST enlazar a Mis solicitudes con query `postulantes` igual al id de la solicitud

#### Scenario: Owner sin postulantes

- **WHEN** el owner abre el detalle y el API devuelve 0 propuestas
- **THEN** el primer control MUST ser un botón deshabilitado con texto «Sin postulantes aún»
- **AND** MUST NOT ser un enlace activo

#### Scenario: Orden de acciones del owner

- **WHEN** el owner ve `#applyCard` en una solicitud `ACTIVE`
- **THEN** el orden visual de controles MUST ser: postulantes → volver a Mis solicitudes → cancelar esta solicitud

#### Scenario: Creador cancela con confirmación

- **WHEN** el owner autenticado pulsa «Cancelar esta solicitud» en una solicitud `ACTIVE`
- **THEN** MUST mostrarse el diálogo «¿Desea cancelar esta solicitud?» con Sí y No
- **AND** al confirmar Sí MUST llamarse el endpoint de cancelación y actualizarse la UI sin el botón de cancelar

#### Scenario: Solicitud cerrada sin botón cancelar

- **WHEN** el owner abre el detalle de su solicitud `CANCELLED`
- **THEN** MUST NOT mostrarse «Cancelar esta solicitud»
- **AND** MUST mostrarse indicación de solicitud cerrada en `#applyCard`

#### Scenario: Visitante no postula a solicitud cancelada

- **WHEN** un usuario autenticado no owner abre el detalle de una solicitud `CANCELLED`
- **THEN** el CTA de postular MUST NOT estar disponible como en solicitudes activas

## ADDED Requirements

### Requirement: El servidor impide postulaciones en solicitudes canceladas

El sistema MUST rechazar `POST /proposals` cuando la solicitud objetivo tenga `lifecycleStatus` = `CANCELLED`, independientemente de validaciones solo en front-end.

#### Scenario: Postulación rechazada en solicitud cancelada

- **WHEN** un usuario intenta crear una propuesta sobre una solicitud `CANCELLED`
- **THEN** la operación MUST fallar sin persistir la propuesta
- **AND** la respuesta MUST ser consumible por el cliente con mensaje claro
