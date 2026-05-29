## ADDED Requirements

### Requirement: Notificación a postulantes cuando se cancela una solicitud

Cuando el titular cancela exitosamente una solicitud abierta (`lifecycleStatus` pasa a `CANCELLED`), el sistema MUST crear una notificación in-app para cada usuario distinto que tenga una propuesta en esa solicitud. El titular que ejecuta la cancelación MUST NOT ser receptor de esas notificaciones.

#### Scenario: Postulante recibe notificación de cancelación

- **WHEN** el usuario A cancela la solicitud `R` que tiene al menos una propuesta del usuario B
- **THEN** MUST persistirse una notificación para B con `type` del catálogo para actualizaciones de solicitud o propuesta (p. ej. `REQUEST_OR_PROPOSAL_UPDATE`)
- **AND** `entityType` MUST permitir navegar a la solicitud (p. ej. `open_request`)
- **AND** `entityId` MUST ser el id de `R`
- **AND** el `title` MUST ser breve (p. ej. «Solicitud cancelada»)
- **AND** el `message` MUST indicar que la solicitud identificada por su título fue cancelada por quien la publicó, sin incluir datos sensibles de la propuesta

#### Scenario: Múltiples postulantes reciben notificación

- **WHEN** `R` tiene propuestas de B y C
- **AND** A cancela `R`
- **THEN** MUST crearse una notificación para B y una para C

#### Scenario: Cancelación sin postulantes no crea notificaciones

- **WHEN** A cancela `R` y no hay propuestas
- **THEN** MUST NOT crearse notificaciones por este evento
- **AND** la cancelación MUST completarse igualmente

#### Scenario: Fallo de notificación no revierte cancelación

- **WHEN** la cancelación se persiste correctamente
- **AND** falla la creación de una o más notificaciones
- **THEN** la operación de cancelación MUST considerarse exitosa para el cliente
- **AND** el fallo MUST registrarse en logs del servidor

#### Scenario: Deduplicación por solicitud y receptor

- **WHEN** se reintenta la creación de notificación de cancelación para el mismo receptor y solicitud
- **THEN** el sistema MUST NOT duplicar notificaciones para el mismo evento lógico (mecanismo `dedupKey` o equivalente)
