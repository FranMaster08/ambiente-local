## Context

**Anyjobs** ya tiene la feature `open-requests` en el front (`anyjobs-front/anyjobs/src/app/features/open-requests/`) con `landing`, `detail`, `proposal-compose` y un `OpenRequestsService` que solo expone **lectura** (`listOpenRequests`, `getOpenRequestDetail`).

El backend (`anyjobs-back/apps/api/src/modules/open-requests/`) ya implementa el endpoint **`POST /open-requests`** vía `OpenRequestsController.create` + `CreateOpenRequestUseCase`, protegido con `@RequirePermissions('open-requests.create')` y deriva `ownerUserId` de `req.user.userId`. Acepta el DTO `CreateOpenRequestDto` con campos requeridos (`title`, `excerpt`, `description`, `tags[]`, `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`) y opcionales (`publishedAtLabel`, `imageUrl`, `imageAlt`, `images[]`, `provider`, `reputation`, `reviewsCount`, `providerReviews[]`).

La sesión del usuario se gestiona con `AuthSessionService` (signals + `localStorage` con claves `anyjobs.auth.token` / `anyjobs.auth.user`); el patrón `vm = computed({ session, isLoggedIn, user })` es el que usan `my-requests-dashboard` y `open-requests-landing` para gating de UI.

El sistema visual reutiliza tokens CSS (`--aj-color-bg`, `--aj-color-surface`, `--aj-color-border`, `--aj-radius-md`, `--aj-shadow-sm`) y el patrón `section.page > .container > header (.kicker / .title / .subtitle)` con clases `.btn`, `.btn--secondary`, `.state`, `.state--error`, `ModalComponent`. Los componentes son **standalone** con `ChangeDetectionStrategy.OnPush` y signals.

**Stakeholders:** usuario final autenticado (necesita publicar solicitudes), equipo backend (contrato vigente), equipo de diseño/UX (consistencia visual).

## Goals / Non-Goals

**Goals:**

- Habilitar a un usuario autenticado a publicar una solicitud abierta desde la UI consumiendo el endpoint vigente sin cambios de contrato.
- Mantener la coherencia visual y estructural con `my-requests-dashboard`, `open-requests-landing` y `registration` (mismo "lenguaje" de tokens, layout, estados, modales).
- Reutilizar `OpenRequestsService` para que la creación viva junto a list/detail (un solo punto de acceso al recurso).
- Manejar de forma explícita los estados `no-auth`, `idle`, `submitting`, `success`, `error` y casos `401/403`.
- Habilitar **CTAs de descubrimiento** en `my-requests-dashboard` y `open-requests-landing` para que el usuario logueado encuentre la acción.

**Non-Goals:**

- **Sin upload de archivos**: las imágenes se aceptan solo por URL (`imageUrl`), igual que el contrato actual del backend para esta entrega. Un futuro `images[]` con upload queda para otro change.
- **Sin formulario multi-paso** estilo `registration`: la cantidad de campos no lo justifica.
- **Sin edición** de solicitudes desde esta UI (`PATCH /open-requests/:id` y `DELETE` quedan para otro change).
- **Sin selector de provider/reviews/reputación** desde el form: son campos del autor que el backend completa con defaults seguros (`provider = { Cliente, NUEVO, Solicitud publicada }`, `reputation = 0`, `reviewsCount = 0`, `providerReviews = []`); exponerlos confunde el modelo mental "estoy publicando MI solicitud".
- **Sin route guard** dedicado: el gating se hace dentro del componente con `AuthSessionService.vm.isLoggedIn` (mismo patrón que `my-requests-dashboard`), evitando crear infraestructura nueva solo para esta vista.
- **Sin spec backend nueva**: el contrato no cambia.

## Decisions

### 1. Ruta y ubicación del componente

