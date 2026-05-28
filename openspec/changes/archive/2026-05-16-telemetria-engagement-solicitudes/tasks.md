## 1. Backend

- [x] 1.1 Migración `open_request_interactions` + entidad TypeORM
- [x] 1.2 `POST /open-requests/interactions` persiste y responde 204
- [x] 1.3 E2e: POST persiste fila consultable

## 2. Front

- [x] 2.1 Servicio `OpenRequestsAnalyticsService` (actor + track)
- [x] 2.2 Eventos en landing (impresión + clic)
- [x] 2.3 Eventos en detalle (`requestDetailView`, `timeOnDetailMs`)
- [x] 2.4 `proposalStarted` en compose de propuesta

## 3. Corrección NG0203 y verificación

- [x] 3.1 `afterNextRender` envuelto en `runInInjectionContext(injector, …)` en landing y home
- [x] 3.2 `track()` desde `IntersectionObserver` dentro de `NgZone.run()`
- [x] 3.3 Landing alcanza `state=success` (listado no bloqueado por telemetría)
- [x] 3.4 Verificación manual: consola sin NG0203, Red con GET 200 + POST 204
