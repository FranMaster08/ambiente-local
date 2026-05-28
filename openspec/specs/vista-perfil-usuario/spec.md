## Purpose

Definir el comportamiento del perfil de usuario rediseñado: visibilidad propia vs pública, cabecera y métricas basadas en datos reales, acciones y pestañas extensibles, placeholder para multimedia futuro, contratos de datos seguros y criterios de calidad.

## Requirements

### Requirement: El sistema SHALL distinguir perfil propio y perfil público

La aplicación SHALL determinar el modo de visibilidad comparando el identificador del usuario autenticado (si existe) con el identificador del perfil mostrado. El modo **propio** SHALL habilitar datos y acciones de gestión permitidas por el producto. El modo **público** SHALL limitar la información a datos públicos y acciones no editoras del perfil ajeno.

#### Scenario: Usuario autenticado abre su propio perfil

- **WHEN** el usuario autenticado navega a la vista de perfil cuyo sujeto es el mismo `userId` que el de la sesión
- **THEN** el sistema SHALL aplicar el modo perfil **propio** y SHALL ofrecer en el pie de acciones del hero al menos el enlace a **Mis solicitudes**; otras acciones globales (p. ej. logout, exploración de solicitudes abiertas) SHALL permanecer en la navegación principal (header/menú de cuenta) sin duplicarse obligatoriamente en el perfil

#### Scenario: Usuario autenticado abre el perfil de otro usuario

- **WHEN** el usuario autenticado navega a la vista de perfil cuyo `userId` difiere del de la sesión
- **THEN** el sistema SHALL aplicar el modo perfil **público** y SHALL NOT mostrar email, teléfono, token, ni acciones de edición del perfil ajeno

#### Scenario: Visitante sin sesión en ruta de perfil público permitido

- **WHEN** un cliente sin sesión accede a una ruta de perfil público que el producto defina como accesible
- **THEN** el sistema SHALL aplicar el modo **público** y SHALL NOT exponer datos privados del titular

### Requirement: La cabecera del perfil SHALL presentar identidad con fallbacks seguros

La cabecera SHALL incluir avatar o iniciales derivadas del nombre visible, nombre visible, identificador público (username u homólogo) si existe en el modelo, ubicación si existe, y bio o descripción corta si existe. Si falta imagen, SHALL usarse iniciales u otro fallback visual consistente con el sistema de diseño.

#### Scenario: Usuario sin imagen de avatar

- **WHEN** el perfil no incluye URL o recurso de avatar
- **THEN** el sistema SHALL mostrar iniciales u placeholder aprobado por diseño sin dejar un hueco roto

#### Scenario: Usuario sin bio

- **WHEN** el perfil no incluye bio o descripción
- **THEN** el sistema SHALL mostrar un placeholder textual neutro (p. ej. indicación de que no hay descripción) sin inventar contenido

#### Scenario: Usuario sin username público

- **WHEN** no existe username en los datos del perfil
- **THEN** el sistema SHALL omitir o sustituir el bloque de username sin romper el layout

### Requirement: Las métricas del perfil SHALL reflejar solo datos reales del backend

Las cifras o indicadores agregados (p. ej. solicitudes creadas, propuestas realizadas, solicitudes completadas, reputación) SHALL mostrarse únicamente cuando el backend u orquestación autorizada los provea. El sistema SHALL NOT hardcodear métricas de demostración ni inventar valores.

#### Scenario: Métrica no disponible en API

- **WHEN** el contexto de perfil no incluye un agregado para una métrica concreta
- **THEN** el sistema SHALL ocultar la tarjeta correspondiente o SHALL mostrar un estado vacío explícito sin número ficticio

#### Scenario: Métricas disponibles

- **WHEN** el backend devuelve valores numéricos o agregados válidos para una métrica
- **THEN** el sistema SHALL mostrarlos de forma legible y coherente con el resto de la UI

### Requirement: Las acciones principales SHALL depender del modo de visibilidad

En modo **propio**, la interfaz SHALL ofrecer al menos el enlace a **Mis solicitudes** en el pie de acciones del hero cuando el producto lo mantenga. **SHALL NOT** exigir que logout o “ver solicitudes abiertas” estén duplicados en el perfil si ya existen en la navegación global. En modo **público**, SHALL ofrecerse acciones no invasivas alineadas al dominio (p. ej. ver solicitudes abiertas, inicio) según existan; SHALL NOT mostrarse controles de edición del perfil ajeno.

