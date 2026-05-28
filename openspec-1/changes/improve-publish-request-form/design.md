## Context

La pantalla `OpenRequestCreate` (`/solicitudes/nueva`) consume `POST /open-requests` con campos requeridos por `CreateOpenRequestDto`, incluyendo hoy `locationLabel` (texto libre), `contactPhone` y `contactEmail` visibles y pre-rellenados desde sesión. El proyecto ya cuenta con catálogo geográfico reutilizable (`LocationGeographyService`, `location-geography.data.ts`, endpoints de auth) usado en registro, con países CO/AR, divisiones, municipios y barrios sugeridos. No existe librería de tours en el front; el stack es Angular 21 standalone + signals.

## Goals / Non-Goals

**Goals:**

- Guiar al usuario con un tour no destructivo al publicar solicitudes.
- Capturar ubicación con selects encadenados (país → división → municipio) + barrio libre.
- Ocultar contacto del formulario y obtener email/teléfono del usuario autenticado en backend.
- Mantener creación multipart, imágenes opcionales y compatibilidad con solicitudes legacy.

**Non-Goals:**

- Migrar el modelo de BD a columnas separadas de ubicación (se persiste `locationLabel` compuesto).
- Cambiar rutas públicas ni el flujo post-creación (modal + navegación a detalle).
- Exponer contacto editable en esta pantalla o modificar reglas de privacidad del perfil.

## Decisions

### 1. Tour con `driver.js`

**Decisión:** Añadir `driver.js` (~5 KB gzip) como dependencia directa del front.

**Alternativas:** `intro.js` (más pesado, estilo antiguo), `shepherd.js` (requiere más CSS/integración), tour custom (más código de mantenimiento).

**Rationale:** Liviano, sin jQuery, compatible con Angular, API simple para steps anclados a `[data-tour]` en el template. El tour se instancia en el componente, no altera estado del formulario.

### 2. Ubicación estructurada en front, `locationLabel` compuesto en API

**Decisión:** Reemplazar el control `locationLabel` por controles `countryCode`, `division`, `municipality`, `neighborhood` (barrio libre, max 120). Al enviar, construir `locationLabel` con `formatProfileLocationLine` (orden: barrio · municipio · departamento · país legible).

**Alternativas:** Extender DTO con campos estructurados (requiere migración y cambios en listados); mantener texto libre con validación regex (insuficiente).

**Rationale:** El backend y listados ya consumen `locationLabel` string; reutilizar catálogo y helper de registro evita duplicar datos y mantiene compatibilidad con lecturas existentes.

### 3. Contacto resuelto en backend desde sesión

**Decisión:** Hacer `contactEmail` y `contactPhone` opcionales en `CreateOpenRequestDto`. En `OpenRequestsController.create`, cargar usuario por `req.user.userId` vía `AUTH_USER_REPOSITORY` e inyectar email/teléfono del perfil; ignorar valores del body si difieren.

**Alternativas:** Solo ocultar en front (inseguro); exigir contacto en body pre-rellenado (sigue permitiendo suplantación).

**Rationale:** Defensa en profundidad; el front deja de enviar contacto en el multipart.

### 4. Reutilizar `LocationGeographyService`

**Decisión:** Inyectar el servicio existente en `OpenRequestCreate`, cargar catálogo en `ngOnInit`/constructor con `ensureCatalog()`, resets en cascada al cambiar país/división (mismo patrón que registro).

## Risks / Trade-offs

- **[Usuario sin teléfono en perfil]** → Backend responde 400 con mensaje claro; front muestra error de API en banner.
- **[Barrio libre vs lista de barrios del catálogo]** → Barrio es texto libre por requisito; no se fuerza selección de lista.
- **[driver.js estilos globales]** → Importar CSS scoped en el componente o en `angular.json` solo el bundle del componente; no modificar tokens globales del design system.
- **[Solicitudes antiguas con locationLabel libre]** → Sin cambio en lectura; utilidades de saneo UUID en landing siguen aplicando.

## Migration Plan

1. Desplegar backend primero (acepta POST sin contacto en body; resuelve desde usuario).
2. Desplegar front con formulario nuevo (sin contacto, ubicación estructurada, tour).
3. Rollback: revertir front mantiene compatibilidad si backend sigue aceptando contacto en body (campos opcionales).

## Open Questions

- Ninguna bloqueante: país limitado a CO/AR ya está en catálogo; tour en español fijo acorde al resto de la pantalla.
