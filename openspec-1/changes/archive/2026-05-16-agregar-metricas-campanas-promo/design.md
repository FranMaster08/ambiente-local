## Decisiones

- **Agregación on-read** (sin tabla materializada en MVP): consultas SQL por `campaign_id` + bucle acotado para `watchProgress` (máx. 500 filas/campaña).
- **Ventana por defecto:** 30 días (`windowDays` query opcional).
- **Completion:** `completionRate >= 0.9` en payload de `watchProgress`.
- **Skip temprano:** `kind = slideSkipped` / impresiones (`slideImpression`).
- **Interacciones:** `slideAction` con `action` like | bookmark | share en JSON payload.
- **Pesos documentados** (referencia para ranking, change 4): retención/completion > saves/shares/likes > penalización early skip.

## Endpoints

| Método | Ruta | Auth |
|--------|------|------|
| POST | `/promo-slides/interactions` | Público (`@Public`) |
| GET | `/promo-slides/metrics` | `promo-slides.metrics.read` |
| GET | `/promo-slides/metrics/:campaignId` | idem |

## Non-goals

- Reordenar `GET /promo-slides` para usuarios finales (change `ranking-feed-promocional-home`).
- Panel admin UI.
- Kafka / jobs batch.
