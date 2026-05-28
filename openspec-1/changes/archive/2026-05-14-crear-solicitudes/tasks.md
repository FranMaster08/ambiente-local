## 1. Modelo y servicio

- [x] 1.1 Añadir tipo `CreateOpenRequestInput` en `anyjobs-front/anyjobs/src/app/features/open-requests/open-requests.models.ts` con los campos requeridos del DTO (`title`, `excerpt`, `description`, `tags: string[]`, `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`) y opcionales (`imageUrl`, `imageAlt`)
- [x] 1.2 Añadir método `createOpenRequest(input: CreateOpenRequestInput): Observable<OpenRequestDetail>` en `OpenRequestsService` (`open-requests.service.ts`) que use `this.http.post<OpenRequestDetailDto>(this.apiUrl, body)` y aplique `normalizeDetail(dto, null)` sobre la respuesta
- [x] 1.3 En el método del 1.2, si `this.apiUrl.includes('/mock/')`, devolver un `Observable` que emite error con mensaje "createOpenRequest no está disponible en modo mock"
- [x] 1.4 Asegurarse de que el `body` enviado NO incluye claves vacías ni opcionales sin valor (`imageUrl`/`imageAlt` solo si llegan con contenido) y que `tags` se envía como array ya normalizado

## 2. Componente "Publicar solicitud"

- [x] 2.1 Crear carpeta `anyjobs-front/anyjobs/src/app/features/open-requests/open-request-create/` con archivos `open-request-create.{ts,html,scss,spec.ts}`
- [x] 2.2 Definir `OpenRequestCreate` como componente standalone con `selector: 'app-open-request-create'`, `ChangeDetectionStrategy.OnPush`, `imports: [CommonModule, ReactiveFormsModule, RouterLink, ModalComponent]`
- [x] 2.3 Inyectar `DestroyRef`, `Router`, `FormBuilder`, `OpenRequestsService`, `AuthSessionService` y exponer `authVm` para gating
- [x] 2.4 Definir signal `state = signal<'idle' | 'submitting' | 'success' | 'error'>('idle')` y signal `errorMessage = signal<string | null>(null)`

## 3. Formulario reactivo y validaciones

- [x] 3.1 Construir `form` con `FormBuilder.nonNullable.group(...)` con todos los campos: `title`, `excerpt`, `description`, `tagsInput` (string), `locationLabel`, `budgetLabel`, `contactPhone`, `contactEmail`, `imageUrl`, `imageAlt`
- [x] 3.2 Añadir validators a campos requeridos (`Validators.required`), `contactEmail` (`Validators.email`), `title` (`minLength(3)`), `description` (`minLength(20)`), `excerpt` (`maxLength(160)`)
- [x] 3.3 Añadir validator de patrón anti-UUID a `locationLabel`: rechazar cualquier match con `/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i`
- [x] 3.4 Añadir validator opcional para `imageUrl`: si tiene valor, debe matchear `/^https?:\/\/.+/i`
- [x] 3.5 Implementar función pura `parseTags(raw: string): string[]` que `split(',') → trim → filter(non-empty) → dedupe` y crear validator de `tagsInput` que falle si `parseTags` devuelve array vacío
- [x] 3.6 En el constructor, si `authVm().user.email` existe, hacer `form.controls.contactEmail.setValue(...)`; si existiera `phone`, también `contactPhone`
- [x] 3.7 Computed `isSubmitDisabled = computed(() => form.invalid || state() === 'submitting')`

## 4. Submit y navegación

- [x] 4.1 Implementar método `submit()` que: marque controles como `markAllAsTouched`, valide `form.valid`, ponga `state.set('submitting')`, construya el `CreateOpenRequestInput` (con `tags = parseTags(form.value.tagsInput)`)
- [x] 4.2 Llamar `openRequests.createOpenRequest(input)` con `takeUntilDestroyed(destroyRef)` y `finalize` para resetear estado si corresponde
- [x] 4.3 En `next`: setear `state.set('success')`, abrir `ModalComponent` con mensaje "¡Solicitud publicada!" y, al cerrar (o tras 1.5 s), navegar a `/solicitudes/${created.id}`
- [x] 4.4 En `error`: clasificar respuesta — si `status === 401`, llamar `AuthSessionService.clear()` y setear mensaje "Tu sesión expiró, vuelve a iniciar sesión"; si `status === 403`, mensaje "Tu cuenta no tiene permiso para publicar solicitudes"; en otro caso, mensaje genérico "No se pudo publicar tu solicitud, intenta de nuevo"
- [x] 4.5 Implementar método `retry()` que reenvía el formulario sin perder los datos
- [x] 4.6 Implementar método `openLogin()` análogo al de `my-requests-dashboard` (`router.navigate([], { queryParams: { login: 1 }, queryParamsHandling: 'merge' })`)

