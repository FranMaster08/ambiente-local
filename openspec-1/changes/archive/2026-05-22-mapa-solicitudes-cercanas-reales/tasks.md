## 1. Backend — persistencia y DTOs

- [x] 1.1 Migración: columnas `location_lat`, `location_lng` nullable en `open_requests`
- [x] 1.2 Entidad TypeORM, dominio y mappers con campos opcionales
- [x] 1.3 `CreateOpenRequestDto` / `PatchOpenRequestDto`: validar `locationLat`/`locationLng` opcionales
- [x] 1.4 Exponer `locationLat`/`locationLng` opcionales en ítems de `GET /open-requests` cuando existan

## 2. Backend — nearby

- [x] 2.1 `ListNearbyOpenRequestsUseCase` + query Haversine en repositorio (filtro `deleted_at`, coords no nulas, `radiusKm`, `limit` ≤ 100)
- [x] 2.2 `GET /open-requests/nearby` en controller + Swagger + DTO de respuesta con `distanceKm`
- [x] 2.3 Tests unitarios del use case y e2e: orden por distancia, exclusión sin coords, límite 100

## 3. Backend — datos de prueba

- [x] 3.1 Actualizar seed/fixtures de open requests con `location_lat`/`location_lng` en al menos varias filas para validar mapa en local

## 4. Frontend — API y modelos

- [x] 4.1 Tipos `NearbyOpenRequestItem` y método `listNearbyOpenRequests(lat, lng, limit?)` en `OpenRequestsService`
- [x] 4.2 Documentar contrato en `ENDPOINTS_Y_CONTRATOS_API.md` si aplica al repo front

## 5. Frontend — landing y mapa

- [x] 5.1 Eliminar `REQUEST_MARKER_OFFSETS`, marcadores `demo-*` y distancias simuladas en `open-requests-landing`
- [x] 5.2 Signals `nearbyItems` / `nearbyState`; cargar nearby tras `userLocation`
- [x] 5.3 `mapMarkers` y `nearbyWithDistance` desde respuesta API (dedupe por `id`, máx. 100)
- [x] 5.4 Estados UX: loading, vacío cercano, error nearby, permiso denegado
- [x] 5.5 `RequestsMapComponent`: popup con excerpt, zona, distancia y navegación a detalle
- [x] 5.6 Ajustar preview de sección ubicación (sin pins que impliquen coords falsas)

## 6. Verificación

- [x] 6.1 Manual: mapa con permiso concedido muestra marcadores reales alineados con API
- [x] 6.2 Manual: permiso denegado y nearby vacío muestran mensajes correctos
- [x] 6.3 Manual: listado principal, detalle, crear solicitud y mis solicitudes sin regresiones
- [x] 6.4 `openspec verify --change mapa-solicitudes-cercanas-reales`
