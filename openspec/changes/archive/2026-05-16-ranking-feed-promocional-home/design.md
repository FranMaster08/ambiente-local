## Score

```
score = (completionRate × 0.5)
      + (saves/imp × 0.15) + (shares/imp × 0.15) + (likes/imp × 0.1)
      − (earlySkipRate × 0.2)
```

- **Cold start:** si `impressions < 10`, orden por `priority` (×1000) + `createdAt`.
- **Testing cap:** default 200 impresiones/día (`slideImpression`) si `testing_daily_impression_cap` es null; campaña excluida del feed al superar cap.

## Personalización

- Actor: `userId` (JWT / `x-user-id` en dev) o `anonymousId` (query en GET).
- Campañas con impresión o interacción previa del actor van al final (mismo score sort dentro del grupo).

## Non-goals

- A/B automático, Explore, viralidad global.
- Cambiar forma de `SlideData` en el front.
