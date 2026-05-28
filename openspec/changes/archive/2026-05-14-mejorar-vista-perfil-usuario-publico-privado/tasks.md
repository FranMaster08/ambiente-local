## 1. Auditoría e inventario

- [x] 1.1 Inventariar componentes, rutas, layouts, hooks/servicios y modelos del perfil en frontend (`Profile`, `app.routes`, `AuthSessionService`, etc.).
- [x] 1.2 Documentar cómo se obtiene el usuario autenticado y qué campos expone la sesión frente a API.
- [x] 1.3 Verificar si existe ruta o necesidad de ruta para perfil público de terceros (`/usuarios/:id` u homólogo).
- [x] 1.4 Revisar backend: endpoints de usuario, DTOs, serialización; listar datos públicos vs privados disponibles hoy.
- [x] 1.5 Revisar si ya hay diferenciación propio/público en respuestas HTTP y anotar brechas.

## 2. Contratos API y seguridad

- [x] 2.1 Definir o ajustar endpoint(s) de perfil público con DTO que excluya email, teléfono y campos sensibles.
- [x] 2.2 Definir o ajustar respuesta de perfil propio/autenticado con campos adicionales permitidos.
- [x] 2.3 Implementar bifurcación por identidad del solicitante en servicio/controlador (no solo en front).
- [x] 2.4 Añadir o extender pruebas backend que fallen si el perfil público incluye datos privados.
- [x] 2.5 Reutilizar modelos/relaciones existentes para agregados de métricas; evitar N+1 sin análisis.

## 3. Agregados y métricas (solo reales)

- [x] 3.1 Por cada métrica acordada (solicitudes creadas, propuestas, completadas, reputación…), confirmar fuente en BD/servicios.
- [x] 3.2 Exponer en API solo métricas con fuente real; si no hay fuente, no devolver cifras inventadas.
- [x] 3.3 Documentar en código o contrato qué métricas quedan “preparadas” pero sin dato (front mostrará vacío u omitirá tarjeta).

## 4. Frontend: rutas y modo de visibilidad

- [x] 4.1 Añadir o ajustar ruta(s) para perfil propio (`/perfil`) y perfil público de terceros según decisión de diseño.
- [x] 4.2 Implementar resolución de `userId` desde ruta o servicio y comparación con sesión para `isOwn`.
- [x] 4.3 Crear o refactorizar componente(s) de cabecera (avatar/iniciales, nombre, username, ubicación, bio con placeholders).
- [x] 4.4 Implementar zona de métricas condicionada a datos de API (sin hardcode).
- [x] 4.5 Implementar acciones principales condicionadas (propio vs público) enlazando flujos existentes.
- [x] 4.6 Implementar tabs/secciones: información general, listados existentes (solicitudes/propuestas/actividad) según datos disponibles.
- [x] 4.7 Añadir pestaña/sección “Multimedia” o equivalente con placeholder “próximamente” sin llamadas a medios.
- [x] 4.8 Asegurar estados vacíos (sin bio, sin avatar, sin actividad, sin métricas) y responsive (desktop/tablet/móvil).
- [x] 4.9 Mantener coherencia con design system y estilos existentes; evitar CSS aislado incoherente.

## 5. Integración navegación y regresiones

- [x] 5.1 Actualizar enlaces en header/menú solo si aplica, sin romper `app-header-responsive-navigation` ni menú usuario.
- [x] 5.2 Verificar que logout y flujos de auth no regresionan.
- [x] 5.3 Verificar que edición de perfil existente (si hay ruta/pantalla) sigue accesible desde acciones del modo propio.

## 6. Validación manual y automática

- [x] 6.1 Validar perfil propio con usuario autenticado (datos y acciones).
- [x] 6.2 Validar perfil público viendo otro usuario (sin datos privados ni acciones de edición).
- [x] 6.3 Validar sin avatar, sin bio, sin solicitudes/propuestas/actividad.
- [x] 6.4 Validar responsive y ausencia de errores de consola en flujos felices.
- [x] 6.5 Ejecutar lint, typecheck, build y tests del/los paquetes tocados; corregir fallos introducidos.

## 7. Especificaciones y cierre

- [x] 7.1 Tras implementación, ejecutar verificación OpenSpec (`openspec-verify-change` o flujo del proyecto) frente a `specs/vista-perfil-usuario/spec.md`.
- [x] 7.2 Valorar sincronización o delta frente a `anyjobs-front/openspec/specs/user-profile-view/spec.md` al archivar el cambio.

## Notas de alineación (post-implementación)

- **Pie del perfil (modo propio):** solo enlace **Mis solicitudes**; sin **Logout** ni **Ver solicitudes abiertas** en `profileActions` (logout y navegación global siguen en el shell).
- **Cliente:** `UserApi.getMyProfile` / `getPublicProfile`; `metrics` opcional en DTO de perfil privado para fallback sin cifras inventadas; **401** limpia sesión; banner en fallos no-401 en `/perfil`.
- **API pública:** `GET /users/profile/:userId` (evita colisión con `users/me`).