#### Scenario: Modo propio sin duplicar logout en el pie

- **WHEN** el usuario está en modo perfil **propio**
- **THEN** el sistema MAY omitir el botón de logout en el pie del perfil **si** el cierre de sesión sigue disponible en el menú de cuenta / header

#### Scenario: Modo público sin permiso de edición

- **WHEN** el modo es público
- **THEN** el sistema SHALL NOT renderizar botones o enlaces que modifiquen datos del usuario titular

### Requirement: El perfil propio SHALL degradarse de forma segura si falla la API de perfil

Tras intentar cargar el perfil enriquecido del titular, el sistema SHALL manejar **401** limpiando la sesión local y mostrando el estado coherente con usuario no autenticado en `/perfil`. Para otros errores de red o servidor en `/perfil`, el sistema MAY mostrar un aviso y datos ya disponibles en la sesión del cliente **sin** inventar métricas numéricas (p. ej. omitir bloque de métricas hasta nueva carga exitosa).

#### Scenario: Respuesta 401 al cargar perfil propio

- **WHEN** el cliente recibe HTTP 401 al solicitar el perfil privado enriquecido
- **THEN** el sistema SHALL invalidar la sesión local del cliente de forma acorde al resto de la app y SHALL NOT seguir mostrando el perfil privado como autenticado

#### Scenario: Fallo no-401 con sesión aún presente

- **WHEN** la solicitud de perfil enriquecido falla con un error distinto de 401 y el usuario sigue teniendo snapshot de sesión local
- **THEN** el sistema SHALL NOT mostrar cifras de métricas inventadas y MAY mostrar un mensaje de advertencia y datos de sesión no sensibles ya conocidos por el cliente

### Requirement: El perfil SHALL organizarse en secciones o pestañas extensibles

La vista SHALL usar una estructura de pestañas o secciones que permita añadir contenido futuro. Las secciones actuales MAY incluir información general, solicitudes publicadas, propuestas o postulaciones, y valoraciones o actividad visible según datos existentes.

#### Scenario: Navegación entre pestañas

- **WHEN** el usuario selecciona una pestaña disponible
- **THEN** el sistema SHALL mostrar el contenido asociado sin recargar de forma que rompa el estado global de autenticación

### Requirement: La pestaña Multimedia SHALL listar y reproducir reels reales del perfil

La sección “Multimedia” SHALL consumir `GET /users/:userId/reels` en perfil público y `GET /user-reels/me` en perfil propio. El dueño SHALL poder subir contenido (`POST /user-media/assets` + publicación de reel). El visitante SHALL ver solo reels aprobados y no en borrador.

#### Scenario: Perfil público con reels publicados

- **WHEN** un visitante abre la pestaña multimedia de un perfil con reels aprobados
- **THEN** el sistema SHALL mostrar una cuadrícula de miniaturas y SHALL permitir abrir el reproductor con la URL devuelta por la API

#### Scenario: Perfil propio sin contenido

- **WHEN** el titular abre multimedia sin haber publicado reels
- **THEN** el sistema SHALL mostrar estado vacío con acción de subida y SHALL NOT inventar contenido

#### Scenario: Subida en perfil propio

- **WHEN** el titular sube un archivo permitido desde la pestaña multimedia
- **THEN** el sistema SHALL crear el asset, el reel y publicarlo según el flujo MVP y SHALL refrescar el listado

### Requirement: El dueño SHALL poder eliminar sus reels desde la galería del perfil propio

En modo perfil **propio**, cada ítem de la cuadrícula multimedia SHALL exponer un control de eliminación con iconografía reconocible (p. ej. papelera o equivalente del sistema de diseño). El control SHALL NOT mostrarse en perfil **público**. La eliminación SHALL requerir confirmación explícita en un diálogo modal antes de invocar la API. El tap en el tile para abrir el reproductor SHALL seguir disponible sin activar el borrado por accidente.

#### Scenario: Icono de eliminar visible solo en perfil propio

- **WHEN** el titular visualiza la cuadrícula de reels en su pestaña Multimedia
- **THEN** cada tile SHALL mostrar un control de eliminar accesible
- **AND** el control SHALL NOT aparecer cuando otro usuario o un visitante ve el mismo perfil en modo público

#### Scenario: Confirmación antes de borrar

