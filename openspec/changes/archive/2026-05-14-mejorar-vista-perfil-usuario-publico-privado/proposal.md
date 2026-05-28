## Why

La vista de perfil de usuario actual no refleja una experiencia completa ni diferencia claramente lo que el dueño de la cuenta ve frente a lo que ven terceros. El producto evolucionará hacia contenido multimedia propio (reels, videos), pero hoy no existe esa capacidad: hace falta un rediseño que mejore claridad, atractivo visual y privacidad, dejando la estructura lista para crecer sin simular funcionalidades inexistentes ni comprometer seguridad.

## What Changes

- Auditoría e inventario de la implementación actual del perfil (front: componentes, rutas, layouts, hooks, servicios, modelos; back: endpoints, DTOs, serialización) y de cómo se obtiene el usuario autenticado y si ya existe ruta para perfiles ajenos.
- Definición explícita de **dos modos de visibilidad**: perfil **propio** (usuario autenticado viendo su cuenta) y perfil **público** (otro usuario u visitante con permisos acordes al producto), con datos y acciones condicionales.
- Rediseño de la **cabecera de perfil**: avatar o iniciales, nombre visible, username/identificador si existe, ubicación si existe, bio con placeholder si falta; inspiración estructural genérica (encabezado, métricas, acciones, tabs, zona futura) **sin** copiar literalmente diseños externos ni textos ajenos al producto.
- **Zona de métricas** solo con datos reales ya disponibles en la aplicación (p. ej. solicitudes creadas, propuestas, completadas, valoraciones/reputación si el sistema las expone). Si una métrica no existe: estructura preparada, estado vacío o ausencia de la tarjeta; **prohibido** hardcodear o inventar cifras.
- **Acciones principales** según visibilidad: propio → enlaces acordados en el producto (p. ej. **Mis solicitudes**); **no** duplicar logout ni navegación global ya cubierta por el header/menú de cuenta. Público → acciones no invasivas (p. ej. ver solicitudes abiertas / inicio para anónimos) según existan en el proyecto; sin acciones de edición en perfiles ajenos.
- **Resiliencia de carga del perfil propio:** ante **401** (p. ej. token inválido tras reinicio del API) limpiar sesión y volver al estado “sin sesión” en `/perfil`; ante otros fallos de red/API en `/perfil`, **fallback** opcional mostrando datos ya presentes en la sesión local **sin** inventar métricas (banner informativo; métricas omitidas si no hay respuesta del servidor).
- **Secciones o tabs** extensibles: información general, solicitudes publicadas, propuestas/postulaciones, valoraciones/actividad según datos disponibles; **sección reservada** para multimedia futura (reels/videos) mostrada como vacío / “próximamente” / placeholder, **sin** carga, reproducción ni datos falsos.
- **Estados vacíos y fallbacks**: sin bio, sin actividad, sin métricas, sin avatar, sin username o ubicación: placeholders y UI coherente que no se vea “rota”.
- **Backend**: separación clara entre respuesta de **perfil público** y **perfil propio** (endpoints y/o DTOs/serializadores); el público **no** debe incluir email, teléfono ni datos sensibles; validación de autorización en servidor, no solo ocultación en cliente; reutilizar modelos existentes; no añadir soporte real de video/reels.
- **Frontend**: rutas o vistas para perfil propio y perfil público; detección de “¿es mi perfil?”; render condicional; coherencia con el sistema de diseño actual; responsive (desktop, tablet, móvil); sin librerías nuevas salvo justificación estricta.
- **Seguridad y privacidad**: no filtrar datos privados en respuestas públicas; no confiar solo en el front; evitar exponer identificadores internos innecesarios.
- **Validación**: casos de prueba manuales y automatizados según existan en el repo; lint, typecheck, build y tests del proyecto; sin errores de consola nuevos; sin romper autenticación, edición de perfil existente, ni rutas de solicitudes/propuestas.

**Restricciones explícitas (no negociables en el alcance)**

- No implementar reels ni videos reales.
- No mostrar multimedia falso ni métricas inventadas.
- No copiar literalmente diseño de apps externas.
- No exponer información privada en perfil público.
- No romper flujo de autenticación ni edición de perfil existente; el **cierre de sesión** permanece disponible en la **navegación global** (header/menú cuenta), sin obligación de duplicarlo en el pie del perfil.

## Capabilities

### New Capabilities

- `vista-perfil-usuario`: Comportamiento y requisitos del perfil de usuario rediseñado: visibilidad propia vs pública, cabecera y métricas basadas en datos reales, acciones condicionales, tabs/secciones extensibles, placeholder para multimedia futuro, estados vacíos, contratos API perfil público vs propio, privacidad y validación (incl. responsive y calidad de build).

### Modified Capabilities

- _(Implementado sin delta de spec de header)_: enlace **“Ver perfil”** en detalle de solicitud hacia `/usuarios/:ownerUserId`; el header ya enlazaba a `/perfil`. No se requirió modificar `app-header-responsive-navigation/spec.md` salvo evolución futura explícita.

## Impact

- **Frontend** (`anyjobs-front` u homólogo): páginas/rutas de perfil, componentes compartidos de cabecera/tabs, servicios HTTP, modelos TypeScript, posible ajuste de guards o resolvers.
- **Backend** (`anyjobs-back` u homólogo): controladores/servicios de usuario, DTOs de salida pública vs autenticada, políticas de autorización.
- **Especificaciones**: nuevo spec bajo `openspec/changes/mejorar-vista-perfil-usuario-publico-privado/specs/vista-perfil-usuario/spec.md` (y deltas si se confirma cambio de header).
- **Sin** nuevas dependencias por defecto; **sin** almacenamiento ni APIs de video hasta que el producto las defina.