- **Ruta canónica:** `/solicitudes/nueva` (declarada en `app.routes.ts` dentro del bloque `solicitudes` ya existente, antes de `:id`).
- **Acceso secundario:** CTA "Publicar nueva solicitud" en `my-requests-dashboard` (header y estado vacío) y en `open-requests-landing` (cabecera). No se crea una segunda ruta `/mis-solicitudes/nueva` para evitar duplicar URLs canónicas.
- **Componente:** `features/open-requests/open-request-create/open-request-create.{ts,html,scss,spec.ts}`, standalone, `OnPush`.
- **Rationale:** vive dentro de `open-requests` porque es el mismo recurso. Ponerlo en `my-requests` obligaría a importar across-feature. La ruta `/solicitudes/nueva` se lee como "publicar en el catálogo de solicitudes abiertas".
- **Alternativa descartada:** modal sobre `my-requests-dashboard`. Se descartó porque el formulario tiene ~10 campos + secciones (contacto, ubicación, descripción), y un modal compromete usabilidad móvil.

### 2. Arquitectura del formulario

- **`ReactiveFormsModule`** con `FormBuilder.nonNullable.group(...)`, igual que `registration`, pero **sin estado de stages**: una sola pantalla con secciones visuales (`fieldset`/`legend` o `.section` divs).
- **Secciones visuales** (sin paso a paso):
  1. *Información principal*: `title`, `excerpt`, `description`, `tags`.
  2. *Ubicación y presupuesto*: `locationLabel`, `budgetLabel`.
  3. *Contacto*: `contactPhone`, `contactEmail` (pre-fill desde `authVm().user` si existen `email`/`phone`).
  4. *Imagen (opcional)*: `imageUrl`, `imageAlt`.
- **Validaciones espejo** del DTO:
  - `Validators.required` en todos los requeridos del DTO.
  - `Validators.email` en `contactEmail`.
  - `Validators.minLength(3)` en `title`, `Validators.minLength(20)` en `description` para forzar contenido útil.
  - `Validators.maxLength(160)` en `excerpt` (resumen visible en card).
  - **`locationLabel`**: `Validators.pattern(/^(?!.*[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}).*/i)` para impedir UUID embebido (defensa en profundidad alineada con `locationLabelZoneOnly` del landing).
  - **`tags`**: control de tipo `string` que se parsea `split(',').map(trim).filter(non-empty).dedupe()`; mínimo 1 tag.
  - **`imageUrl`**: opcional; si se rellena, `Validators.pattern(/^https?:\/\/.+/i)`.
- **Sin async validators** en esta entrega (no hay endpoints de "título disponible" ni similar).

### 3. Tags input UX

- **Decisión:** input de texto único con placeholder "Limpieza, Plomería" y hint "Separa con comas". Al `blur` o submit, se normaliza a `string[]`.
- **Rationale:** menor superficie y costo. Un componente chip-input dedicado es valioso pero queda fuera de scope (otro change si se valida demanda).
- **Alternativa considerada:** chip-input con `(keydown.enter)` y `(keydown.,)` agregando chips visibles. Rechazada por scope.

### 4. Manejo de imágenes

- **Decisión:** solo `imageUrl` + `imageAlt`. No se expone `images[]` (galería) en esta entrega.
- **Rationale:** no hay endpoint de upload ni storage configurado en el front. Aceptar URLs externas (https) cubre el contrato y permite avanzar; una vez exista upload, se añadirá `images[]`.
- **Alternativa considerada:** `<input type="file">` con base64. Rechazada: el DTO espera URLs, no blobs.

### 5. Campos derivados / no expuestos

- **No se piden** al usuario: `provider`, `reputation`, `reviewsCount`, `providerReviews`, `publishedAtLabel`. El use case les asigna defaults razonables (`Cliente / NUEVO / 0 / [] / "Recién publicado"`).
- **`provider.name`** podría enriquecerse a futuro con `authVm().user.fullName` si el backend lo aceptara como override del `Cliente` por defecto, pero para esta entrega se respeta el default del backend para no introducir comportamiento divergente.
- **Open question** (ver abajo): si en el futuro queremos que `provider.name` muestre el nombre real del autor.

### 6. Auth gating y errores 401/403

