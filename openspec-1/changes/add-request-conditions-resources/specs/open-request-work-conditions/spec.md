## Purpose

Definir el contrato funcional compartido de **condiciones y recursos de trabajo** asociados a una solicitud abierta: catálogo de valores, reglas de optionalidad, etiquetas de UI y comportamiento de visualización pública.

## ADDED Requirements

### Requirement: Catálogo de valores permitidos para workConditions

El objeto `workConditions` MUST contener subcampos opcionales con los siguientes valores permitidos cuando están presentes:

| Subcampo API | Etiqueta UI (español) | Valores permitidos | Etiquetas UI por valor |
|--------------|----------------------|--------------------|------------------------|
| `ownToolsRequired` | Herramientas propias requeridas | `yes`, `no`, `optional` | Sí / No / Opcional · No estoy seguro |
| `workerMustTravel` | El trabajador debe trasladarse al lugar | `yes`, `no`, `to_coordinate` | Sí / No / A coordinar |
| `requesterProvidesMaterials` | El solicitante ofrece materiales | `yes`, `no`, `partially` | Sí / No / Parcialmente |
| `requesterProvidesTools` | El solicitante ofrece herramientas o equipos | `yes`, `no`, `partially` | Sí / No / Parcialmente |
| `priorExperienceRequired` | Se requiere experiencia previa | `yes`, `no`, `desirable` | Sí / No / Deseable |
| `scheduleFlexible` | Se permite coordinar horario | `yes`, `no`, `to_coordinate` | Sí / No / A coordinar |
| `priorVisitRequired` | El trabajo requiere visita previa | `yes`, `no`, `to_coordinate` | Sí / No / A coordinar |
| `easyAccessOrInstructions` | El lugar tiene acceso fácil o instrucciones especiales | `yes`, `no`, `requires_instructions` | Sí / No / Requiere instrucciones |
| `additionalInstructions` | Instrucciones adicionales | string ≤500 chars | (texto libre) |

#### Scenario: Mapeo consistente de etiquetas

- **WHEN** la UI muestra un subcampo enum con valor `to_coordinate`
- **THEN** MUST mostrarse la etiqueta «A coordinar» al usuario final, no el valor técnico del enum

#### Scenario: Valor parcialmente para materiales y herramientas

- **WHEN** `requesterProvidesMaterials` es `partially`
- **THEN** la UI MUST mostrar «Parcialmente»

### Requirement: Optionalidad de la sección completa

Ningún subcampo de `workConditions` MUST ser obligatorio para crear una solicitud. Un objeto vacío o ausente MUST tratarse como «sin condiciones declaradas».

#### Scenario: Publicación sin ninguna condición

- **WHEN** el publicador no selecciona ninguna opción ni escribe instrucciones
- **THEN** el flujo de publicación MUST completarse con éxito

### Requirement: Visualización pública en detalle

La vista de detalle MUST mostrar una sección titulada **«Condiciones y recursos»** cuando exista al menos un subcampo con valor. MUST mostrar solo subcampos con información útil. MUST usar etiquetas legibles (tabla anterior). MUST NOT mostrar email ni teléfono del publicador en esta sección.

#### Scenario: Detalle con condiciones parciales

- **WHEN** una solicitud tiene `workConditions.ownToolsRequired = "yes"` y ningún otro subcampo
- **THEN** la sección MUST mostrar únicamente la fila «Herramientas propias requeridas: Sí»

#### Scenario: Detalle legacy sin condiciones

- **WHEN** una solicitud no tiene `workConditions`
- **THEN** la sección «Condiciones y recursos» MUST NOT renderizarse

#### Scenario: Instrucciones adicionales como texto

- **WHEN** `additionalInstructions` contiene texto no vacío
- **THEN** MUST mostrarse bajo el subtítulo «Instrucciones adicionales» preservando saltos de línea razonables
