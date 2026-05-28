## 1. Saneo y lista cercana

- [x] 1.1 Implementar `locationLabelZoneOnly` (UUID en primera línea o prefijo en línea única).
- [x] 1.2 Usar `nearbyZoneLabel` en `open-requests-landing.html` para `.nearbyList` / `.nearbyText`.

## 2. Mapa y vista previa

- [x] 2.1 Sustituir etiquetas de `mapMarkers` que concatenaban `id` + `locationLabel` por zona saneada + fallback.
- [x] 2.2 Sustituir `label: req.id` en `previewPins` por zona saneada + fallback.

## 3. Verificación

- [x] 3.1 `npm run build` en `anyjobs-front/anyjobs`.

## 4. Seguimiento (opcional)

- [ ] 4.1 Auditar y normalizar datos en BD / seed para `location_label` sin UUID embebido.
- [ ] 4.2 Documentar en contrato de API que `locationLabel` es solo texto de ubicación (revisión OpenAPI/DTO).
