## Purpose

Reglas de negocio y contrato para **postulaciones/propuestas** en solicitudes abiertas: prohibición de auto-postulación del creador (validación en servidor), listado de postulantes solo para el dueño, y requisitos de UI asociados.

## Requirements

### Requirement: El servidor impide que el creador de una request se postule a la misma request

El sistema MUST rechazar la creación de una postulación/propuesta cuando el usuario autenticado sea el creador u owner de la request objetivo. La validación MUST ejecutarse en el back-end y MUST no depender exclusivamente del front-end.

#### Scenario: Intento de auto-postulación

- **WHEN** el usuario autenticado es el creador/owner de la request `R`
- **AND** solicita crear una postulación asociada a `R`
- **THEN** la operación MUST fallar con un código HTTP acorde a la convención del proyecto (por ejemplo 400 o 403)
- **AND** la respuesta MUST incluir un mensaje claro para el cliente, por ejemplo indicando que no se puede postular a la propia request

#### Scenario: Postulación válida a request de otro usuario

- **WHEN** el usuario autenticado no es el creador/owner de la request `R`
- **AND** las demás reglas de negocio y permisos del sistema permiten la postulación
- **THEN** la postulación MUST poder crearse con el mismo comportamiento exitoso que ya exista para ese flujo

### Requirement: El creador de una request puede consultar las postulaciones recibidas

El sistema MUST exponer un medio de consulta (endpoint o extensión coherente con el API actual) que devuelva las postulaciones asociadas a una request concreta, con información suficiente para identificar postulantes y la fecha (y estado si el modelo lo tiene).

#### Scenario: Creador lista postulaciones de su request

- **WHEN** el usuario autenticado es el creador/owner de la request `R`
- **AND** solicita las postulaciones de `R`
- **THEN** la respuesta MUST incluir, por cada postulación, al menos: identificador del postulante, nombre o username, fecha de postulación
- **AND** si el dominio tiene estado de postulación, MUST incluirse
- **AND** si el modelo de usuario incluye avatar/imagen y el API ya lo expone en contextos equivalentes, MUST incluirse de forma consistente

#### Scenario: Request sin postulaciones

- **WHEN** el creador consulta las postulaciones de su request y no existe ninguna
- **THEN** la respuesta MUST ser una lista vacía o el equivalente ya usado en el proyecto para colecciones vacías, sin error 4xx/5xx por ausencia de ítems

#### Scenario: Usuario no autorizado no accede al listado privado

- **WHEN** un usuario que no es el creador/owner de `R` (y no tiene un rol explícito del proyecto que autorice esta lectura, si existiera)
- **AND** intenta consultar las postulaciones de `R` mediante el endpoint protegido
- **THEN** el sistema MUST denegar el acceso con el código y cuerpo de error acordes a la convención del proyecto (por ejemplo 403 o 404 según política de ocultación de recursos)

### Requirement: El cuerpo de respuesta y errores mantiene convenciones del proyecto

Las respuestas exitosas y de error del nuevo o ajustado listado de postulaciones MUST seguir la misma forma (envoltorios, nombres de campos, serialización de fechas) que el resto de endpoints del mismo módulo de requests/postulaciones, salvo decisión explícita de versión nueva documentada.

#### Scenario: Error de auto-postulación consumible por el cliente

- **WHEN** el back-end rechaza una auto-postulación
- **THEN** el payload de error MUST ser parseable por el cliente con el mismo mecanismo que usa hoy para otros errores de negocio del API

### Requirement: Duplicidad de postulaciones

Si el sistema ya define unicidad de postulación por usuario y request, esa regla MUST mantenerse o reforzarse sin romper datos válidos existentes. Si no existe tal regla pero el producto la exige, la implementación MUST documentar en tareas el mecanismo elegido (p. ej. validación en servicio y/o restricción de persistencia) sin contradecir datos legacy sin plan de migración.

#### Scenario: Segundo intento de postulación del mismo usuario

- **WHEN** el mismo usuario autenticado intenta crear otra postulación para la misma request `R`
- **AND** el modelo de negocio exige una sola postulación activa por usuario y request
- **THEN** el sistema MUST rechazar el intento con el comportamiento ya establecido o el nuevo comportamiento acordado en diseño, de forma determinista

### Requirement: El front-end refleja reglas de negocio y visibilidad para el creador

La interfaz MUST mostrar al creador autenticado de una request la lista (o vista equivalente) de usuarios postulados obtenida del back-end, con indicadores de carga y un estado vacío cuando no haya postulaciones. La acción de postularse MUST estar deshabilitada u oculta cuando el usuario autenticado sea el creador de esa request.

La sección **Postulantes** en el detalle público de una solicitud (`/solicitudes/:id`) MUST renderizarse **únicamente** cuando exista sesión activa, el detalle incluya `ownerUserId` no vacío y ese identificador coincida con el `userId` de la sesión. Visitantes sin sesión y usuarios autenticados que no son el owner MUST NOT ver la sección (ni título, ni estados de carga/vacío/error, ni listado).

Cuando el contrato de listado incluya el identificador del postulante (`userId` u homónimo documentado), el nombre visible, el avatar (si existe) y el bloque identitario principal de cada postulación MUST permitir la navegación al perfil del usuario referenciado usando la convención de rutas del proyecto, con el mismo criterio de perfil propio frente a público que el resto de la aplicación. Los elementos interactivos MUST ser accesibles por teclado y, si el objetivo clickeable es solo el avatar, MUST incluir un nombre accesible (p. ej. `aria-label`).

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

### Requirement: Nueva postulación genera notificación persistida al owner

Además de permitir al creador consultar postulaciones en el detalle, cuando un usuario distinto al owner crea exitosamente una postulación sobre una solicitud, el sistema MUST generar una notificación in-app persistida para el owner, independiente de que el owner esté viendo el detalle en ese momento.

#### Scenario: Owner recibe notificación al postular un tercero

- **WHEN** el usuario B crea una postulación válida en una solicitud de A
- **THEN** A MUST tener una notificación de tipo postulación recibida asociada a esa solicitud
- **AND** B MUST NOT recibir esa notificación como receptor

#### Scenario: Listado de postulantes y notificación son complementarios

- **WHEN** A abre el detalle como owner y consulta postulantes
- **THEN** la UI de postulantes MUST seguir las reglas de visibilidad existentes
- **AND** la existencia de la notificación MUST NOT sustituir el listado privado de postulantes en detalle
