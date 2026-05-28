## ADDED Requirements

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
