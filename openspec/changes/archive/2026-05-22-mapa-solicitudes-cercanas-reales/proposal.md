## Why

El mapa de la landing de solicitudes abiertas muestra marcadores simulados (offsets fijos y pins `demo-*`) en lugar de solicitudes reales con ubicación persistida. Eso impide que el usuario descubra qué trabajos abiertos existen cerca de su zona de forma confiable.

## What Changes

- Eliminar mocks, offsets y marcadores demo en `open-requests-landing` y componentes asociados.
- Persistir coordenadas opcionales (`locationLat`, `locationLng`) en open requests cuando el publicador las provea.
- Nuevo endpoint `GET /open-requests/nearby` que devuelve hasta 100 solicitudes abiertas no eliminadas, con coordenadas válidas, ordenadas por distancia al punto del usuario.
- Flujo front: obtener área del usuario (geolocalización existente) → consultar nearby → renderizar marcadores y lista “cerca de ti” con datos reales.
- Popup/tooltip en marcador con excerpt, zona, tags, distancia y enlace al detalle.
- Estados de UI: carga, vacío cercano, error de ubicación, error de API.
- Sin geocodificación improvisada en front ni back; solicitudes sin coordenadas no aparecen en el mapa.

## Capabilities

### New Capabilities

- `open-requests-nearby`: contrato API, consulta por proximidad y límite de 100 resultados.

### Modified Capabilities

- `open-requests` (back): columnas y DTOs de coordenadas; filtro de registros visibles con ubicación.
- `open-requests-browse` (front): sección “Trabajos en tu zona” y carga de datos cercanos reales.
- `modal-map` (front): marcadores reales y estados del modal.
- `open-requests-location-ui`: distancias y etiquetas de zona basadas en respuesta nearby, no en offsets.

## Impact

- **Backend:** migración `location_lat`/`location_lng`, entidad/DTO, `ListNearbyOpenRequestsUseCase`, controller, repositorio (Haversine o equivalente), tests e2e.
- **Front:** `open-requests-landing`, `open-requests.service`, `requests-map` (popup/enlace), modelos TypeScript.
- **Specs:** deltas en `openspec/changes/mapa-solicitudes-cercanas-reales/specs/`.
- **Sin cambio de contrato** en `GET /open-requests` paginado salvo campos opcionales nuevos en ítems si se exponen en listado.
- **Fuera de alcance inmediato:** geocodificar `locationLabel` retroactivamente; cambiar formulario de publicación salvo aceptar coords opcionales en POST/PATCH.
