## ADDED Requirements

### Requirement: Proposals list response envelope

El cliente Angular SHALL interpretar las respuestas exitosas de `GET /proposals` como un objeto JSON con al menos `items` (lista de propuestas) y `meta` (metadatos de paginación coherente con el backend, incluyendo información de página siguiente/anterior).

#### Scenario: Listado utiliza items y puede usar meta

- **WHEN** el cliente recibe `200` de `GET /proposals` con cuerpo que incluye `items` y `meta`
- **THEN** el cliente SHALL construir la lista de propuestas a partir de `items` y MAY usar `meta` (p. ej. `nextPage`, `hasNextPage`) para decisiones de paginación o “cargar más”

### Requirement: Proposal creation contract

El cliente SHALL enviar `POST /proposals` con cuerpo JSON compatible con el DTO de creación del backend (`requestId`, `userId`, `authorName`, `authorSubtitle`, `whoAmI`, `message`, `estimate` — todos requeridos salvo que el backend acuerde otra cosa en una versión posterior documentada).

El cliente SHALL aceptar respuesta `201 Created` (y MAY aceptar `200` si el servidor lo devuelve en despliegues legados) con cuerpo que corresponde al modelo de propuesta persistida, incluyendo `author` anidado con `name` y `subtitle` requeridos en el contrato del API.

#### Scenario: Respuesta de creación se mapea al modelo de dominio

- **WHEN** el servidor responde tras crear una propuesta con un cuerpo JSON alineado a `ProposalDto`
- **THEN** el cliente SHALL mapearlo al tipo de dominio `Proposal` sin asumir formatos obsoletos (p. ej. arreglos planos en lugar de objeto de propuesta)

### Requirement: Open request create and patch transport

Para `POST /open-requests` y `PATCH /open-requests/:id`, el cliente SHALL usar peticiones compatibles con el controlador que aplica `FilesInterceptor('files', 6)`:

- contenido multipart (`multipart/form-data`) cuando corresponda publicar o adjuntar imágenes como archivos;
- partes de archivo usando el nombre de campo esperado **`files`** (hasta 6 ficheros por petición según el backend);
- campos escalares y colecciones del DTO enviados de forma que el backend pueda aplicar sus reglas de validación y `@Transform` (incluyendo campos opcionales como `imageUrl` / `imageAlt` / `images` según producto).

#### Scenario: Crear solicitud con archivos adjuntos

- **WHEN** el usuario publica una solicitud incluyendo imágenes locales seleccionadas en el cliente
- **THEN** el cliente SHALL enviar `POST /open-requests` como multipart con esos ficheros en `files` más los campos requeridos del formulario traducidos al contrato del API

#### Scenario: Actualizar solicitud existente con multipart

- **WHEN** un usuario autenticado con permiso de actualización modifica una solicitud abierta existente
- **THEN** el cliente SHALL llamar `PATCH /open-requests/{id}` con payload multipart acorde al DTO parcial esperado por el backend y SHALL mapear la respuesta al modelo `OpenRequestDetail` del front

### Requirement: Open request read endpoints alignment

El cliente SHALL seguir consumiendo `GET /open-requests` (público), `GET /open-requests/mine` (autenticado) y `GET /open-requests/{id}` (público) con los parámetros de query soportados por el backend (`page`, `pageSize`, `sort` donde aplique), y SHALL normalizar las respuestas de listado y detalle a los modelos de dominio existentes del front sin perder campos requeridos por la UI (p. ej. `images` como arreglo, objeto `provider`).

#### Scenario: Detalle por id

- **WHEN** el cliente solicita el detalle de una solicitud por id
- **THEN** el cliente SHALL interpretar la respuesta como `OpenRequestDetailDto` compatible y SHALL producir un `OpenRequestDetail` con reglas de fallback documentadas en implementación (títulos, excerpt, imágenes)

### Requirement: Documentación de contratos en el front

El proyecto del front SHALL mantener documentación actualizada (p. ej. `anyjobs-front/anyjobs/docs/ENDPOINTS_Y_CONTRATOS_API.md`) que refleje los envoltorios reales (`items`+`meta` para propuestas, multipart para creación/edición de open requests, códigos HTTP de creación) para que implementaciones futuras no reintroduzcan contratos obsoletos.

#### Scenario: Payloads reflejan el API actual

- **WHEN** un desarrollador consulta la documentación de contratos del front
- **THEN** la documentación SHALL describir la forma de las peticiones y respuestas alineada con el backend descrito en este cambio
