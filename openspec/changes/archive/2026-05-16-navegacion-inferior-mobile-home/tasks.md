## 1. Inventario (rutas, layout, auth)

- [x] 1.1 Confirmar en `app.routes.ts` y shell los destinos finales para: home, solicitudes (y fragmentos), perfil (`/perfil`, `/usuarios/:userId`), y mapa/ubicación.
- [x] 1.2 Revisar `features/home` (template y estilos): estructura del contenido principal, footer o sliders que afecten el padding inferior.
- [x] 1.3 Identificar cómo el front expone sesión (`AuthSessionService` u homólogo) y cómo el shell abre login (`openLogin`, query `login=1`).
- [x] 1.4 Listar iconos o componentes reutilizables ya usados en navegación o botones.

## 2. Componente de barra inferior

- [x] 2.1 Crear componente dedicado (p. ej. `home-mobile-bottom-nav`) con tres `routerLink` o navegación programática equivalente.
- [x] 2.2 Aplicar `position: fixed` inferior, ancho completo, fondo/borde/sombra alineados al tema AnyJobs.
- [x] 2.3 Ocultar por CSS (o no renderizar) por encima del breakpoint móvil alineado al shell (≤900px o convención documentada).

## 3. Integración solo en home

- [x] 3.1 Importar y colocar la barra en la plantilla de **Home** (no en `Shell` global salvo decisión justificada).
- [x] 3.2 Añadir reserva de espacio inferior al contenedor de contenido de home en móvil (variable CSS o clase utilitaria).

## 4. Lógica de Perfil y login

- [x] 4.1 Reutilizar la misma regla de URL de perfil que `profileRouterLink()` del shell (extraer a helper compartido si el equipo lo aprueba para evitar duplicación).
- [x] 4.2 Si no hay sesión: invocar el mecanismo existente de login (modal vía servicio/output o `navigate` con `queryParams: { login: '1' }` según patrón ya soportado en `shell.ts`).

## 5. Estado activo

- [x] 5.1 Configurar `routerLinkActive` (o `Router.isActive` con `matrixParams`/`fragment` según API) para Solicitudes, Perfil y Ver mapa con criterios exactos a cada destino.
- [x] 5.2 Estilos distintivos para ítem activo (color, peso, subrayado o fondo) coherentes con la app.

## 6. Validación manual y calidad

- [x] 6.1 Móvil: barra visible en `/home`; ausente en anchos grandes.
- [x] 6.2 Toques: Solicitudes, Perfil (logueado / no logueado), Ver mapa — sin rutas inexistentes.
- [x] 6.3 Comprobar que el último contenido de home no queda tapado; probar con safe-area si aplica.
- [x] 6.4 Verificar header, hamburguesa y menú de cuenta sin regresiones.
- [x] 6.5 Ejecutar lint, typecheck y build del paquete `anyjobs-front` según scripts del repositorio.
