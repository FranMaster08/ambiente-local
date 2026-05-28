## Context

El backend es **NestJS 10** con arquitectura hexagonal en `apps/api/src/modules/auth/`. El flujo de registro ya existe y almacena el estado en una entidad `RegistrationFlow` (cookie `aj_reg_flow`). Los use cases de verificación OTP son stubs MVP que marcan `emailVerified: true` o `phoneVerified: true` sin validar ningún código ni enviar ningún mensaje. No existe módulo mailer, ni dependencia de `nodemailer` ni servicio SMTP. La configuración de entorno usa `@nestjs/config` + Zod en `apps/api/src/config/`. El frontend es Angular con flujo multi-etapa y Reactive Forms.

## Goals / Non-Goals

**Goals:**
- Implementar un `MailerModule` reutilizable en el backend para enviar correos vía SMTP.
- Generar un código de seguridad (6 dígitos) al registrar usuario y enviarlo por e-mail.
- Validar el código en `verify-email-otp` contra el código almacenado en el flow.
- Deshabilitar temporalmente el endpoint `POST /auth/verify-phone` y el flag `phoneVerificationRequired`.
- Reemplazar todos los textos visibles al usuario con "OTP" por "código de seguridad".
- Agregar Mailpit al `docker-compose.yml` de la raíz para desarrollo local.
- Agregar variables SMTP a `.env.example` y documentar su uso.

**Non-Goals:**
- Implementar proveedor SMS (Twilio, etc.) ni reactivar verificación por teléfono.
- Implementar lógica de expiración de OTP, reintentos o rate-limiting (queda para futura iteración).
- Soporte de plantillas HTML complejas de e-mail (texto plano es suficiente).
- Cambiar la lógica de negocio del registro más allá de lo necesario para el envío de e-mail.

## Decisions

### 1. Librería SMTP: `nodemailer`

**Decisión**: Usar `nodemailer` directamente, sin wrapper de NestJS (`@nestjs-modules/mailer`).

**Alternativas consideradas**:
- `@nestjs-modules/mailer` (Handlebars/EJS templates): añade complejidad innecesaria para e-mails de texto plano. Dependency adicional con menor mantenimiento.
- `resend`, `SendGrid SDK`: lock-in a proveedor externo, no compatible con SMTP local.

**Rationale**: `nodemailer` es el estándar de Node.js para SMTP, maduro, sin lock-in, funciona directamente con Mailpit y con cualquier proveedor que soporte SMTP. Mantiene la arquitectura simple.

### 2. Estructura: `MailerModule` con `MailerService` como abstracción de puerto

**Decisión**: Crear `apps/api/src/modules/mailer/` con:
- `mailer.module.ts` — módulo NestJS exportable
- `mailer.service.ts` — servicio con método `sendMail(to, subject, text)` usando `nodemailer`
- `mailer.config.ts` — lectura y validación de variables SMTP desde `ConfigService`

**Rationale**: Encapsula el SMTP en un módulo reutilizable. El `AuthModule` importa `MailerModule` sin conocer detalles de `nodemailer`. Permite mockear en tests.

### 3. Generación y almacenamiento del código de seguridad en `RegistrationFlow`

**Decisión**: Extender `RegistrationFlowEntity` con campos `emailOtpCode: string | null`. Generar el código en `RegisterUseCase` (6 dígitos, `Math.random` o `crypto.randomInt`) y persistirlo en el flow. Validar en `VerifyEmailOtpUseCase` comparando `input.otpCode === flow.emailOtpCode`.

**Alternativas consideradas**:
- Redis/cache separado: añade dependencia de infraestructura. La tabla `registration_flow` ya existe y tiene TTL implícito por el proceso de registro.
- JWT firmado en el e-mail: no compatible con el contrato actual `POST /auth/verify-email { otpCode }`.

**Rationale**: Mínimo cambio de infraestructura. La entidad `RegistrationFlow` ya es el estado del flujo de registro; agregar `emailOtpCode` es natural.

### 4. Desactivación de SMS: feature-flag por variable de entorno + `503` en endpoint

**Decisión**: Introducir variable `PHONE_VERIFICATION_ENABLED=false`. En `RegisterUseCase` devolver `phoneVerificationRequired: false` cuando la variable esté en `false`. En `AuthController`, el endpoint `POST /auth/verify-phone` devuelve `503 Service Unavailable` con mensaje `"Phone verification is temporarily disabled"` cuando `PHONE_VERIFICATION_ENABLED=false`.

