## Why

En mobile, la página principal de AnyJobs depende casi por completo del header compacto y del menú hamburguesa para acceder a solicitudes, perfil y la vista de mapa/ubicación. Un patrón de **barra de navegación inferior fija** (estilo app nativa) reduce fricción y acelera el acceso a las tres acciones más frecuentes sin sustituir la navegación existente en desktop ni el menú actual.

## What Changes

- **Front-end**: Añadir una barra de navegación inferior **visible solo en viewports móviles** en el contexto de la **página principal** (`/home`), fija al borde inferior, con exactamente tres ítems: **Solicitudes**, **Perfil** y **Ver mapa**.
- **Front-end**: Navegación a rutas/fragmentos ya definidos en la aplicación (p. ej. listado de solicitudes abiertas, ancla de mapa/ubicación en la landing de solicitudes, perfil público o privado según sesión), **sin cambiar** el contrato de rutas salvo imposibilidad técnica demostrable.
- **Front-end**: Comportamiento de **Perfil** alineado al flujo actual: si hay sesión, navegar al destino de perfil que ya usa el shell; si no, abrir el **login existente** (modal / query `login=1` según patrón del proyecto), **sin** duplicar lógica de autenticación si ya existe servicio, señal o helper.
- **Front-end**: Estado **activo** por ruta (y fragmento si aplica), usando las capacidades del router de Angular (`routerLinkActive`, `Router.isActive`, etc.) en lugar de comparar solo por texto fijo.
- **Front-end / UX**: Espaciado inferior del contenido de home para que **nada quede oculto** detrás de la barra; áreas táctiles amplias, iconos y etiquetas legibles, coherencia con tokens/estilos de AnyJobs.
- **No objetivos**: No eliminar el header ni el menú hamburguesa; no degradar desktop/tablet ancha; no añadir dependencias nuevas si el proyecto ya ofrece iconos o componentes reutilizables.

## Capabilities

### New Capabilities

- `home-mobile-bottom-navigation`: Barra inferior fija solo en mobile en la vista principal, tres destinos (Solicitudes, Perfil con login condicional, Ver mapa), estado activo por URL, convivencia con header y menú existentes, y reserva de espacio al contenido.

### Modified Capabilities

- *(Ninguno: los requisitos del header en `app-header-responsive-navigation` se mantienen; la integración se expresa como no regresión dentro de la nueva capacidad.)*

## Impact

- **Código principal**: `anyjobs-front/anyjobs` — componente o layout de **home**, estilos responsive asociados, posible componente reutilizable de barra inferior bajo `shared` o `components` según convención del repo.
- **Referencias de integración**: `shell.ts` / `shell.html` (fuente de verdad de `mainNavItems`, `profileRouterLink()`, `openLogin()`, breakpoint `SHELL_HEADER_COMPACT_MAX_PX`), `app.routes.ts` (rutas `home`, `solicitudes`, `perfil`, `usuarios/:userId`).
- **Dependencias**: Reutilizar iconografía y utilidades ya presentes; evitar librerías nuevas salvo vacío demostrable.
- **Riesgo**: Solapamiento con footer o sliders de home; mitigar con padding seguro y revisión visual en anchos típicos (~375px).
