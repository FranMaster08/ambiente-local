## Decisiones

### Backend

- **Patrón:** reutilizar el modelo de `promo_slide_interactions` (append-only, actor `subjectType` + `userId` / `anonymousId`, `payload` JSON).
- **`POST /open-requests/interactions`:** `@Public`, respuesta `204`; ruta registrada **antes** de `GET :id` en el controller.
- **DTO:** `kind` restringido a los cinco eventos de engagement; `openRequestId` como `string` (compatible con UUIDs de seed que no son UUID v4 estricto).
- **Migración:** `20260516140000-open-request-interactions.ts`; columna `open_request_id` tipo `uuid` en Postgres.

### Front

- **`OpenRequestsAnalyticsService`:** `providedIn: 'root'`; URL `POST /open-requests/interactions`; actor con `anyjobs.openRequests.actor.anonymousId` en `localStorage` (distinto del slider promo).
- **Impresión de lista:** `IntersectionObserver` threshold 0.5, una impresión por `openRequestId` por visita a la landing; atributo `data-open-request-id` en la card.
- **Clic en card:** output `cardNavigate` en `OpenRequestCardComponent` → `requestCardClick`.
- **Detalle:** `requestDetailView` al cargar; `timeOnDetailMs` con `viewDurationMs` al destruir o cambiar de `id`.
- **`proposalStarted`:** al cargar compose (`/solicitudes/:id/propuesta`) y al pulsar postular en detalle.
- **Orden del listado:** sin cambios; sigue `sort=publishedAtDesc`.

### Angular 21 — `afterNextRender` (NG0203)

En Angular 21, `afterNextRender()` **solo** es válido dentro de un contexto de inyección. No puede invocarse directamente en callbacks de `subscribe`, `effect` ni `IntersectionObserver`.

**Patrón obligatorio** para diferir setup del DOM tras datos async:

```typescript
private readonly injector = inject(Injector);

private scheduleListImpressionsAfterRender(): void {
  runInInjectionContext(this.injector, () => {
    afterNextRender(() => this.setupListImpressions());
  });
}
```

Aplicado en:

- `open-requests-landing.ts` — tras `loadFirstPage` / `loadMore` con éxito.
- `home.ts` — dentro del `effect` que activa retención del slider promo (mismo patrón).

**Telemetría desde `IntersectionObserver`:** ejecutar `track()` dentro de `NgZone.run()` para no perder detección de cambios.

## Tabla `open_request_interactions`

| Columna | Tipo | Notas |
|---------|------|-------|
| id | uuid PK | |
| kind | varchar(64) | evento |
| open_request_id | uuid | FK lógica a solicitud |
| route | varchar(128) nullable | p. ej. `/solicitudes` |
| list_page | int nullable | página del listado |
| subject_type | varchar(16) | `user` \| `anonymous` |
| user_id | uuid nullable | |
| anonymous_id | varchar(64) nullable | |
| emitted_at | timestamp | |
| payload | text nullable | JSON |
| created_at | timestamp | |

Índices: `(open_request_id, emitted_at)`, `(anonymous_id, user_id, emitted_at)`, `(kind, open_request_id)`.

## Archivos principales

| Ámbito | Ruta |
|--------|------|
| Back | `anyjobs-back/.../open-request-interaction.entity.ts`, `track-open-request-interaction.dto.ts`, `open-requests-interactions.service.ts`, `open-requests.controller.ts`, migración `20260516140000-*` |
| Back e2e | `anyjobs-back/apps/api/test/e2e/open-requests/open-requests.e2e-spec.ts` |
| Front | `open-requests-analytics.service.ts`, `open-requests-landing.ts`, `open-request-detail.ts`, `open-request-proposal-compose.ts`, `open-request-card.*` |
| Front (promo, mismo fix NG0203) | `home/home.ts` |

## Verificación manual

1. `/solicitudes` — sin `NG0203` en consola; listado visible.
2. Red: `GET /open-requests` → 200; tras scroll, `POST /open-requests/interactions` → 204.
3. Detalle + salida → `requestDetailView` + `timeOnDetailMs`.
4. `psql`: filas en `open_request_interactions`.

## Non-goals

- `sort=relevance` ni agregados (change `ranking-relevancia-solicitudes`).
- Panel admin de métricas.
