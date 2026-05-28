## Why

En la landing de **solicitudes abiertas**, la sección **Ubicación** muestra una lista de solicitudes cercanas (demo). El campo **`locationLabel`** que llega del API a veces incluye el **UUID de la solicitud** (prefijo en la misma línea o primera línea en texto multilínea), lo que ensucia la UI y no aporta valor al usuario final.

## What Changes

- **Lista «Solicitudes cercanas»** (`nearbyList`): solo texto de **zona** (ciudad · barrio, etc.), sin mostrar el id de negocio.
- **Función pura `locationLabelZoneOnly`** en `open-requests-landing.ts`: elimina una primera línea que sea solo UUID y un prefijo UUID en una sola línea antes del separador `·`.
- **Mapa modal** y **pines de vista previa** del mapa: etiquetas basadas en la zona saneada (o texto corto de respaldo), **sin** concatenar `id` + `locationLabel`.
- **Backend / datos (recomendación):** persistir **`location_label`** solo como etiqueta humana; el **`id`** ya identifica la solicitud en el JSON.

## Capabilities

### New Capabilities

- `open-requests-location-ui`: Presentación consistente de zona en lista cercana y marcadores asociados a la sección ubicación.

### Modified Capabilities

- _(Ninguno formal en otros specs raíz; cambio acotado al feature landing.)_

## Impact

- **Código:** `anyjobs-front/anyjobs/src/app/features/open-requests/open-requests-landing/open-requests-landing.ts`, `open-requests-landing.html`.
- **Backend:** opcional — limpieza de datos o migración si `location_label` almacenaba texto con UUID incrustado.

## Observaciones

- El saneo en front **defensa en profundidad**; la fuente de verdad debería ser el API/BD sin embebidos de id en labels.
- Si `locationLabel` queda vacío tras el saneo, los marcadores usan respaldo corto (`Solicitud`, `Solicitud abierta`) para no volver a mostrar UUID.
