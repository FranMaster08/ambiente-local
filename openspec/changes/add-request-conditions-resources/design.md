## Context

La pantalla `OpenRequestCreate` (`/solicitudes/nueva`) tiene tres secciones: Información principal, Ubicación y presupuesto, Contenido multimedia. El formulario envía multipart a `POST /open-requests` vía `buildOpenRequestCreateFormData`. El modelo `OpenRequestDetail` en front y back no incluye hoy condiciones de trabajo.

El tour guiado (`publish-request-tour.ts`, driver.js) tiene 9 pasos anclados a `[data-tour]`. El detalle público (`OpenRequestDetail`) muestra header, galería, descripción y «Publicado por», sin bloque de condiciones.

Restricciones del usuario: no eliminar campos actuales, no romper ubicación estructurada CO/AR, no reintroducir texto libre de ubicación, no copiar UI de Airbnb literalmente, mantener responsive y compatibilidad con registros antiguos.

## Goals / Non-Goals

**Goals:**

- Capturar 8 condiciones con valores controlados + texto opcional «Instrucciones aditional».
- Persistir en BD asociado a `open_requests` con defaults seguros para legacy.
- Validar enums en backend; rechazar valores fuera de catálogo.
- Mostrar sección legible en detalle público solo con datos útiles.
- Integrar paso en tour guiado.
- Diseño responsive (2 columnas desktop, 1 columna mobile) coherente con tokens existentes.
- Todos los campos opcionales para publicar.

**Non-Goals:**

- Filtros o badges en listado/mapa (fase 2).
- Pantalla de edición dedicada (PATCH aceptará `workConditions` pero UI de edición puede quedar para fase 2).
- Catálogo dinámico administrable; los enums son constantes compartidas front/back.
- Mostrar email/teléfono del publicador en esta sección.
- Columnas separadas por cada condición (se usa JSON tipado).

## Decisions

### 1. Objeto anidado `workConditions` en API y JSONB en BD

**Decisión:** Exponer un objeto opcional `workConditions` en create/patch/detail. Persistir en columna `work_conditions JSONB NULL` en `open_requests`.

**Alternativas:** 9 columnas nullable (verboso, migración pesada); tabla hija (overkill); campos planos en raíz del DTO (contamina contrato).

**Rationale:** Un solo campo nullable mantiene compatibilidad legacy (`NULL` = sin condiciones). Validación anidada con `WorkConditionsDto` + `@ValidateNested`. Patrón similar a `provider` JSON existente.

### 2. Enums como strings literales compartidos

**Decisión:** Definir enums TypeScript en backend (`open-request-work-conditions.enums.ts`) y constantes/espejo en front (`open-request-work-conditions.constants.ts`) con los valores exactos de la propuesta.

**Alternativas:** i18n keys como valores persistidos (acopla idioma a datos); enteros opacos (peor legibilidad en BD).

**Rationale:** Strings estables, legibles en logs/Swagger, fáciles de validar con `@IsIn`/`@IsEnum`. Front mapea a etiquetas españolas para UI.

**Catálogo de valores:**

```
ownToolsRequired:          yes | no | optional
workerMustTravel:          yes | no | to_coordinate
requesterProvidesMaterials: yes | no | partially
requesterProvidesTools:    yes | no | partially
priorExperienceRequired:   yes | no | desirable
scheduleFlexible:          yes | no | to_coordinate
priorVisitRequired:        yes | no | to_coordinate
easyAccessOrInstructions:  yes | no | requires_instructions
additionalInstructions:    string (0–500 chars, trim, optional)
```

Campos internos del objeto son todos opcionales individualmente.

### 3. Ubicación de la sección en el formulario

**Decisión:** Insertar `<fieldset>` «Condiciones y recursos disponibles» entre la sección de ubicación/presupuesto y multimedia, con `data-tour="publish-work-conditions"`.

**Rationale:** Ubicación y presupuesto definen dónde/cuánto; condiciones contextualizan el trabajo antes de adjuntar fotos. Coherente con el requisito del usuario.

### 4. UI: filas/tarjetas con controles tipo segmented o radio group

**Decisión:** Cada condición en una fila `.conditionRow` dentro de grid responsive (`grid-template-columns: 1fr` mobile; `1fr 1fr` desde ≥768px). Opciones como botones radio estilizados (patrón existente de la app) o `<select>` nativo estilizado si no hay patrón radio — preferir botones pill para claridad tipo Airbnb conceptual.

**Alternativas:** Checkboxes múltiples (incorrecto semánticamente); un solo textarea (viola requisito de opciones controladas).

**Rationale:** Selección única explícita, táctil en mobile, no satura si se agrupa con espaciado `--aj-space-*` existente.

### 5. Envío multipart: `workConditions` como JSON string

**Decisión:** En `buildOpenRequestCreateFormData`, serializar `workConditions` con `JSON.stringify` cuando al menos un subcampo tenga valor; omitir clave si objeto vacío.

**Alternativas:** Campos planos `workConditions.ownToolsRequired` (multipart anidado inconsistente con backend actual).

**Rationale:** Alineado con cómo ya se envía `tags` como JSON string en multipart.

### 6. Visualización en detalle: sección condicional

**Decisión:** Componente o bloque en `open-request-detail.html` titulado «Condiciones y recursos», después de Descripción y antes de «Publicado por». Mostrar filas label + valor solo para subcampos presentes. `additionalInstructions` como párrafo si no vacío.

**Rationale:** No rompe layout existente; oculta ruido cuando no hay datos (legacy).

### 7. Validación: opcional en publicación, estricta si se envía

**Decisión:** Toda la sección es opcional. Si el cliente envía `workConditions`, cada subcampo presente MUST cumplir enum/longitud; subcampos ausentes se ignoran. Backend no inventa defaults excepto `null` en persistencia.

**Rationale:** Cumple criterio de publicar sin completar la sección; evita texto libre donde hay enum.

## Risks / Trade-offs

- **[Objeto parcialmente relleno]** → Aceptado: mostrar solo campos con valor en detalle; no forzar completitud.
- **[JSONB sin índice]** → Aceptable en fase 1 (sin filtros); índice GIN en fase 2 si hay búsqueda.
- **[Desalineación front/back en enums]** → Mitigar con tests de contrato y archivo de constantes documentado; `@IsIn` en DTO rechaza desvíos.
- **[Tour más largo]** → Un paso adicional breve; usuario puede cerrar sin perder datos.
- **[PATCH sin UI]** → API lista para edición futura; documentar en Open Questions.

## Migration Plan

1. Migración TypeORM: `ALTER TABLE open_requests ADD COLUMN work_conditions JSONB NULL`.
2. Desplegar backend (acepta y devuelve `workConditions`; legacy `NULL`).
3. Desplegar frontend (captura y muestra).
4. Rollback: revertir front; backend ignora campo si no se envía; columna nullable no rompe lecturas antiguas.

## Open Questions

- ¿Límite de 500 caracteres para `additionalInstructions` es suficiente? (Propuesta: sí; ajustable sin breaking change).
- ¿Incluir UI de edición en el mismo change o dejar solo API PATCH? (Propuesta: solo API en este change; UI edición fase 2).
