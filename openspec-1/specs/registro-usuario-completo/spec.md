## Purpose

Definir el flujo de registro de usuario de punta a punta para que la cuenta solo exista y pueda autenticarse cuando se complete el onboarding mediante `POST /auth/register/complete`.

## Requirements

### Requirement: El registro inicial no crea un usuario definitivo en servidor
El sistema SHALL mantener el progreso del wizard en el cliente (sessionStorage) hasta la finalización y MUST NOT crear un usuario definitivo ni autenticable al completar solo la etapa Cuenta.

#### Scenario: Continuar Cuenta sin POST register
- **WHEN** el usuario completa Cuenta válida y pulsa Continuar
- **THEN** el wizard avanza a Verificación guardando draft en sessionStorage sin llamar `POST /auth/register`

### Requirement: La disponibilidad de credenciales consulta solo usuarios definitivos
`GET /auth/email-available` y `GET /auth/phone-available` SHALL considerar ocupado solo si existe en tabla `users`, no por flows de registro incompletos.

#### Scenario: Email solo en draft no bloquea
- **WHEN** el email existe solo en `auth_registration_flows` y no en `users`
- **THEN** `email-available` devuelve `available: true`

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

### Requirement: La finalizacion revalida unicidad y consistencia
El sistema SHALL revalidar email, teléfono y consistencia del payload en el momento de crear la cuenta definitiva.

#### Scenario: Conflicto de unicidad al finalizar
- **WHEN** el email o el teléfono ya existen en `users` al momento de finalizar
- **THEN** el sistema rechaza la creación e informa el campo en conflicto

#### Scenario: Finalizacion atomica
- **WHEN** el sistema crea la cuenta definitiva desde un payload válido
- **THEN** la creación del usuario ocurre en una operación consistente sin estados parcialmente creados

### Requirement: El login solo acepta cuentas finalizadas
El sistema SHALL autenticar exclusivamente cuentas definitivas con status `ACTIVE` y MUST NOT permitir inicio de sesión para registros incompletos.

#### Scenario: Login exitoso despues de finalizar
- **WHEN** una persona intenta autenticarse con una cuenta creada tras `register/complete`
- **THEN** el sistema permite el login y devuelve snapshot de usuario incluyendo ubicación completa

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

### Requirement: Rechazo de finalizacion con mensajes de validacion estructurados
El backend SHALL devolver `fieldErrors` en `VALIDATION.INVALID_INPUT` para fallos previsibles.

#### Scenario: Ubicacion incompleta al completar
- **WHEN** falta `municipality` o `area` en location
- **THEN** la respuesta indica el campo faltante en `fieldErrors`

### Requirement: Catálogo geografico para divisiones y municipios
El backend SHALL exponer catálogo de divisiones por país y municipios por división desde base de datos sembrada (CO departamentos, AR provincias).

#### Scenario: Divisiones por pais
- **WHEN** `GET /auth/location-catalog?countryCode=CO`
- **THEN** responde lista de divisiones

#### Scenario: Municipios por division
- **WHEN** `GET /auth/location-catalog?countryCode=CO&division=Antioquia`
- **THEN** responde lista de municipios de esa división

### Requirement: Perfil privado y publico exponen ubicacion completa
El backend SHALL incluir `municipality` en `GET /users/me/profile` y `GET /users/profile/:userId` junto con `city`, `area` y `countryCode`.

#### Scenario: Perfil con municipio persistido
- **WHEN** el usuario tiene municipio guardado tras el registro
- **THEN** las respuestas de lectura de perfil incluyen `municipality`