## 5. Plantilla HTML

- [x] 5.1 Estructura raíz `<section class="page createRequest"><div class="container"><header class="header">...</header>...</div></section>` con `kicker = "PUBLICAR"`, `title = "Publicar solicitud"`, `subtitle = "Cuéntanos qué necesitas y recibe propuestas."`
- [x] 5.2 Bloque `*ngIf="!authVm().isLoggedIn; else logged"` con `.state` "Inicia sesión para publicar una solicitud" y CTAs "Iniciar sesión" + "Crear cuenta" (mismo patrón que `my-requests-dashboard.html`)
- [x] 5.3 Dentro del template `#logged`, renderizar el `<form [formGroup]="form" (ngSubmit)="submit()" novalidate>` con secciones visuales: *Información principal*, *Ubicación y presupuesto*, *Contacto*, *Imagen (opcional)*
- [x] 5.4 Cada control envuelto en `<div class="field">` con `<label class="field__label">`, control con `class="field__control"` y `<p class="field__error" *ngIf="...">`
- [x] 5.5 Hint visible bajo el campo de tags: "Separa con comas (ej: Limpieza, Plomería)"; preview de tags parseados en tiempo real
- [x] 5.6 Botones al pie: `<button type="submit" class="btn" [disabled]="isSubmitDisabled()" [attr.aria-busy]="state() === 'submitting' ? 'true' : null">Publicar solicitud</button>` y secundario "Cancelar" que navega atrás
- [x] 5.7 Bloque `*ngIf="state() === 'error'"` con `.state.state--error`, mensaje desde `errorMessage()`, botón "Reintentar" (`(click)="retry()"`) y, si el mensaje es de sesión expirada, también botón "Iniciar sesión"
- [x] 5.8 Integrar `<app-modal>` para confirmación de éxito vinculado a un signal `isSuccessOpen`

## 6. Estilos SCSS

- [x] 6.1 Crear `open-request-create.scss` reutilizando los tokens y patrones de `my-requests-dashboard.scss`: `.createRequest { padding: 24px; background: var(--aj-color-bg); }`, `.container { max-width: 860px; margin: 0 auto; }`, header con borde superior accent
- [x] 6.2 Extraer estilos `.field`, `.field__label`, `.field__control`, `.field__error` (idénticos o muy próximos a los usados en `registration.scss`); si ya son globales, importar; si no, replicar en este SCSS
- [x] 6.3 Estilo de la lista de chips de tags parseados (preview), usando tokens existentes (`--aj-color-surface`, `--aj-color-border`, `--aj-radius-md`)
- [x] 6.4 Media query `@media (max-width: 520px) { padding: 16px; }` para mantener consistencia móvil
- [x] 6.5 Verificar que NO se introducen nuevas variables CSS (todas se reusan de `:root`)

## 7. Routing

- [x] 7.1 En `anyjobs-front/anyjobs/src/app/app.routes.ts`, dentro del bloque `path: 'solicitudes'`, añadir entrada `{ path: 'nueva', loadComponent: () => import('./features/open-requests/open-request-create/open-request-create').then((m) => m.OpenRequestCreate) }` ANTES de la ruta `:id` para garantizar precedencia
- [ ] 7.2 Verificar manualmente con `ng serve` que `/solicitudes/nueva` no es interpretado como `:id = "nueva"` _(QA manual; precedencia garantizada por orden literal antes de `:id`)_

## 8. CTAs de descubrimiento

- [x] 8.1 En `my-requests-dashboard.html`, dentro del `header`, añadir `<a *ngIf="authVm().isLoggedIn" class="btn" routerLink="/solicitudes/nueva">Publicar solicitud</a>`
- [x] 8.2 En `my-requests-dashboard.html`, dentro del estado vacío (`#empty`), añadir el mismo CTA junto al texto
- [x] 8.3 En `open-requests-landing.html`, en la cabecera principal, añadir CTA secundario `<a *ngIf="authVm().isLoggedIn" class="btn btn--secondary" routerLink="/solicitudes/nueva">¿Necesitas algo? Publica tu solicitud</a>`
- [x] 8.4 En `open-requests-landing.ts`, inyectar `AuthSessionService` y exponer `authVm` si aún no está expuesto

## 9. Pruebas unitarias

