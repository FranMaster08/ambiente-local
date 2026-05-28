## ADDED Requirements

### Requirement: Captura de condiciones y recursos en publicación

La pantalla «Publicar solicitud» MUST incluir una sección titulada **«Condiciones y recursos disponibles»** ubicada después de «Ubicación y presupuesto» y antes de «Contenido multimedia».

La sección MUST permitir configurar las siguientes opciones mediante selección única controlada (no texto libre):

1. Herramientas propias requeridas — `yes` / `no` / `optional`
2. El trabajador debe trasladarse al lugar — `yes` / `no` / `to_coordinate`
3. El solicitante ofrece materiales — `yes` / `no` / `partially`
4. El solicitante ofrece herramientas o equipos — `yes` / `no` / `partially`
5. Se requiere experiencia previa — `yes` / `no` / `desirable`
6. Se permite coordinar horario — `yes` / `no` / `to_coordinate`
7. El trabajo requiere visita previa — `yes` / `no` / `to_coordinate`
8. El lugar tiene acceso fácil o instrucciones especiales — `yes` / `no` / `requires_instructions`

La sección MUST incluir un campo de texto opcional **«Instrucciones adicionales»** (máx. 500 caracteres) para detalles como acceso, parqueadero, materiales o restricciones.

Ningún campo de esta sección MUST ser obligatorio para publicar.

#### Scenario: Sección visible en orden correcto

- **WHEN** un usuario autenticado renderiza `/solicitudes/nueva`
- **THEN** el DOM MUST mostrar la sección «Condiciones y recursos disponibles» después del fieldset de ubicación/presupuesto y antes del fieldset de contenido multimedia

#### Scenario: Publicar sin completar condiciones

- **WHEN** el usuario completa todos los campos requeridos del resto del formulario y deja vacía la sección de condiciones
- **THEN** el sistema MUST permitir enviar el formulario
- **AND** MUST NOT incluir `workConditions` en el payload o MUST enviar objeto vacío omitido

#### Scenario: Valores seleccionados se envían al backend

- **WHEN** el usuario selecciona «Sí» en herramientas propias requeridas y escribe instrucciones adicionales
- **THEN** el `POST /open-requests` MUST incluir `workConditions` con `ownToolsRequired: "yes"` y el texto en `additionalInstructions`

### Requirement: Diseño responsive de la sección de condiciones

La sección MUST usar diseño limpio agrupado en filas o tarjetas, coherente con tokens y patrones de `open-request-create`. En viewport ≥768px MAY mostrarse en dos columnas; en mobile MUST apilarse en una columna con targets táctiles adecuados.

#### Scenario: Layout mobile

- **WHEN** el viewport es ≤640px
- **THEN** cada condición MUST ocupar ancho completo sin overflow horizontal

#### Scenario: Layout desktop

- **WHEN** el viewport es ≥768px
- **THEN** las filas de condiciones MAY organizarse en grid de dos columnas manteniendo legibilidad

### Requirement: Tour guiado incluye paso de condiciones

El tour «Guía paso a paso» MUST incluir un paso anclado a `[data-tour="publish-work-conditions"]` que explique brevemente el propósito de la sección.

#### Scenario: Tour muestra paso de condiciones

- **WHEN** el usuario inicia el tour desde el encabezado
- **THEN** MUST existir un paso que resalte la sección de condiciones y recursos antes del paso de multimedia

### Requirement: Etiquetas legibles en UI de captura

Cada opción MUST mostrarse al usuario con etiquetas en español legibles (p. ej. «Sí», «No», «Opcional / No estoy seguro»), no con los valores técnicos del enum.

#### Scenario: Usuario ve etiquetas humanas

- **WHEN** la sección se renderiza
- **THEN** las opciones MUST mostrar textos en español comprensibles, no valores como `to_coordinate`

## MODIFIED Requirements

### Requirement: Formulario MUST capturar los campos requeridos por el contrato del backend

El formulario MUST capturar como mínimo los siguientes campos requeridos por `POST /open-requests`: `title`, `excerpt`, `description`, `tags`, `budgetLabel`. MUST capturar ubicación mediante controles estructurados (país, departamento/provincia, municipio/ciudad, barrio opcional) y MUST derivar `locationLabel` con formato consistente antes del envío. MUST permitir campos opcionales de imágenes vía `files` multipart. MUST NOT mostrar controles editables para `contactPhone` ni `contactEmail` en esta pantalla. MUST permitir opcionalmente el objeto `workConditions` descrito en la sección «Condiciones y recursos disponibles».

#### Scenario: Render inicial del formulario

- **WHEN** el formulario se renderiza para un usuario autenticado
- **THEN** el sistema MUST mostrar controles para título, resumen, descripción, etiquetas, ubicación estructurada (país, división, municipio, barrio), presupuesto y la sección de condiciones y recursos
- **AND** MUST NOT mostrar inputs editables de email ni teléfono
- **AND** MUST NOT mostrar un único campo de ubicación de texto libre

