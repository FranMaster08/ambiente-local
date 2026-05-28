## Purpose

Validaciones visibles, geografía en cascada, registro atómico al final del wizard y errores accionables por campo en el onboarding de registro.

## Requirements

### Requirement: Etapa Cuenta con validación visible y sin bloqueos opacos
El frontend del wizard de registro SHALL mostrar errores por campo en la etapa Cuenta y MUST NOT mantener deshabilitado el botón Continuar sin que el usuario pueda inferir la causa (validación síncrona, validación async en curso o error de API).

#### Scenario: Campos inválidos muestran error al intentar continuar
- **WHEN** el usuario pulsa Continuar en Cuenta con algún campo inválido o sin roles/términos
- **THEN** el formulario marca los controles como touched y muestra el mensaje de error correspondiente en cada campo afectado

#### Scenario: Validación async de email o teléfono en curso
- **WHEN** los validadores async de email o teléfono están en estado pending
- **THEN** el botón Continuar permanece deshabilitado y la interfaz indica que se está comprobando disponibilidad

#### Scenario: Email disponible no bloqueado por drafts de servidor
- **WHEN** el usuario introduce un email que solo existía en un flow/draft antiguo en servidor pero no en `users`
- **THEN** `GET /auth/email-available` responde `available: true` y el usuario puede continuar el wizard

#### Scenario: Tipos de input mobile en Cuenta
- **WHEN** el usuario enfoca email o teléfono en mobile
- **THEN** email usa `type="email"` y teléfono usa `type="tel"`

### Requirement: Progreso del wizard en cliente hasta finalizar
El frontend SHALL persistir el progreso del onboarding en almacenamiento de sesión del navegador y MUST NOT crear usuario ni flow de registro en servidor al completar solo la etapa Cuenta.

#### Scenario: Continuar Cuenta sin POST register
- **WHEN** el usuario completa Cuenta válida y pulsa Continuar
- **THEN** el wizard avanza a Verificación guardando draft en sessionStorage sin llamar `POST /auth/register`

#### Scenario: Finalización única
- **WHEN** el usuario completa todas las etapas obligatorias y confirma en Personal (o CLIENT equivalente)
- **THEN** el frontend envía un único `POST /auth/register/complete` con account, verificaciones, location, perfil y personalInfo según roles

### Requirement: Etapa Verificación con OTP numérico usable en mobile
El frontend SHALL usar entradas OTP que favorezcan teclado numérico en mobile.

#### Scenario: OTP email con teclado numérico
- **WHEN** el usuario enfoca el campo OTP de email en mobile
- **THEN** el input usa `inputmode="numeric"` para facilitar la entrada del código

#### Scenario: Avance en Verificación según rol
- **WHEN** el usuario WORKER tiene teléfono verificado (flags en draft/estado)
- **THEN** puede continuar a Ubicación
- **WHEN** el usuario CLIENT tiene al menos email o teléfono verificado
- **THEN** puede continuar a Ubicación

### Requirement: Etapa Ubicación en cascada con municipio y barrio libre
El sistema SHALL exigir país (CO o AR), departamento/provincia, municipio del catálogo y barrio en texto libre antes de continuar y antes de incluir ubicación en `register/complete`.

#### Scenario: Cascada país → división → municipio
- **WHEN** el usuario selecciona un país
- **THEN** se cargan divisiones (departamentos/provincias) y el combo de división se habilita
- **WHEN** el usuario selecciona una división
- **THEN** se cargan municipios de esa división y el combo de municipio se habilita

#### Scenario: Barrio como texto libre
- **WHEN** el usuario selecciona municipio
- **THEN** puede escribir el barrio en un campo de texto (mínimo 2 caracteres, máximo 120)
- **THEN** el barrio no está limitado a una lista cerrada del catálogo

