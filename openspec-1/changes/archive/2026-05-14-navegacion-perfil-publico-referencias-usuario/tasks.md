## 1. Auditoría e inventario

- [x] 1.1 Inventariar en `anyjobs-front` todas las vistas y componentes que renderizan nombre, avatar, username o iniciales de usuarios (solicitudes, propuestas, postulaciones, cards, detalles, comentarios, cabeceras).
- [x] 1.2 Por cada superficie, anotar si el modelo incluye `userId` (o equivalente) y si el texto es estático o ya es enlace; marcar brechas donde falte id en el payload.
- [x] 1.3 Documentar excepciones UX donde un bloque identitario no deba ser navegable, con justificación breve en este cambio o en comentario enlazado desde `tasks.md`.
- [x] 1.4 Revisar rutas existentes (`/perfil`, `/usuarios/:userId`) y el router para confirmar que no se añaden rutas duplicadas para el mismo recurso.

## 2. Primitivo compartido de identidad navegable

- [x] 2.1 Crear o consolidar un componente/patrón único (p. ej. `UserIdentityLink`) que reciba `userId`, texto visible, `avatarUrl` opcional y emita navegación a `/usuarios/:userId` alineada con `design.md`.
- [x] 2.2 Integrar detección “es mi perfil” reutilizando la misma fuente de verdad de sesión que el resto del perfil, sin duplicar lógica contradictoria con `mejorar-vista-perfil-usuario-publico-privado`.
- [x] 2.3 Asegurar `aria-label` o texto accesible cuando el hit target principal sea solo el avatar; foco visible y soporte de teclado.
- [x] 2.4 Evitar enlaces anidados inválidos (card clickeable + nombre): una sola capa activable o manejo de eventos documentado.

## 3. Solicitudes abiertas y detalle

- [x] 3.1 Actualizar listados y detalle de solicitudes abiertas donde aparezca el owner o participantes con `ownerUserId` / ids equivalentes para usar el primitivo de identidad.
- [x] 3.2 Verificar que “Ver perfil” u otros CTAs existentes no dupliquen rutas ni comportamiento; unificar con el primitivo si aplica.
- [x] 3.3 Ajustar estilos (cursor, hover, focus) usando tokens/clases existentes sin nuevas dependencias.

## 4. Postulaciones y propuestas

- [x] 4.1 En la vista de postulaciones para el creador, enlazar nombre/avatar/bloque identitario al perfil cuando el API exponga `userId` del postulante.
- [x] 4.2 En listados y detalle de propuestas, enlazar autor/postulante cuando el modelo de cliente incluya `userId`; si no existe en el DTO, coordinar ampliación mínima del backend y mapeo en front.
- [x] 4.3 Mantener reglas existentes de auto-postulación y errores; no regresar mensajes ni códigos de negocio.

## 5. Mis solicitudes, publicación y demás superficies

- [x] 5.1 En `my-requests-dashboard`, aplicar enlaces de perfil en la pestaña “Postulé a estas” (y cualquier otra fila con terceros identificables según inventario).
- [x] 5.2 En `/solicitudes/nueva`, si existe bloque identitario de sesión fuera del formulario, enlazarlo al perfil propio según convención.
- [x] 5.3 Repasar header global, menús y cualquier avatar suelto listado en 1.1 y alinear con el primitivo.

## 6. Backend y contratos

- [x] 6.1 Confirmar que `GET /users/profile/:userId` y DTOs públicos no exponen email, teléfono ni configuración interna; ajustar serializers si algún listado reutiliza campos privados.
- [x] 6.2 Donde el inventario requiera `userId` en listados (postulaciones, propuestas, etc.), ampliar respuestas del backend de forma compatible hacia atrás (campos opcionales o no rompientes).
- [x] 6.3 Alinear respuestas 404/403 con mensajes seguros para “usuario no encontrado” sin filtrar datos de otros.

## 7. Estados vacíos, errores y responsive

- [x] 7.1 Implementar o reutilizar estados de “usuario no encontrado” y errores de carga en la ruta de perfil público con refresh directo.
- [x] 7.2 Fallback de avatar (iniciales/placeholder) coherente en el primitivo cuando falte imagen.
- [x] 7.3 Probar desktop, tablet y mobile en las pantallas tocadas; corregir desbordes o targets demasiado pequeños.

## 8. Validación y calidad

- [x] 8.1 Pruebas manuales: usuario A abre perfil público de B desde listado y detalle de solicitud, propuesta y postulación; A abre su propio perfil desde referencias; refresh en URL pública; usuario inexistente.
- [x] 8.2 Verificar que no aparezcan datos privados en red de perfil ajeno (inspección de respuestas).
- [x] 8.3 Ejecutar lint, typecheck, build y tests automatizados del monorepo según scripts del proyecto; corregir regresiones.
- [x] 8.4 Pasar revisión de consola en flujos anteriores sin errores nuevos no controlados.

## 9. Documentación y cierre

- [x] 9.1 Actualizar documentación de contratos del front (`ENDPOINTS_Y_CONTRATOS_API.md` u homónimo) si cambian DTOs o campos de listados.
- [x] 9.2 Marcar el inventario de 1.1 como cerrado cuando todas las filas estén “cubierta” o “excepción justificada”.
- [x] 9.3 Coordinar con el cambio `mejorar-vista-perfil-usuario-publico-privado` para evitar divergencias de rutas o payload antes de release conjunto.

## 10. Ajustes posteriores a la entrega inicial (trazabilidad)

- [x] 10.1 Añadir CTA explícito “Ver perfil” (`btn btn--secondary`, `routerLink` a `/usuarios/:userId`) en `my-requests-dashboard` junto a `UserIdentityLink` para postulantes y “Postulé a estas”.
- [x] 10.2 Landing solicitudes abiertas: eliminar métrica hero “24/7 · exploración y contacto” y pasar `.heroMetrics` a dos columnas (`open-requests-landing.html` / `.scss`); ajuste de copy/UX fuera del delta de perfil pero documentado en `AUDIT-IMPLEMENTATION.md` de este cambio.
