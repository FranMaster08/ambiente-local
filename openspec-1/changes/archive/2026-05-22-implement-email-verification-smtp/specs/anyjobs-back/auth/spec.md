## MODIFIED Requirements

### Requirement: Register creates pending user and returns next stage
El sistema MUST aceptar `POST /auth/register` con el body JSON:

- `fullName: string`
- `email: string`
- `phoneNumber: string`
- `password: string`
- `roles: ("CLIENT" | "WORKER")[]` (min 1)

El sistema MUST responder `200` con JSON que incluya:

- `userId: string`
- `status: "PENDING"`
- `emailVerificationRequired: boolean` (siempre `true`)
- `phoneVerificationRequired: boolean` (siempre `false` mientras la verificación por SMS esté deshabilitada)
- `nextStage: "VERIFY"`

Tras crear el usuario pendiente, el sistema MUST generar un código de seguridad de 6 dígitos, almacenarlo en el `RegistrationFlow`, y enviarlo al e-mail del usuario mediante el `MailerService`. El asunto del correo MUST ser `"Tu código de seguridad"` y el cuerpo MUST indicar claramente el código generado.

Si el envío del e-mail falla, el sistema MUST lanzar un error controlado y MUST NOT crear el usuario en estado incompleto sin que el usuario reciba su código.

#### Scenario: Successful register sends security code by email
- **WHEN** el cliente envía `POST /auth/register` con un payload válido
- **THEN** el sistema MUST responder `200` con `userId`, `status="PENDING"`, `phoneVerificationRequired=false` y `nextStage="VERIFY"`, y MUST enviar un e-mail con el código de seguridad al `email` del usuario registrado

#### Scenario: phoneVerificationRequired is always false
- **WHEN** el cliente envía `POST /auth/register` con `roles: ["WORKER"]`
- **THEN** el sistema MUST responder con `phoneVerificationRequired: false` (mientras SMS esté deshabilitado)

### Requirement: Verify email with security code stored in registration flow
El sistema MUST aceptar `POST /auth/verify-email` con body JSON:

- `otpCode: string`

El sistema MUST validar que el `otpCode` recibido coincide con el código de seguridad almacenado en el `RegistrationFlow` activo de la sesión del usuario. Si el código coincide, MUST marcar `emailVerified: true` en el flow y responder `204 No Content`. Si el código no coincide, MUST responder `400` con `{ "message": "Código de seguridad incorrecto" }`.

#### Scenario: Verify email succeeds with correct security code
- **WHEN** el cliente envía `POST /auth/verify-email` con el `otpCode` correcto
- **THEN** el sistema MUST responder `204` y MUST marcar `emailVerified: true` en el flow de registro

#### Scenario: Verify email fails with incorrect security code
- **WHEN** el cliente envía `POST /auth/verify-email` con un `otpCode` incorrecto
- **THEN** el sistema MUST responder `400` con `{ "message": "Código de seguridad incorrecto" }` y MUST NOT marcar `emailVerified: true`

## ADDED Requirements

### Requirement: Verify phone endpoint MUST responder 503 cuando SMS está deshabilitado
Cuando la variable de entorno `PHONE_VERIFICATION_ENABLED` tiene valor `false`, el sistema MUST responder a `POST /auth/verify-phone` con status `503 Service Unavailable` y body `{ "message": "Phone verification is temporarily disabled" }`. El sistema MUST NOT procesar la verificación de teléfono cuando SMS está deshabilitado.

#### Scenario: verify-phone returns 503 when disabled
- **WHEN** `PHONE_VERIFICATION_ENABLED=false` y el cliente llama `POST /auth/verify-phone`
- **THEN** el sistema MUST responder `503` con `{ "message": "Phone verification is temporarily disabled" }`

### Requirement: La variable PHONE_VERIFICATION_ENABLED MUST controlar el estado de verificación por SMS
El sistema MUST leer la variable de entorno `PHONE_VERIFICATION_ENABLED` (boolean, default `false`). Esta variable MUST estar validada en el schema Zod de configuración. Cuando su valor es `false`, el campo `phoneVerificationRequired` en la respuesta de `POST /auth/register` MUST ser `false`.

#### Scenario: PHONE_VERIFICATION_ENABLED=false desactiva SMS en registro
- **WHEN** `PHONE_VERIFICATION_ENABLED=false` y el cliente registra un usuario con rol `WORKER`
- **THEN** la respuesta MUST contener `phoneVerificationRequired: false`
