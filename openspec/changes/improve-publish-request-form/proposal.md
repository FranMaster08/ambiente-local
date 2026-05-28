## Why

La pantalla "Publicar solicitud" (`/solicitudes/nueva`) permite crear solicitudes, pero hoy presenta tres problemas que degradan datos y UX: no hay ayuda guiada para completar el formulario, la ubicación es texto libre (datos inconsistentes) y se muestran email/teléfono editables aunque pertenecen al usuario autenticado. Corregir esto mejora la calidad de las publicaciones, reduce errores de usuario y evita suplantación de contacto desde el cliente.

## What Changes

- **Tour guiado de ayuda** en la pantalla de publicación: botón visible cerca del encabezado que inicia un recorrido explicativo (título, resumen, descripción, etiquetas, ubicación, presupuesto, imágenes, publicar) sin modificar ni enviar el formulario.
- **Ubicación estructurada** en lugar de un único campo de texto libre: país (solo Colombia o Argentina), departamento/provincia dependiente, municipio/ciudad dependiente y barrio como texto libre opcional con longitud máxima.
- **Eliminación de la sección Contacto** (email y teléfono) del formulario visible; el backend MUST resolver contacto desde el perfil del usuario autenticado y MUST NOT confiar en valores enviados en el body para definir contacto del creador.
- **Validaciones cliente** actualizadas para los campos de ubicación estructurada; construcción de `locationLabel` con formato consistente (`barrio · municipio · departamento · país`) antes del `POST`.
- **Compatibilidad**: solicitudes existentes con `locationLabel` en formato anterior siguen mostrándose; el contrato `POST /open-requests` mantiene `locationLabel` como string (sin migración de modelo).

## Capabilities

### New Capabilities

- `publish-request-guided-tour`: Botón de ayuda y tour guiado contextual en la pantalla "Publicar solicitud", cerrable sin borrar datos del formulario.

### Modified Capabilities

- `crear-solicitud`: Formulario sin campos visibles de contacto; ubicación estructurada con catálogo CO/AR; validaciones y payload alineados; tour de ayuda integrado.

## Impact

- **Frontend (`anyjobs-front/anyjobs`)**: `open-request-create` (componente, template, estilos, specs), utilidades de ubicación, nueva dependencia liviana `driver.js` para el tour, `open-requests.models.ts`, `open-requests-multipart.ts`, tests.
- **Backend (`anyjobs-back`)**: `CreateOpenRequestDto` (contacto opcional en body), `OpenRequestsController.create` (resolución de contacto desde usuario autenticado), posible import de `AuthModule`/`AUTH_USER_REPOSITORY`, tests e2e/unitarios de creación.
- **OpenSpec**: delta en `crear-solicitud`; nueva spec `publish-request-guided-tour`.
- **Sin breaking changes** en rutas públicas ni en lecturas de solicitudes existentes.