- **Componente** consulta `inject(AuthSessionService).vm` y renderiza el bloque "Inicia sesión para publicar una solicitud" con CTAs `Iniciar sesión` (`?login=1`) y `Crear cuenta` (`/registro`), idéntico al de `my-requests-dashboard`.
- **Si la sesión expira durante el submit** y el backend devuelve `401`/`403`:
  - Llamar `AuthSessionService.clear()` para invalidar token.
  - Mostrar `state = 'error'` con mensaje claro ("Tu sesión expiró, vuelve a iniciar sesión") y CTA "Iniciar sesión".
  - **No** se navega forzosamente: se preserva el formulario en memoria local (signals) para que tras login el usuario pueda reintentar (en esta entrega no se persiste cross-session; es trade-off aceptado).
- **Rationale:** no introducir route guards ni un interceptor HTTP global solo para este flujo (existe deuda técnica al respecto, pero se aborda en otro change).

### 7. Servicio HTTP

- **Extensión de `OpenRequestsService`** con:
  ```ts
  createOpenRequest(input: CreateOpenRequestInput): Observable<OpenRequestDetail>
  ```
  donde `CreateOpenRequestInput` espeja `CreateOpenRequestDto`. Usa `this.http.post<OpenRequestDetailDto>(this.apiUrl, body)` y aplica el `normalizeDetail(dto, null)` ya existente para devolver el modelo de dominio del front.
- **Headers `Authorization: Bearer <token>`** los provee el interceptor existente (asumiendo que ya existe; si no, se añade en este change como dependencia mínima).
- **Mock support:** el bloque `if (this.apiUrl.includes('/mock/'))` actual no cubre POST. **Decisión:** para mock, el método rechaza con un error claro ("createOpenRequest no está disponible en modo mock") y se acepta que el flujo solo funcione contra backend real. Alternativa rechazada (simular creación in-memory en mock) por costo y poco valor.
- **Rationale:** un solo servicio para el recurso evita duplicación y mantiene `OpenRequestsService` como SSOT.

### 8. Estados de UI y navegación post-éxito

- **Estados locales** (signal `state`): `'idle' | 'submitting' | 'success' | 'error'`.
- **Submit:** botón `disabled` cuando `form.invalid || state() === 'submitting'`; `aria-busy="true"` durante submit.
- **Éxito:** navegar a `/solicitudes/:id` (detalle de la solicitud recién creada, usando el `id` devuelto por la API). Mostrar `ModalComponent` o banner inline "¡Solicitud publicada!" durante 1-2 s antes de navegar (decisión: **modal** consistente con `my-requests-dashboard` que ya importa `ModalComponent`).
- **Error:** banner `.state.state--error` con mensaje genérico + botón `Reintentar` que vuelve a `submit()`.
- **Rationale:** llevar al detalle confirma materialmente que la solicitud existe y aterriza al usuario en una vista útil.

### 9. CTAs de descubrimiento

- **`my-requests-dashboard`**:
  - En `header`: añadir `<a class="btn" routerLink="/solicitudes/nueva">Publicar solicitud</a>` visible solo si `authVm().isLoggedIn`.
  - En estado vacío (`items().length === 0`): añadir el mismo CTA junto al texto.
- **`open-requests-landing`**: añadir CTA secundario en cabecera ("¿Necesitas algo? Publica tu solicitud") visible solo si autenticado.
- **Rationale:** el flujo se descubre desde los dos lugares donde el usuario "siente" que necesita publicar.

### 10. Estilos

- **Reutilizar tokens** (`--aj-color-bg/-surface/-border/-subtle`, `--aj-radius-md`, `--aj-shadow-sm`) y mismo layout de página (`section.page > .container max-width 860px`).
- **Inputs**: aplicar las mismas clases que `registration.scss` para mantener altura, foco y estados de error (`.field`, `.field__label`, `.field__control`, `.field__error`).
- **Sin nuevas variables CSS**.

### 11. Tests

