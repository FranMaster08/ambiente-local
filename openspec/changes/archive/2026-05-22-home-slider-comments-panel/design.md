## Context

- Home (`app-home`) monta `<media-slider>` con reels desde `GET /home/featured-reels` y escucha `(slideAction)="onSlideAction($event)"`.
- `ngx-vertical-slider` define `SlideAction = 'like' | 'comment' | 'bookmark' | 'share'`. En `comment`, el botón emite `toggle` con `action: 'comment'` y además incrementa el contador local (`bumpCounter(+1)`); no hay hook propio de «abrir panel» en la librería.
- El proyecto ya tiene `app-modal` (centrado, overlay, Escape, clic fuera, lock scroll). El panel de comentarios es un patrón distinto (anclado abajo, ~50vh) y conviene no reutilizar el modal centrado para no forzar estilos inadecuados.

## Goals / Non-Goals

**Goals:**

- Abrir/cerrar panel de comentarios al recibir `slideAction` con `action === 'comment'`.
- UI accesible (`role="dialog"`, `aria-modal`, etiquetas de cierre).
- Animación suave bottom → top; overlay que deja ver el contenido detrás.
- Placeholder listo para conectar lista de comentarios y composer en iteración posterior.
- No romper scroll del slider, reproducción de vídeo ni otras acciones.

**Non-Goals:**

- Endpoints, modelos ni guardado de comentarios.
- Cambiar diseño del slider, orden de botones ni lógica de like/bookmark/share en la librería.
- Replicar el panel en `/reels` (solo Home en esta change; extensible después).
- Nueva dependencia (CDK, animaciones de terceros).

## Decisions

### 1. Orquestación en `Home` vía `slideAction`

**Decisión:** En `onSlideAction`, si `event.action === 'comment'`, establecer estado `commentsPanelOpen = true` y guardar `commentsPanelSlideIndex` (y opcionalmente `reelId` desde `slides()[event.index]`).

**Alternativa descartada:** Listener DOM en `media-action-button[data-action=comment]` — frágil ante actualizaciones de la librería y duplica el canal de eventos ya cableado.

**Alternativa descartada:** Fork de `ngx-vertical-slider` para no incrementar contador en comment — fuera de alcance; el bump del contador es aceptable hasta integración real.

### 2. Markup del panel en `home.html` (hermano del slider)

**Decisión:** Renderizar overlay + panel como hermanos dentro de `section.homeSliderPage` / junto a `homeSliderWrap`, controlados por signals en `Home`. `z-index` por encima del slider y por debajo del drawer móvil del shell (referencia: bottom nav ~50, drawer ~70 — panel ~60).

**Alternativa:** Componente `HomeCommentsPanelComponent` en `shared/media/` — válido si el markup supera ~40 líneas; misma API (`open`, `slideIndex`, `closed`).

### 3. Estilos propios, inspirados en `app-modal`

**Decisión:** Clases locales (p. ej. `.homeCommentsOverlay`, `.homeCommentsPanel`) con:

- Overlay: `position: fixed; inset: 0; background: rgba(17,24,39,.45);`
- Panel: `position: fixed; left: 0; right: 0; bottom: 0; height: min(50vh, 480px); border-radius: 16px 16px 0 0;`
- Animación: `transform: translateY(100%)` → `translateY(0)` con `transition` o `@keyframes slideUp` al abrir; al cerrar, invertir o desmontar tras `transitionend` (implementación mínima: clase `.is-open`).

**Alternativa descartada:** Reutilizar `app-modal` — layout centrado y `place-items: center` no encajan con bottom sheet 50vh.

### 4. Cierre y scroll del documento

**Decisión:** Reutilizar el mismo comportamiento que `ModalComponent`: clic en overlay (target === currentTarget), Escape, botón X; opcional `overflow: hidden` en `body` mientras el panel está abierto para evitar scroll de fondo en móvil.

**Riesgo:** Pausar vídeo — no obligatorio en esta fase; el overlay no debe capturar gestos del viewport del slider si el panel está cerrado.

### 5. Telemetría

**Decisión:** Mantener el `trackInteraction` actual en `onSlideAction` para `comment` (ya incluye `slideIndex`, `reelId`). Opcional en implementación: evento `kind: 'commentsPanelOpen'` — **no** requerido en specs de esta change.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|------------|
| La librería incrementa el contador de comentarios en cada clic | Aceptado hasta API real; documentado en proposal |
| Panel tapa la barra de acciones del slide visible | Overlay solo cubre parte inferior (~50vh); acciones siguen visibles arriba |
| Conflicto de z-index con nav móvil / drawer | Valores documentados; probar en viewport estrecho |
| `slideAction` se dispara en otros slides si el usuario cambia de slide con panel abierto | Al abrir, fijar índice; al cambiar slide visible, cerrar panel o actualizar contexto (implementación: cerrar al detectar cambio de slide recomendado en tasks) |

## Migration Plan

Despliegue solo frontend. Sin migraciones. Rollback: revertir cambios en `home.*` y componente panel si se extrajo.

## Open Questions

- ¿Cerrar automáticamente el panel al cambiar de slide en el slider? **Recomendación:** sí, en implementación, para evitar desincronización reel/comentarios.
- ¿Extender el mismo panel a `/reels` en un change posterior? Fuera de alcance aquí.
