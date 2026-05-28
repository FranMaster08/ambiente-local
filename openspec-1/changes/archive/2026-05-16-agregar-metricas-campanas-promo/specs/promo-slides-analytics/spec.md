## ADDED Requirements

### Requirement: Persistencia append-only de interacciones promo

El sistema SHALL persistir cada `POST /promo-slides/interactions` en `promo_slide_interactions` con `kind`, actor (`subjectType`, `userId`, `anonymousId`), contexto de slide y `payload` JSON opcional.

#### Scenario: Evento guardado

- **WHEN** el cliente envía un cuerpo válido a `POST /promo-slides/interactions`
- **THEN** el API responde 204 y el evento es consultable en BD

### Requirement: Eventos de retención

El cliente SHALL poder enviar `kind` entre: `slideImpression`, `slideViewStart`, `slideViewEnd`, `watchProgress`, `slideSkipped`, además de los eventos de interacción existentes.

#### Scenario: Progreso de visualización

- **WHEN** el cliente envía `watchProgress` con `watchMs` y opcionalmente `completionRate`
- **THEN** el payload queda almacenado para agregación de métricas
