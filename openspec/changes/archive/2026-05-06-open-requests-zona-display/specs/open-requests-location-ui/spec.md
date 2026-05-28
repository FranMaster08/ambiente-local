## Purpose

Reglas de presentación de **zona / ubicación** en la landing de solicitudes abiertas cuando `locationLabel` puede contener artefactos de id (UUID) mezclados con texto legible.

## ADDED Requirements

### Requirement: Lista de solicitudes cercanas muestra solo zona legible

En la sección de ubicación de la landing de solicitudes abiertas, el bloque que lista solicitudes cercanas (demo) SHALL mostrar **solo** el texto de ubicación apto para humanos (p. ej. ciudad y barrio), **sin** el identificador técnico de la solicitud.

#### Scenario: Label con UUID en línea previa

- **WHEN** `locationLabel` contiene una primera línea que es únicamente un UUID y líneas siguientes con la zona
- **THEN** la interfaz MUST NOT mostrar la línea UUID y SHALL mostrar el resto como etiqueta de zona

#### Scenario: Label con UUID en la misma línea

- **WHEN** `locationLabel` es una sola línea con formato prefijo UUID seguido de separador y zona
- **THEN** la interfaz SHALL omitir el prefijo UUID y SHALL mostrar solo la parte de zona

### Requirement: Marcadores de mapa alineados con la misma semántica de zona

Los marcadores de solicitud en el mapa modal y los pines de vista previa asociados a la misma vista SHALL usar para **etiqueta visible** la zona derivada del mismo criterio que la lista cercana, **not** el UUID como texto principal de la etiqueta.

#### Scenario: Marcador con locationLabel mezclado

- **WHEN** el ítem tiene `locationLabel` con UUID embebido
- **THEN** la etiqueta del marcador MUST NOT mostrar el UUID como parte del texto principal salvo que no quede ningún otro texto usable tras el saneo (caso en el cual MAY mostrarse un fallback genérico acordado)

### Requirement: Identificador de solicitud no sustituye a la zona en etiquetas

La interfaz SHALL NOT usar `id` de la solicitud como texto mostrado al usuario en la lista cercana ni como etiqueta principal de pin/marcador cuando exista posibilidad de mostrar zona o un fallback genérico sin id.

#### Scenario: Usuario lee la lista

- **WHEN** el usuario visualiza la lista de solicitudes cercanas
- **THEN** no aparece el UUID de la solicitud como contenido principal de cada fila

## Observaciones

- El campo **`id`** sigue existiendo en el modelo para `trackBy`, enlaces a detalle y API; solo se restringe su uso como **texto visible** en estos componentes.
