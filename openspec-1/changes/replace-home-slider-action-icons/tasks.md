## 1. Assets e iconografía compartida

- [x] 1.1 Crear `shared/media/icons/` con SVG (like, comment, bookmark, share) y nota de licencia/autoría
- [x] 1.2 Crear `shared/media/_media-slider-action-icons.scss` con overrides `::ng-deep` por `[data-action]` (ocultar emoji, mostrar mask SVG, estados activos)
- [x] 1.3 Importar el partial en `home.scss`, `reels-feed.scss` y `reels-desktop-gallery.scss`

## 2. Avatares placeholder locales

- [x] 2.1 Sustituir `buildUserAvatarPlaceholderUrl` por generación `data:image/svg+xml` con iniciales en `user-avatar-placeholder.ts`
- [x] 2.2 Actualizar `resolveSlideAvatarUrl` para nunca devolver ui-avatars (reescritura + vacío → data URL)
- [x] 2.3 Añadir tests unitarios para iniciales, ui-avatars legacy y URL de foto real

## 3. Back-end

- [x] 3.1 Eliminar generación `ui-avatars.com` en `user-reels-feed-ranking.service.ts` (`avatarUrl` → omitir/vacío sin foto)
- [x] 3.2 Verificar que `GET /home/featured-reels` reutiliza el mismo mapper o aplicar el mismo criterio de avatar
- [x] 3.3 Ajustar tests del servicio de ranking si aserten URLs ui-avatars

## 4. Integración en vistas del slider

- [x] 4.1 Confirmar que Home sigue resolviendo avatar en el pipe/map de slides antes de pasarlos a `media-slider`
- [x] 4.2 Confirmar mismo resolver en `reels-feed` y `reels-desktop-gallery`
- [x] 4.3 Actualizar comentarios en SCSS que mencionen emojis (♥ / 💬 / 🔖)

## 5. Verificación

- [x] 5.1 Verificación manual en `/home`: iconos SVG visibles, like/bookmark activos, avatar sin request a ui-avatars (DevTools Network)
- [x] 5.2 Verificación manual en `/reels` (mobile) y galería desktop
- [x] 5.3 Ejecutar `npm run lint` y `npm run test` en `anyjobs-front/anyjobs/`
- [x] 5.4 Ejecutar tests del back-end en `anyjobs-back/` para módulo user-media / feed reels
