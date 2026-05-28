## Purpose

Módulo reutilizable de envío de correos vía SMTP en el backend NestJS (`MailerModule` / `MailerService`).

## Requirements

### Requirement: El sistema MUST proveer un MailerModule reutilizable para envío de e-mails
El sistema MUST implementar un módulo NestJS `MailerModule` en `apps/api/src/modules/mailer/` que encapsule la lógica de envío de correos vía SMTP usando `nodemailer`. El módulo MUST ser importable por cualquier otro módulo de la aplicación.

#### Scenario: AuthModule importa MailerModule sin conocer detalles de nodemailer
- **WHEN** el `AuthModule` necesita enviar un e-mail
- **THEN** el sistema MUST permitir inyectar `MailerService` en cualquier use case o servicio sin importar directamente `nodemailer`

### Requirement: MailerService MUST exponer un método sendMail con parámetros to, subject y text
El sistema MUST exponer en `MailerService` un método `sendMail(to: string, subject: string, text: string): Promise<void>` que envíe un correo electrónico al destinatario indicado con el asunto y cuerpo de texto plano especificados.

#### Scenario: Envío de e-mail exitoso
- **WHEN** se llama a `sendMail` con un `to` válido, `subject` y `text` no vacíos
- **THEN** el sistema MUST entregar el e-mail al servidor SMTP configurado sin lanzar excepciones

#### Scenario: Fallo de conexión SMTP se propaga como error controlado
- **WHEN** el servidor SMTP no está disponible o rechaza la conexión
- **THEN** el sistema MUST lanzar una excepción con mensaje descriptivo y MUST NOT silenciar el error

### Requirement: La configuración SMTP MUST leerse exclusivamente de variables de entorno
El sistema MUST leer la configuración SMTP desde las siguientes variables de entorno, sin valores hardcodeados:

- `SMTP_HOST` (requerida): host del servidor SMTP
- `SMTP_PORT` (requerida): puerto del servidor SMTP (número entero)
- `SMTP_FROM` (requerida): dirección del remitente (ej: `noreply@example.com`)
- `SMTP_USER` (opcional): usuario SMTP para autenticación
- `SMTP_PASSWORD` (opcional): contraseña SMTP para autenticación
- `SMTP_SECURE` (opcional, default `false`): si usar TLS (`true`) o no (`false`)

#### Scenario: Variables requeridas presentes — aplicación arranca
- **WHEN** las variables `SMTP_HOST`, `SMTP_PORT` y `SMTP_FROM` están definidas en el entorno
- **THEN** el sistema MUST inicializar `MailerService` correctamente y la aplicación MUST arrancar

#### Scenario: Variable requerida ausente — aplicación NO arranca
- **WHEN** alguna de las variables `SMTP_HOST`, `SMTP_PORT` o `SMTP_FROM` está ausente o vacía
- **THEN** el sistema MUST lanzar un error de configuración durante el bootstrap y MUST NOT arrancar la aplicación

### Requirement: La validación de variables SMTP MUST integrarse con el schema Zod existente
El sistema MUST agregar las variables SMTP (`SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_SECURE`) al schema de validación Zod en `apps/api/src/config/env.validation.ts`. Las variables requeridas MUST usar `.min(1)` o equivalente. Las variables opcionales MUST usar `.optional()`.

#### Scenario: Schema Zod rechaza configuración incompleta
- **WHEN** el proceso arranca sin `SMTP_HOST` definida
- **THEN** el módulo de configuración MUST lanzar un `ZodError` durante la validación de entorno, antes de que cualquier módulo de negocio se inicialice

### Requirement: MailerService MUST ser mockeable en tests sin conexión SMTP real
El sistema MUST diseñar `MailerService` como una clase inyectable que pueda sustituirse por un mock en los tests de otros módulos (p.ej. `AuthModule`) sin necesitar un servidor SMTP disponible.

#### Scenario: Test de RegisterUseCase con MailerService mockeado
- **WHEN** se ejecuta un test unitario de `RegisterUseCase`
- **THEN** el sistema MUST permitir proveer un `MailerService` mock que no intente conexión SMTP real y el test MUST verificar que `sendMail` fue llamado con los parámetros esperados
