## ADDED Requirements

### Requirement: Sección Condiciones y recursos en detalle público

La página de detalle de solicitud (`/solicitudes/:id`) MUST mostrar una sección **«Condiciones y recursos»** cuando el detalle incluya `workConditions` con al menos un subcampo con valor. La sección MUST ubicarse en la columna principal, después de la descripción larga y antes de «Publicado por», sin romper el layout responsive existente.

Cada ítem MUST mostrar etiqueta en español + valor legible (p. ej. «El trabajador debe trasladarse al lugar: Sí»). MUST NOT mostrar claves técnicas del API ni valores enum sin traducir.

#### Scenario: Usuario ve condiciones en detalle

- **WHEN** el detalle incluye `workConditions` con datos
- **THEN** el sistema MUST renderizar la sección con las filas correspondientes
- **AND** MUST NOT mostrar filas para subcampos ausentes o vacíos

#### Scenario: Usuario no ve sección vacía

- **WHEN** el detalle no incluye `workConditions` o está vacío
- **THEN** MUST NOT existir bloque «Condiciones y recursos» en el DOM

#### Scenario: Separación visual con secciones adyacentes

- **WHEN** se muestran Descripción, Condiciones y recursos, y Publicado por
- **THEN** MUST existir separación vertical consistente (gap ≥16px) entre cards/secciones

## MODIFIED Requirements

### Requirement: Composición responsive del detalle

El layout del detalle (header, galería, cards de contenido, sidebar de postulación) MUST adaptarse sin overflow horizontal ni solapamientos en viewports móvil, tablet y desktop. La columna principal (`main`) MUST usar espaciado vertical consistente entre bloques (p. ej. gap ≥ 16px) de modo que **Descripción**, **Condiciones y recursos** (cuando aplique) y **Publicado por** se perciban como secciones separadas.

#### Scenario: Vista móvil apilada

- **WHEN** el viewport es estrecho (p. ej. ≤ 640px)
- **THEN** header, galería, contenido (incl. condiciones) y sidebar MUST apilarse en un orden legible
- **AND** los CTAs del header MUST permanecer usables sin desbordar el ancho

#### Scenario: Separación entre Descripción y Publicado por

- **WHEN** el detalle muestra Descripción y Publicado por
- **THEN** MUST existir separación visual clara (espacio vertical) entre la card de Descripción y la card de Publicado por
- **AND** si existe la sección Condiciones y recursos, MUST intercalarse con la misma separación

#### Scenario: Vista desktop con sidebar

- **WHEN** el viewport es amplio
- **THEN** el sidebar de postulación MUST mantenerse visible según el patrón sticky existente sin tapar el contenido principal
