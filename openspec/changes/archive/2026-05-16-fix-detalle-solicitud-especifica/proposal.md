## Why

La página de detalle de solicitud abierta (`/solicitudes/:id`) presentaba datos incorrectos o confusos: postulantes visibles para visitantes o con errores de API (“No autenticado.”), bloque “Ofrecido por” con datos demo, UUID interno visible, antigüedad fija en “Recién publicado”, galería modal poco usable, nombre genérico “Publicador” y CTAs redundantes en el header. Este cambio alinea la UI con las reglas de postulaciones, perfiles públicos y una experiencia de lectura más clara.

## What Changes

- **Visibilidad de postulantes**: La tarjeta “Postulantes” MUST mostrarse solo al creador autenticado, únicamente en estados de carga o listado exitoso. Visitantes, no-owners y respuestas 401/403 MUST NOT ver la sección (ni mensajes de error de API como “No autenticado.”). Cancelación de peticiones obsoletas al cambiar de solicitud.
- **Publicador real**: Sección **“Publicado por”** con `UserIdentityLinkComponent` y `ownerUserId`. El nombre visible MUST obtenerse de `GET /users/profile/:userId` (`fullName`); no usar el placeholder “Publicador” ni el objeto `provider` demo cuando exista perfil. Ocultar reputación/reseñas demo.
- **Sin UUID en UI**: Eliminar `ID: {uuid}` de descripción y del estado de error.
- **Antigüedad relativa**: `publishedAtLabel` calculado en backend desde `publishedAtSort` en listado y detalle.
- **Estética responsive**: Layout con `gap` entre bloques del main (separación Descripción / Publicado por), header y sidebar adaptables.
- **Galería modal**: Controles iconográficos, contador centrado, teclado ←/→ y `aria-label`.
- **Header simplificado**: Ocultar CTAs **“Ver perfil”** y **“Contactar”** del header; mantener **“Postular”** para visitantes no creadores. El perfil del publicador queda en la sección “Publicado por”.

## Capabilities

### New Capabilities

- _(ninguna)_

### Modified Capabilities

- `open-requests-postulations-owner-and-applicants`: Postulantes privados del creador; sin filtrar errores de auth al visitante.
- `open-requests-proposals-front-contract`: `ownerUserId`, perfil público para nombre del publicador, `publishedAtLabel` dinámico.
- `crear-solicitud` / `open-requests`: Antigüedad relativa en lecturas.
- `open-request-detail-page`: Publicador con nombre real, espaciado, header sin Ver perfil/Contactar, postulantes endurecidos.
- `modal-gallery`: Navegación accesible del modal.

## Impact

- **Front**: `open-request-detail` (componente, template, estilos), `UserApi.getPublicProfile`, `open-requests.service.ts`, tests `open-request-detail.spec.ts`.
- **Back**: `format-relative-published-at.ts`, repositorios TypeORM/in-memory, ranking service.
- **Docs**: `ENDPOINTS_Y_CONTRATOS_API.md` (`publishedAtLabel` derivado).
- **Sin breaking API** en contratos JSON existentes.
