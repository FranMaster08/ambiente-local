## MODIFIED Requirements

### Requirement: Listado paginado de solicitudes

El endpoint `GET /open-requests` SHALL aceptar `sort` con valores `relevance`, `date` o `publishedAtDesc`, y opcionalmente `anonymousId` para personalización de visitantes.

#### Scenario: sort relevance

- **WHEN** el cliente llama `GET /open-requests?sort=relevance&page=1&pageSize=12`
- **THEN** la respuesta es 200 con items ordenados por relevancia

#### Scenario: sort date explícito

- **WHEN** el cliente llama `GET /open-requests?sort=date`
- **THEN** el orden coincide con `publishedAtDesc` por fecha de publicación