- **Component spec** (`open-request-create.spec.ts`): renderiza bloque "no-auth" cuando `isLoggedIn === false`; renderiza form cuando `true`; valida required/email/minLength; submit feliz navega al detalle; submit con 401 limpia sesión y muestra error.
- **Service spec** (`open-requests.service.spec.ts`): `createOpenRequest` envía `POST` al `apiUrl` con el body correcto y normaliza la respuesta. `listMyOpenRequests` envía `GET` a `<apiUrl>/mine` con `page` y `pageSize` y normaliza items vía `normalizeListItem`.

### 12. Endpoint backend `GET /open-requests/mine`

- **Decisión:** crear un endpoint **separado y autenticado** en `OpenRequestsController`, en vez de añadir un query param `?mine=1` o `?ownerUserId=me` al `GET /open-requests` actual.
- **Ruta:** `GET /open-requests/mine`, declarada **antes** de `GET /:id` para evitar que `mine` se interprete como un `id`.
- **Permisos:** `@RequirePermissions('open-requests.read.own')`. El `AuthRbacGuard` es deny-by-default y el MVP del guard hace passthrough de permisos requeridos cuando no se proveen vía `x-permissions`, por lo que cualquier sesión válida pasa el chequeo. Más adelante, el role admin del usuario decidirá si tiene esa permission de forma real.
- **Use case:** `ListMyOpenRequestsUseCase`, paralelo a `ListOpenRequestsUseCase`, usa `normalizePageRequest` y delega en `repo.listByOwner(ownerUserId, pageRequest)`.
- **Repository port:** se añade `listByOwner(ownerUserId: string, pageRequest: PageRequest): Promise<PageResult<OpenRequestListItem>>`.
  - **TypeORM:** `where: { ownerUserId }` con la lógica equivalente al `list` actual (orden `publishedAtSort DESC, id ASC`, paginación). El soft-delete se respeta automáticamente porque la entidad usa `@DeleteDateColumn`.
  - **InMemory:** filtrar `listItems` por `id` cuyo `owners.get(id) === ownerUserId` y aplicar el mismo orden y paginación.
- **Response DTO:** se reutiliza `OpenRequestsListResponseDto` para no fragmentar el contrato. El front consume con la misma normalización (`normalizeListItem`) que ya hace para `GET /open-requests`.
- **Rationale (endpoint separado):**
  - Mantiene **`GET /open-requests` público y sin auth**; mezclar lógica autenticada con un endpoint público invita errores (cache, headers).
  - URL legible y discoverable (`/open-requests/mine`).
  - Permite endurecer el filtro server-side sin riesgo de bypass por query string.
- **Alternativa descartada:** `?ownerUserId=me` en el endpoint público — requeriría un guard condicional + duplicar lógica de auth solo cuando se pasa el query param; mayor superficie, menor claridad.

### 13. UI de tabs en `my-requests-dashboard`

- **Decisión:** dos pestañas dentro de la misma pantalla, controladas por un signal `activeTab = 'published' | 'applied'` en el componente.
  - **"Publicadas por mí" (`published`)**: lista las solicitudes del usuario obtenidas desde `OpenRequestsService.listMyOpenRequests({ page: 1, pageSize: 20 })`.
  - **"Postulé a estas" (`applied`)**: lista actual basada en `ProposalsService` + `OpenRequestsService.getOpenRequestDetail` (no se modifica su semántica).
- **Carga:** ambas pestañas cargan en paralelo en `load()` para que el usuario pueda alternar instantáneamente. Cada lista tiene su propio estado `'loading' | 'success' | 'error'` independiente.
- **Empty state por pestaña:**
  - `published` vacío → "No has publicado solicitudes todavía." + CTA "Publicar solicitud".
  - `applied` vacío → texto y CTA actuales (no cambian).