#### Scenario: País limitado a Colombia y Argentina

- **WHEN** el usuario abre el selector de país
- **THEN** el sistema MUST ofrecer únicamente Colombia (CO) y Argentina (AR)

#### Scenario: Divisiones y municipios dependientes

- **WHEN** el usuario selecciona un país
- **THEN** el selector de departamento/provincia MUST listar solo divisiones válidas para ese país
- **WHEN** el usuario selecciona una división
- **THEN** el selector de municipio/ciudad MUST listar solo municipios válidos para esa división

#### Scenario: Barrio como texto libre opcional

- **WHEN** el usuario completa barrio
- **THEN** el sistema MUST aceptar texto libre hasta la longitud máxima configurada (120 caracteres)
- **WHEN** barrio está vacío y país, división y municipio son válidos
- **THEN** el sistema MUST permitir el envío del formulario

### Requirement: Validaciones cliente espejo del DTO del backend

El formulario MUST validar en cliente las restricciones del DTO `CreateOpenRequestDto` antes de emitir el `POST`, incluyendo ubicación estructurada obligatoria (país, división, municipio) y, si el usuario completó `workConditions`, los enums y longitud de `additionalInstructions`. El botón "Publicar solicitud" MUST permanecer **siempre clickable** (excepto durante un envío en curso), y al pulsarlo con el formulario inválido el sistema MUST mostrar feedback explícito de qué falta corregir, sin emitir el `POST`.

#### Scenario: Submit con campos requeridos vacíos muestra resumen y NO envía

- **WHEN** el usuario pulsa el botón de envío y cualquiera de los campos requeridos (`title`, `excerpt`, `description`, `tags`, país, división, municipio, `budgetLabel`) está vacío o solo contiene espacios
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST marcar los controles como tocados para que cada campo afectado muestre su mensaje de error en línea
- **AND** el sistema MUST mostrar un banner resumen que indique cuántos y cuáles son los campos por completar o corregir
- **AND** el sistema MUST llevar el foco al primer campo inválido visible

#### Scenario: Submit con instrucciones adicionales demasiado largas bloquea el envío

- **WHEN** el usuario pulsa el botón de envío y `additionalInstructions` supera 500 caracteres
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el banner resumen MUST listar «Instrucciones adicionales» entre los campos por corregir

#### Scenario: Submit con barrio demasiado largo bloquea el envío

- **WHEN** el usuario pulsa el botón de envío y barrio supera 120 caracteres
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el banner resumen MUST listar "Barrio" entre los campos por corregir

#### Scenario: Corregir el formulario tras un error de validación oculta el banner

- **WHEN** el banner resumen está visible por una validación local fallida
- **AND** el usuario corrige todos los campos pendientes hasta que el formulario es válido
- **THEN** el sistema MUST ocultar el banner resumen automáticamente y volver al estado `idle`

### Requirement: Envío MUST consumir `POST /open-requests` y normalizar la respuesta

El envío del formulario MUST llamar a `OpenRequestsService.createOpenRequest`, que a su vez MUST hacer `POST` al mismo `apiUrl` que usa el listado y MUST devolver un `OpenRequestDetail` normalizado con la misma lógica que `getOpenRequestDetail`. Cuando existan condiciones capturadas, MUST serializar `workConditions` en el multipart (JSON string) o body según el contrato vigente.

#### Scenario: Submit feliz con condiciones

- **WHEN** el usuario envía un formulario válido incluyendo al menos un subcampo de `workConditions`
- **THEN** el sistema MUST realizar `POST` con `workConditions` serializado correctamente
- **AND** el sistema MUST recibir un `OpenRequestDetail` con `id` no vacío

#### Scenario: Submit feliz

- **WHEN** el usuario envía un formulario válido
- **THEN** el sistema MUST realizar `POST` al endpoint con un body que contiene los campos validados y normalizados (tags como array, sin campos vacíos)
- **AND** el sistema MUST recibir un `OpenRequestDetail` con `id` no vacío

### Requirement: Campos no expuestos en el formulario delegan al default del backend

El formulario MUST NOT exponer los campos `provider`, `reputation`, `reviewsCount`, `providerReviews`, `publishedAtLabel` ni `images[]` como URLs en esta entrega; el backend MUST asignarles defaults seguros. Las imágenes MUST enviarse vía `files` multipart.

#### Scenario: Body enviado al backend no contiene campos no expuestos

- **WHEN** el formulario se envía
- **THEN** el body del `POST` NO MUST incluir las claves `provider`, `reputation`, `reviewsCount`, `providerReviews` ni `images` como array URL
- **AND** el body NO MUST incluir `publishedAtLabel` (el backend asigna `"Recién publicado"` como default)