- [x] 9.1 En `open-requests.service.spec.ts`, añadir test de `createOpenRequest`: dispara `POST` al `apiUrl` correcto con el body esperado y emite el `OpenRequestDetail` normalizado al recibir un DTO mock
- [x] 9.2 En `open-requests.service.spec.ts`, añadir test que verifica que en modo mock (`apiUrl` con `/mock/`) `createOpenRequest` emite error sin emitir `POST`
- [x] 9.3 En `open-request-create.spec.ts`, test "renderiza bloque no-auth cuando no hay sesión" (mockear `AuthSessionService.vm` con `isLoggedIn: false`)
- [x] 9.4 Test "renderiza formulario cuando hay sesión" (mockear `isLoggedIn: true`)
- [x] 9.5 Test "submit deshabilitado con campos requeridos vacíos"
- [x] 9.6 Test "validación rechaza `contactEmail` inválido"
- [x] 9.7 Test "validación rechaza `locationLabel` con UUID embebido"
- [x] 9.8 Test "tags `'a, b, a, '` se normalizan a `['a','b']` en el body enviado"
- [x] 9.9 Test "submit feliz navega a `/solicitudes/<id>`" (mockear servicio + `Router`)
- [x] 9.10 Test "respuesta 401 limpia sesión vía `AuthSessionService.clear()` y muestra mensaje de sesión expirada"
- [x] 9.11 Test "respuesta 403 mantiene sesión y muestra mensaje de permisos"

## 10. Validación cruzada y QA manual

- [x] 10.1 Ejecutar `npm run lint` (o `ng lint`) y `npm run test` en `anyjobs-front/anyjobs/` y dejar todo en verde _(`ng lint`: ✓ all pass; `ng test`: 52/53 ✓ — el 1 fallo restante es pre-existente y ajeno: `Home > should create` falla por `IntersectionObserver is not defined` en `ngx-vertical-slider`, no relacionado con este change)_

## 11. Backend: endpoint `GET /open-requests/mine`

- [x] 11.1 Añadir método `listByOwner(ownerUserId: string, pageRequest: PageRequest): Promise<PageResult<OpenRequestListItem>>` al puerto `OpenRequestsRepositoryPort` (`anyjobs-back/apps/api/src/modules/open-requests/application/ports/open-requests-repository.port.ts`)
- [x] 11.2 Implementar `listByOwner` en `TypeOrmOpenRequestsRepository` con `where: { ownerUserId }`, mismo orden (`publishedAtSort DESC, id ASC`) y paginación que `list`
- [x] 11.3 Implementar `listByOwner` en `InMemoryOpenRequestsRepository` filtrando por `owners.get(id) === ownerUserId` con misma paginación
- [x] 11.4 Crear `ListMyOpenRequestsUseCase` (en `application/use-cases/list-my-open-requests.use-case.ts`) con interfaz `{ ownerUserId, page?, pageSize? }`, normalización vía `normalizePageRequest` y delegación a `repo.listByOwner`
- [x] 11.5 Registrar el nuevo use case en `OpenRequestsModule`
- [x] 11.6 Añadir handler `GET /open-requests/mine` en `OpenRequestsController` (declarado ANTES de `GET /:id`), protegido por `@RequirePermissions('open-requests.read.own')`, que toma `ownerUserId = req.user.userId` y devuelve `OpenRequestsListResponseDto`
- [x] 11.7 Crear helper Swagger `GetMyOpenRequestsListSwagger` en `api/swagger/get-my-open-requests-list.swagger.ts` y exportarlo desde el `index.ts`
- [x] 11.8 Añadir test e2e en `apps/api/test/e2e/open-requests/open-requests.e2e-spec.ts` que valide: 401 sin Bearer; 200 con Bearer devolviendo solo solicitudes propias; cambios soft-delete excluidos; query `?ownerUserId=otro` ignorado _(13/13 e2e tests del módulo `open-requests` en verde)_

## 12. Frontend: `listMyOpenRequests` en service

- [x] 12.1 Añadir método `listMyOpenRequests(params: OpenRequestsListParams): Observable<OpenRequestsListResponse>` en `OpenRequestsService` que haga `GET <apiUrl>/mine` con `page` y `pageSize`, y reuse `toListResponse` + `normalizeListItem`
- [x] 12.2 En modo mock (`apiUrl` con `/mock/`), emitir error con mensaje "listMyOpenRequests no está disponible en modo mock"
- [x] 12.3 Añadir tests en `open-requests.service.spec.ts`: GET al apiUrl + `/mine`, normalización, comportamiento en mock _(6/6 tests del service en verde)_

## 13. Frontend: tabs en `my-requests-dashboard`

