## ADDED Requirements

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
