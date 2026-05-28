## 1. OpenSpec y revisión de baseline

- [x] 1.1 Validar change `editar-perfil-propio` (proposal, design, specs, tasks)
- [x] 1.2 Revisar `Profile`, `UserApi`, DTOs y use cases existentes de `/users/me/*` como referencia

## 2. Backend — persistencia y displayName

- [x] 2.1 Crear migración TypeORM: columna `display_name VARCHAR(200) NULL` en `users`
- [x] 2.2 Añadir `displayName` a `UserEntity` y repositorio de usuario
- [x] 2.3 Incluir `displayName` en `UserPrivateProfileResponseDto` y `UserPublicProfileResponseDto`
- [x] 2.4 Mapear `displayName` en `UserProfileReadService`

## 3. Backend — PATCH /users/me/profile

- [x] 3.1 Crear `UpdateProfileRequestDto` con whitelist estricta y validaciones por campo
- [x] 3.2 Implementar `UpdateProfileUseCase` reutilizando validaciones de ubicación/worker/client existentes
- [x] 3.3 Exponer `PATCH /users/me/profile` en `UserProfileController` (204, permiso alineado a otros PATCH)
- [x] 3.4 Rechazar campos protegidos en body (`forbidNonWhitelisted`) y validar catálogo geográfico
- [x] 3.5 Añadir tests unitarios de `UpdateProfileUseCase`
- [x] 3.6 Añadir tests e2e: éxito parcial, payload con `email`/`fullName` rechazado, municipio inválido

## 4. Frontend — modelos y API

- [x] 4.1 Añadir `displayName` a `UserPrivateProfileDto` y `UserPublicProfileDto`
- [x] 4.2 Crear `UpdateProfileRequest` en `user.models.ts`
- [x] 4.3 Añadir `updateProfile()` en `UserApi` → `PATCH /users/me/profile`

## 5. Frontend — UI Editar perfil

- [x] 5.1 Añadir botón «Editar perfil» en hero de perfil propio (`isOwnProfile`)
- [x] 5.2 Crear componente/modal de edición con campos editables según rol (worker/client)
- [x] 5.3 Reutilizar `LocationGeographyService` y cascada país → división → municipio + barrio
- [x] 5.4 Implementar «Guardar cambios» con estado loading, éxito (banner/toast) y errores de validación
- [x] 5.5 Implementar «Cancelar» sin persistir cambios
- [x] 5.6 Tras guardar exitoso: cerrar formulario y recargar perfil (`reload()`)
- [x] 5.7 Usar `displayName ?? fullName` en cabecera e iniciales del perfil
- [x] 5.8 Estilos responsive acordes a `profile.scss` / design system

## 6. Frontend — tests

- [x] 6.1 Test: botón «Editar perfil» visible solo en perfil propio
- [x] 6.2 Test: formulario no incluye campos protegidos (email, documento, etc.)
- [x] 6.3 Test: submit llama a `updateProfile` con payload esperado
- [x] 6.4 Test: cancelar no invoca API

## 7. Validación final

- [x] 7.1 Ejecutar linter front (`anyjobs-front/anyjobs`)
- [x] 7.2 Ejecutar linter back (`anyjobs-back`)
- [x] 7.3 Ejecutar tests front relevantes
- [x] 7.4 Ejecutar tests back relevantes (unit + e2e user-profile)
- [x] 7.5 Revisar documentación (`README`, contratos API) y actualizar si aplica
- [x] 7.6 Marcar tareas completadas en este archivo
