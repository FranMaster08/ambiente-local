## Why

Hoy un usuario logueado solo puede **listar** y **ver el detalle** de solicitudes abiertas o postularse con propuestas; **no existe forma desde la UI de publicar una solicitud nueva**, aunque el backend ya expone `POST /open-requests` (ver `open-requests.controller.ts` + `CreateOpenRequestUseCase`). Sin un punto de entrada en el front, esa capacidad del backend está inaccesible para los usuarios reales y bloquea el ciclo "publico solicitud → recibo propuestas → elijo proveedor".

## What Changes

- **Nueva sección "Publicar solicitud"** accesible solo para usuarios autenticados, que renderiza un formulario para crear una solicitud abierta usando el endpoint existente `POST /open-requests`.
- **Nueva ruta** dentro del shell, dependiente de sesión (p. ej. `solicitudes/nueva` y/o `mis-solicitudes/nueva`), con redirección a login si el usuario no está autenticado, siguiendo el mismo patrón de `mis-solicitudes` (`AuthSessionService.vm.isLoggedIn` + CTA "Iniciar sesión / Crear cuenta").
- **Formulario reactivo** con los campos requeridos por `CreateOpenRequestDto` (`title`, `excerpt`, `description`, `tags[]`, `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`) y opcionales clave (`imageUrl`/`imageAlt`, `publishedAtLabel`), con validaciones cliente alineadas a los validators del DTO (`@IsNotEmpty`, `@IsEmail`, etc.) y mensajes en español.
- **Extensión de `OpenRequestsService`** con métodos `createOpenRequest(input): Observable<OpenRequestDetail>` y `listMyOpenRequests(params): Observable<OpenRequestsListResponse>` que envían `POST`/`GET` al endpoint real y normalizan la respuesta con los helpers ya existentes.
- **Estados de UI consistentes** con el resto de features: `idle`, `submitting`, `success`, `error` (skeletons / `state state--error` / botón `Reintentar`), `aria-busy` y `role="status"` como en `my-requests-dashboard`.
- **Entradas de navegación**: CTA "Publicar nueva solicitud" en `my-requests-dashboard` (estado vacío y header) y en `open-requests-landing`, visibles solo si `isLoggedIn`.
- **Después de crear** la solicitud, navegar al detalle (`/solicitudes/:id`) o al listado de "Mis solicitudes" mostrando un toast/banner de éxito.
- **Manejo de auth**: si el token expira o el backend responde 401/403, limpiar la sesión vía `AuthSessionService.clear()` y redirigir a login conservando el formulario en estado de error recuperable.
- **Tabs "Publicadas por mí" / "Postulé a estas"** en `my-requests-dashboard`: la pantalla MUST permitir al usuario alternar entre las solicitudes que él mismo publicó (vía nuevo endpoint autenticado) y las solicitudes a las que postuló (lista actual basada en proposals locales).
- **Nuevo endpoint backend `GET /open-requests/mine`** autenticado bajo nuevo permiso `open-requests.read.own`, que devuelve paginadas únicamente las solicitudes cuyo `ownerUserId` coincide con el `req.user.userId`. Reutiliza el mismo `OpenRequestsListResponseDto` para que el front pueda compartir el modelo de lista.
- **Sin cambios breaking** en el contrato del endpoint público existente `GET /open-requests` (sigue listando todas y se mantiene `@Public()`); el nuevo endpoint es aditivo.

## Capabilities

### New Capabilities

- `crear-solicitud`: Sección de UI autenticada que permite a un usuario logueado componer y publicar una solicitud abierta consumiendo `POST /open-requests`, incluyendo formulario validado, manejo de estados (carga / éxito / error / no autenticado), navegación post-creación y CTAs de entrada desde "Mis solicitudes" y "Solicitudes abiertas".
- `mis-solicitudes-publicadas`: Capability que permite al usuario autenticado consultar las solicitudes que él mismo publicó. Cubre el nuevo endpoint backend `GET /open-requests/mine` (autenticado, filtrado por `ownerUserId = req.user.userId`) y la integración en `my-requests-dashboard` mediante tabs que separan "Publicadas por mí" de "Postulé a estas".

### Modified Capabilities

- _(Ninguna spec raíz existente afectada formalmente: `home-promotional-slider` y `registro-usuario-completo` no cambian sus requisitos. El comportamiento extendido de `my-requests-dashboard` se documenta en la nueva capability `mis-solicitudes-publicadas` para no fragmentar el spec original entre el repo `anyjobs-front` y este change a nivel raíz.)_

## Impact

- **Frontend (Angular, `anyjobs-front/anyjobs/src/app`):**
  - Nueva carpeta de feature (p. ej. `features/open-requests/open-request-create/`) con componente standalone (`open-request-create.ts`/`.html`/`.scss`/`.spec.ts`) que reutiliza el patrón visual `page > container > header (kicker/title/subtitle)`.
  - Nueva entrada en `app.routes.ts` bajo `solicitudes/nueva` (y/o redirección desde `mis-solicitudes/nueva`), cargada como `loadComponent`.
  - Modificación de `features/open-requests/open-requests.service.ts` para añadir `createOpenRequest()` y `listMyOpenRequests()`, junto a sus DTO/normalización.
  - Modificación de `features/my-requests/my-requests-dashboard/*` para incorporar tabs "Publicadas por mí" / "Postulé a estas" y los CTAs visibles a usuarios autenticados.
  - Modificación de `features/open-requests/open-requests-landing/*` para añadir CTA visible a usuarios autenticados.
  - Posible reutilización de `ModalComponent` para confirmación de éxito.
- **Backend (`anyjobs-back/apps/api/src/modules/open-requests`):**
  - Extensión del puerto `OpenRequestsRepositoryPort` con `listByOwner(ownerUserId, pageRequest)`.
  - Implementación en `TypeOrmOpenRequestsRepository` (`where: { ownerUserId, deletedAt IS NULL }`) y en `InMemoryOpenRequestsRepository` (filtrar por `owners` map).
  - Nuevo `ListMyOpenRequestsUseCase` análogo al `ListOpenRequestsUseCase`, con paginación normalizada.
  - Nueva ruta `GET /open-requests/mine` en `OpenRequestsController` protegida por `@RequirePermissions('open-requests.read.own')`, que pasa `req.user.userId` al use case y devuelve `OpenRequestsListResponseDto`.
  - Nuevo helper Swagger `GetMyOpenRequestsListSwagger`.
  - Registro del nuevo use case en `OpenRequestsModule`.
  - El endpoint público `GET /open-requests` y el resto del contrato no cambian.
- **Permisos / seguridad:**
  - `open-requests.create` (ya existente) sigue gobernando `POST /open-requests`.
  - **Nuevo permiso `open-requests.read.own`** asignado por el backend (deny-by-default del guard) para `GET /open-requests/mine`. En MVP, el guard ya hace passthrough cuando no se proveen `x-permissions` y el endpoint declara permisos requeridos, por lo que un usuario autenticado pasa la verificación.
- **Dependencias:** ninguna nueva. Se usa el stack existente: Angular standalone + signals, `HttpClient`, `AuthSessionService`, `ReactiveFormsModule`; NestJS + TypeORM en backend.
- **Pruebas:**
  - Frontend: `*.spec.ts` para el nuevo componente y para los nuevos métodos del servicio (`createOpenRequest`, `listMyOpenRequests`); actualización del spec de `my-requests-dashboard` para el flujo de tabs.
  - Backend: pruebas unitarias del nuevo use case y, si aplica, e2e del nuevo endpoint.
