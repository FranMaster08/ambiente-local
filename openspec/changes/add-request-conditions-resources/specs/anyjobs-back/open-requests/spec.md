## ADDED Requirements

### Requirement: Open request MAY include structured work conditions

El sistema MUST permitir asociar a una open request un objeto opcional `workConditions` con subcampos controlados. Todos los subcampos son opcionales; la ausencia del objeto completo o de subcampos individuales MUST NOT impedir crear, leer, actualizar ni listar solicitudes.

Los subcampos enum MUST aceptar únicamente estos valores:

| Subcampo | Valores permitidos |
|----------|-------------------|
| `ownToolsRequired` | `yes`, `no`, `optional` |
| `workerMustTravel` | `yes`, `no`, `to_coordinate` |
| `requesterProvidesMaterials` | `yes`, `no`, `partially` |
| `requesterProvidesTools` | `yes`, `no`, `partially` |
| `priorExperienceRequired` | `yes`, `no`, `desirable` |
| `scheduleFlexible` | `yes`, `no`, `to_coordinate` |
| `priorVisitRequired` | `yes`, `no`, `to_coordinate` |
| `easyAccessOrInstructions` | `yes`, `no`, `requires_instructions` |

El subcampo `additionalInstructions` MUST ser string opcional con longitud máxima 500 caracteres tras recorte de espacios.

#### Scenario: Crear solicitud sin workConditions

- **WHEN** el cliente envía `POST /open-requests` con body válido sin clave `workConditions`
- **THEN** el sistema MUST responder `201`
- **AND** el registro persistido MUST tener `work_conditions` nulo
- **AND** `GET /open-requests/{id}` MUST NOT incluir `workConditions` o MUST devolverlo ausente/null

#### Scenario: Crear solicitud con workConditions parcial

- **WHEN** el cliente envía `POST /open-requests` con `workConditions: { "ownToolsRequired": "yes", "additionalInstructions": "Entrada por portería" }`
- **THEN** el sistema MUST responder `201`
- **AND** MUST persistir el objeto con esos subcampos
- **AND** `GET /open-requests/{id}` MUST devolver los mismos valores

#### Scenario: Valor enum inválido rechazado

- **WHEN** el cliente envía `POST /open-requests` con `workConditions.ownToolsRequired = "maybe"`
- **THEN** el sistema MUST responder `400` con contrato de validación global
- **AND** MUST NOT persistir la solicitud

#### Scenario: additionalInstructions demasiado largo rechazado

- **WHEN** el cliente envía `workConditions.additionalInstructions` con más de 500 caracteres
- **THEN** el sistema MUST responder `400`

### Requirement: Persistencia de workConditions en open_requests

El modelo de persistencia MUST almacenar `workConditions` en columna `work_conditions` de tipo JSON nullable en la tabla `open_requests`. Registros creados antes de esta migración MUST leerse con `workConditions` ausente o null.

#### Scenario: Solicitud legacy sin columna poblada

- **WHEN** el cliente llama `GET /open-requests/{id}` para un registro con `work_conditions` NULL
- **THEN** el sistema MUST responder `200` sin error
- **AND** MUST NOT incluir claves de condiciones con valores vacíos inventados

### Requirement: Actualización parcial de workConditions

`PATCH /open-requests/{id}` MUST aceptar `workConditions` opcional. Si se envía, MUST validarse con las mismas reglas que en creación. El titular MUST seguir siendo el `owner_user_id`.

#### Scenario: Owner actualiza condiciones

- **WHEN** el titular envía `PATCH /open-requests/{id}` con `workConditions` válido
- **THEN** el sistema MUST responder `200` con el detalle actualizado incluyendo `workConditions`

#### Scenario: Non-owner no puede actualizar condiciones

- **WHEN** un usuario distinto al titular envía `PATCH` con `workConditions`
- **THEN** el sistema MUST responder `403`

### Requirement: Detalle público expone workConditions cuando existen

`GET /open-requests/{id}` MUST incluir `workConditions` en el JSON cuando el registro tiene datos persistidos. El listado paginado (`GET /open-requests`) MUST NOT requerir incluir `workConditions` en ítems (fuera de alcance fase 1).

#### Scenario: Detalle incluye condiciones persistidas

- **WHEN** el registro tiene `work_conditions` no nulo
- **THEN** `GET /open-requests/{id}` MUST incluir objeto `workConditions` con los subcampos almacenados
