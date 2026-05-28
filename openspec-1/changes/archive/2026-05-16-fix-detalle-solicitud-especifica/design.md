## Context

La página `open-request-detail` consume `GET /open-requests/:id` y normaliza a `OpenRequestDetail`. Problemas detectados en implementación y QA:

- Postulantes visible con “No autenticado.” por token expirado + condición de owner en cliente, o por suscripciones HTTP sin cancelar al navegar.
- Publicador mostraba “Publicador” por fallback a `provider` demo en lugar de `fullName` del perfil.
- Sin separación visual entre Descripción y Publicado por.
- Header duplicaba “Ver perfil” y “Contactar” respecto al sidebar y la card de publicador.

## Goals / Non-Goals

**Goals:**

- Detalle público sin filtraciones (postulantes, UUID, errores de API en tarjetas privadas).
- Nombre real del publicador vía perfil público.
- Antigüedad relativa correcta (backend).
- UX responsive, galería accesible, header sin CTAs redundantes.

**Non-Goals:**

- Nuevo endpoint de nombre de publicador en open-requests (se usa perfil de usuario existente).
- Reseñas reales del publicador hasta contar con API dedicada.
- Restaurar “Contactar” o “Ver perfil” en el header.

## Decisions

1. **Visibilidad de postulantes**  
   **Decisión:** `isOwnerWithSession` exige sesión + `ownerUserId` + match con `user.id`. `showPostulantesSection` solo si además `postulantesState` es `loading` o `success` (nunca mostrar tarjeta en `error`). En 401/403 al listar: resetear estado, ocultar tarjeta; en 401 limpiar sesión local.  
   **Implementación:** `switchMap` en carga de detalle; secuencia (`postulantesLoadSeq`) para ignorar respuestas tardías.

2. **Publicador en UI**  
   **Decisión:** Card **“Publicado por”** con `UserIdentityLinkComponent`. Tras cargar detalle, `UserApi.getPublicProfile(ownerUserId)` → `fullName` en el enlace. Fallback: `provider.name` si no es demo, luego “Publicador”.  
   **Resuelto:** Ya no se depende solo del DTO de open-request para el nombre.

3. **Antigüedad relativa**  
   **Decisión:** `formatRelativePublishedAt(publishedAtSort)` en backend al serializar list/detail/listByOwner/ranking.

4. **UUID en UI**  
   **Decisión:** Eliminado de descripción y estado de error.

5. **Layout main**  
   **Decisión:** `.main { display: flex; flex-direction: column; gap: 18px; }` para separar Descripción, Publicado por y demás bloques.

6. **Modal galería**  
   **Decisión:** Botones circulares con chevron, contador centrado, teclado ←/→, `aria-label`.

7. **Header CTAs**  
   **Decisión:** Quitar “Ver perfil” y “Contactar” del `detailHeader`. Solo “Postular” (`*ngIf="!isRequestOwner()"`) que hace scroll al sidebar. Perfil del creador solo en “Publicado por”.

## Risks / Trade-offs

- **[Riesgo]** Flash breve “Publicador” hasta cargar perfil. **Mitigación:** petición rápida a perfil público; nombre suele reemplazar en el mismo tick si `of()`/red es rápida.
- **[Riesgo]** Creador con token inválido no ve postulantes ni mensaje explicativo. **Mitigación:** sesión se limpia en 401; puede reautenticarse.
- **[Trade-off]** Sin “Contactar” en header; acción equivalente vía sidebar.

## Migration Plan

1. Backend (etiquetas relativas) — compatible.
2. Front (detalle) — compatible.
3. Rollback independiente por capa.

## Open Questions

- _(ninguna pendiente para este cambio)_
