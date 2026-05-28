## Why

El botón de comentarios (💬) del slider de reels destacados en `/home` ya existe en la UI de `ngx-vertical-slider`, pero no ofrece ninguna respuesta visual al usuario. Se necesita un panel inferior preparado para futuros comentarios reales, sin bloquear la evolución del feed ni tocar backend en esta iteración.

## What Changes

- Detectar la acción `comment` emitida por `(slideAction)` del `<media-slider>` en Home y abrir un panel inferior superpuesto.
- Panel tipo bottom sheet (~50vh), animación de entrada desde abajo, overlay semitransparente y cierre por botón X, clic fuera y tecla Escape.
- Contenido placeholder: título «Comentarios», mensaje de estado vacío y área scrollable reservada para la lista futura.
- Mantener telemetría existente (`slideAction` con `action: 'comment'`) y el resto de acciones del slider (like, bookmark, share, seguir, reproducción).
- Sin API de comentarios, modelos de dominio ni persistencia en esta fase.

## Capabilities

### New Capabilities

- `home-slider-comments-panel`: panel inferior de comentarios en Home, interacción de apertura/cierre, layout responsive y estado vacío placeholder.

### Modified Capabilities

- `home-promotional-slider`: comportamiento al pulsar comentarios en el slider de reels destacados — abrir el panel en lugar de limitarse al incremento de contador de la librería.

## Impact

- **Frontend:** `features/home/home/` (`home.ts`, `home.html`, `home.scss`); posible componente compartido pequeño bajo `shared/` si se extrae el panel (opcional, ver design).
- **Librería:** `ngx-vertical-slider` — solo consumo del output `slideAction`; sin fork ni nueva dependencia.
- **Backend / API:** ninguno.
- **Specs:** delta en `home-promotional-slider`; spec nueva `home-slider-comments-panel`.
