## Context

La aplicación expone una cabecera persistente con navegación principal (Inicio, Solicitudes, Ubicación, Contacto), selector de idioma, acción “Ver más” y menú de usuario. En anchos pequeños el patrón hamburguesa existe pero el panel asociado no respeta de forma uniforme el sistema visual del resto de la UI.

## Goals / Non-Goals

**Goals:**

- Cabecera usable y visualmente coherente desde mobile hasta desktop.
- Un solo breakpoint (o conjunto mínimo alineado al sistema de diseño ya usado, p. ej. Tailwind/CSS del proyecto) que defina cuándo el menú principal pasa al panel hamburguesa.
- Panel del menú que reutilice variables/tokens/clases del tema (fondo, borde, radio, sombra, tipografía, espaciado) ya presentes en cards, dropdowns o drawers existentes.
- Cierre del menú al navegar, al clic fuera cuando sea viable sin hacks frágiles, y orden de ítems lógico (navegación primero, luego acciones globales como idioma/“Ver más”, luego usuario si aplica).
- Accesibilidad: botón con nombre accesible, `aria-expanded` (o patrón equivalente del componente base), foco manejable dentro del panel al abrir si el stack lo permite.

**Non-Goals:**

- Cambiar rutas, textos de menú o lógica de negocio no ligada al header.
- Rediseño global de marca o nuevo design system.
- Nuevas librerías de UI salvo imposibilidad técnica demostrable con el stack actual.

## Decisions

1. **Breakpoint**  
   Alinear el umbral con el sistema responsive ya adoptado en el front (p. ej. prefijos `md`/`lg` existentes). Documentar en código o comentario breve el ancho elegido y la razón (evitar “magic numbers” sueltos sin convención del proyecto).

2. **Patrón de panel**  
   Preferir el mismo patrón que ya use la app para overlays portables (dropdown, `Popover`, drawer lateral, etc.). Si hoy el menú móvil es un bloque ad-hoc, refactorizarlo para compartir superficie visual con un componente existente de “superficie elevada”.

3. **Duplicación de enlaces**  
   Extraer la definición de ítems de navegación a una única fuente de verdad (array/config o composición) y renderizar o la barra horizontal o el panel móvil según breakpoint, evitando dos listas divergentes.

4. **Clic fuera**  
   Usar el mecanismo nativo del componente (p. ej. listener en overlay, `onInteractOutside`) si existe; si no, implementar cierre con `pointerdown` en `document` con limpieza en `useEffect`/equivalente, respetando SSR si aplica.

5. **Z-index y superposición**  
   Revisar stacking del header y del panel respecto a contenido y modales; alinear z-index a la escala ya definida en el proyecto.

## Risks / Trade-offs

- **[Riesgo] Regresión en desktop** al tocar flex/grid del header → **[Mitigación]** Cambios acotados al bloque responsive; validación visual en anchos grandes.
- **[Riesgo] Doble foco o doble menú de usuario** → **[Mitigación]** Un solo punto de montaje para el menú usuario en móvil; no duplicar instancias de popover.
- **[Riesgo] Hidración o layout shift** si el breakpoint depende solo de JS → **[Mitigación]** Preferir CSS media queries para mostrar/ocultar cuando sea posible.

## Migration Plan

- Implementar en rama dedicada; validar manualmente tres anchos (móvil ~375px, tablet ~768px, desktop ≥1024px o los que use el proyecto).
- Tras merge, monitorizar feedback visual; no requiere migración de datos ni API.

## Open Questions

- ¿El header vive en un layout raíz concreto (nombre de archivo/ruta) que deba citarse en tareas tras el inventario?
- ¿Existe ya un componente de “sheet” o “drawer” estilado que deba reutilizarse en lugar de un `<div>` flotante?
