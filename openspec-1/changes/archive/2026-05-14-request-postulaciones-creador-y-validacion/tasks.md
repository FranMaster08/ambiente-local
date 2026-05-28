## 1. Descubrimiento y alineación con el código existente

- [x] 1.1 Inventariar modelos/entidades/tablas de requests, postulaciones/propuestas y usuarios en `anyjobs-back` y documentar relaciones (owner/creador de request).
- [x] 1.2 Localizar endpoints actuales: creación de request, creación de postulación/propuesta, listados y detalle; anotar rutas, DTOs y formato de errores.
- [x] 1.3 En `anyjobs-front`, localizar vistas/servicios donde se listan requests del usuario, detalle y acción de postularse; anotar patrones de UI para vacío, carga y errores.

## 2. Back-end: validación de auto-postulación

- [x] 2.1 En el servicio/controlador que crea la postulación, comparar usuario autenticado con creador/owner de la request antes de persistir.
- [x] 2.2 Devolver error controlado con código HTTP alineado a la convención del proyecto (400 o 403) y mensaje claro (p. ej. “No puedes postularte a tu propia request.”) usando el mismo esquema de error existente.
- [x] 2.3 Añadir o ajustar tests automáticos que cubran éxito para usuario no creador y rechazo para creador (manipulación directa del endpoint).

## 3. Back-end: listado de postulaciones por request

- [x] 3.1 Implementar o corregir endpoint para listar postulaciones de una request con payload mínimo acordado (id postulante, nombre/username, fecha, estado si existe, avatar si ya se expone en contextos similares).
- [x] 3.2 Aplicar autorización: solo creador/owner (y roles ya definidos en el proyecto, si aplica) puede obtener el listado; otros usuarios reciben denegación según política existente.
- [x] 3.3 Mantener forma de respuesta y serialización coherente con el resto del módulo (envoltorios, nombres de campos).
- [x] 3.4 Tests de listado: creador ve datos; usuario no autorizado no accede; lista vacía sin error 4xx/5xx.

## 4. Back-end: duplicados y regresiones

- [x] 4.1 Verificar comportamiento actual ante postulaciones duplicas del mismo usuario a la misma request; mantener o reforzar validación sin romper datos existentes.
- [x] 4.2 Ejecutar suite de tests existente del back-end y corregir fallos introducidos.

## 5. Front-end: consumo y UX para el creador

- [x] 5.1 Añadir llamada al servicio HTTP (tipos/DTOs) para el listado de postulaciones, respetando el contrato del API.
- [x] 5.2 En la vista de detalle o equivalente de “mis requests”, mostrar sección/lista/modal/drawer de postulantes con estado de carga y vacío (“Todavía no hay postulaciones para esta request.” o texto acordado con UX existente).
- [x] 5.3 Ocultar o deshabilitar el botón/acción de postularse cuando el usuario autenticado sea el creador de la request mostrada.
- [x] 5.4 Manejar el error del servidor por auto-postulación con mensaje entendible usando el mismo canal de errores que el resto de la app.

## 6. Documentación y validación final

- [x] 6.1 Actualizar documentación de contratos del proyecto (p. ej. `ENDPOINTS_Y_CONTRATOS_API.md` u homólogo) si el repo lo mantiene.
- [x] 6.2 Validación manual o e2e según disponibilidad: postulación cruzada OK; auto-postulación bloqueada en red; creador ve lista; request sin postulantes muestra vacío; flujos de creación/listado/detalle de requests intactos.
- [ ] 6.3 Ejecutar tests del front-end existentes y añadir tests nuevos donde ya haya infraestructura (servicio o componente).
