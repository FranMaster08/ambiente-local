## MODIFIED Requirements

### Requirement: Render de mapa con ubicación y solicitudes cercanas

El modal de mapa MUST renderizar un mapa interactivo (Leaflet u equivalente) cuando haya ubicación disponible, mostrando:

- Un marcador de “Tu ubicación”.
- Hasta 100 marcadores de solicitudes abiertas con coordenadas reales devueltas por `GET /open-requests/nearby`, uno por solicitud, sin duplicar `id`.
- Una leyenda que explique ambos tipos de marcador.

Cada marcador de solicitud MUST usar `locationLat` y `locationLng` del ítem API. El sistema MUST NOT renderizar marcadores demo ni posiciones derivadas de offsets fijos respecto al usuario.

Al interactuar con un marcador de solicitud, el mapa MUST mostrar tooltip o popup con datos reales (zona saneada, excerpt, distancia aproximada cuando exista) y MUST permitir acceder al detalle de la solicitud.

#### Scenario: Usuario abre el modal con ubicación disponible

- **WHEN** el modal se abre y existe `userLocation` y nearby ha respondido con éxito
- **THEN** el sistema MUST mostrar el mapa centrado en la ubicación del usuario
- **AND** MUST mostrar un marcador por cada ítem nearby con coordenadas válidas

#### Scenario: Usuario abre el modal sin ubicación

- **WHEN** el modal se abre y no existe `userLocation`
- **THEN** el sistema MUST mostrar un estado “Obteniendo tu ubicación…” o error si falla la geolocalización

#### Scenario: Carga de solicitudes en el modal

- **WHEN** el modal está abierto y la consulta nearby está en progreso
- **THEN** el sistema MUST indicar carga sin mostrar marcadores de solicitud falsos

#### Scenario: Popup de marcador con datos reales

- **WHEN** el usuario activa un marcador de solicitud
- **THEN** el sistema MUST mostrar información del ítem (no texto genérico “Solicitud cercana N”)
- **AND** MUST permitir navegar al detalle de esa solicitud
