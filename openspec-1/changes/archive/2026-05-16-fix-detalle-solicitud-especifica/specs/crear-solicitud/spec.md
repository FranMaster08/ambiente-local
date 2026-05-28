## ADDED Requirements

### Requirement: Etiqueta de publicación en lecturas refleja antigüedad real

Aunque al crear una solicitud el backend MAY persistir un `publishedAtLabel` inicial (p. ej. `"Recién publicado"`), las respuestas de **lectura** (`GET /open-requests`, `GET /open-requests/mine`, `GET /open-requests/{id}`) MUST devolver `publishedAtLabel` calculado en tiempo de respuesta a partir de `publishedAtSort` (timestamp de publicación), en español y con granularidad relativa (minutos/horas recientes, días, semanas, meses).

#### Scenario: Solicitud creada hace un día

- **WHEN** una solicitud fue publicada hace aproximadamente 24 horas
- **AND** el cliente solicita su detalle o su ítem en listado
- **THEN** `publishedAtLabel` MUST ser equivalente a “Hace 1 día” (o la variante acordada en implementación)
- **AND** MUST NOT permanecer como “Recién publicado” por haberse guardado así al crear

#### Scenario: Solicitud recién creada

- **WHEN** una solicitud fue publicada hace menos del umbral configurado para “recién”
- **THEN** `publishedAtLabel` MAY ser “Recién publicado”
