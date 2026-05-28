## 1. OpenSpec y preparación

- [x] 1.1 Validar artefactos del change `add-request-conditions-resources` (proposal, design, specs, tasks)
- [x] 1.2 Acordar constantes compartidas de enums front/back según design.md

## 2. Backend — persistencia y contrato API

- [x] 2.1 Crear migración TypeORM: columna `work_conditions JSONB NULL` en `open_requests`
- [x] 2.2 Añadir tipos/enums y `WorkConditionsDto` con validación `@IsIn` / `@MaxLength(500)` para `additionalInstructions`
- [x] 2.3 Integrar `workConditions` en `CreateOpenRequestDto`, `PatchOpenRequestDto`, dominio `OpenRequestDetail`, entidad y repositorio/mappers
- [x] 2.4 Exponer `workConditions` en `OpenRequestDetailDto` (Swagger)
- [x] 2.5 Tests unitarios del DTO y use cases (create/update con condiciones parciales, inválidas, legacy null)
- [x] 2.6 Tests e2e: POST con/sin workConditions, GET detalle, PATCH owner, 400 enum inválido

## 3. Frontend — modelos y serialización

- [x] 3.1 Añadir tipos `WorkConditions` y constantes/labels en `open-requests.models.ts` (o módulo dedicado)
- [x] 3.2 Actualizar `CreateOpenRequestInput`, servicio y `buildOpenRequestCreateFormData` para serializar `workConditions` como JSON en multipart
- [x] 3.3 Normalizar `workConditions` en respuesta de `getOpenRequestDetail`

## 4. Frontend — formulario de publicación

- [x] 4.1 Añadir FormGroup anidado o controles para `workConditions` en `open-request-create.ts`
- [x] 4.2 Implementar sección «Condiciones y recursos disponibles» en template (entre ubicación y multimedia)
- [x] 4.3 Estilos responsive SCSS (grid 1 col mobile, 2 col desktop; targets táctiles)
- [x] 4.4 Validación cliente: enums y max 500 en instrucciones adicionales
- [x] 4.5 Añadir `data-tour="publish-work-conditions"` y paso en `publish-request-tour.ts`
- [x] 4.6 Tests `open-request-create.spec.ts`: sección visible, envío opcional, envío con valores, validación longitud instrucciones

## 5. Frontend — detalle público

- [x] 5.1 Renderizar sección «Condiciones y recursos» en `open-request-detail` con helper de labels
- [x] 5.2 Ocultar sección cuando no hay datos; estilos coherentes con cards existentes
- [x] 5.3 Tests de detalle: con condiciones, legacy sin condiciones

## 6. Documentación y cierre

- [x] 6.1 Actualizar docs de API/contratos (`ENDPOINTS_Y_CONTRATOS_API.md` u equivalente) con `workConditions`
- [x] 6.2 Ejecutar linter front (`anyjobs-front/anyjobs`) y back (`anyjobs-back`)
- [x] 6.3 Ejecutar tests front y back
- [x] 6.4 Marcar tareas completadas en este archivo
