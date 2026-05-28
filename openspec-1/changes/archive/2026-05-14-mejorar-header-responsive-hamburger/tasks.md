## 1. Revisión de la implementación actual

- [x] 1.1 Identificar el componente, layout o vista que renderiza la cabecera global (ruta de archivo en el front).
- [x] 1.2 Documentar cómo se gestionan hoy los breakpoints (CSS, hooks, librería de UI) y qué umbral(es) se usan.
- [x] 1.3 Localizar el render del menú de navegación principal, selector de idioma, botón “Ver más” y menú de usuario en modo desktop y en modo compacto.
- [x] 1.4 Reproducir y anotar el comportamiento actual del menú hamburguesa en anchos pequeños (inconsistencias visuales, solapamientos, duplicados).

## 2. Ajuste del comportamiento responsive

- [x] 2.1 Definir o alinear el breakpoint con el sistema existente (evitar soluciones válidas solo para un ancho fijo arbitrario sin convención).
- [x] 2.2 Garantizar que en pantallas grandes el layout del header permanece equivalente al actual (sin regresiones de flex/grid).
- [x] 2.3 En pantallas pequeñas, ocultar ordenadamente los elementos de navegación que no caben y mostrar el botón hamburguesa claro, accesible y alineado en la cabecera.
- [x] 2.4 Centralizar la lista de ítems de navegación (mismas rutas y etiquetas) para evitar divergencia entre desktop y panel móvil.

## 3. Rediseño del menú hamburguesa

- [x] 3.1 Aplicar estilos del sistema visual existente al panel (tokens/clases compartidas con otros menús o superficies).
- [x] 3.2 Incluir en el panel: Inicio, Solicitudes, Ubicación, Contacto (mismas rutas que desktop).
- [x] 3.3 Integrar idioma, “Ver más” y opciones de usuario según el diseño actual del header responsive, sin duplicación incorrecta.
- [x] 3.4 Revisar z-index y posicionamiento para evitar superposiciones incorrectas con el contenido u otros overlays.

## 4. Experiencia de usuario

- [x] 4.1 Implementar apertura/cierre fiable del menú.
- [x] 4.2 Cerrar el menú al seleccionar una opción de navegación.
- [x] 4.3 Implementar cierre al clic fuera si la arquitectura del proyecto lo soporta de forma limpia.
- [x] 4.4 Mantener orden lógico de secciones y buen comportamiento en mobile y tablet (áreas táctiles, scroll si hace falta).

## 5. Accesibilidad

- [x] 5.1 Añadir `aria-label` descriptivo al botón hamburguesa (u otra técnica equivalente alineada al proyecto).
- [x] 5.2 Exponer estado abierto/cerrado (`aria-expanded` u homólogo según el componente base).
- [x] 5.3 Verificar foco visible y navegación por teclado dentro del panel según lo que permita el stack actual.
- [x] 5.4 Asegurar que los estados no dependan solo del color.

## 6. Validaciones finales

- [x] 6.1 Probar manualmente desktop, tablet y mobile (incluida rotación si aplica).
- [x] 6.2 Confirmar que el hamburguesa solo aparece bajo el breakpoint definido y que no hay duplicación incorrecta de navegación.
- [x] 6.3 Confirmar menú de usuario, selector de idioma y “Ver más” intactos.
- [x] 6.4 Revisar consola del navegador sin errores nuevos atribuibles al cambio.
- [x] 6.5 Ejecutar lint, typecheck, build y tests del paquete de front según scripts del repositorio.
