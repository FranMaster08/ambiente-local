## 1. Auditoría (frontend y backend)

- [x] 1.1 Documentar rutas/vistas privadas que cargan datos sin validar sesión (`app.routes.ts`, componentes con `isLoggedIn`)
- [x] 1.2 Inventariar manejos ad hoc de `401` (`profile.ts`, `open-request-create.ts`, `open-request-detail.ts`, `profile-multimedia.ts`)
- [x] 1.3 Verificar respuestas actuales de `AuthRbacGuard` y `GlobalExceptionFilter` para token ausente/inválido

## 2. Backend — respuestas 401 consistentes

- [x] 2.1 Asegurar que endpoints protegidos devuelven `401` + `AUTH.UNAUTHORIZED` sin datos privados ni detalles del token
- [x] 2.2 Diferenciar `401` (no autenticado) vs `403` (sin permiso) en el guard
- [x] 2.3 Añadir/ajustar tests e2e o unit del guard para token ausente, malformado y desconocido
- [x] 2.4 Confirmar que endpoints `@Public()` de auth no regresan datos protegidos sin token

## 3. Frontend — invalidación centralizada

- [x] 3.1 Extender `AuthSessionService` con `invalidateSession(reason)` y flag `authBlocked` / debounce
- [x] 3.2 Implementar `authUnauthorizedInterceptor` con exclusiones (`/auth/login`, endpoints públicos de registro/recuperación)
- [x] 3.3 Registrar interceptor en `app.config.ts` (orden correcto respecto a Bearer)
- [x] 3.4 Integrar limpieza de stores dependientes (`notifications.reset()` u otros identificados)
- [x] 3.5 Añadir mensaje i18n de sesión expirada y mostrarlo una vez desde `Shell` o servicio de UI

## 4. Frontend — boot, rutas y cargas privadas

- [x] 4.1 Implementar validación al boot (session probe opcional, p. ej. `GET /users/me/profile` o endpoint ligero) y fallar a no autenticado en `401`
- [x] 4.2 Definir constante/lista de rutas privadas y helper de redirección post-invalidación
- [x] 4.3 Ajustar vistas privadas para no disparar loads si `!isLoggedIn` (perfil, mis solicitudes, crear solicitud, propuestas, etc.)
- [x] 4.4 Eliminar `auth.clear()` duplicado en componentes; confiar en interceptor + estado global

## 5. Verificación obligatoria

- [x] 5.1 Token válido: datos protegidos cargan con normalidad
- [x] 5.2 Token inválido/vencido (o no registrado tras restart backend): primera petición protegida → `401`, limpieza, UI no logueada, sin tormenta de requests
- [x] 5.3 Sin token: vista privada abre login sin cargar datos privados
- [x] 5.4 Ruta pública con token inválido: limpieza sin redirección forzada
- [x] 5.5 Recarga con token inválido: no autenticado tras validación
- [x] 5.6 Re-login tras limpieza sin errores residuales
- [x] 5.7 Sin loops de redirección ni peticiones infinitas
- [x] 5.8 Login, registro, recuperación de contraseña y navegación pública sin regresiones

## 6. Cierre

- [x] 6.1 Ejecutar `openspec verify --change fix-auth-session-expiration` si el CLI lo soporta
- [x] 6.2 Revisión de que no queden datos privados en UI tras expiración
