## 1. UI — control de eliminar en la galería

- [x] 1.1 En `profile-multimedia.html`, envolver cada tile en estructura que permita un `<button type="button">` de eliminar **fuera** de `multimediaTile`, visible solo con `@if (isOwnProfile())`
- [x] 1.2 Añadir icono de papelera (SVG o clase) con `aria-label="Eliminar reel"` y `(click)="$event.stopPropagation(); requestDelete(reel)"`
- [x] 1.3 Estilos en `profile-multimedia.scss`: posición esquina superior derecha, contraste, estados hover/focus/disabled

## 2. Modal de confirmación

- [x] 2.1 Añadir segundo `app-modal` (`size="sm"`) enlazado a `reelPendingDelete()` con texto “¿Estás seguro de que quieres borrar este reel?”
- [x] 2.2 Botones Cancelar (cierra sin borrar) y Eliminar (dispara borrado, deshabilitado mientras `deleteBusy()`)

## 3. Lógica de borrado

- [x] 3.1 En `profile-multimedia.ts`: signals `reelPendingDelete`, `deleteBusy`, `deleteError`; métodos `requestDelete`, `cancelDelete`, `confirmDelete`
- [x] 3.2 `confirmDelete`: llamar `mediaApi.deleteReel(id)`, en éxito filtrar `reels`, cerrar player si coincide, `reelsChanged.emit()`, cerrar modal
- [x] 3.3 Manejo de errores HTTP (401, 403, 404, red) con mensajes en español coherentes con el componente

## 4. Verificación

- [x] 4.1 Probar en perfil propio: icono visible, confirmación, cancelar no borra, confirmar quita tile y llama API
- [x] 4.2 Probar perfil público / otro usuario: sin icono de eliminar
- [x] 4.3 Ejecutar lint/typecheck del front afectado
