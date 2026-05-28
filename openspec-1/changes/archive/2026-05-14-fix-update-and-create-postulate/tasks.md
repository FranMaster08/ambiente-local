## 1. Contratos TypeScript — propuestas

- [x] 1.1 Definir tipos DTO en el cliente para `GET /proposals`: `items`, `meta` (al menos `page`, `pageSize`, `hasNextPage`, `nextPage`, `totalItems`, `totalPages` alineados al `PageMetaDto` del backend)
- [x] 1.2 Actualizar `ProposalsService` para parsear `ProposalsListResponseDto` y exponer `readonly Proposal[]` (y opcionalmente `meta`) en `listByUser`, `getByUserAndRequest`, `listByRequest`
- [x] 1.3 Asegurar que `POST /proposals` trate `201` como éxito y mapee `ProposalDto` (incl. `author` obligatorio) al modelo `Proposal`

## 2. Multipart — solicitudes abiertas (crear / actualizar)

- [x] 2.1 Implementar un builder reutilizable (`FormData`) que serialice `CreateOpenRequestInput` y campos parciales para patch, respetando límites (`files` × 6) y formato aceptado por los `@Transform` del DTO (`tags`, `images` JSON si aplica)
- [x] 2.2 Cambiar `createOpenRequest` en `OpenRequestsService` para usar `multipart/form-data` contra el backend real (no mocks)
- [x] 2.3 Añadir `patchOpenRequest(id, input)` (o equivalente) que invoque `PATCH /open-requests/:id` con multipart y mapee la respuesta con `normalizeDetail`
- [x] 2.4 Conectar UI de edición (si existe) o dejar API de servicio lista y documentar entrada esperada; cubrir con pruebas donde haya componentes

## 3. Autenticación y errores

- [x] 3.1 Verificar que las llamadas a `POST`/`PATCH`/`GET mine` de open requests y a `proposals` envían el token/credencial requerido por el backend (interceptor o opciones `HttpClient`)
- [x] 3.2 Mantener o alinear manejo de `{ message: string }` en `4xx` con la UI existente

## 4. Documentación y verificación

- [x] 4.1 Actualizar `anyjobs-front/anyjobs/docs/ENDPOINTS_Y_CONTRATOS_API.md`: envoltorio de listado de propuestas, `201` en creación, multipart en open requests (create/patch)
- [x] 4.2 Prueba manual o e2e breve: crear solicitud con archivo, listar/detalle, postular, listar propuestas con respuesta paginada real
