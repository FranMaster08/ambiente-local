## Context

El proyecto ya define **perfil propio** en `/perfil` y **perfil por id** en `/usuarios/:userId`, con lectura **`GET /users/me/profile`** (privado, Bearer) y **`GET /users/profile/:userId`** (público, DTO acotado). El cambio paralelo `mejorar-vista-perfil-usuario-publico-privado` documenta cabecera, métricas y modos propio/público en la página de perfil.

Este cambio aborda la **superficie transversal**: cualquier lista, detalle, card o comentario que muestre identidad de usuario (nombre, avatar, username, iniciales) debe comportarse como **entrada de navegación** coherente hacia esa misma convención de rutas y APIs, sin duplicar contratos ni exponer datos privados.

## Goals / Non-Goals

**Goals:**

- Inventario explícito de vistas/componentes donde aparece un usuario y decisión por ítem: enlace al perfil, excepción UX documentada, o dato no identitario (p. ej. texto genérico “Profesional”).
- Componente o patrón reutilizable (p. ej. `UserIdentityLink`, envoltorio `routerLink` + teclado) que centralice ruta, `aria-label`, foco y fallback de avatar/iniciales.
- Misma regla de **propio vs ajeno** que en diseño de perfil: `userId` de sesión vs `userId` mostrado → navegación a `/perfil` o `/usuarios/:id` según lo ya acordado en el otro cambio, sin bifurcar lógica contradictoria.
- Backend: confirmar que cualquier listado que hoy serialice datos de usuario para UI no inyecta campos privados; cualquier ampliación de payload MUST seguir el DTO público existente o uno restringido reutilizado.
- Estados UX: 404 de usuario, lista vacía, error de red, permisos — mensajes claros sin filtrar internals.

**Non-Goals:**

- Nuevo tipo de feed, reels, vídeo o notificaciones.
- Nuevas librerías de UI o routing.
- Cambiar el modelo de negocio de quién ve postulaciones (solo cómo se presenta y navega).

## Decisions

1. **Ruta canónica para “ver a este usuario”**  
   **Decisión:** Reutilizar **`/usuarios/:userId`** para terceros y la misma ruta cuando el id coincide con la sesión (el layout existente ya bifurca público/privado), y **`/perfil`** solo como atajo al usuario autenticado sin id en URL. Los enlaces generados desde listados MUST usar siempre `userId` conocido del dominio (`ownerUserId`, `userId` del postulante, etc.) hacia `/usuarios/:userId` para no duplicar reglas.  
   **Alternativa descartada:** Generar solo enlaces a `/perfil` para “yo” y `/usuarios/:id` para otros — duplica criterios en cada call site; la decisión del otro diseño ya unifica `/usuarios/:id` para el dueño.

2. **Primitivo de UI**  
   **Decisión:** Introducir o consolidar un **único** componente/directiva “identidad de usuario clickeable” usado en solicitudes, propuestas, postulaciones y cards. Props mínimas: `userId`, `displayName`, `avatarUrl?`, `subtitle?`, `navigateToProfile: boolean` (por defecto `true` para excepciones documentadas).  
   **Alternativa:** Repetir `routerLink` en cada template — alto riesgo de inconsistencia y a11y rota.

3. **CTA explícito “Ver perfil” además del bloque identitario**  
   **Decisión:** En `my-requests-dashboard` (postulantes desplegados y “Postulé a estas”), además de `UserIdentityLink`, mostrar un `<a class="btn btn--secondary">` “Ver perfil” hacia `/usuarios/:userId` cuando haya `userId`, como **hermano** del bloque de identidad (no anidado), para reforzar descubribilidad sin romper HTML ni duplicar rutas en el router.  
   **Alternativa descartada:** Solo el bloque identitario — algunos usuarios no percibían el destino; modal “próximamente” previo se eliminó.

4. **Accesibilidad**  
   **Decisión:** Si el hit target es solo avatar, el control MUST tener `aria-label` que incluya nombre o “Perfil de {nombre}”. El foco MUST ser visible (clases existentes del DS). No usar solo color: combinar subrayado opcional, `cursor: pointer`, o borde en foco según tokens actuales.

5. **Backend**  
   **Decisión:** No añadir nuevos campos sensibles a listados; si falta `userId` en algún DTO que hoy alimenta una fila con nombre, **extender** el DTO de salida con `userId` opaco ya usado en el sistema, no con email. Preferir reutilizar el serializador público de usuario ya usado en `GET /users/profile/:userId` para la forma de “usuario resumido” en listas si existe; si no, alinear nombres de campos con el front en un solo tipo TypeScript.

6. **Excepciones UX**  
   **Decisión:** Las excepciones (texto no navegable) MUST listarse en `tasks.md` con justificación (p. ej. usuario desanonimizado en flujo legal, placeholder “Usuario eliminado” sin id). Por defecto no hay excepción.

7. **Coordinación con `mejorar-vista-perfil-usuario-publico-privado`**  
   **Decisión:** Misma fuente de verdad de rutas y DTOs; cualquier cambio de contrato de perfil MUST actualizar ambos cambios o archivarse en orden explícito en tareas.

## Risks / Trade-offs

- **[Riesgo]** Algún listado no incluye `userId` en el JSON → no se puede enlazar sin nueva query. **Mitigación:** Tarea de auditoría back+front; ampliar DTO en servidor con id opaco.

- **[Riesgo]** Doble navegación (card entera + nombre ambos con link) genera HTML anidado inválido. **Mitigación:** Una sola capa clickeable por ítem o `stopPropagation` documentado; dos enlaces **hermanos** al mismo destino (identidad + “Ver perfil”) están permitidos explícitamente donde se documentó.

- **[Riesgo]** Perfil público sin sesión vs con sesión — diferencias de CTA. **Mitigación:** Reutilizar política `@Public()` ya documentada; no filtrar datos extra en cliente.

- **[Trade-off]** Más componentes tocados en un solo release vs entrega incremental por módulo. **Mitigación:** Orden en tasks: núcleo compartido → solicitudes → propuestas → resto.

## Migration Plan

1. Desplegar backend primero si se amplían DTOs de listados (compatibles hacia atrás: solo campos añadidos opcionales).
2. Desplegar front: el perfil público ya consumible por URL directa debe seguir funcionando tras refresh.
3. Rollback: revertir front deja enlaces estáticos; revertir back solo si se añadieron campos breaking (evitar breaking).

## Open Questions

- Inventario final de pantallas con “usuario sin `userId`” (resolver caso por caso en implementación).
- Si existe comentarios o foro con autores parciales: mismo patrón o queda fuera hasta exista id.
