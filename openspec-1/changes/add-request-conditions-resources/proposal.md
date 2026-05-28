## Why

Los trabajadores que evalúan una solicitud abierta hoy solo disponen de título, descripción, ubicación y presupuesto. Eso obliga a inferir condiciones críticas (herramientas, traslado, materiales, experiencia, horarios, acceso al lugar) desde texto libre o contacto posterior, looser postulaciones poco informadas y más fricción. Agregar una sección estructurada de **condiciones y recursos** — inspirada conceptualmente en la claridad de Airbnb «Lo que ofrece este lugar», pero adaptada a servicios — entrega contexto accionable antes de postularse sin complicar el flujo de publicación.

## What Changes

- **Nueva sección en publicación** (`/solicitudes/nueva`): «Condiciones y recursos disponibles», ubicada después de «Ubicación y presupuesto» y antes de «Contenido multimedia», con 8 opciones controladas (sí/no/variantes) y un campo opcional de texto «Instrucciones adicionales».
- **Persistencia backend**: objeto opcional `workConditions` asociado a cada open request, con enums validados y texto libre acotado; compatibilidad total con solicitudes existentes (`NULL` / ausente).
- **Contrato API**: `POST /open-requests` y `PATCH /open-requests/:id` aceptan `workConditions` opcional; `GET /open-requests/:id` lo devuelve cuando existe.
- **Detalle público**: nueva sección «Condiciones y recursos» que muestra solo campos con valor útil, con etiquetas legibles en español.
- **Tour guiado**: paso adicional en «Guía paso a paso» anclado a la nueva sección.
- **Tests y documentación**: cobertura en front y back; actualización de contratos OpenSpec y docs de API.

**Campos fase 1 (imprescindibles):**

| Campo | Valores permitidos |
|-------|-------------------|
| Herramientas propias requeridas | `yes`, `no`, `optional` |
| El trabajador debe trasladarse | `yes`, `no`, `to_coordinate` |
| El solicitante ofrece materiales | `yes`, `no`, `partially` |
| El solicitante ofrece herramientas | `yes`, `no`, `partially` |
| Se requiere experiencia previa | `yes`, `no`, `desirable` |
| Se permite coordinar horario | `yes`, `no`, `to_coordinate` |
| El trabajo requiere visita previa | `yes`, `no`, `to_coordinate` |
| Acceso fácil o instrucciones especiales | `yes`, `no`, `requires_instructions` |
| Instrucciones adicionales (texto) | string opcional, máx. 500 caracteres |

**Fase 2 (fuera de alcance inicial):**

- Resumen de condiciones en tarjetas del listado (`/solicitudes`) y mapa.
- Filtros de búsqueda por condiciones.
- Badges/iconografía compacta en cards.
- UI de edición de condiciones en flujo de actualización de solicitud (si el PATCH ya existe pero no hay pantalla).

Ningún campo de la sección es obligatorio para publicar en fase 1.

## Capabilities

### New Capabilities

- `open-request-work-conditions`: Captura, persistencia, validación y visualización pública de condiciones y recursos de una solicitud abierta.

### Modified Capabilities

- `crear-solicitud`: Formulario de publicación incluye la nueva sección, envío de `workConditions` y paso del tour.
- `open-request-detail-page`: Detalle público muestra sección «Condiciones y recursos».
- `anyjobs-back/open-requests`: Contrato de escritura/lectura con `workConditions` opcional y migración de persistencia.

## Impact

- **Frontend (`anyjobs-front/anyjobs`)**: `open-request-create` (template, TS, SCSS, specs), `open-requests.models.ts`, `open-requests-multipart.ts`, `open-request-detail`, `publish-request-tour.ts`, utilidades de etiquetas legibles, tests.
- **Backend (`anyjobs-back`)**: entidad `OpenRequestEntity`, dominio `OpenRequestDetail`, DTOs create/patch/detail, migración TypeORM, repositorio/mappers, tests e2e y unitarios.
- **OpenSpec**: nueva spec `open-request-work-conditions`; deltas en `crear-solicitud`, `open-request-detail-page`, `anyjobs-back/open-requests`.
- **Sin breaking changes**: solicitudes legacy sin `workConditions` siguen creándose, listándose y mostrándose con normalidad.
