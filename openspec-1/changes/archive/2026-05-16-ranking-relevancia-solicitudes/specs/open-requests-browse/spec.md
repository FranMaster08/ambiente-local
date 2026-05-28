## MODIFIED Requirements

### Requirement: Carga del listado de solicitudes

La landing de solicitudes SHALL solicitar el listado con `sort=relevance` para mejorar el descubrimiento, manteniendo paginación infinita existente.

#### Scenario: Primera página por relevancia

- **WHEN** el usuario abre `/solicitudes`
- **THEN** el cliente llama `GET /open-requests` con `sort=relevance` y `anonymousId` estable
