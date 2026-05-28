## Context

**Anyjobs** — ruta de **solicitudes abiertas** (`OpenRequestsLanding`). Los ítems vienen de **`OpenRequestsService.listOpenRequests`** → **`GET /open-requests`**. Cada ítem incluye **`id`** y **`locationLabel`**.

En algunos entornos, **`locationLabel`** no es solo «Ciudad · Barrio» sino que repite o antepone el identificador (UUID), por ejemplo en varias líneas o como `uuid · Sevilla · Triana`.

## Goals / Non-Goals

**Goals:**

- Que la lista **`.nearbyList`** muestre únicamente texto útil de ubicación.
- Reutilizar la misma lógica de etiqueta para **markers del mapa** y **preview pins** dentro de la misma vista, evitando duplicar UUID en UI.

**Non-Goals:**

- Cambiar el contrato del DTO del API en esta entrega (opcional más adelante).
- Validación en backend del formato de `locationLabel` (podría añadirse como invariante de dominio).

## Decisions

1. **Helper `locationLabelZoneOnly(raw)`**  
   - Si hay ≥2 líneas y la primera coincide con patrón UUID v4 (hex + guiones), se descarta esa línea y se concatena el resto.  
   - En una sola línea, se elimina prefijo `^[uuid](\s*·\s*|\s+)`.  
   - Se recorta un `·` inicial sobrante tras quitar la primera línea.

2. **Exposición al template**  
   - Método **`nearbyZoneLabel(it.item.locationLabel)`** en el componente para la lista.

3. **Mapa (`mapMarkers`)**  
   - Antes: `req.locationLabel ? \`${req.id} · ${req.locationLabel}\` : req.id`.  
   - Después: `locationLabelZoneOnly(req.locationLabel)` con fallback **`Solicitud abierta`** si queda vacío.

4. **Preview pins**  
   - Antes: `label: req.id`.  
   - Después: zona saneada o **`Solicitud`**.

## Risks / Trade-offs

- **Heurística UUID:** si una zona legítima coincidiera con el patrón (improbable), podría truncarse; el patrón es el estándar 8-4-4-4-12 hex.
- **Fallback genérico:** puede homogeneizar varios pins si todos los labels fallan el saneo; mejor corregir datos.

## Open Questions

- ¿Migración SQL o script para **normalizar** filas existentes en `open_requests.location_label`?
- ¿Exponer **`city`** / **`district`** como campos estructurados** en el API** y derivar el label en el cliente?
