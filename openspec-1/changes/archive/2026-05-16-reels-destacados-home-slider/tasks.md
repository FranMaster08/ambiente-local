## 1. Modelo y puntuación (backend)

- [x] 1.1 Migración: agregar columna `ranking_score` (NOT NULL, default 0) a `user_reels` y mapear en `UserReelEntity`
- [x] 1.2 Crear `UserReelRankingScoreService` con `resolveEffectiveScore` / `computeScore`; extraer lógica desde `UserReelsFeedRankingService` sin duplicar pesos; **solo cálculo on-read** (no escribir `ranking_score` en este change)
- [x] 1.3 Documentar en el servicio que la fórmula definitiva y la materialización en BD se definirán más adelante (comentario breve)

## 2. API Reels destacados Home (backend)

- [x] 2.1 Implementar `listForHome(actor, limit)` en `UserReelsFeedRankingService` reutilizando elegibilidad, validación de media y orden existente
- [x] 2.2 Crear `GET /home/featured-reels` (`@Public`, query `anonymousId`, `limit` opcional con **default 15**, máximo 15) devolviendo `FeedReelSlide[]`
- [x] 2.3 Registrar ruta en módulo `user-media` y proxy front (`/home` → API)
- [x] 2.4 Añadir tests e2e: array vacío, orden por score, exclusión de reel sin media / no aprobado, máximo **15** ítems con default y con `limit` menor

## 3. Home slider (frontend)

- [x] 3.1 Cambiar `home.ts` para cargar `GET /home/featured-reels` con `anonymousId`; eliminar fallback a `home-promo-slides.mock.json` como fuente principal
- [x] 3.2 Cambiar telemetría a `POST /feed/reels/interactions` con `reelId` y `sliderId` `home-featured-reels`
- [x] 3.3 Implementar placeholder visual en `home.html` / `home.scss` para vacío y error (área del slider, sin mock); textos de carga acordes
- [x] 3.4 Mapear slides a `SlideData` incluyendo `user`, `caption`, `counts` opcionales sin romper si faltan métricas
- [x] 3.5 Actualizar `auth-bearer.interceptor.ts` / proxy si hace falta incluir `/home/featured-reels`

## 4. Validación manual y regresión

- [x] 4.1 Verificar Home con 0 reels (placeholder visual, sin mock ni slider activo)
- [x] 4.2 Verificar Home con 1 reel y con varios reels; orden descendente por score
- [x] 4.3 Verificar que CRUD de reels del cliente y ruta `/reels` siguen funcionando
- [x] 4.4 Verificar mute por defecto y overlay (`slide__overlay`) con datos reales
- [x] 4.5 Ejecutar `openspec verify --change reels-destacados-home-slider` (sustituido por e2e `feed-reels` + `home-featured-reels`: 4/4 OK)

## 5. Reproducción de vídeo en slider (frontend)

- [x] 5.1 `MediaPlaybackService` global: parar vídeo en `NavigationStart` y al ocultar pestaña
- [x] 5.2 Utilidades `media-slider-playback`: pausar todos antes de reproducir el visible; `hardStop` con `video.src = ''`
- [x] 5.3 Sincronización en scroll del viewport y en cambio de slide (`MutationObserver` + `requestAnimationFrame`)
- [x] 5.4 Misma lógica en Home (`/home`) y feed dedicado (`/reels`); avatar navega a perfil sin audio residual
