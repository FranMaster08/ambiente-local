## Why

Los usuarios pueden subir y ver reels en la pestaña Multimedia del perfil propio, pero no pueden retirar contenido publicado por error o que ya no desean mostrar. El backend ya expone `DELETE /user-reels/:reelId` y el cliente `UserMediaApi.deleteReel`; falta la experiencia en la galería (`app-profile-multimedia`) con intención clara de borrado y confirmación para evitar eliminaciones accidentales.

## What Changes

- Icono de eliminar visible en cada tile de la cuadrícula **solo en perfil propio** (`isOwnProfile`), sin interferir con el tap que abre el reproductor.
- Diálogo modal de confirmación (“¿Estás seguro de que quieres borrar este reel?”) con acciones cancelar y confirmar.
- Tras confirmar: llamada a `DELETE /user-reels/:reelId`, actualización del listado local, cierre del reproductor si el reel eliminado estaba abierto, y feedback de error si falla la API.
- Sin cambios de contrato HTTP ni permisos: se reutiliza la capacidad existente de `user-media-content`.

## Capabilities

### New Capabilities

_(ninguna — el borrado del dueño ya está especificado en `user-media-content`)_

### Modified Capabilities

- `vista-perfil-usuario`: la pestaña Multimedia en perfil propio SHALL permitir eliminar reels propios con confirmación explícita.

## Impact

- **Front:** `anyjobs-front/anyjobs/src/app/features/auth/profile/profile-multimedia.{html,ts,scss}` (icono, modal confirmación, integración `deleteReel`).
- **Back:** sin cambios (endpoint y servicio ya implementados).
- **Specs:** delta en `vista-perfil-usuario`; `user-media-content` permanece como referencia del contrato API.
