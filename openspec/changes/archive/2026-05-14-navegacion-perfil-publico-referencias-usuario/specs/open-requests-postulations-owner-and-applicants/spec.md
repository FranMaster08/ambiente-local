## MODIFIED Requirements

### Requirement: El front-end refleja reglas de negocio y visibilidad para el creador

La interfaz MUST mostrar al creador de una request la lista (o vista equivalente) de usuarios postulados obtenida del back-end, con indicadores de carga y un estado vacío cuando no haya postulaciones. La acción de postularse MUST estar deshabilitada u oculta cuando el usuario autenticado sea el creador de esa request.

Cuando el contrato de listado incluya el identificador del postulante (`userId` u homónimo documentado), el nombre visible, el avatar (si existe) y el bloque identitario principal de cada postulación MUST permitir la navegación al perfil del usuario referenciado usando la convención de rutas del proyecto, con el mismo criterio de perfil propio frente a público que el resto de la aplicación. Los elementos interactivos MUST ser accesibles por teclado y, si el objetivo clickeable es solo el avatar, MUST incluir un nombre accesible (p. ej. `aria-label`).

#### Scenario: Creador ve postulantes con carga y vacío

- **WHEN** el usuario autenticado es el creador y abre el detalle o vista donde aplica ver postulantes
- **THEN** la UI MUST mostrar estado de carga mientras la petición está en curso
- **AND** si la lista viene vacía, MUST mostrarse un mensaje vacío claro (por ejemplo que aún no hay postulaciones)

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
