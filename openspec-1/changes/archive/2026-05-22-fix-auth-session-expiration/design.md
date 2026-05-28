## Context

- **Frontend**: `AuthSessionService` persiste `token` + `user` en `localStorage` (`anyjobs.auth.token`, `anyjobs.auth.user`) y expone `isLoggedIn` como `computed` basado en la existencia de sesión restaurada al boot — sin validar vigencia del token con el backend.
- **Interceptores**: `authBearerInterceptor` adjunta Bearer a prefijos API; `authCredentialsInterceptor` solo para `/auth` (registro). No hay interceptor de respuesta para `401`.
- **Protección de rutas**: No hay `canActivate`; las vistas privadas usan `authVm().isLoggedIn` y query `?login=1` en `Shell`.
- **401 ad hoc**: `profile.ts` y `open-request-create.ts` hacen `auth.clear()`; `open-request-detail.ts` igual en un flujo; `profile-multimedia.ts` solo muestra mensaje sin limpiar sesión.
- **Backend**: Token opaco UUID en `AuthTokenRegistry` (memoria). `AuthRbacGuard` global exige Bearer y token registrado. Errores vía `GlobalExceptionFilter` con `errorCode: AUTH.UNAUTHORIZED` y status `401`.
- **Sin refresh token** ni expiración temporal del token en el payload (no es JWT).

## Goals / Non-Goals

**Goals:**

- Un único camino para invalidar sesión en frontend (`SessionExpirationService` o extensión de `AuthSessionService`).
- Interceptor de respuesta que reconozca `401` + `AUTH.UNAUTHORIZED` (y equivalentes en endpoints protegidos) y ejecute limpieza una sola vez por “oleada” de errores.
- `isLoggedIn` refleje estado real tras limpieza; componentes dejen de disparar cargas privadas sin token válido.
- Rutas/vistas privadas: gating antes de `ngOnInit` loads; redirección a login solo si la ruta lo exige.
- Vistas públicas: limpiar sesión sin redirección.
- Mensaje i18n opcional (`session.expired`) vía toast/snackbar o estado en `Shell` — una vez por expiración.
- Backend: auditar guard y asegurar que ningún endpoint protegido devuelva `200` con token inválido/ausente.

**Non-Goals:**

- Refresh token, rotación de tokens ni migración a JWT.
- Persistencia de sesiones en BD (registry sigue en memoria en MVP).
- Revocación server-side explícita en logout (fuera de alcance salvo ya exista).
- Reescribir RBAC ni permisos.
- Route guards Angular formales en todas las rutas (se prioriza helper + gating existente; guard funcional mínimo solo si reduce duplicación).

## Decisions

### 1. `SessionExpirationHandler` central en frontend

**Decisión:** Extender `AuthSessionService` con `invalidateSession(reason?: 'expired' | 'logout' | 'invalid')` que: borra `localStorage`, resetea signals, resetea stores dependientes (`notifications.reset()`), emite evento opcional para UI, y setea flag `sessionInvalidated` para que el interceptor ignore nuevos Bearer en la misma navegación.

**Alternativa descartada:** Duplicar `clear()` en cada componente — ya demostró inconsistencia.

### 2. Interceptor `authUnauthorizedInterceptor` (orden después de Bearer)

**Decisión:** `HttpInterceptorFn` que en `catchError` / tap de respuesta detecte `HttpErrorResponse.status === 401` y body con `errorCode` que empiece por `AUTH.` (o lista blanca: `AUTH.UNAUTHORIZED`). Invoca `invalidateSession('expired')` con debounce (solo primera vez hasta navegación estable).

**Exclusiones:** No actuar en `POST /auth/login` (401 esperado por credenciales), ni en rutas `@Public()` del front que llamen auth sin sesión (forgot-password, register, reset-password).

**Alternativa descartada:** RxJS global `HttpClient` wrapper — el proyecto ya usa interceptors en `app.config.ts`.

### 3. Redirección condicional

**Decisión:** Tras invalidar, consultar `Router` + lista de rutas “privadas” (constante: `/perfil`, `/mis-solicitudes`, `/crear-solicitud`, etc.) o metadata en rutas. Si `url` coincide → `navigate` a `/home` con `?login=1` o abrir modal vía query existente. Si ruta pública → solo limpiar, sin `navigate`.

**Alternativa descartada:** Siempre redirigir a `/home` — rompe navegación pública con token viejo en storage.

### 4. Boot / restauración de sesión

**Decisión:** Mantener restauración desde `localStorage` para UX rápida, pero la primera petición protegida que devuelva `401` invalida sesión. Opcional en implementación: al boot, si hay token, no marcar cargas privadas hasta que un “session probe” (`GET /users/me` ligero) responda 200 — **recomendado** en tasks si reduce flash de UI autenticada con token muerto.

**Alternativa descartada:** Eliminar restauración al boot — peor UX en token válido.

### 5. Evitar tormenta de peticiones

**Decisión:** Flag `authBlocked` en servicio; interceptor de request (o el mismo Bearer) no adjunta Bearer ni cancela con `EMPTY` si `authBlocked`. Primera `401` setea flag.

### 6. Consolidar 401 en componentes

**Decisión:** Eliminar `auth.clear()` local en favor del interceptor; componentes solo manejan estados UI vacíos si `!isLoggedIn`.

### 7. Backend — consistencia 401

**Decisión:** Revisar `AuthRbacGuard`: token ausente, mal formado, no en registry → `UnauthorizedException` mapeado a `AUTH.UNAUTHORIZED` / 401. No devolver `403` para “no autenticado” (reservar 403 para RBAC con usuario autenticado sin permiso). No incluir token ni stack en body.

**Nota MVP:** Tras reinicio del backend, tokens en cliente quedan inválidos — comportamiento esperado, cubierto por esta change.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Loop login ↔ 401 en ruta con carga automática | Excluir endpoints públicos; debounce invalidación; `authBlocked` |
| Flash de header “logueado” con token muerto | Session probe al boot o invalidación inmediata en primer 401 |
| Login devuelve 401 y dispara limpieza | Excluir URL de login del interceptor de expiración |
| Múltiples tabs | `storage` event listener para sincronizar `clear` (opcional en tasks) |
| Registry en memoria pierde sesión al deploy backend | Documentado; usuario re-login — aceptado en MVP |

## Migration Plan

1. Implementar backend 401 audit (sin breaking en contrato existente).
2. Desplegar interceptor + `invalidateSession`.
3. Refactor componentes con 401 local.
4. Verificación manual según tasks (token válido, vencido/inválido, sin token, ruta pública).
5. Rollback: revertir interceptor y restaurar handlers locales si necesario.

## Open Questions

- ¿Session probe al boot (`GET /users/me/profile` o similar)? **Recomendación:** sí, en tasks 3.x, para cumplir “recarga con token vencido no autenticado”.
- ¿Sincronización multi-tab? **Recomendación:** nice-to-have en tasks opcional.
- ¿Lista exhaustiva de rutas privadas? Derivar de `app.routes.ts` + componentes con `isLoggedIn` gating en implementación.