**Alternativas consideradas**:
- Eliminar el endpoint: rompe compatibilidad si el frontend lo llama; dificulta reactivación futura.
- Solo flag sin 503: el frontend podría llamar al endpoint igualmente y recibir éxito falso.

**Rationale**: La respuesta `503` es semánticamente correcta (servicio existente pero temporalmente no disponible). El código del use case permanece intacto; solo el controlador añade el guard. Fácil de reactivar cambiando la variable.

### 5. Mailpit en `docker-compose.yml` raíz

**Decisión**: Agregar servicio `mailpit` al `docker-compose.yml` de la raíz con imagen `axllent/mailpit`. Puerto `1025` para SMTP, puerto `8025` para la UI web.

**Alternativas consideradas**:
- MailHog: menos mantenido (último release 2021), sin TLS simulado, UI más limitada.
- Papercut: solo Windows nativo.

**Rationale**: Mailpit es el sucesor activo de MailHog. Imagen oficial Docker pequeña, SMTP en 1025, UI moderna en 8025. Se integra directamente con `nodemailer` sin configuración TLS.

### 6. Configuración SMTP con Zod en `env.validation.ts`

**Decisión**: Agregar al schema Zod las variables `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`, `SMTP_SECURE` y `PHONE_VERIFICATION_ENABLED`. `SMTP_HOST`, `SMTP_PORT` y `SMTP_FROM` son **requeridas**. Si faltan, la aplicación no arranca (Zod lanza error en bootstrap).

**Rationale**: Consistente con el patrón existente del proyecto. Falla rápido y controlado en startup, nunca en runtime al intentar enviar.

### 7. Textos "OTP" → "código de seguridad"

**Decisión**: Buscar y reemplazar en el frontend Angular (templates, i18n/translations, mensajes de validación). Los nombres técnicos internos (`otpCode`, `emailOtpCode`, `VerifyEmailOtpUseCase`) **no se renombran** para no romper el contrato de API ni las migraciones.

**Rationale**: El contrato de API ya está en producción (spec `anyjobs-back/auth` usa `otpCode`). Cambiar el nombre técnico requeriría versionar la API. El cambio de texto visible es solo UI/UX.

## Risks / Trade-offs

- **[Riesgo] El código de seguridad no expira** → Mitigación: documentar como deuda técnica; el flow de registro ya tiene un TTL de sesión implícito. El riesgo de seguridad es bajo en un entorno local/MVP.
- **[Riesgo] `crypto.randomInt` no disponible en Node < 14.10** → Mitigación: `anyjobs-back` usa Node 20+; verificado en package.json engines.
- **[Trade-off] E-mail en texto plano** → Acepta la limitación para el MVP; se puede agregar HTML en futura iteración sin cambiar la interfaz de `MailerService`.
- **[Riesgo] Frontend llama a `POST /auth/verify-phone` si no se oculta la UI de SMS** → Mitigación: la tarea de frontend debe ocultar la opción SMS antes de que el backend devuelva `503`; el `503` es el último respaldo.

## Migration Plan

1. Agregar `nodemailer` + `@types/nodemailer` al `package.json` de `anyjobs-back`.
2. Crear migración TypeORM para agregar columna `email_otp_code` a `registration_flow`.
3. Actualizar `env.validation.ts` y `configuration.ts` con variables SMTP + `PHONE_VERIFICATION_ENABLED`.
4. Crear `MailerModule` / `MailerService`.
5. Modificar `RegisterUseCase` para generar código y llamar al mailer.
6. Modificar `VerifyEmailOtpUseCase` para validar el código almacenado.
7. Modificar `AuthController` para el guard de `verify-phone`.
8. Actualizar `docker-compose.yml` raíz con servicio Mailpit.
9. Actualizar `.env.example` con variables SMTP apuntando a Mailpit local.
10. Frontend: reemplazar textos "OTP" → "código de seguridad" y ocultar UI de verificación por SMS.

**Rollback**: Revertir el flag `PHONE_VERIFICATION_ENABLED` a `true` activa el endpoint. El mailer puede desconectarse cambiando `SMTP_HOST` a un valor inválido (el sistema fallará en registro, no en runtime silencioso).

## Open Questions

- ¿El frontend debe mostrar un mensaje de "verificación por teléfono próximamente disponible" o simplemente ocultarlo sin explicación? → Decisión de UX; el spec lo deja como "oculto/no disponible".
- ¿Se debe limitar el número de reenvíos del código de seguridad? → Fuera de scope de este cambio.
