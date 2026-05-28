## Why

Además del rediseño de la vista de perfil (visibilidad propia vs pública), el producto necesita que **cualquier referencia visible a un usuario** en la aplicación sea **navegable** hacia el perfil público correspondiente. Hoy el riesgo es texto o avatares estáticos que no llevan al perfil ajeno, fragmentando la experiencia y dificultando descubrir perfiles desde solicitudes, propuestas, postulaciones y listados. Este cambio cierra ese gap de forma segura y consistente, sin exponer datos privados ni duplicar rutas ya establecidas.

## What Changes

- **Auditoría de UI**: inventariar en frontend vistas, componentes y listados donde se muestre información de usuarios (solicitudes, propuestas, postulaciones, cards, detalles, comentarios, creador, postulantes, avatares, nombres, username, iniciales) y clasificar qué es texto estático vs enlace funcional.
- **Referencias usables**: convertir nombre, avatar y/o bloque de usuario en enlaces o acciones que naveguen al **perfil público** del usuario referenciado; interacción coherente (cursor, hover, focus, accesibilidad); reutilizar la **ruta existente** del proyecto (`/usuarios/:id`, `/profile/:id`, etc.) o definir una única convención mantenible **sin** duplicar rutas.
- **Descubribilidad**: donde el bloque identitario no baste (p. ej. listados densos de postulaciones en “Mis solicitudes”), MAY coexistir un **CTA explícito** “Ver perfil” como enlace hermano al mismo `userId`, sin anidar `<a>` dentro de `<a>`.
- **Propio vs ajeno**: si el visitante es el mismo usuario que el referenciado, mostrar perfil propio o redirigir según la arquitectura actual; en perfiles ajenos, solo datos y acciones públicas; sin acciones privadas ni datos sensibles en vistas de terceros.
- **Backend y contratos**: revisar o añadir endpoint(s) de **perfil público** que devuelvan solo campos públicos; no exponer email, teléfono, configuración interna ni datos sensibles; reutilizar DTOs/serializers/servicios existentes; permisos y autenticación alineados al flujo actual.
- **Vista de perfil público**: implementar o ajustar la vista consumida por esas rutas; enlaces que funcionen desde listados y detalles de solicitudes, propuestas/postulaciones, cards, menús y demás referencias visibles; excepciones UX explícitas donde no deba ser clickeable.
- **Estados y errores**: usuario no encontrado, sin avatar (iniciales/placeholder), datos públicos faltantes, permisos sin filtrar datos internos; evitar pantallas rotas y errores de consola nuevos.
- **Accesibilidad**: navegación por teclado, `aria-label` o texto accesible en avatares solos, foco visible, no depender solo del color para indicar interactividad.
- **Validación**: flujos autenticado → perfil ajeno, autenticado → propio desde referencias, refresh directo en URL pública, usuario inexistente/eliminado, responsive, lint, typecheck, build y tests del repo.

**Restricciones (no negociables)**

- No exponer información privada de otros usuarios.
- No romper perfil propio, autenticación ni rutas existentes.
- No duplicar convenciones de rutas de perfil si ya hay una establecida.
- No hardcodear IDs, nombres ni datos de usuarios.
- No implementar reels, videos u otras funcionalidades futuras no pedidas.
- No introducir librerías nuevas salvo estricta necesidad; mantener arquitectura y sistema visual actuales.

**Relación con otros cambios**

- Complementa y extiende el alcance de `mejorar-vista-perfil-usuario-publico-privado` (cabecera, tabs, API público vs propio) hacia **toda la superficie de la app** donde aparezca un usuario. Conviene coordinar rutas y DTOs para no divergir.

## Capabilities

### New Capabilities

- `referencias-usuario-perfil-publico`: Requisitos para que las referencias visibles a usuarios en la aplicación sean navegables al perfil público (o al propio cuando corresponda), incluyendo inventario de superficies, contrato de navegación, diferenciación propio/ajeno, accesibilidad, estados de error/vacío y validación cruzada con listados y detalles de solicitudes y propuestas/postulaciones.

### Modified Capabilities

- `open-requests-postulations-owner-and-applicants`: Si los requisitos actuales no obligan a que postulantes/creador sean enlaces al perfil público, actualizar el comportamiento esperado en listados y detalles.
- `open-requests-proposals-front-contract`: Alinear contrato de UI con enlaces a perfil desde propuestas/postulaciones donde se muestre usuario.
- `mis-solicitudes-publicadas` / `crear-solicitud`: Donde se muestre creador u otros usuarios, exigir navegación al perfil público cuando aplique según el inventario.

_(Los nombres anteriores son los de `openspec/specs/`. Tras el inventario, puede ajustarse la lista de deltas si alguna otra capability queda afectada a nivel de requisito.)_

## Impact

- **Frontend**: componentes compartidos de “usuario” (avatar + nombre), páginas de solicitud/propuesta/postulación, listados, comentarios, router y guards.
- **Backend**: endpoints de usuario/perfil público, serialización y políticas de autorización.
- **Especificaciones**: nuevo delta bajo `openspec/changes/navegacion-perfil-publico-referencias-usuario/specs/referencias-usuario-perfil-publico/spec.md` y deltas en capabilities modificadas según corresponda.
- **Coordinación** con el cambio `mejorar-vista-perfil-usuario-publico-privado` para rutas y payload público únicos.
