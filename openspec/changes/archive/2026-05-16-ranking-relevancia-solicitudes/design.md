## Score

```
engagement = (ctr × 0.3) + (detailRate × 0.4) + (proposalRate × 0.2) + min(avgTimeOnDetailMs/60000, 1) × 0.1
ctr = cardClicks / max(impressions, 1)
detailRate = detailViews / max(impressions, 1)
proposalRate = proposalsStarted / max(detailViews, 1)

score = freshnessNorm × 0.35
      + engagement × 0.4
      + relationshipBoost × 0.15
      + tagAffinity × 0.1
```

- **freshnessNorm:** `publishedAtSort / max(publishedAtSort)` en el conjunto activo.
- **relationshipBoost:** 1.0 si el actor (usuario autenticado) envió propuesta a otra solicitud del mismo `owner_user_id`, o 0.6 si solo vio detalle de otra solicitud del mismo dueño; 0 si no aplica.
- **tagAffinity:** proporción de tags de la solicitud que aparecen en solicitudes que el actor abrió en detalle (`requestDetailView`).
- **Cold start:** si `impressions < 5`, score = `freshnessNorm × 0.35` (solo componente de frescura; no compite con 1.0).
- **Vistas previas:** solicitudes con `requestListImpression` o `requestDetailView` del actor van al final del mismo score.

## API

| Parámetro | Valores | Default listado público |
|-----------|---------|---------------------------|
| `sort` | `relevance`, `date`, `publishedAtDesc` | `publishedAtDesc` en API; front envía `relevance` |
| `anonymousId` | string | opcional |

## Non-goals

- Panel admin de métricas.
- Feed vertical tipo Reels.
- ML / Kafka.
