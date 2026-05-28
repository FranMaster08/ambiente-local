## Purpose

Definir el comportamiento y los requisitos de la pantalla **"Publicar solicitud"** que permite a un usuario autenticado crear una nueva solicitud abierta consumiendo el endpoint vigente `POST /open-requests`, con manejo explícito de validaciones, estados UX (carga / éxito / error / no-auth), navegación post-creación y CTAs de descubrimiento desde "Mis solicitudes" y "Solicitudes abiertas".

## ADDED Requirements

### Requirement: Ruta de "Publicar solicitud"
El sistema MUST exponer una ruta dedicada para la pantalla "Publicar solicitud".

#### Scenario: Usuario navega a "Publicar solicitud"
- **WHEN** el usuario navega a la URL `/solicitudes/nueva`
- **THEN** el sistema MUST renderizar la pantalla "Publicar solicitud"

#### Scenario: La ruta convive con el listado y el detalle
- **WHEN** el usuario navega a `/solicitudes/nueva`
- **THEN** el sistema MUST resolver la pantalla de creación y NO MUST tratar `nueva` como un `:id` de solicitud existente

### Requirement: "Publicar solicitud" MUST requerir sesión iniciada
La pantalla "Publicar solicitud" MUST estar disponible únicamente para usuarios con sesión activa.

#### Scenario: Usuario sin sesión accede a la pantalla
- **WHEN** el usuario no tiene sesión iniciada y accede a `/solicitudes/nueva`
- **THEN** el sistema MUST bloquear el formulario y MUST mostrar un bloque de "no-auth" con CTAs para iniciar sesión y para crear cuenta

#### Scenario: Usuario con sesión accede correctamente
- **WHEN** el usuario tiene sesión iniciada y accede a `/solicitudes/nueva`
- **THEN** el sistema MUST renderizar el formulario de publicación

### Requirement: Formulario MUST capturar los campos requeridos por el contrato del backend
El formulario MUST capturar como mínimo los siguientes campos requeridos por `POST /open-requests`: `title`, `excerpt`, `description`, `tags`, `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`. MUST permitir campos opcionales `imageUrl` e `imageAlt`.

#### Scenario: Render inicial del formulario
- **WHEN** el formulario se renderiza para un usuario autenticado
- **THEN** el sistema MUST mostrar controles para todos los campos requeridos del contrato y para los opcionales `imageUrl`/`imageAlt`

#### Scenario: Pre-fill de contacto desde la sesión
- **WHEN** la sesión activa contiene `email` (y opcionalmente `phone`) del usuario
- **THEN** el sistema MUST pre-rellenar `contactEmail` (y `contactPhone` si está disponible) con esos valores

### Requirement: Validaciones cliente espejo del DTO del backend
El formulario MUST validar en cliente las restricciones del DTO `CreateOpenRequestDto` antes de emitir el `POST`. El botón "Publicar solicitud" MUST permanecer **siempre clickable** (excepto durante un envío en curso), y al pulsarlo con el formulario inválido el sistema MUST mostrar feedback explícito de qué falta corregir, sin emitir el `POST`.

#### Scenario: Submit con campos requeridos vacíos muestra resumen y NO envía
- **WHEN** el usuario pulsa el botón de envío y cualquiera de los campos requeridos (`title`, `excerpt`, `description`, `tags`, `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`) está vacío o solo contiene espacios
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST marcar los controles como tocados para que cada campo afectado muestre su mensaje de error en línea
- **AND** el sistema MUST mostrar un banner resumen que indique cuántos y cuáles son los campos por completar o corregir
- **AND** el sistema MUST llevar el foco al primer campo inválido visible

#### Scenario: Submit con `contactEmail` mal formado muestra el campo en la lista de pendientes
- **WHEN** el usuario pulsa el botón de envío y `contactEmail` no respeta el formato de email
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST mostrar un mensaje de error en `contactEmail`
- **AND** el banner resumen MUST listar "Email" entre los campos por corregir

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

### Requirement: Tags MUST normalizarse a una lista no vacía de strings únicos
El campo `tags` MUST aceptarse como entrada de texto separada por comas y MUST enviarse al backend como un array de strings recortados, no vacíos y sin duplicados.

#### Scenario: Entrada con espacios y duplicados se normaliza
- **WHEN** el usuario introduce `"Limpieza, plomería ,  Limpieza ,  "` en el campo de tags
- **THEN** el sistema MUST enviar `tags = ["Limpieza", "plomería"]` al backend

#### Scenario: Submit con tags que tras normalizar queda vacío bloquea el envío
- **WHEN** el usuario pulsa el botón de envío y tras la normalización el array de tags queda vacío
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST mostrar un mensaje de error en el campo de tags
- **AND** el banner resumen MUST listar "Etiquetas" entre los campos por corregir

### Requirement: `locationLabel` MUST rechazar UUID embebido
El campo `locationLabel` MUST rechazar valores que contengan un UUID v4 (patrón hex 8-4-4-4-12) en cualquier posición, como defensa en profundidad ante datos sucios observados en el listado.

#### Scenario: Submit con `locationLabel` con UUID embebido bloquea el envío
- **WHEN** el usuario pulsa el botón de envío y `locationLabel` contiene un fragmento que coincide con el patrón UUID v4 (por ejemplo `"4f1a2b3c-9d2e-4a7b-8c6d-1234567890ab · Sevilla · Triana"`)
- **THEN** el sistema NO MUST emitir el `POST` al backend
- **AND** el sistema MUST mostrar un mensaje de error en `locationLabel`
- **AND** el banner resumen MUST listar "Ubicación" entre los campos por corregir

#### Scenario: `locationLabel` con etiqueta humana es aceptado
- **WHEN** `locationLabel` contiene únicamente texto humano (por ejemplo `"Barcelona · Eixample"`)
- **THEN** el sistema MUST permitir el envío del formulario

