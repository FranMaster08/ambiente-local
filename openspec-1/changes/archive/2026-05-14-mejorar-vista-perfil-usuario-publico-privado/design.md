## Context

La ruta `/perfil` carga el componente `Profile` (`anyjobs-front/anyjobs/src/app/features/auth/profile/`), con datos enriquecidos vía **`GET /users/me/profile`** (Bearer) y sesión en `AuthSessionService`. La ruta **`/usuarios/:userId`** muestra perfil público (`GET /users/profile/:userId`) o, si el `userId` coincide con la sesión, el mismo flujo privado que `/perfil`.

Existe documentación previa en `anyjobs-front/openspec/specs/user-profile-view/spec.md` centrada en “Mi perfil” y logout **en la vista de perfil**; la implementación actual **no duplica logout** en el pie del perfil (sigue en el menú de cuenta del shell). Conviene delta o sync al archivar.

## Goals / Non-Goals

**Goals:**

- Experiencia de perfil más clara y responsive con cabecera, métricas reales, acciones y tabs extensibles.
- Dos visibilidades bien definidas (propio / público) con lógica y datos alineados entre front y back.
- Contratos API que no expongan datos sensibles en contexto público.
- Sección explícita “contenido multimedia” como placeholder sin implementar video/reels.

**Non-Goals:**

- Implementar reels, videos, subida o reproducción de multimedia.
- Copiar diseños de terceros; librerías UI nuevas salvo justificación documentada.
- Inventar métricas o datos de demostración hardcodeados.

## Decisions

1. **Detección “perfil propio”**  
   **Decisión:** Comparar el identificador del usuario autenticado en sesión con el identificador del perfil cargado (misma fuente de verdad que el backend, p. ej. `userId` UUID). Si coinciden → modo propio; si no → público. Si no hay sesión y la ruta es pública de tercero → solo modo público (o 401 según política de rutas públicas).  
   **Alternativa descartada:** Confiar solo en la ruta (`/perfil` = siempre propio) sin unificar con `/usuarios/:id` para el dueño — fragmenta la UX y duplica lógica.

2. **Rutas**  
   **Decisión:** Mantener `/perfil` como entrada al perfil del usuario autenticado (propio). Introducir o reutilizar una ruta explícita para perfil ajeno (p. ej. `/usuarios/:userId` o la convención ya existente en back) de forma que el mismo layout de página pueda recibir `userId` por parámetro. Documentar en tareas la convención final tras auditoría.  
   **Alternativa:** Solo query `?id=` — menos REST y peor para compartir enlaces; solo considerar si el proyecto ya lo usa masivamente.

3. **API: lectura de perfil**  
   **Implementado:** `GET /users/me/profile` (autenticado, DTO privado) y `GET /users/profile/:userId` (público, `ParseUUIDPipe`, DTO público). Evita colisión con `/users/me/*` usando el segmento literal `profile/` antes del UUID.

4. **Métricas**  
   **Decisión:** Cada tarjeta de métrica se renderiza solo si el backend (o agregación documentada) devuelve el valor o un objeto de agregación vacío permitido. Si no hay endpoint → no mostrar la tarjeta o mostrar sección “sin datos” sin números ficticios.

5. **Tabs y multimedia futuro**  
   **Decisión:** Componente de tabs (o segment control) reutilizando patrones del proyecto; pestaña “Multimedia” o equivalente con copy de “Próximamente” y sin llamadas de red a medios.

6. **Coherencia visual**  
   **Decisión:** Reutilizar tokens, tipografía y componentes del design system / estilos existentes (`profile.scss` evoluciona en lugar de CSS aislado incompatible).

7. **Pie de acciones en perfil propio**  
   **Decisión:** En el hero del modo propio, el pie (`profileActions`) incluye solo el enlace **“Mis solicitudes”**. No se duplican **“Ver solicitudes abiertas”** ni **logout** (ya accesibles desde el header / menú de cuenta).

8. **Resiliencia ante fallo de `GET /users/me/profile`**  
   **Decisión:** **401** → limpiar sesión local y mostrar estado equivalente a “sin sesión” en `/perfil`. Otros errores en `/perfil` → banner + vista usable con datos de **sesión** ya cargados, **sin** rellenar métricas inventadas (`metrics` opcional en el modelo de cliente hasta que el API responda).

## Risks / Trade-offs

- **[Riesgo]** El backend aún no expone métricas agregadas → la cabecera queda rica pero la zona numérica vacía. **Mitigación:** Estados vacíos explícitos y tareas priorizadas por datos ya disponibles (p. ej. conteos desde repositorios existentes de solicitudes/propuestas).

- **[Riesgo]** Exponer `userId` en URLs puede facilitar enumeración. **Mitigación:** Alinear con práctica actual del producto; no añadir datos extra en respuesta pública; valorar UUID opaco ya usado por el sistema.

- **[Riesgo]** Divergencia entre spec del monorepo front (`user-profile-view`) y spec raíz `vista-perfil-usuario`. **Mitigación:** Al archivar, `openspec-sync-specs` o merge manual explícito en tareas.

- **[Trade-off]** Dos rutas implican más pruebas e2e; beneficio: URLs claras y compartibles.

## Migration Plan

1. Desplegar backend con nuevos DTOs/endpoints antes o en el mismo release que el front que los consume (feature flag opcional solo si el equipo lo usa; no es obligatorio en el diseño).
2. Rollback: revertir despliegue conjunto; rutas antiguas `/perfil` deben seguir respondiendo (compatibilidad hacia atrás en sesión).
3. Sin migración de datos para multimedia (no aplica).

## Open Questions

- ~~¿Existe ya endpoint de usuario por id público?~~ **Resuelto:** `GET /users/profile/:userId`.
- ~~¿Agregados de conteo?~~ **Resuelto:** solicitudes publicadas (`open_requests.owner_user_id`) y propuestas (`proposals.user_id`); “completadas” pendiente de modelo de negocio.
- **Perfiles públicos sin autenticación:** hoy el endpoint público es `@Public()`; SEO y rate limiting quedan como mejora futura si el producto lo exige.
