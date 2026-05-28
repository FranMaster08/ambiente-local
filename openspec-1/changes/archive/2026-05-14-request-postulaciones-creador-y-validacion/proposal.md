## Why

Hoy no hay una forma clara para que el creador de una **request** vea **quiénes se postularon**, y el sistema permite que el mismo creador se postule a su propia solicitud, lo cual es un error de negocio y de integridad del flujo. Hace falta alinear **back-end** y **front-end** con validación autoritativa en servidor y una UX que refleje esas reglas.

## What Changes

- **Back-end**: En el flujo de creación de postulación/propuesta asociada a una request, validar que el usuario autenticado **no sea el creador/owner** de esa request; responder con error controlado (p. ej. **400** o **403**, según convención del proyecto) y mensaje claro, por ejemplo: *"No puedes postularte a tu propia request."*
- **Back-end**: Endpoint (nuevo o corregido) para **listar postulaciones** de una request concreta, con datos mínimos del postulante (id, nombre/username, avatar si existe, fecha de postulación, estado si existe) y **email solo** si el sistema ya lo expone de forma segura y consistente con el resto del API.
- **Back-end**: **Permisos**: solo el creador de la request (y roles que el proyecto ya defina, si aplica) puede ver el listado de postulantes; el resto no accede a información privada no prevista hoy.
- **Back-end**: Revisar y **mantener o reforzar** la validación contra **postulaciones duplicadas** si la lógica actual lo requiere.
- **Front-end**: Vista/sección de detalle o listado de “mis requests” (o el patrón existente) donde el creador vea **lista de postulantes** con estados de carga, vacío (*"Todavía no hay postulaciones para esta request."*) y errores alineados al resto de la app.
- **Front-end**: **Ocultar o deshabilitar** la acción de postularse cuando el usuario autenticado sea el creador de la request; si aún así se intenta (p. ej. manipulación), mostrar el mensaje del back-end de forma entendible.
- **No objetivos explícitos**: no cambiar el flujo de **creación** de requests; no renombrar rutas/contratos públicos salvo estricta necesidad; no exponer datos que hoy el API no expone.

## Capabilities

### New Capabilities

- `open-requests-postulations-owner-and-applicants`: Reglas de negocio y contrato API para **postulaciones** vinculadas a **requests**: prohibición de auto-postulación del creador (validación en servidor), listado de postulantes visible solo para el creador (y convenciones de respuesta HTTP/mensajes), y requisitos de UI en el cliente (lista de postulantes, vacío, carga, deshabilitar postular en requests propias, manejo de error del servidor).

### Modified Capabilities

- *(ninguno en `openspec/specs/` de la raíz del repo que deba cambiar a nivel de requisito; este cambio introduce un spec dedicado al dominio postulaciones + creador.)*

## Impact

- **Código típico**: `anyjobs-back` — servicio/controlador que crea postulaciones/propuestas; guards o políticas de autorización para listar postulantes; tests (unit/integration/e2e según exista en el repo).
- **Código típico**: `anyjobs-front` — pantallas de detalle/listado de requests creadas por el usuario; servicios HTTP y modelos alineados al contrato; estados vacío/carga/error.
- **Documentación**: actualizar referencias de contrato si el proyecto mantiene un doc de endpoints (p. ej. `ENDPOINTS_Y_CONTRATOS_API.md` u homólogo).
- **Relación con otros cambios**: puede solaparse en tema con `openspec/changes/fix-update-and-create-postulate` (contrato front/back de solicitudes abiertas y propuestas); conviene coordinar para no duplicar specs contradictorios.

## Criterios de aceptación (resumen)

- Un usuario **normal** puede postularse a una request de **otro** usuario.
- El **creador** no puede postularse a la suya; el **back-end rechaza** el intento aunque el front se manipule.
- El **creador** ve la lista de postulantes (con vacío adecuado si no hay ninguno).
- No se rompen flujos existentes de creación, listado y detalle de requests; las respuestas del API **mantienen el formato** habitual del proyecto.