### Requirement: Envío MUST consumir `POST /open-requests` y normalizar la respuesta
El envío del formulario MUST llamar a `OpenRequestsService.createOpenRequest`, que a su vez MUST hacer `POST` al mismo `apiUrl` que usa el listado y MUST devolver un `OpenRequestDetail` normalizado con la misma lógica que `getOpenRequestDetail`.

#### Scenario: Submit feliz
- **WHEN** el usuario envía un formulario válido
- **THEN** el sistema MUST realizar `POST` al endpoint con un body que contiene los campos validados y normalizados (tags como array, sin campos vacíos)
- **AND** el sistema MUST recibir un `OpenRequestDetail` con `id` no vacío

#### Scenario: Modo mock no soporta creación
- **WHEN** la URL del API apunta a un mock local (`/mock/`)
- **THEN** el sistema MUST mostrar un mensaje de error claro indicando que la creación no está disponible en modo mock y NO MUST emitir un `POST`

### Requirement: Estados UX de carga, éxito y error durante el envío
La pantalla MUST exponer estados UX explícitos durante el envío del formulario.

#### Scenario: Estado de envío en curso
- **WHEN** el formulario se envía y la respuesta del backend aún no llega
- **THEN** el sistema MUST deshabilitar el botón de envío
- **AND** el sistema MUST exponer un indicador accesible de actividad (por ejemplo `aria-busy="true"`)

#### Scenario: Éxito de creación
- **WHEN** el backend responde con éxito y entrega un `OpenRequestDetail` con `id`
- **THEN** el sistema MUST mostrar una confirmación visible al usuario
- **AND** el sistema MUST navegar a `/solicitudes/<id>` con el `id` devuelto por el backend

#### Scenario: Error genérico del backend
- **WHEN** el backend responde con un error distinto de `401`/`403` (por ejemplo `400`, `500` o fallo de red)
- **THEN** el sistema MUST mostrar un estado de error con un mensaje en español
- **AND** el sistema MUST ofrecer una acción "Reintentar" que vuelva a enviar el formulario sin perder los datos introducidos

### Requirement: Manejo explícito de sesión expirada o sin permisos
El sistema MUST diferenciar los casos `401` (no autorizado) y `403` (sin permisos) del backend y reaccionar adecuadamente.

#### Scenario: Sesión expirada (`401`)
- **WHEN** el backend responde `401` al intentar publicar la solicitud
- **THEN** el sistema MUST limpiar la sesión local del usuario
- **AND** el sistema MUST mostrar un mensaje "Tu sesión expiró, vuelve a iniciar sesión" con CTA a iniciar sesión

#### Scenario: Sin permisos (`403`)
- **WHEN** el backend responde `403` al intentar publicar la solicitud
- **THEN** el sistema MUST mostrar un mensaje claro indicando que la cuenta no tiene permiso para publicar solicitudes
- **AND** el sistema MUST mantener al usuario en la pantalla con sus datos preservados

### Requirement: Campos no expuestos en el formulario delegan al default del backend
El formulario MUST NOT exponer los campos `provider`, `reputation`, `reviewsCount`, `providerReviews`, `publishedAtLabel` ni `images[]` en esta entrega; el backend MUST asignarles defaults seguros.

#### Scenario: Body enviado al backend no contiene campos no expuestos
- **WHEN** el formulario se envía
- **THEN** el body del `POST` NO MUST incluir las claves `provider`, `reputation`, `reviewsCount`, `providerReviews` ni `images`
- **AND** el body NO MUST incluir `publishedAtLabel` (el backend asigna `"Recién publicado"` como default)

### Requirement: CTAs de descubrimiento desde otras vistas
La aplicación MUST exponer CTAs visibles solo a usuarios autenticados que naveguen a `/solicitudes/nueva` desde la pantalla "Mis solicitudes" y desde la landing de "Solicitudes abiertas".

#### Scenario: CTA en "Mis solicitudes"
- **WHEN** un usuario autenticado entra a `/mis-solicitudes`
- **THEN** el sistema MUST mostrar un CTA "Publicar solicitud" que navega a `/solicitudes/nueva`

#### Scenario: CTA en "Solicitudes abiertas"
- **WHEN** un usuario autenticado entra a `/solicitudes`
- **THEN** el sistema MUST mostrar un CTA "Publicar solicitud" que navega a `/solicitudes/nueva`

#### Scenario: CTAs ocultos para usuarios no autenticados
- **WHEN** un usuario sin sesión iniciada entra a `/mis-solicitudes` o `/solicitudes`
- **THEN** el sistema MUST NOT mostrar el CTA "Publicar solicitud"

### Requirement: Consistencia visual con el sistema de diseño existente
La pantalla MUST reutilizar tokens y patrones visuales ya presentes en `my-requests-dashboard`, `open-requests-landing` y `registration`, sin introducir nuevas variables CSS ni romper la jerarquía visual.

#### Scenario: Layout y tipografía
- **WHEN** la pantalla se renderiza en un viewport ≥520 px
- **THEN** el sistema MUST usar el patrón `section.page > .container` con `max-width` equivalente al usado en "Mis solicitudes"
- **AND** el sistema MUST usar el patrón de cabecera `kicker` / `title` / `subtitle` con los mismos tokens (`--aj-color-subtle`, `--aj-color-surface`, `--aj-color-border`, `--aj-radius-md`, `--aj-shadow-sm`)

#### Scenario: Botones y estados
- **WHEN** la pantalla expone botones primarios y secundarios o estados de error
- **THEN** el sistema MUST usar las clases existentes `.btn`, `.btn--secondary`, `.state` y `.state--error` sin redefinir su apariencia base
