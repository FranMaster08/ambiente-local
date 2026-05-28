# Inventario y auditoría (implementación)

## 1.1 Frontend — componentes y rutas

- **Rutas:** `app.routes.ts` → `/perfil` (propio), `/usuarios/:userId` (público o propio si coincide id con sesión).
- **Vista:** `features/auth/profile/profile.ts|html|scss`.
- **Sesión:** `shared/auth/auth-session.service.ts` (localStorage `anyjobs.auth.*`).
- **API usuarios:** `shared/api/user.api.ts` + `user-profile.models.ts`.

## 1.2 Usuario autenticado

- Tras login, `AuthSessionService.setSession` persiste `UserDto` del backend (incl. id, email, roles, campos MVP opcionales).
- El perfil enriquecido se obtiene con `GET /users/me/profile` (Bearer) cuando la ruta es propia o `/usuarios/:id` con `id === session.user.id`.

## 1.3 Perfil público de terceros

- **Antes:** no existía ruta dedicada.
- **Ahora:** `/usuarios/:userId` + enlace “Ver perfil” en detalle de solicitud si hay `ownerUserId` y el visitante no es el dueño; además enlaces desde **Mis solicitudes** (postulantes / “Postulé a estas”) vía `UserIdentityLink` y CTA “Ver perfil”; menú “Mi perfil” en shell apunta a `/usuarios/:id` cuando hay sesión (cambio coordinado `navegacion-perfil-publico-referencias-usuario`).

## 1.4 Backend — endpoints y datos

- **Existentes:** `PATCH /users/me/*` (perfil parcial), auth login/register.
- **Nuevos:**
  - `GET /users/me/profile` — `@RequirePermissions('users.profile.read')`, serialización **privada** (`UserPrivateProfileResponseDto`).
  - `GET /users/profile/:userId` — `@Public()`, UUID, serialización **pública** (`UserPublicProfileResponseDto`).
- **Métricas reales:** conteos TypeORM `open_requests` por `owner_user_id` (sin borrados) y `proposals` por `user_id`. Sin métrica “completadas” hasta exista estado en dominio.

## 1.5 Diferenciación propio/público

- **Antes:** no había lectura de perfil por API segregada.
- **Ahora:** DTOs distintos + pruebas e2e que fallan si el JSON público incluye `email` o `phoneNumber`.

## 7.2 Spec `user-profile-view` (front legacy)

- La spec en `anyjobs-front/openspec/specs/user-profile-view/spec.md` aún exige logout **en la vista de perfil**; la implementación actual lo centraliza en el **shell**. Al archivar: **MODIFIED** o nueva spec que refleje logout solo en header/menú cuenta.

## UX y pie de acciones (actualización)

- **Modo propio — `profileActions`:** solo `routerLink` a **/mis-solicitudes**. Eliminados del hero: **Logout**, **Ver solicitudes abiertas** (accesibles por header / landing de solicitudes).
- **Resiliencia:** `GET /users/me/profile` → 401 `auth.clear()`; otros errores en `/perfil` → banner + datos desde `AuthSessionService` sin métricas falsas.
- **Tipos front:** `UserPrivateProfileDto.metrics` opcional cuando solo hay snapshot de sesión.