- **WHEN** el titular activa el control de eliminar en un reel
- **THEN** el sistema SHALL abrir un diálogo que pregunte si está seguro de borrar el reel
- **AND** SHALL ofrecer acciones para cancelar y para confirmar la eliminación
- **AND** SHALL NOT llamar a `DELETE /user-reels/:reelId` hasta que el usuario confirme

#### Scenario: Cancelar eliminación

- **WHEN** el titular abre el diálogo de confirmación y elige cancelar o cierra el diálogo
- **THEN** el sistema SHALL cerrar el diálogo sin modificar el listado ni el reel en el servidor

#### Scenario: Eliminar reel confirmado

- **WHEN** el titular confirma la eliminación de un reel propio
- **THEN** el cliente SHALL enviar `DELETE /user-reels/:reelId` con la sesión del dueño
- **AND** tras respuesta exitosa SHALL quitar el reel de la cuadrícula sin recargar toda la página
- **AND** si el reproductor modal estaba mostrando ese reel, SHALL cerrarlo

#### Scenario: Error al eliminar

- **WHEN** la API responde con error distinto de éxito al intentar borrar
- **THEN** el sistema SHALL mantener el reel en la galería
- **AND** SHALL mostrar un mensaje de error comprensible al usuario

#### Scenario: Control de eliminar no dispara reproducción

- **WHEN** el titular activa el control de eliminar en un tile
- **THEN** el sistema SHALL NOT abrir el reproductor del reel como si hubiera hecho clic en el tile completo

### Requirement: El backend SHALL segregar datos de perfil público y perfil propio

Las respuestas HTTP que alimenten la vista SHALL construirse con DTOs o proyecciones que excluyan datos sensibles en el contexto público. La decisión de qué campos devolver SHALL basarse en identidad del solicitante y en reglas de autorización del servidor, no solo en el cliente.

#### Scenario: Cliente solicita perfil público de un usuario

- **WHEN** un cliente solicita el recurso de perfil público definido por el diseño de API
- **THEN** la carga útil SHALL NOT incluir email, teléfono ni otros campos marcados como privados por el modelo de amenazas del producto

#### Scenario: Usuario autenticado solicita su perfil enriquecido

- **WHEN** el titular solicita su propio perfil o recurso equivalente autenticado
- **THEN** el sistema MAY incluir campos adicionales permitidos para gestión personal, respetando las mismas reglas de no exposición a terceros

### Requirement: La experiencia SHALL permanecer usable con datos incompletos o sin actividad

Si no hay solicitudes, propuestas o actividad, el sistema SHALL mostrar estados vacíos claros. Si no hay métricas, la zona de métricas SHALL no mostrar valores falsos.

#### Scenario: Sin actividad pública

- **WHEN** las listas o agregados de actividad están vacíos
- **THEN** el sistema SHALL mostrar un mensaje de vacío coherente con el tono del producto

### Requirement: El rediseño SHALL mantener compatibilidad con autenticación y edición de perfil existentes

El flujo de login, sesión y cierre de sesión existente SHALL seguir operativo. Si ya existe pantalla o flujo de edición de perfil, el rediseño SHALL integrarse sin romper su navegación salvo migración explícitamente documentada.

#### Scenario: Logout desde la navegación global

- **WHEN** el usuario ejecuta la acción de cerrar sesión desde el menú de cuenta o equivalente en el header (no necesariamente desde el pie del perfil)
- **THEN** el sistema SHALL invalidar la sesión y SHALL reflejar el estado no autenticado de forma coherente con el resto de la aplicación

### Requirement: La vista SHALL ser responsive y libre de errores de consola atribuibles al cambio

El layout SHALL adaptarse a anchos típicos de escritorio, tablet y móvil. Los cambios introducidos SHALL NOT generar errores nuevos en consola en flujos felices de perfil propio y público.

#### Scenario: Viewport móvil en perfil propio

- **WHEN** el usuario visualiza el perfil propio en un viewport estrecho
- **THEN** la cabecera, métricas y pestañas SHALL permanecer usables sin solapamientos críticos

### Requirement: El cambio SHALL validarse con herramientas de calidad del repositorio

Antes de considerarse listo para archivo, el equipo SHALL ejecutar lint, typecheck, build y batería de tests disponibles en el monorepo afectado, corrigiendo regresiones introducidas por el cambio.

#### Scenario: Pipeline local o CI

- **WHEN** se ejecutan los comandos de calidad documentados en el proyecto para front y back tocados
- **THEN** los comandos SHALL completar con éxito o las desviaciones SHALL quedar documentadas como bloqueantes en tareas
