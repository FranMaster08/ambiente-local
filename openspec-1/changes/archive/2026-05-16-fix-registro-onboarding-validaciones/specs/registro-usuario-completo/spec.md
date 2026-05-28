## MODIFIED Requirements

### Requirement: La cuenta se crea solo al completar todos los pasos obligatorios
El sistema SHALL crear la cuenta definitiva únicamente cuando el cliente invoque `POST /auth/register/complete` con verificaciones, ubicación (país, departamento/provincia, municipio, barrio), perfil según roles y datos personales WORKER completos (incl. mayor de edad y nacionalidad ISO válida).

#### Scenario: Finalizacion exitosa del onboarding
- **WHEN** el payload de `register/complete` cumple todas las reglas para los roles seleccionados
- **THEN** el sistema crea el usuario en `users`, persiste `municipality` y deja el registro finalizado

#### Scenario: Intento de finalizacion con pasos faltantes
- **WHEN** faltan verificaciones, ubicación, categorías WORKER o datos personales WORKER
- **THEN** el sistema rechaza con `fieldErrors` identificables

#### Scenario: Finalizacion rechazada por menor de edad
- **WHEN** `personalInfo.birthDate` indica edad menor a 18 años
- **THEN** el backend rechaza con error en `birthDate` sin crear usuario

#### Scenario: Finalizacion rechazada por nacionalidad invalida
- **WHEN** `personalInfo.nationality` no es un código ISO-3166-1 reconocido
- **THEN** el backend rechaza con error en `nationality`

### Requirement: El frontend debe reflejar un registro en progreso y no una cuenta creada
El frontend SHALL modelar el proceso como onboarding en progreso hasta confirmación de `register/complete`, MUST usar sessionStorage para el draft, y MUST alinear botones Continuar con validez de la etapa actual.

#### Scenario: Wizard mantiene estado de onboarding
- **WHEN** el usuario completa Cuenta
- **THEN** no se crea cuenta en servidor; solo se actualiza draft local y etapa VERIFY

#### Scenario: Confirmacion de cuenta creada solo al cierre
- **WHEN** `register/complete` responde 204
- **THEN** el frontend muestra DONE y limpia el draft

#### Scenario: No avance con formulario invalido
- **WHEN** el formulario de la etapa actual es inválido
- **THEN** no se avanza de etapa ni se llama `register/complete`

## ADDED Requirements

### Requirement: Enum de tipo de documento incluye cedula de ciudadania
El backend SHALL aceptar `CC` además de `DNI`, `NIE`, `PASSPORT`.

#### Scenario: Registro con CC
- **WHEN** `register/complete` incluye `documentType: "CC"` válido para WORKER
- **THEN** el usuario se crea con ese tipo de documento

### Requirement: Ubicacion con municipio en contrato de registro
El backend SHALL aceptar y persistir `location.municipality` junto con `city`, `area` y `countryCode` en `register/complete`.

#### Scenario: Payload con municipio
- **WHEN** se envía `location: { countryCode, city, municipality, area }` válidos según catálogo
- **THEN** el usuario queda con los cuatro campos persistidos

#### Scenario: Municipio invalido para division
- **WHEN** `municipality` no pertenece a la división y país indicados
- **THEN** el backend rechaza con `fieldErrors.municipality`

### Requirement: Barrio texto libre con longitud valida
El backend SHALL aceptar cualquier `area` (barrio) con longitud entre 2 y 120 caracteres sin exigir coincidencia con catálogo de barrios.

#### Scenario: Barrio personalizado aceptado
- **WHEN** `area` es un texto libre válido no listado en seed
- **THEN** el registro se completa correctamente

### Requirement: Disponibilidad de email y telefono solo para usuarios definitivos
`GET /auth/email-available` y `GET /auth/phone-available` SHALL considerar ocupado solo si existe en tabla `users`, no por flows de registro incompletos.

#### Scenario: Email solo en draft no bloquea
- **WHEN** el email existe solo en `auth_registration_flows` y no en `users`
- **THEN** `email-available` devuelve `available: true`

### Requirement: Rechazo de finalizacion con mensajes de validacion estructurados
El backend SHALL devolver `fieldErrors` en `VALIDATION.INVALID_INPUT` para fallos previsibles.

#### Scenario: Ubicacion incompleta al completar
- **WHEN** falta `municipality` o `area` en location
- **THEN** la respuesta indica el campo faltante en `fieldErrors`

#### Scenario: DTO register/complete con municipio en location
- **WHEN** el cliente envía `location.municipality` en el body
- **THEN** ValidationPipe lo acepta (campo en whitelist del DTO)

### Requirement: Catálogo geografico para divisiones y municipios
El backend SHALL exponer catálogo de divisiones por país y municipios por división desde base de datos sembrada (CO departamentos, AR provincias).

#### Scenario: Divisiones por pais
- **WHEN** `GET /auth/location-catalog?countryCode=CO`
- **THEN** responde lista de divisiones

#### Scenario: Municipios por division
- **WHEN** `GET /auth/location-catalog?countryCode=CO&division=Antioquia`
- **THEN** responde lista de municipios de esa división