- [x] 13.1 En `my-requests-dashboard.ts`, añadir signal `activeTab = signal<'published' | 'applied'>('published')` y signals independientes `publishedState`, `publishedItems`, `appliedState` (renombrando `state` y `items` actuales)
- [x] 13.2 Modificar `load()` para disparar en paralelo: la carga "publicadas" (vía `OpenRequestsService.listMyOpenRequests`) y la carga "postulé" (lógica actual basada en `ProposalsService` + `OpenRequestsService.getOpenRequestDetail`)
- [x] 13.3 Exponer método `setTab(tab: 'published' | 'applied')` y getters `publishedCount`/`appliedCount` para los contadores
- [x] 13.4 En `my-requests-dashboard.html`, añadir bloque de tabs entre el `header` y el contenido: dos botones "Publicadas por mí (N)" / "Postulé a estas (N)" con `aria-selected` y clase `tab--active` para el activo
- [x] 13.5 Renderizar bloque "publicadas": loading skeleton, error con `Reintentar`, lista de cards reutilizando `.item / .itemGrid / .itemMain`, badge "Publicada por ti" en `.chips`, action "Ver detalle"
- [x] 13.6 Empty state de "publicadas": "No has publicado solicitudes todavía." + CTA `Publicar solicitud` (`routerLink="/solicitudes/nueva"`)
- [x] 13.7 La tab "postulé" MUST conservar exactamente el render actual (proposals + acciones existentes)
- [x] 13.8 Añadir estilos `.tabs`, `.tab`, `.tab--active`, `.tabBadge` en `my-requests-dashboard.scss` reutilizando tokens existentes (`--aj-color-surface`, `--aj-color-border`, `--aj-radius-pill`, accent `rgba(14, 165, 164, *)`); patrón inspirado en `regStep`/`regStep--active`
- [x] 13.9 Sesión inactiva: NO renderizar tabs (mantener bloque "Inicia sesión" actual)
- [x] 13.10 Actualizar `my-requests-dashboard.spec.ts`: tab activa por defecto = `published`, alternar tabs cambia el contenido visible, `listMyOpenRequests` se invoca en `load()` _(7/7 tests del dashboard en verde)_

## 14. Verificación final extendida

- [x] 14.1 `npm run lint` y `npm test` en `anyjobs-front/anyjobs/` en verde (excluyendo el fallo pre-existente de `Home > should create`) _(`ng lint`: ✓ all pass; `ng test`: 57/58 ✓ — el 1 fallo restante sigue siendo el pre-existente y ajeno: `Home > should create` por `IntersectionObserver`)_
- [x] 14.2 `npm test` en `anyjobs-back/` en verde para los nuevos tests del use case y e2e _(13/13 e2e del módulo `open-requests` ✓; los 3 fallos en `users-me.e2e-spec.ts` son pre-existentes y ajenos a este change — confirmado con `git stash` antes de los cambios)_
- [x] 14.3 Bug pre-existente bloqueante de la suite e2e arreglado: la migración inicial `20260314200000-create-core-tables.ts` no creaba `open_requests.owner_user_id` ni `open_requests.deleted_at`, pero el seed de la misma migración intentaba insertar usando metadata de la entity (que sí declara `ownerUserId`), causando `table open_requests has no column named owner_user_id`. Fix: añadir las dos columnas en la creación inicial de la tabla; la segunda migración (`20260413120000-open-requests-owner-soft-delete.ts`) sigue siendo idempotente y no se reaplica donde la columna ya existe. Tipo `deleted_at` parametrizado por `DB_TYPE` (`timestamp` en postgres, `datetime` en SQLite/sqljs) para coincidir con la entity
- [x] 14.4 Seed de usuarios necesarios en `beforeAll` del e2e de `open-requests` para satisfacer la FK `open_requests.owner_user_id -> users.id` añadida por la migración 2 (los IDs estáticos que usaban los tests previos no existían en `users`, por lo que cualquier `POST /open-requests` autenticado fallaba con 500 `FOREIGN KEY constraint failed`)
- [ ] 10.2 Levantar el stack local con `docker-compose up` y verificar que un usuario autenticado puede publicar una solicitud y el detalle resultante (`/solicitudes/:id`) muestra los campos enviados _(QA manual del usuario)_
- [ ] 10.3 Verificar manualmente los CTAs de descubrimiento desde `/mis-solicitudes` y `/solicitudes` (visibles solo con sesión activa) _(QA manual del usuario)_
- [ ] 10.4 Verificar manualmente flujo 401 (forzar token inválido en `localStorage.anyjobs.auth.token` y reintentar submit) y flujo 403 (si hay rol sin permiso disponible) _(QA manual del usuario)_
- [ ] 10.5 Verificar accesibilidad básica: orden de tab por todos los campos, mensajes de error asociados (`aria-describedby` o equivalente), `aria-busy` durante submit _(QA manual del usuario)_
- [ ] 10.6 Verificar que el diseño respeta el sistema visual existente comparando lado a lado con `my-requests-dashboard` y `registration` (tokens, espaciados, tipografías) _(QA manual del usuario)_
