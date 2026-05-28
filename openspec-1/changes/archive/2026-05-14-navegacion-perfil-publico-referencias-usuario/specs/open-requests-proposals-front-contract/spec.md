## ADDED Requirements

### Requirement: Navegación a perfil desde vistas que consumen propuestas y solicitudes abiertas

El cliente Angular MUST, en las vistas de listado y detalle relacionadas con solicitudes abiertas y propuestas, renderizar como **navegación al perfil** (según la convención de rutas del proyecto) el nombre, avatar o bloque identitario de todo usuario cuyo `userId` esté disponible en el modelo de presentación (incluyendo objetos anidados como `author` o equivalentes documentados). La implementación MUST reutilizar el patrón compartido de identidad de usuario cuando exista y MUST NOT exponer datos privados adicionales obtenidos fuera del contrato público.

#### Scenario: Listado de propuestas con autor identificable

- **WHEN** un ítem de propuesta incluye `userId` del autor o postulante en el modelo del cliente
- **THEN** la UI MUST ofrecer un control que navegue al perfil de ese `userId` al activarlo
- **AND** la interactividad MUST ser perceptible sin depender exclusivamente del color

#### Scenario: Detalle de solicitud con owner u otros usuarios visibles

- **WHEN** el detalle de una solicitud abierta muestra identidad del owner u otros participantes con `userId` en el modelo
- **THEN** la UI MUST permitir la misma navegación coherente al perfil
- **AND** el teclado MUST poder activar la navegación con foco visible

#### Scenario: Modelo sin userId

- **WHEN** el modelo no incluye `userId` para una fila que muestra solo texto libre de autor
- **THEN** el equipo MUST registrar la brecha en el inventario de tareas y MUST ampliar el contrato API o el mapeo del cliente antes de simular un enlace con datos insuficientes