#### Scenario: Continuar con ubicación incompleta
- **WHEN** falta país, división, municipio o barrio válido
- **THEN** Continuar está deshabilitado o muestra resumen “Corrige lo siguiente” con cada campo faltante

### Requirement: Etapa Perfil no permite avance con datos mínimos inválidos para el rol
El frontend SHALL impedir avanzar desde ROLE_PROFILE cuando WORKER no tiene categorías.

#### Scenario: WORKER sin categorías
- **WHEN** el usuario WORKER no seleccionó categorías
- **THEN** no avanza a Personal

### Requirement: Etapa Personal con catálogo alineado al backend
El frontend SHALL ofrecer tipos de documento con valores `DNI`, `NIE`, `PASSPORT`, `CC`.

#### Scenario: Opción Cédula de ciudadanía visible
- **WHEN** el usuario abre tipo de documento
- **THEN** aparece “Cédula de ciudadanía” con valor `CC`

### Requirement: Datos personales obligatorios para WORKER incluyendo mayor de edad
Para WORKER, el sistema SHALL exigir documento, fecha de nacimiento (≥ 18 años), género y nacionalidad antes de finalizar.

#### Scenario: Menor de edad rechazado
- **WHEN** el usuario WORKER ingresa fecha de nacimiento que implica menos de 18 años
- **THEN** el frontend muestra error de mayor de edad y no envía `register/complete`

#### Scenario: Nacionalidad de cualquier país ISO
- **WHEN** el usuario WORKER abre nacionalidad
- **THEN** ve un desplegable con países del mundo (códigos ISO-3166-1 alpha-2)
- **WHEN** selecciona un código válido (ej. `ES`, `CO`, `VE`)
- **THEN** el valor se envía en `personalInfo.nationality`

#### Scenario: WORKER con payload personal completo en register/complete
- **WHEN** WORKER completa todos los campos obligatorios
- **THEN** `POST /auth/register/complete` incluye `personalInfo` completo y crea usuario si el resto es válido

### Requirement: Errores de registro accionables con resumen por campo
El frontend SHALL mostrar un resumen “Corrige lo siguiente:” con mensajes concretos por campo y MUST NOT mostrar solo mensajes genéricos cuando existen errores de campo identificables.

#### Scenario: Resumen en Personal con campos faltantes
- **WHEN** WORKER pulsa Continuar con campos personales inválidos
- **THEN** aparece lista con mensajes como “Selecciona un género”, “La nacionalidad es obligatoria”, etc.

#### Scenario: Error API con fieldErrors
- **WHEN** el backend responde `VALIDATION.INVALID_INPUT` con `details.fieldErrors`
- **THEN** cada campo afectado muestra mensaje traducido en resumen y/o junto al control

#### Scenario: Mensaje Nest whitelist legible
- **WHEN** el backend rechaza un campo no permitido en DTO (ej. municipio en servidor desactualizado)
- **THEN** el usuario ve mensaje que indica qué campo no reconoce el servidor, no texto crudo `property municipality should not exist`

### Requirement: Logs de depuración del registro sin datos sensibles
El frontend MUST NOT registrar contraseñas, OTP ni documento completo en consola.

#### Scenario: Log de error de API
- **WHEN** falla una petición de registro
- **THEN** el log incluye código, etapa y nombres de campos, sin PII sensible

### Requirement: Vista de perfil muestra ubicacion e identidad legibles
El frontend SHALL mostrar ubicación completa (país, división, municipio, barrio) y etiquetas legibles para roles, documento, género y nacionalidad en la pantalla de perfil.

#### Scenario: Ubicacion en perfil tras registro
- **WHEN** el usuario consulta su perfil tras registrarse con municipio
- **THEN** ve municipio y barrio en la sección Ubicación, no solo división y barrio

#### Scenario: Labels con capitalización normal
- **WHEN** el usuario ve etiquetas de campos en perfil
- **THEN** los labels usan primera mayúscula y el resto minúsculas (no todo en mayúsculas)