- **Visual:** las pestañas usan los tokens existentes (`--aj-color-surface/-border/-radius-pill`, `--aj-color-ink`, accent `rgba(14, 165, 164, *)`); inspiradas en el patrón `regStep`/`regStep--active` del registro. Cada tab muestra un contador `(N)` con el total cargado.
- **Item card "publicadas":** usa la misma `.item / .itemGrid / .thumb / .itemMain` ya existente; en `chips` se muestra una badge "Publicada por ti" en lugar de las chips de propuesta. Los `metaPills` muestran `locationLabel`, `budgetLabel` y `publishedAtLabel`. Acciones: "Ver detalle" (link a `/solicitudes/:id`).
- **Auth gating:** mismo bloque "Inicia sesión" actual. Si no hay sesión, no se muestran tabs (no hay nada que ver).
- **Rationale:** evita reescribir el dashboard. Un solo punto de entrada para el usuario y las dos vistas comparten cabecera + estilos.
- **Alternativa descartada:** dos rutas separadas (`/mis-solicitudes/publicadas` y `/mis-solicitudes/postuladas`). Rechazado: añade clic extra y navegación, no aporta valor sobre tabs locales.

## Risks / Trade-offs

- **[Riesgo] Sin upload de imagen** → la UX inicial es limitada (URLs externas) → **Mitigación:** dejar `imageUrl` opcional, mostrar preview si la URL es válida; documentar como follow-up explícito.
- **[Riesgo] Sin persistencia del form al expirar sesión** → si el usuario invierte tiempo y la sesión muere, pierde lo escrito → **Mitigación:** mantener form en signal del componente durante la sesión actual del SPA; persistir en `localStorage` queda fuera de scope (otro change si se valida).
- **[Riesgo] Tags por coma** → puede ser frágil si el usuario usa comas en un tag → **Mitigación:** documentar en hint, normalizar agresivo (trim/dedupe) y mostrar preview de chips parseados antes de enviar.
- **[Riesgo] Pattern anti-UUID en `locationLabel`** → falsos positivos (improbables, hex 8-4-4-4-12) → **Mitigación:** el patrón es muy específico; el riesgo es mínimo y consistente con el saneo del landing.
- **[Riesgo] Mock no soporta POST** → el flujo no se puede demostrar contra mock → **Mitigación:** documentar que se requiere backend; el resto de la app sigue funcionando contra mock.
- **[Riesgo] Permiso `open-requests.create` ausente para algunos roles** → el usuario llega al form y el POST falla con 403 → **Mitigación:** mostrar error claro tras 403 ("Tu cuenta no tiene permiso para publicar solicitudes; contacta soporte"); a futuro, consultar permisos en sesión y ocultar el CTA proactivamente.
- **[Trade-off] Provider con default genérico ("Cliente")** → el detalle de la solicitud recién creada se ve "anónimo" en `provider.name` → aceptado por scope; resolver cuando el backend acepte que el `provider.name` venga del front o derive del perfil del owner.

## Migration Plan

- **No hay migración de datos** ni cambios de schema. Es un cambio aditivo en el front + nuevas pruebas.
- **Deploy:** subir build del front; el backend ya tiene el endpoint listo desde antes.
- **Rollback:** revertir el commit del front. No queda estado roto en backend (las solicitudes creadas siguen siendo válidas).
- **Feature flag:** no se usa en esta entrega; el riesgo es bajo y el endpoint ya está expuesto.

## Open Questions

- **¿Pre-fill de `contactPhone`/`contactEmail`** desde `authVm().user`? Depende de qué campos exporta hoy `AuthSession.user`. Si solo tiene `id` y `email`, pre-fill solo `contactEmail`.
- ~~**¿`my-requests-dashboard` debería listar también las solicitudes que el usuario CREÓ**~~ → **Resuelto en este change** (ver capability `mis-solicitudes-publicadas` y decisiones 12–13): se añade endpoint `GET /open-requests/mine` y tabs en el dashboard.
- **¿`provider.name` desde el perfil real del autor** vs default "Cliente"? Requiere alinear con backend si quiere aceptar override en el create.
- **¿Interceptor HTTP global** que escuche 401/403 y limpie sesión? Sería deuda técnica útil; en este change se resuelve solo en el componente para no expandir alcance.
- **¿Validación de tags** contra un catálogo conocido (autocomplete)? Útil para discoverability del catálogo; fuera de scope.
