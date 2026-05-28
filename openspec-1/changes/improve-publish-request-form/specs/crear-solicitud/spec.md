## MODIFIED Requirements

### Requirement: Formulario MUST capturar los campos requeridos por el contrato del backend

El formulario MUST capturar como mínimo los siguientes campos requeridos por `POST /open-requests`: `title`, `excerpt`, `description`, `tags`, `budgetLabel`. MUST capturar ubicación mediante controles estructurados (país, departamento/provincia, municipio/ciudad, barrio opcional) y MUST derivar `locationLabel` con formato consistente antes del envío. MUST permitir campos opcionales de imágenes vía `files` multipart. MUST NOT mostrar controles editables para `contactPhone` ni `contactEmail` en esta pantalla.

#### Scenario: Render inicial del formulario

- **WHEN** el formulario se renderiza para un usuario autenticado
- **THEN** el sistema MUST mostrar controles para título, resumen, descripción, etiquetas, ubicación estructurada (país, división, municipio, barrio) y presupuesto
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

El formulario MUST validar en cliente las restricciones del DTO `CreateOpenRequestDto` antes de emitir el `POST`, incluyendo ubicación estructurada obligatoria (país, división, municipio). El botón "Publicar solicitud" MUST permanecer **siempre clickable** (excepto durante un envío en curso), y al pulsarlo con el formulario inválido el sistema MUST mostrar feedback explícito de qué falta corregir, sin emitir el `POST`.

#### Scenario: Submit con campos requeridos vacíos muestra resumen y NO envía

- **WHEN** el usuario pulsa el botón de envío y cualquiera de los campos requeridos (`title`, `excerpt`, `description`, `tags`, país, división, municipio, `budgetLabel`) está vacío o solo contiene espacios
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST marcar los controles como tocados para que cada campo afectado muestre su mensaje de error en línea
- **AND** el sistema MUST mostrar un banner resumen que indique cuántos y cuáles son los campos por completar o corregir
- **AND** el sistema MUST llevar el foco al primer campo inválido visible

#### Scenario: Submit con barrio demasiado largo bloquea el envío

- **WHEN** el usuario pulsa el botón de envío y barrio supera 120 caracteres
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el banner resumen MUST listar "Barrio" entre los campos por corregir

#### Scenario: Submit con `imageUrl` no http(s) muestra el campo en la lista de pendientes

- **WHEN** el usuario pulsa el botón de envío con `imageUrl` rellenado y sin esquema `http://` ni `https://`
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST mostrar un mensaje de error en `imageUrl`
- **AND** el banner resumen MUST listar "URL de imagen" entre los campos por corregir

#### Scenario: `imageUrl` vacío es aceptado

- **WHEN** `imageUrl` está vacío y el resto de campos requeridos son válidos
- **THEN** el sistema MUST permitir el envío del formulario sin marcarlo como inválido

#### Scenario: Corregir el formulario tras un error de validación oculta el banner

- **WHEN** el banner resumen está visible por una validación local fallida
- **AND** el usuario corrige todos los campos pendientes hasta que el formulario es válido
- **THEN** el sistema MUST ocultar el banner resumen automáticamente y volver al estado `idle`

### Requirement: `locationLabel` MUST rechazar UUID embebido

El valor derivado de `locationLabel` a partir de los campos estructurados MUST rechazar composiciones que contengan un UUID v4 (patrón hex 8-4-4-4-12) en cualquier posición, como defensa en profundidad.

#### Scenario: Submit con barrio o segmento con UUID embebido bloquea el envío

- **WHEN** el usuario pulsa el botón de envío y algún segmento de ubicación contiene un fragmento UUID v4
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el banner resumen MUST listar "Ubicación" entre los campos por corregir

#### Scenario: Ubicación estructurada válida produce etiqueta humana

- **WHEN** país, división y municipio son válidos
- **THEN** el sistema MUST construir `locationLabel` como texto legible (p. ej. `"Palermo · Ciudad Autónoma de Buenos Aires · Argentina"`) sin UUID

### Requirement: Envío MUST consumir `POST /open-requests` y normalizar la respuesta

El envío del formulario MUST llamar a `OpenRequestsService.createOpenRequest`, que a su vez MUST hacer `POST` al mismo `apiUrl` que usa el listado y MUST devolver un `OpenRequestDetail` normalizado con la misma lógica que `getOpenRequestDetail`. El body MUST incluir `locationLabel` derivado de la ubicación estructurada y MUST NOT incluir `contactPhone` ni `contactEmail` confiables desde inputs del formulario.

#### Scenario: Submit feliz

- **WHEN** el usuario envía un formulario válido
- **THEN** el sistema MUST realizar `POST` al endpoint con un body que contiene los campos validados y normalizados (tags como array, `locationLabel` compuesto, sin contacto desde inputs visibles)
- **AND** el sistema MUST recibir un `OpenRequestDetail` con `id` no vacío

#### Scenario: Modo mock no soporta creación

- **WHEN** la URL del API apunta a un mock local (`/mock/`)
- **THEN** el sistema MUST mostrar un mensaje de error claro indicando que la creación no está disponible en modo mock y NO MUST emitir un `POST`

## REMOVED Requirements

### Requirement: Pre-fill de contacto desde la sesión

**Reason:** El email y teléfono ya no se capturan ni muestran en el formulario; el backend los resuelve desde el usuario autenticado.

**Migration:** Ninguna acción del usuario; contacto gestionado en perfil/registro y aplicado server-side al crear.

## ADDED Requirements

### Requirement: Contacto del creador MUST resolverse desde el usuario autenticado

Al crear una solicitud, el backend MUST asociar `contactEmail` y `contactPhone` al perfil del usuario identificado por la sesión (`ownerUserId` / token). MUST NOT confiar en valores de contacto enviados en el body del cliente para definir el contacto del creador.

#### Scenario: Creación con sesión válida

- **WHEN** un usuario autenticado envía un formulario válido sin campos de contacto en el body
- **THEN** el backend MUST persistir la solicitud con email y teléfono del usuario autenticado
- **AND** MUST asociar `ownerUserId` al usuario de la sesión

#### Scenario: Body con contacto distinto al perfil es ignorado

- **WHEN** el cliente envía `contactEmail` o `contactPhone` en el body distintos al perfil del usuario autenticado
- **THEN** el backend MUST ignorar esos valores y MUST persistir el contacto del perfil autenticado

#### Scenario: Usuario sin teléfono en perfil

- **WHEN** el usuario autenticado no tiene teléfono registrado y intenta publicar
- **THEN** el backend MUST responder con error de validación claro (4xx)
- **AND** MUST NOT crear la solicitud con contacto inventado

### Requirement: Botón de ayuda integrado en la pantalla de creación

La pantalla MUST incluir el botón de ayuda descrito en la capability `publish-request-guided-tour`, visible en el encabezado del formulario para usuarios autenticados.

#### Scenario: Ayuda disponible durante edición

- **WHEN** el usuario está completando el formulario
- **THEN** puede iniciar el tour en cualquier momento sin perder datos ya ingresados
