## 1. Backend — antigüedad relativa

- [x] 1.1 Crear helper `formatRelativePublishedAt(publishedAtSort: number, now?: number): string` en módulo open-requests (español: recién, hace X minutos/horas/días/semanas/meses).
- [x] 1.2 Añadir tests unitarios del helper cubriendo umbrales (recién, 1 día, 30 días, 1 año).
- [x] 1.3 Aplicar el helper al mapear `GET /open-requests/{id}` (TypeORM e in-memory) sobrescribiendo `publishedAtLabel` en la respuesta.
- [x] 1.4 Aplicar el mismo helper en `list` y `listByOwner` para ítems de listado.
- [x] 1.5 Verificar que `OpenRequestDetailDto` expone `ownerUserId` en detalle cuando existe en entidad.

## 2. Front — servicio y modelo

- [x] 2.1 Confirmar que `normalizeDetail` preserva `ownerUserId` del DTO sin perderlo en fallbacks.
- [x] 2.2 Antigüedad relativa en cliente vía `publishedAtLabel` recalculado por el backend (sin cálculo duplicado en front).

## 3. Front — visibilidad postulantes y publicador

- [x] 3.1 `isOwnerWithSession` / `showPostulantesSection`: sesión + `ownerUserId` + match; tarjeta solo en loading/success.
- [x] 3.2 No invocar listado de postulaciones si no es owner; cancelar respuestas obsoletas (`switchMap` + secuencia).
- [x] 3.3 Sección **Publicado por** con `app-user-identity-link` y `ownerUserId`.
- [x] 3.4 Ocultar reputación/reseñas demo; cargar `fullName` con `UserApi.getPublicProfile`.
- [x] 3.5 Eliminar `ID: {uuid}` de descripción y estado error.
- [x] 3.6 En 401/403 al listar postulantes: ocultar tarjeta (no mostrar “No autenticado.”); en 401 limpiar sesión.

## 4. Front — header, estilos y galería modal

- [x] 4.1 `publishedAtLabel` recalculado en meta del header.
- [x] 4.2 Layout responsive: `gap` en `.main`, header/sidebar apilables.
- [x] 4.3 Galería modal: botones icono, contador, disabled con una imagen.
- [x] 4.4 Teclado ←/→ en modal abierto.
- [x] 4.5 `aria-label` en navegación del modal.
- [x] 4.6 Quitar CTAs **Ver perfil** y **Contactar** del header; mantener solo **Postular** para no creadores.

## 5. Tests y validación

- [x] 5.1 Tests: visitante / otro usuario / owner — visibilidad postulantes.
- [x] 5.2 Test: sin sección Postulantes para no-owner; sin UUID en DOM.
- [x] 5.3 Test: 401 al listar oculta postulantes y limpia sesión.
- [x] 5.4 Test: nombre del publicador desde `getPublicProfile` (`fullName`).
- [x] 5.5 `npm test` helper back + `open-request-detail.spec.ts` en verde.

## 6. Documentación

- [x] 6.1 `ENDPOINTS_Y_CONTRATOS_API.md`: nota sobre `publishedAtLabel` derivado de `publishedAtSort`.
