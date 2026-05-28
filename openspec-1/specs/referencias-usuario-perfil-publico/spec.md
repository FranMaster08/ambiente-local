## Purpose

Requisitos transversales para que **toda referencia visible a un usuario** en la aplicación sea **navegable** al perfil público correspondiente (o al perfil propio cuando aplique), con accesibilidad, contratos de datos seguros y estados de error claros.

## Requirements

### Requirement: Inventario de superficies y excepciones explícitas

El equipo MUST mantener un inventario (p. ej. sección en `tasks.md` o checklist enlazado) de vistas, componentes y listados donde se muestre identidad de usuario, indicando si cada superficie queda cubierta por el patrón de enlace al perfil o si existe una **excepción UX** justificada. Las excepciones MUST ser enumerables y MUST NOT usarse para omitir enlaces por conveniencia de implementación.

#### Scenario: Superficie con identidad y userId disponible

- **WHEN** una vista muestra nombre, avatar, username o iniciales identificables de un usuario y el modelo incluye su `userId` (u identificador equivalente documentado)
- **THEN** esa superficie MUST aparecer en el inventario como “cubierta” con enlace al perfil antes de dar por cerrado el cambio

#### Scenario: Excepción documentada

- **WHEN** el producto decide que una referencia identificable no debe ser navegable
- **THEN** la excepción MUST documentar el motivo de UX o legal y MUST NOT exponer datos privados adicionales

### Requirement: Navegación canónica al perfil sin rutas duplicadas

La aplicación MUST usar una **única convención de rutas** ya establecida en el proyecto para abrir el perfil de un usuario a partir de su `userId` (p. ej. `/usuarios/:userId`), sin introducir rutas paralelas que representen el mismo recurso. El atajo de perfil propio sin id en path (p. ej. `/perfil`) MAY coexistir como entrada adicional, pero los enlaces generados desde datos de dominio MUST preferir la ruta parametrizada cuando el `userId` esté disponible para reducir bifurcaciones de lógica.

#### Scenario: Listado genera URL con id opaco

- **WHEN** el usuario activa una referencia identitaria en un listado que dispone de `userId`
- **THEN** el sistema MUST navegar a la ruta parametrizada acordada sin duplicar registros de ruta en el router

#### Scenario: Refresh directo

- **WHEN** el usuario carga o refresca directamente la URL del perfil público de un tercero
- **THEN** el sistema MUST renderizar el perfil público o el estado de usuario no encontrado sin errores de consola no controlados

#### Scenario: CTA secundario sin anidar enlaces

- **WHEN** una vista muestra un bloque identitario navegable y además un enlace con etiqueta “Ver perfil” al mismo `userId`
- **THEN** los destinos activables MUST ser hermanos en el DOM (MUST NOT anidar `<a>` dentro de `<a>`) y MUST usar la misma ruta canónica `/usuarios/:userId`

### Requirement: Separación estricta entre perfil propio y perfil ajeno

El sistema MUST detectar si el `userId` del perfil visitado coincide con el del usuario autenticado y MUST mostrar la experiencia de **perfil propio** (datos y acciones privadas permitidas por el producto) o **perfil público** para terceros, sin filtrar datos sensibles en el modo público. Las acciones privadas (edición, datos de contacto no públicos, etc.) MUST NOT aparecer en el modo público.

#### Scenario: Usuario abre su propio perfil desde una referencia

- **WHEN** el usuario autenticado navega a su propio `userId` desde una referencia en la aplicación
- **THEN** el sistema MUST presentar la experiencia de perfil propio o redirigir a la entrada de perfil propio según la arquitectura vigente, sin mostrar datos como si fuera un tercero

#### Scenario: Usuario abre perfil ajeno

- **WHEN** el usuario autenticado navega al perfil de otro `userId`
- **THEN** el sistema MUST mostrar únicamente información pública permitida por el backend y MUST NOT mostrar acciones de cuenta privadas

### Requirement: Contratos de backend y ausencia de fuga de datos privados

Las respuestas HTTP utilizadas para pintar perfiles de terceros MUST limitarse a campos públicos acordados (p. ej. vía DTO de perfil público existente). Listados que amplíen payload para permitir enlaces MUST NOT añadir email, teléfono, tokens, preferencias internas ni campos equivalentes. La autorización MUST validarse en servidor según las políticas actuales del proyecto.

#### Scenario: Perfil público por id

- **WHEN** un cliente solicita el perfil público de un `userId` existente
- **THEN** el cuerpo de respuesta MUST NOT incluir email ni teléfono ni datos de configuración de cuenta salvo que el producto los haya explícitamente clasificado como públicos en una especificación distinta

#### Scenario: Usuario inexistente

- **WHEN** el cliente solicita un `userId` que no existe o fue eliminado según reglas del dominio
- **THEN** el sistema MUST responder con el código y cuerpo de error acordes al proyecto sin revelar información interna de otros usuarios

### Requirement: Estados vacíos, fallbacks y errores de presentación

La UI MUST manejar avatar ausente con iniciales o placeholder, datos públicos faltantes con copy vacío no roto, y usuario no encontrado con mensaje claro. Los errores de red o permisos MUST mostrar mensajes comprensibles sin volcar trazas internas en pantalla ni en consola de producción.

#### Scenario: Sin avatar

- **WHEN** no hay URL de avatar disponible
- **THEN** el sistema MUST mostrar iniciales o placeholder coherente con el diseño existente

#### Scenario: Error al cargar perfil

- **WHEN** la petición de perfil falla por red o error 5xx
- **THEN** el sistema MUST mostrar un estado de error reutilizable y MUST permitir reintento o navegación segura hacia atrás

### Requirement: Accesibilidad de los enlaces a perfil

Los controles que navegan al perfil MUST ser operables con teclado, MUST tener foco visible y, cuando el elemento activable sea principalmente un avatar u icono sin texto visible, MUST incluir un nombre accesible (p. ej. `aria-label`). La interactividad MUST NOT depender únicamente del color.

#### Scenario: Navegación por teclado

- **WHEN** el usuario mueve el foco hasta un bloque identitario enlazado y activa Enter
- **THEN** el sistema MUST navegar al mismo destino que un clic con puntero

#### Scenario: Solo avatar

- **WHEN** el hit target visible es solo el avatar
- **THEN** el control MUST incluir un `aria-label` o texto oculto visualmente que identifique el destino del perfil

### Requirement: Calidad y regresiones

Antes de considerar el cambio completo, el equipo MUST ejecutar en el repositorio las herramientas de calidad disponibles (lint, typecheck, build y batería de tests automatizados existentes) y MUST validar manualmente los flujos listados en las tareas (navegación desde solicitudes, propuestas/postulaciones, listados, refresh directo, responsive y ausencia de errores de consola nuevos).

#### Scenario: Pipeline local verde

- **WHEN** se ejecutan los comandos de calidad definidos en las tareas del cambio
- **THEN** el sistema MUST completarlos sin fallos nuevos atribuibles a este cambio
