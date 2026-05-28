## Why

El backend actualizó el contrato de las APIs relacionadas con **solicitudes abiertas** y con la **creación y actualización de propuestas** vinculadas a esas solicitudes; el front (tipos Angular, payloads y parseo HTTP) puede quedar desalineado, lo que provoca errores en runtime o datos mal tipados especialmente en el flujo de **postulación desde solicitud abierta**. Hace falta formalizar qué debe coincidir para cerrar ese gap antes de más cambios de producto.

## What Changes

- Revisión y actualización de **contratos TS y DTOs** del cliente para solicitudes abiertas (`OPEN_REQUESTS_API_URL`): listados, detalle y operaciones que el front ejecute tras el cambio de API (campos opcionales/requeridos, nombres, formatos normalizados).
- Revisión y actualización del **servicio/modelo de propuestas** (`PROPOSALS_API_URL`): cuerpos de `POST`/`GET` (y `PATCH`/`PUT` si el backend los expone), forma de las respuestas (p. ej. envoltorio `items` vs array plano, códigos `201` vs `200`) y mappings hacia los modelos de dominio que usa la vista de compose y “mis solicitudes”.
- Actualización de **documentación de contratos consumidos por el front** (p. ej. `anyjobs-front/anyjobs/docs/ENDPOINTS_Y_CONTRATOS_API.md`) para reflejar el backend vigente.

## Capabilities

### New Capabilities

- `open-requests-proposals-front-contract`: Requisitos de alineación entre el cliente Angular y el backend para **solicitudes abiertas** y **propuestas** en los flujos de creación/lectura pertinentes al postular (incluye request/response y normalización esperada en el cliente).

### Modified Capabilities

- *(ninguno por ahora).* Los specs existentes en `openspec/specs/` (`open-requests-location-ui`, `home-promotional-slider`, `registro-usuario-completo`) cubren otras preocupaciones; este cambio introduce un spec dedicado al contrato API front/back para open requests + propuestas.

## Impact

- Código: `anyjobs-front/anyjobs` — `open-requests.models.ts`, `open-requests.service.ts`, componentes de creación/detalle/compose; `proposals.models.ts`, `proposals.service.ts`; tests y mocks asociados.
- Documentación: `ENDPOINTS_Y_CONTRATOS_API.md` y cualquier referencia cruzada a payloads de propuestas/solicitudes abiertas.
- Dependencias: contrato real del backend (`anyjobs-back` / OpenAPI o specs de módulo); coordinación para no asumir campos obsoletos en el front.
