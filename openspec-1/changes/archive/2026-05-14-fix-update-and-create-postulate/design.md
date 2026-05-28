## Context

El front AnyJobs Angular consume `OPEN_REQUESTS_API_URL` y `PROPOSALS_API_URL` contra el API NestJS en `anyjobs-back`. El `proposal.md` recoge el problema: tras evolucionar el backend, los tipos y el transporte HTTP del cliente pueden divergir del contrato real. Hallazgos al comparar código:

- `**GET /proposals**`: el backend devuelve `ProposalsListResponseDto` (`items` + `meta` con paginación). El cliente hoy tipa solo `{ items?: Proposal[] }` e ignora `meta` (funciona para volúmenes pequeños pero el contrato está incompleto).
- `**POST /proposals**`: el DTO de creación y `ProposalDto` de respuesta coinciden en lo esencial con lo que envía `sendProposal`; la API documenta `201 Created` (Swagger). Conviene aceptar `201` explícitamente y asumir `author` anidado siempre presente en respuesta.
- `**POST /open-requests` y `PATCH /open-requests/:id**`: el controlador usa `FilesInterceptor('files', 6)` y recibe `CreateOpenRequestDto` / `PatchOpenRequestDto`. El cliente hoy hace `post` con JSON (`application/json`) vía `buildCreateBody`. Eso puede funcionar sin archivos en algunos despliegues, pero **no es el contrato del controlador** para subida de imágenes; hace falta **multipart** alineado con Nest (campos de formulario + partes `files`).
- **Actualización de solicitudes**: el backend expone `PATCH /open-requests/:id`; el servicio del front **no** expone aún un método de actualización acorde al contrato multipart.

## Goals / Non-Goals

**Goals:**

- Alinear tipos y serialización del cliente con los DTOs y códigos HTTP que expone el backend para **open requests** (list, detail, mine, create, patch) y **proposals** (list, create).
- Documentar en el repo del front el contrato consumido (payloads, envoltorios, multipart).
- Dejar tareas verificables para implementación y pruebas.

**Non-Goals:**

- Cambiar el diseño de la API en el backend (solo consumo en front).
- Implementar en este documento el código (va en `tasks.md` / implementación).

## Decisions

1. **Propuestas — envoltorio de listado**
  - **Decisión**: Tipar y parsear `items` + `meta` en el cliente; extraer listas desde `items` y, si hace falta paginación en UI, usar `meta.nextPage` / `meta.hasNextPage` en lugar de inventar flags.  
  - **Alternativa descartada**: Seguir tipando solo `items` sin `meta` — mantiene deuda y riesgo si el backend pagina de verdad.
2. **Solicitudes abiertas — create/patch**
  - **Decisión**: Usar `FormData` (multipart) para `POST` y `PATCH`, mapeando campos escalares y `tags` de forma compatible con los `@Transform` del DTO (p. ej. `tags` como JSON string o lista según lo que valide Nest en integración). Archivos en el campo `**files`** (hasta 6), como en el interceptor.  
  - **Alternativa descartada**: Forzar solo JSON — incompatible con el flujo de subida previsto en el controlador.
3. **Autenticación**
  - **Decisión**: Asumir que create/mine/patch/delete de open requests y proposals requieren el mismo mecanismo que ya usa el API (Bearer); el cliente debe enviar credenciales donde hoy falte (p. ej. interceptor) — solo **mencionar** en riesgos si no está en alcance inmediato; las tareas pueden incluir verificación puntual.
4. `**userId` en POST /proposals**
  - **Decisión**: Mantener compatibilidad con el DTO actual del backend (`userId` en body) hasta que el producto elimine ese campo en favor de solo token; si el backend pasa a derivar usuario del JWT, el front dejaría de enviar `userId` (**cambio coordinado**, fuera de este diseño si no está en marcha).

## Risks / Trade-offs

- **[Riesgo]** Multipart mal formado → validación `400` en Nest. → **Mitigación**: pruebas manuales o e2e contra API real; contrastar con Swagger / DTO `CreateOpenRequestDto`.
- **[Riesgo]** Duplicar lógica de transformación de `tags`/`images` entre create y patch. → **Mitigación**: factorizar un único builder de `FormData` compartido.
- **[Riesgo]** El front no envía `Authorization` en algunas rutas → `401/403` aunque el contrato sea correcto. → **Mitigación**: tarea explícita de verificar interceptor o headers en llamadas tocadas.

## Migration Plan

1. Implementar cambios en servicios/modelos según `tasks.md`.
2. Probar contra backend local: crear solicitud con y sin archivos; listar/detalle; postular (`POST /proposals`); listar propuestas con `meta`.
3. Actualizar documentación de contratos en el front.
4. **Rollback**: revertir commits del cliente; sin migración de datos.

## Open Questions

- ¿El gateway o proxy fuerza solo `multipart` para `POST /open-requests` o acepta JSON sin `files`? (Confirmar en entorno real; el diseño asume multipart como referencia oficial del controlador.)  
solo multipart
- ¿Hay que paginar propuestas en UI usando `meta` o basta con `pageSize` grande fijo por ahora?

  por el momento no