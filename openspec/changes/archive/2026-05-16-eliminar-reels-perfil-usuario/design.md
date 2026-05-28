## Context

- Componente objetivo: `ProfileMultimediaComponent` (`app-profile-multimedia`) en la pestaña Multimedia del perfil.
- DOM actual: cada reel es un `<li.multimediaGrid__item>` con `<button.multimediaTile>` que abre `app-modal` reproductor al hacer clic.
- API existente: `UserMediaApi.deleteReel(reelId)` → `DELETE /user-reels/:reelId` (backend `UserReelsService.delete` ya implementado).
- Spec base: `user-media-content` ya define el escenario de eliminación del dueño; este change solo añade UX en `vista-perfil-usuario`.

## Goals / Non-Goals

**Goals:**

- Icono de eliminar por tile en perfil propio, con `aria-label` accesible.
- Modal de confirmación reutilizando `app-modal` (mismo patrón que el reproductor).
- Flujo: confirmar → `deleteReel` → quitar ítem del signal `reels` → `reelsChanged.emit()` → cerrar reproductor si aplica.
- `stopPropagation` en el botón eliminar para no abrir el player.

**Non-Goals:**

- Cambios en backend, permisos o política de borrado del `media_asset`.
- Eliminar en lote, deshacer (undo) o papelera temporal.
- Eliminar desde el modal reproductor (solo desde la galería en v1).

## Decisions

1. **Control de eliminar como botón hermano dentro del `<li>`, no dentro del `<button.multimediaTile>`**  
   Evita anidar botones (HTML inválido) y separa “reproducir” de “eliminar”. El tile sigue siendo un único botón para abrir el player.

2. **Segundo `app-modal` para confirmación (`size="sm"`)**  
   Reutiliza scroll lock, overlay y tecla Escape del componente existente. Título: “Eliminar reel”; cuerpo: texto de confirmación; pie: “Cancelar” (secundario) y “Eliminar” (destructivo).

3. **Icono: SVG inline o clase utilitaria**  
   Papelera estándar, posición absoluta en esquina superior derecha del tile (`multimediaTile__delete`), visible al hover/focus en desktop y siempre visible en touch si el diseño lo requiere.

4. **Estado local**  
   - `reelPendingDelete: signal<UserReelDto | null>`  
   - `deleteBusy: signal<boolean>`  
   - `deleteError: signal<string | null>` (banner bajo la galería o en el modal de confirmación)

5. **Tras DELETE exitoso**  
   Filtrar `reels` por id; si `playerReel()?.id === id`, llamar `closePlayer()`.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Doble tap elimina sin querer | Modal obligatorio antes del DELETE |
| Icono tapa miniatura | Tamaño ~32px, contraste con fondo semitransparente |
| Error 401/403 | Mensaje en español; no quitar tile del listado |
| Reel visible en feed tras borrar | Fuera de alcance; el feed puede cachear; documentar si hace falta invalidación en change futuro |

## Migration Plan

Despliegue solo front. Sin migraciones de datos. Rollback: revertir commit del componente multimedia.

## Open Questions

- ¿Mostrar icono siempre en móvil o solo al mantener pulsado? **Propuesta v1:** siempre visible en perfil propio para descubribilidad.
