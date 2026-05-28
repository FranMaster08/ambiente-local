## Why

La cabecera de la aplicación no se comporta de forma aceptable en anchos reducidos: el menú hamburguesa y su panel se ven desalineados respecto al sistema visual (colores, forma, tipografía y espaciado), lo que genera una experiencia poco integrada y poco presentable. Hace falta unificar el comportamiento responsive del header con el resto de la UI, sin degradar la experiencia en desktop.

## What Changes

- **Front-end**: Revisar el componente o layout que renderiza la cabecera, los breakpoints actuales y el render del menú de navegación, selector de idioma, acción “Ver más” y menú de usuario en vista compacta.
- **Front-end**: Definir un breakpoint claro para pasar de navegación horizontal a menú hamburguesa; en desktop mantener el layout actual; en tablet/mobile ocultar de forma ordenada los enlaces que no caben y exponer un control de menú accesible y alineado en la cabecera.
- **Front-end**: Rediseñar el panel del menú hamburguesa para que use tokens/estilos del diseño existente (colores, bordes, radios, sombras, espaciado, tipografía), de modo que se perciba como extensión natural del header.
- **Front-end**: Incluir en el menú compacto las mismas rutas de navegación principales que en desktop (**Inicio**, **Solicitudes**, **Ubicación**, **Contacto**), más idioma, “Ver más” y opciones de usuario cuando ya formen parte del flujo responsive actual, sin duplicar enlaces de forma incorrecta.
- **Front-end / UX**: Abrir/cerrar el menú de forma fiable; cerrar al elegir una opción y al hacer clic fuera si la arquitectura lo permite; orden lógico; evitar solapamientos con el contenido; buen uso en mobile y tablet.
- **Accesibilidad**: `aria-label` descriptivo en el botón hamburguesa; estado abierto/cerrado reflejado con atributos adecuados; navegación por teclado coherente con la estructura actual; no depender solo del color para estados.
- **Validación**: Comprobar desktop, tablet y mobile; ausencia de duplicados de navegación; menú de usuario, idioma y “Ver más” intactos; sin errores de consola; ejecutar lint, typecheck, build y tests disponibles en el proyecto.
- **No objetivos**: No cambiar rutas ni etiquetas de navegación existentes; no alterar funcionalidades fuera del ámbito del header; no introducir librerías nuevas salvo que ya existan en el proyecto o sean estrictamente necesarias.

## Capabilities

### New Capabilities

- `app-header-responsive-navigation`: Comportamiento responsive de la cabecera global: breakpoint para hamburguesa, panel coherente con el sistema visual, contenido de navegación y acciones del header en vista compacta, cierre y foco, accesibilidad del control y validación multi-dispositivo sin regresiones en desktop.

### Modified Capabilities

- *(Ninguno en `openspec/specs/` requiere delta: no hay spec previo de cabecera en el repositorio.)*

## Impact

- **Código típico**: `anyjobs-front` (o el paquete de cliente donde viva el layout principal, navbar/header, estilos globales o tema).
- **Dependencias**: Preferir componentes y tokens ya usados en el front; evitar dependencias nuevas.
- **Riesgo de regresión**: Layout desktop, menú de usuario, selector de idioma y “Ver más”; mitigar con pruebas manuales en anchos representativos y suite automatizada disponible.
