# Inventario de referencias a usuario (post-implementación)

Ubicación del código: `anyjobs-front/anyjobs/src/app/`.

## Superficies con identidad y `userId` disponible → enlace a `/usuarios/:userId`

| Superficie | Modelo / fuente | Implementación |
|-------------|-----------------|----------------|
| Detalle solicitud — postulantes (owner) | `Proposal.userId` | `UserIdentityLinkComponent` en `open-request-detail.html` |
| Mis solicitudes — postulantes / “Postulé a estas” | `Proposal.userId` | `UserIdentityLinkComponent` + enlace **“Ver perfil”** (`btn btn--secondary`) hermano en `my-requests-dashboard.html` |
| Detalle solicitud — CTA creador ajeno | `detail.ownerUserId` | `routerLink` existente “Ver perfil” (sin duplicar ruta) |
| Cabecera / menú cuenta — usuario en sesión | `authVm().user.id` | `shell.html` → `[routerLink]="profileRouterLink()"` → `/usuarios/:id` |

## Brechas / sin `userId` en modelo (no enlazables sin ampliar contrato)

| Superficie | Motivo |
|------------|--------|
| Card listado solicitudes (`open-request-card`) | `OpenRequestListItem` no incluye `ownerUserId`; el listado público no expone creador en la card. |
| Bloque “Ofrecido por” en detalle | `OpenRequestDetail.provider` es texto/demo sin id de usuario. |
| Reseñas `providerReviews` | Solo `author: string`; sin id estable. |

## Excepciones UX (no aplicar enlace de perfil)

| Caso | Justificación |
|------|----------------|
| Avatar + nombre en **botón menú cuenta** que abre dropdown | El control primario es abrir menú; el enlace explícito “Mi perfil” ya navega al perfil. Duplicar navegación en el mismo botón competiría con el menú. |
| Listados de cards de solicitud sin datos de creador | No hay identidad de tercero visible; no aplica. |

## Rutas

- `/perfil` — perfil propio sin id en URL (se mantiene).
- `/usuarios/:userId` — perfil por id (público o propio si coincide sesión). **No** se añadieron rutas duplicadas.

## Backend

- `GET /users/profile/:userId` — DTO público sin email/teléfono (ver `UserPublicProfileResponseDto`).
- `NotFoundException` con mensaje genérico cuando el usuario no existe (perfil público y privado).

## Cierre inventario (tarea 9.2)

Todas las filas anteriores están **cubiertas** o **excepción justificada** / **brecha documentada**.

## Coordinación `mejorar-vista-perfil-usuario-publico-privado`

Misma ruta `/usuarios/:userId` y mismos endpoints de perfil; este cambio añade el componente compartido, enlaces desde solicitudes/postulaciones/menú y CTAs explícitos donde aplica.

## Validación (CI / local)

- Front: `npm run build`, `npm run lint` OK (Node ≥ 20). `ng test --watch=false`: 70/71 tests OK; fallo conocido en `home.spec.ts` (`IntersectionObserver` no definido en jsdom), no introducido por este cambio.
- Back: `npm test` en `anyjobs-back` OK (37 tests).

## Ajustes de UI relacionados (misma ventana de entrega)

- **Landing solicitudes abiertas** (`open-requests-landing`): se retiró la métrica hero estática “24/7 · exploración y contacto”; el resumen del hero queda en dos tarjetas (solicitudes abiertas + destacadas cerca). No forma parte del alcance original de navegación a perfil; queda registrado aquí para trazabilidad.
