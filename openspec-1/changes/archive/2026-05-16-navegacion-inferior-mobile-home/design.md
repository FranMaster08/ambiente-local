## Context

AnyJobs (Angular) usa un **Shell** global con navegación principal, menú hamburguesa bajo **≤900px** (`SHELL_HEADER_COMPACT_MAX_PX`), login en **modal** y rutas hijas bajo `path: ''` con `home` en `/home` y solicitudes abiertas en `/solicitudes` con **fragmentos** (`#solicitudes`, `#ubicacion`, `#contacto`) para anclas en la landing. El enlace de perfil ya se resuelve con `profileRouterLink()` (público `/usuarios/:id` con sesión, o `/perfil`).

## Goals / Non-Goals

**Goals:**

- Barra inferior **solo** en la página principal (`/home`), **solo** por debajo del umbral móvil acordado con el sistema existente (alineado a **≤900px** o al mismo criterio que el shell compacto, documentado en implementación).
- Tres ítems fijos: **Solicitudes** → `/solicitudes` (mismo patrón que `mainNavItems` para solicitudes, incl. fragment si hoy se usa para scroll), **Perfil** → destino según sesión o apertura de login, **Ver mapa** → `/solicitudes` con fragmento **`ubicacion`** (equivalente a “Ubicación” en nav actual), salvo inventario que demuestre otra ruta oficial de mapa.
- Posición **fixed** inferior, z-index por debajo de modales pero por encima del scroll normal del contenido; **padding-bottom** (o contenedor con `safe-area-inset-bottom` si ya existe en el proyecto) en el contenedor de contenido de home.
- Estado activo vía **RouterLinkActive** u homólogo con `isActive` que considere **ruta y fragmento** donde aplique.
- Accesibilidad: cada ítem como enlace o botón con **nombre accesible**, foco visible, contraste suficiente.

**Non-Goals:**

- Redefinir rutas globales ni el contrato del header.
- Mostrar la barra en desktop o en rutas distintas de home (salvo decisión explícita posterior).
- Sustituir el modal de login por una nueva ruta de login si no existe hoy.

## Decisions

1. **Montaje**  
   Integrar la barra en el **template del componente Home** (o un hijo directo exclusivo de home) para no afectar otras rutas. Alternativa aceptable: subcomponente `HomeMobileBottomNav` importado solo desde `home`.

2. **Visibilidad responsive**  
   Preferir **CSS** (`display: none` por encima del breakpoint) para ocultar en desktop; el mismo breakpoint que usa el shell compacto (900px) mantiene coherencia “mobile app” con el header.

3. **Perfil sin sesión**  
   Reutilizar **`openLogin()`** del shell si el componente home puede inyectar o comunicarse con el shell (servicio de UI, `output` del shell, o navegación con `?login=1` que ya dispara `openLogin()` en `NavigationEnd`). La opción elegida MUST NOT reimplementar credenciales ni llamadas HTTP de login.

4. **Iconos**  
   Usar el mismo set que el resto del front (SVG inline, Material, etc. según inventario); si no hay iconos dedicados, usar marcadores mínimos alineados al design system.

5. **Contenido no tapado**  
   Variable CSS o clase en el host de home (`--home-bottom-nav-height`) alimentada por la altura real de la barra + safe area, y `padding-bottom` en el contenedor scrollable de home.

## Risks / Trade-offs

- **Acoplamiento Shell–Home** si hace falta abrir login: mitigar con query `login=1` (ya soportada en shell) o un servicio ligero de “acciones de shell” existente o nuevo mínimo.
- **Doble navegación** (header + barra): aceptado solo en home y solo en mobile; mensaje en spec de no duplicar más allá de estos tres atajos.

## Migration Plan

- Implementar tras inventario de rutas; validar manualmente móvil vs ancho >900px; ejecutar lint/build del front.

## Open Questions

- ¿Home incluye secciones full-bleed que requieran `padding` en un wrapper interno y no en el host? (resolver en implementación tras leer `home.html` / estilos.)
