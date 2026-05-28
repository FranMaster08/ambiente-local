## ADDED Requirements

### Requirement: Carga de solicitudes cercanas reales para mapa y lista

Cuando la landing obtiene la ubicación del usuario (`lat`, `lng`), MUST consultar `GET /open-requests/nearby` con `limit=100` y MUST usar exclusivamente esa respuesta para:

- Marcadores de solicitud en el mapa modal.
- Lista “cerca de ti” en la sección de ubicación.
- Distancias mostradas al usuario.

La landing MUST NOT usar offsets, coordenadas inventadas ni marcadores `demo-*` para representar solicitudes.

#### Scenario: Ubicación concedida dispara consulta nearby

- **WHEN** el usuario concede geolocalización y la landing tiene `userLocation`
- **THEN** el cliente MUST llamar `GET /open-requests/nearby` con las coordenadas del usuario
- **AND** MUST construir marcadores solo a partir de ítems devueltos con `locationLat` y `locationLng`

#### Scenario: Solicitud sin coordenadas en respuesta no genera marcador

- **WHEN** un ítem del listado paginado principal no tiene coordenadas en BD
- **THEN** MUST NOT aparecer como marcador en el mapa aunque figure en el listado por relevancia

### Requirement: Estados de UI para flujo de cercanía

La sección “Trabajos en tu zona” y el modal de mapa MUST manejar:

- Carga mientras se obtiene ubicación y/o nearby.
- Mensaje claro si no hay solicitudes cercanas con coordenadas (`items` vacío en nearby).
- Mensaje claro si falla geolocalización (sin bloquear el resto de la landing).
- Mensaje y reintento si falla la consulta nearby.

#### Scenario: Sin solicitudes cercanas con ubicación

- **WHEN** nearby responde `200` con `items: []`
- **THEN** el sistema MUST mostrar un mensaje indicando que no hay solicitudes abiertas cerca
- **AND** MUST NOT mostrar marcadores de solicitud simulados

#### Scenario: Error en consulta nearby

- **WHEN** `GET /open-requests/nearby` falla
- **THEN** el sistema MUST mostrar error controlado en la sección de ubicación
- **AND** MUST ofrecer reintentar sin afectar el listado principal ya cargado

### Requirement: Interacción con marcador hacia detalle

Al activar un marcador de solicitud en el mapa, el sistema MUST mostrar información del ítem real (excerpt, zona saneada, tags si existen, distancia) y MUST permitir navegar al detalle `/solicitudes/:id` sin romper el flujo existente desde cards.

#### Scenario: Usuario abre detalle desde marcador

- **WHEN** el usuario activa el enlace o acción de detalle en el popup del marcador
- **THEN** el sistema MUST navegar a la ruta de detalle de esa solicitud

## REMOVED Requirements

### Requirement: Ubicación con geolocalización y marcadores cercanos (demo)

**Reason**: Reemplazado por consulta real a `GET /open-requests/nearby` y marcadores con coordenadas persistidas.

**Migration**: Eliminar `REQUEST_MARKER_OFFSETS`, marcadores `demo-*` y distancias calculadas sobre posiciones simuladas; usar `distanceKm` del API.
