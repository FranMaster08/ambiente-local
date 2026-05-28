## Context

**Estado actual**

| Área | Ubicación | Comportamiento |
|------|-----------|----------------|
| Home slider | `anyjobs-front/.../home/home.ts`, `home.html`, `home.scss` | `GET /promo-slides` → fallback `mock/home-promo-slides.mock.json`; telemetría `POST /promo-slides/interactions`; `sliderId=home-promotional` |
| DOM objetivo | `section.homeSliderPage` → `media-slider` → `media-slide` → `.slide__overlay` | Contenido mock tipo «@Anyjobs Publicidad — vídeo de ejemplo» |
| Reels UGC | `user_reels`, `UserReelEntity`, `UserReelsService` | CRUD por dueño; estados `moderation_status`, `distribution_status` |
| Ranking feed | `UserReelsFeedRankingService`, `GET /feed/reels` | Score on-read con métricas 30d; cold start por `published_at`; cap testing; depriorizar vistos |
| Feed dedicado | `features/reels-feed/reels-feed.ts`, ruta `/reels` | Mismo patrón de telemetría que Home pero contra `/feed/reels` |

**Dependencias satisfechas:** `feed-reels-ranking-usuario` (archivado), telemetría de retención en slider, modelo multimedia.

## Goals / Non-Goals

**Goals:**

- Exponer Reels destacados para Home ordenados por score descendente.
- Persistir `ranking_score` preparado para materialización futura de la fórmula.
- Centralizar cálculo en `UserReelRankingScoreService`; orden en `UserReelsFeedRankingService` (o delegado).
- Conectar Home al endpoint sin mock como fuente principal.
- Mantener `SlideData` / `ngx-vertical-slider` sin cambiar estructura DOM del slider.

**Non-Goals:**

- Fórmula definitiva de ranking (retención × interacciones × relevancia usuario) — solo estructura y stub documentado.
- Eliminar módulo `promo-slides` o campañas promocionales.
- Modelo social (seguidores) ni recomendación ML.
- Cambiar `/reels` ni endpoints CRUD de Reels.
- Transcodificación o moderación automática nueva.

## Decisions

### 1. Endpoint dedicado `GET /home/featured-reels`

**Decisión:** Nuevo endpoint en lugar de reutilizar solo `GET /feed/reels`.

**Rationale:** Home necesita **límite acotado** (p. ej. 10–20 slides) y `sliderId` semántico distinto; el feed completo en `/reels` puede seguir sin límite o con paginación futura. Evita romper clientes del feed.

**Query params:** `anonymousId` (visitante), `limit` opcional con **default fijo `15`**. Usuario autenticado vía JWT / `x-user-id` en dev, igual que `/feed/reels`.

**Respuesta:** `FeedReelSlide[]` compatible con `SlideData` (`id`, `type`, `media`, `user`, `caption`, `counts` opcionales si el mapper las expone).

### 2. Campo `ranking_score` en `user_reels`

**Decisión:** `ranking_score` `double` / `decimal`, **NOT NULL**, default `0`.

**Rationale:** Alineado con convención del proyecto y con `priority` en campañas promo. Permite jobs futuros que materialicen el score sin recalcular en cada request.

**Uso en este change:** el servicio de ranking **calcula** el score on-read para ordenar. **No** se materializa ni persiste `ranking_score` en BD durante este change (solo columna con default `0`); la escritura del valor calculado queda para un change/job posterior.

### 3. `UserReelRankingScoreService` aislado

**Decisión:** Nuevo servicio con métodos `computeScore(reelId, metrics?)` y `resolveEffectiveScore(reel, metrics?)`.

**Implementación inicial:** delegar a la lógica existente de `UserReelsFeedRankingService.computeScore` (extraer a servicio compartido) o invocar desde ahí. Comentario breve: *«Fórmula definitiva pendiente de definición funcional»*.

**No** duplicar pesos en `home.ts` ni en controladores.

### 4. Reutilizar elegibilidad y orden del feed

