## Why

Cuando el token de sesión deja de ser válido (expirado, inválido o revocado en backend), el frontend sigue restaurando la sesión desde `localStorage` y ejecutando peticiones protegidas como si el usuario estuviera autenticado. El manejo de `401` es ad hoc en algunos componentes y ausente en otros, lo que provoca estados inconsistentes, errores repetidos y datos privados visibles tras una sesión inválida. Es necesario un contrato centralizado de expiración de sesión en frontend y respuestas `401` consistentes en backend.

## What Changes

- Servicio centralizado de limpieza de sesión (`clearSession`) invocado desde un único punto ante `401` / token inválido.
- Interceptor HTTP global que detecta respuestas de autenticación inválida (`401` con `errorCode` de auth) y dispara limpieza sin duplicar lógica por componente.
- Validación de sesión al boot: no considerar autenticado solo por existencia de token en `localStorage`; opcionalmente validar con petición ligera o rechazar peticiones protegidas hasta confirmación.
- Guards o gating de rutas/vistas privadas: no cargar datos protegidos sin sesión válida; redirigir o abrir login (`?login=1`) en rutas que lo requieran.
- En rutas públicas: limpiar sesión inválida sin redirección forzada al login.
- Mensaje controlado de sesión expirada (i18n) cuando el flujo lo permita; sin errores técnicos crudos.
- Cancelación/evitación de peticiones protegidas en cascada tras detectar sesión inválida (flag o cola en interceptor).
- Eliminar o consolidar manejo ad hoc de `401` en componentes (`profile`, `open-request-create`, `open-request-detail`, etc.).
- Backend: garantizar `401` + contrato global (`AUTH.UNAUTHORIZED`) para token ausente, inválido o no registrado en endpoints protegidos; sin datos privados ni mezcla con errores `500`.
- Sin refresh token en esta change (no existe hoy); sin migración a JWT.

## Capabilities

### New Capabilities

- `auth-session-expiration`: Detección centralizada de sesión inválida/expirada, limpieza de almacenamiento y estado, coordinación de redirección vs. vistas públicas, y prevención de peticiones privadas en cascada.

### Modified Capabilities

- `anyjobs-front/user-login-session`: Restauración de sesión, criterio de `isLoggedIn`, logout y UX ante expiración; dejar de confiar únicamente en token persistido.
- `anyjobs-back/auth`: Respuestas `401` consistentes en recursos protegidos cuando el Bearer falta, es inválido o no está registrado.

## Impact

- **Frontend (`anyjobs-front/anyjobs`)**: `auth-session.service.ts`, nuevos interceptor/servicio de expiración, `app.config.ts`, posible guard funcional o helper de rutas privadas, `shell.ts`, componentes que hoy manejan `401` localmente, i18n para mensaje de sesión expirada.
- **Backend (`anyjobs-back`)**: `auth-rbac.guard.ts`, posible ajuste en `auth-token-registry` / filtro de errores para asegurar `401` + `AUTH.UNAUTHORIZED` sin filtrar detalles del token.
- **Sin impacto** en login/registro/recuperación de contraseña salvo no romper flujos `@Public()` ni cookie `aj_reg_flow`.
- **Sin impacto** en refresh token (no implementado).
- **Tests**: e2e/unit en guard/interceptor y auth guard backend según patrones existentes.
