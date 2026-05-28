## 1. Configuración y dependencias del backend

- [x] 1.1 Agregar `nodemailer` y `@types/nodemailer` al `package.json` de `anyjobs-back`
- [x] 1.2 Agregar las variables `SMTP_HOST`, `SMTP_PORT`, `SMTP_FROM`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_SECURE` y `PHONE_VERIFICATION_ENABLED` al schema Zod en `apps/api/src/config/env.validation.ts`
- [x] 1.3 Agregar el mapeo de las variables SMTP y `PHONE_VERIFICATION_ENABLED` al objeto de configuración tipado en `apps/api/src/config/configuration.ts`

## 2. Módulo MailerService

- [x] 2.1 Crear directorio `apps/api/src/modules/mailer/`
- [x] 2.2 Implementar `mailer.service.ts` con método `sendMail(to: string, subject: string, text: string): Promise<void>` usando `nodemailer` y leyendo la configuración SMTP vía `ConfigService`
- [x] 2.3 Crear `mailer.module.ts` que declare y exporte `MailerService`
- [x] 2.4 Escribir tests unitarios de `MailerService` mockeando el `transporter` de nodemailer para verificar el envío correcto y el fallo controlado

## 3. Generación y almacenamiento del código de seguridad

- [x] 3.1 Crear migración TypeORM para agregar columna `email_otp_code VARCHAR(6) NULL` a la tabla `registration_flow`
- [x] 3.2 Actualizar la entidad `RegistrationFlowEntity` con el campo `emailOtpCode: string | null`
- [x] 3.3 Actualizar el puerto `IRegistrationFlowStore` y la implementación `TypeOrmRegistrationFlowStore` para soportar lectura y escritura de `emailOtpCode`

## 4. Integración del envío de e-mail en el registro

- [x] 4.1 Importar `MailerModule` en `AuthModule`
- [x] 4.2 Modificar `RegisterUseCase` para generar un código de seguridad de 6 dígitos con `crypto.randomInt(100000, 999999)`, almacenarlo en el flow y llamar a `MailerService.sendMail` con asunto `"Tu código de seguridad"` y el código en el cuerpo
- [x] 4.3 Asegurar que si `MailerService.sendMail` lanza un error, el `RegisterUseCase` lo propague como error controlado (no silencioso)
- [x] 4.4 Actualizar `RegisterUseCase` para devolver siempre `phoneVerificationRequired: false` cuando `PHONE_VERIFICATION_ENABLED=false`
- [x] 4.5 Escribir tests unitarios de `RegisterUseCase` con `MailerService` mockeado, verificando que `sendMail` se invoca con los argumentos correctos

## 5. Validación del código de seguridad en verificación de e-mail

- [x] 5.1 Modificar `VerifyEmailOtpUseCase` para comparar `input.otpCode` con `flow.emailOtpCode` almacenado
- [x] 5.2 Si el código no coincide, lanzar `BadRequestException` con mensaje `"Código de seguridad incorrecto"`
- [x] 5.3 Escribir tests unitarios de `VerifyEmailOtpUseCase` para los escenarios: código correcto (éxito), código incorrecto (400), flow no encontrado (401)

## 6. Desactivación temporal de la verificación por SMS

- [x] 6.1 Modificar `AuthController` para que `POST /auth/verify-phone` devuelva `503` con `{ "message": "Phone verification is temporarily disabled" }` cuando `PHONE_VERIFICATION_ENABLED=false`
- [x] 6.2 Verificar que el use case `VerifyPhoneOtpUseCase` no se llama cuando el endpoint devuelve `503`
- [x] 6.3 Agregar test e2e o de integración que confirme la respuesta `503` de `POST /auth/verify-phone` con el flag deshabilitado

## 7. Docker y entorno local

- [x] 7.1 Agregar servicio `mailpit` al `docker-compose.yml` de la raíz con imagen `axllent/mailpit`, puerto `1025` (SMTP) y `8025` (UI web)
- [x] 7.2 Agregar variable de entorno `SMTP_HOST=mailpit` al servicio `anyjobs-back` en el `docker-compose.yml` de la raíz junto al resto de variables SMTP apuntando a Mailpit
- [x] 7.3 Actualizar `anyjobs-back/.env.example` con las variables SMTP pre-configuradas para Mailpit local y la variable `PHONE_VERIFICATION_ENABLED=false`

## 8. Frontend — textos y UI de verificación

- [x] 8.1 Buscar todas las apariciones de "OTP" en el frontend Angular (templates, i18n, mensajes de error, títulos, placeholders) y reemplazarlas por "código de seguridad"
- [x] 8.2 Ocultar o deshabilitar la opción de verificación por teléfono/SMS en el componente de verificación de contacto cuando `phoneVerificationRequired === false`
- [x] 8.3 Actualizar la lógica de gating del flujo de registro para que la etapa de verificación de teléfono no sea obligatoria cuando `phoneVerificationRequired === false`
- [x] 8.4 Verificar que el campo `phoneNumber` y su validador asíncrono `phoneTaken` no bloquean el avance cuando la verificación por SMS está deshabilitada
- [x] 8.5 Conectar `onAccountContinue()` a `POST /auth/register` (envía el e-mail) y `verifyEmail()` a `POST /auth/verify-email` (valida el código)

## 9. Documentación

- [x] 9.1 Agregar sección en el `README` (raíz o `anyjobs-back`) explicando cómo levantar el entorno con Mailpit, la URL de la UI (`http://localhost:8025`) y el flujo de verificación de e-mail local
- [x] 9.2 Verificar que `.env.example` incluye todos los valores SMTP necesarios con comentarios claros

## 10. Validación final

- [x] 10.1 Verificar que el proyecto backend compila sin errores tras todos los cambios (`npm run build` o equivalente)
- [x] 10.2 Ejecutar los tests existentes del backend y confirmar que no hay regresiones (2 fallas pre-existentes no relacionadas con este cambio)
- [ ] 10.3 Levantar el stack local con `docker compose up`, registrar un usuario nuevo y confirmar que el correo de verificación aparece en `http://localhost:8025`
- [ ] 10.4 Confirmar que `POST /auth/verify-phone` devuelve `503` en el stack local
- [ ] 10.5 Confirmar que el frontend no muestra la palabra "OTP" en ningún texto visible al usuario