**Decisión:** `UserReelsFeedRankingService.listForHome(actor, limit)` filtra igual que `listRankedFeed`:

- `moderation_status = approved`
- `distribution_status ∈ { testing, scaling }`
- `media_asset.status = ready`
- cap diario si `testing`
- excluir sin media válida
- orden: no vistos primero → score desc → `published_at` desc
- aplicar `.slice(0, limit)` al final con **default y máximo 15**

### 5. Frontend Home

**Decisión:**

- URL: `GET /home/featured-reels?anonymousId=...`
- Eliminar `catchError` hacia mock como cadena principal; no datos ficticios como reales.
- **Estado vacío / error:** mostrar **placeholder visual** en el área del slider (misma zona que `homeSliderWrap`), sin montar `media-slider` con slides mock. El placeholder SHALL ser accesible y coherente con el diseño de Home (mensaje breve + estilo neutro; sin simular un reel real).
- `sliderId`: `home-featured-reels` (cambio de `home-promotional` en telemetría nueva).
- `POST /feed/reels/interactions` con `reelId` en lugar de `campaignId`.
- Reutilizar instrumentación de retención copiada de `reels-feed.ts` / `home.ts` actual (MutationObserver, `watchProgress`, etc.).
- Textos UI: «Reels» / «contenido» en lugar de «promociones» donde aplique.

**Archivos:** `home.ts`, `home.html`, `proxy.conf.json` (ruta `/home`), `auth-bearer.interceptor.ts` si aplica.

### 6. Control de reproducción en slider

**Decisión:** `MediaPlaybackService` en raíz de la app (`app.ts`) detiene todos los `<video>` en `NavigationStart` y `visibilitychange`. En Home y `/reels`, utilidades compartidas pausan **todos** los vídeos del slider antes de reproducir solo el slide con `is-visible`, con listener de scroll en `.media-slider__viewport` para vencer carreras con el `IntersectionObserver` de `ngx-vertical-slider`.

**Rationale:** La librería puede llamar `play()` en varios slides durante el scroll; el cleanup del componente llega tarde al navegar.

### 7. Métricas opcionales en overlay

**Decisión:** Mapear `counts` en `SlideData` solo si existen en API (likes, comments, saves, shares); si faltan, omitir o cero sin error. El slider no debe fallar por campos ausentes.

### 8. Alternativas consideradas

| Alternativa | Por qué no |
|-------------|------------|
| Reemplazar `GET /promo-slides` por reels | Rompe contrato promo y analytics de campañas |
| Solo `GET /feed/reels?limit=N` en Home | Acopla semántica feed exploración = Home destacados |
| Score solo en memoria sin columna | No cumple preparación para reglas futuras materializadas |
| Duplicar ranking en front | Viola requisito de una sola fuente de verdad |

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| Home vacía sin Reels aprobados en testing/scaling | Placeholder visual en área del slider; documentar flujo de moderación/distribución |
| Doble telemetría promo + reels durante transición | Cambiar solo Home a `/feed/reels/interactions`; promo intacto para otros consumidores |
| `ranking_score` desincronizado del cálculo live | MVP ordena por score calculado; columna para jobs futuros |
| Regresión en estilos `::ng-deep .slide__overlay` | No cambiar estructura del slider; solo datos del input `slides` |

## Migration Plan

1. Migración BD: `ranking_score` default 0.
2. Deploy backend: endpoint nuevo; sin cambiar `/feed/reels`.
3. Deploy front: Home apunta a nuevo endpoint.
4. Rollback: revertir front a `/promo-slides` si es necesario; columna nueva es compatible hacia atrás.

## Decisiones de producto (cerradas)

| Tema | Decisión |
|------|----------|
| Límite del slider Home | **15** reels como máximo (default de `GET /home/featured-reels`; query `limit` MAY permitir menos, no más de 15 salvo cambio futuro) |
| Materialización de `ranking_score` | **Más adelante** — este change solo añade la columna y ordena por score calculado on-read |
| Sin reels / error de carga | **Placeholder visual** en el área del slider (no ocultar la sección ni usar mock como contenido real) |
