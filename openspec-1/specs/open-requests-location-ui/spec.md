## Purpose

Reglas de presentación de **zona / ubicación** en la landing de solicitudes abiertas cuando `locationLabel` puede contener artefactos de id (UUID) mezclados con texto legible.

El campo **`id`** sigue existiendo en el modelo para `trackBy`, enlaces a detalle y API; solo se restringe su uso como **texto visible** en estos componentes.

## Requirements

### Requirement: Distancia en lista cercana desde el API

En la lista “cerca de ti” de la landing, cuando exista `userLocation` y la consulta nearby haya tenido éxito, la distancia mostrada MUST provenir del campo `distanceKm` devuelto por `GET /open-requests/nearby` para ese ítem.

La interfaz MUST NOT calcular distancia usando offsets simulados respecto a la ubicación del usuario.

#### Scenario: Distancia coherente con backend

- **WHEN** nearby devuelve un ítem con `distanceKm: 2.3`
- **THEN** la fila en la lista cercana MUST mostrar una distancia equivalente a 2.3 km (formato acordado en UI, p. ej. “~2.3 km”)

#### Scenario: Sin ubicación de usuario

- **WHEN** no hay `userLocation`
- **THEN** la lista cercana MUST NOT mostrar distancias inventadas
- **AND** MAY mostrar solicitudes sin distancia o un mensaje que invite a activar ubicación

### Requirement: Lista de solicitudes cercanas muestra solo zona legible

En la sección de ubicación de la landing de solicitudes abiertas, el bloque que lista solicitudes cercanas SHALL mostrar **solo** el texto de ubicación apto para humanos (p. ej. ciudad y barrio), **sin** el identificador técnico de la solicitud.

#### Scenario: Label con UUID en línea previa

- **WHEN** `locationLabel` contiene una primera línea que es únicamente un UUID y líneas siguientes con la zona
- **THEN** la interfaz MUST NOT mostrar la línea UUID y SHALL mostrar el resto como etiqueta de zona

#### Scenario: Label con UUID en la misma línea

- **WHEN** `locationLabel` es una sola línea con formato prefijo UUID seguido de separador y zona
- **THEN** la interfaz SHALL omitir el prefijo UUID y SHALL mostrar solo la parte de zona

### Requirement: Marcadores de mapa alineados con la misma semántica de zona

Los marcadores de solicitud en el mapa modal y los pines de vista previa asociados a la misma vista SHALL usar para **etiqueta visible** la zona derivada del mismo criterio que la lista cercana, **not** el UUID como texto principal de la etiqueta.

Las coordenadas del marcador MUST ser las devueltas por el API (`locationLat`, `locationLng`), no derivadas del listado paginado por relevancia ni de offsets.

#### Scenario: Marcador con locationLabel mezclado

- **WHEN** el ítem tiene `locationLabel` con UUID embebido
- **THEN** la etiqueta del marcador MUST NOT mostrar el UUID como parte del texto principal salvo que no quede ningún otro texto usable tras el saneo (caso en el cual MAY mostrarse un fallback genérico acordado)

#### Scenario: Marcador usa coordenadas del ítem nearby

- **WHEN** el ítem nearby incluye `locationLat` y `locationLng`
- **THEN** el marcador MUST posicionarse en esas coordenadas

### Requirement: Identificador de solicitud no sustituye a la zona en etiquetas

La interfaz SHALL NOT usar `id` de la solicitud como texto mostrado al usuario en la lista cercana ni como etiqueta principal de pin/marcador cuando exista posibilidad de mostrar zona o un fallback genérico sin id.

#### Scenario: Usuario lee la lista

- **WHEN** el usuario visualiza la lista de solicitudes cercanas
- **THEN** no aparece el UUID de la solicitud como contenido principal de cada fila
