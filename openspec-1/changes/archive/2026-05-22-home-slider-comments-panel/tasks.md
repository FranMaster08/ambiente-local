## 1. Estado y eventos en Home

- [x] 1.1 Añadir signals en `home.ts`: `commentsPanelOpen`, `commentsPanelSlideIndex` (y opcional `commentsPanelReelId`)
- [x] 1.2 En `onSlideAction`, si `event.action === 'comment'`, abrir panel y conservar `trackInteraction` existente
- [x] 1.3 Implementar `closeCommentsPanel()` y enlazar a botón X, overlay click y Escape
- [x] 1.4 Cerrar panel al cambiar slide visible (MutationObserver existente o hook en `setupRetentionTracking`)

## 2. Markup y accesibilidad

- [x] 2.1 Añadir en `home.html` overlay + panel condicionados a `commentsPanelOpen()`
- [x] 2.2 Encabezado con título «Comentarios», botón cerrar con `aria-label="Cerrar comentarios"`
- [x] 2.3 Región scrollable `.homeCommentsBody` con placeholder de estado vacío (sin comentarios mock)
- [x] 2.4 Atributos `role="dialog"`, `aria-modal="true"`, `aria-labelledby` en el panel

## 3. Estilos y animación

- [x] 3.1 Estilos en `home.scss`: overlay fijo semitransparente, panel inferior `min(50vh, 480px)`, bordes superiores redondeados
- [x] 3.2 Animación entrada `translateY(100%)` → `0` con transición suave; salida al cerrar
- [x] 3.3 `z-index` coherente con slider y `app-home-mobile-bottom-nav` (probar móvil)
- [x] 3.4 Ancho completo en móvil; comportamiento correcto en desktop (columna 70% del slider no obliga a acotar panel al 70% — panel full viewport)

## 4. Comportamiento del slider

- [x] 4.1 Verificar que con panel cerrado no hay regresión en scroll vertical, like, bookmark, share, seguir, mute
- [x] 4.2 Verificar que overlay/panel cerrado no captura eventos del viewport del slider
- [x] 4.3 Opcional: `body { overflow: hidden }` mientras el panel está abierto (patrón `ModalComponent`)

## 5. Verificación manual

- [x] 5.1 Click en 💬 abre panel desde abajo (~50vh) con placeholder visible
- [x] 5.2 Cierre por X, clic fuera y Escape sin errores en consola
- [x] 5.3 Responsive móvil y desktop
- [x] 5.4 `openspec verify --change home-slider-comments-panel` (comando no disponible en CLI; verificación por revisión de código y build local con Node ≥20)
