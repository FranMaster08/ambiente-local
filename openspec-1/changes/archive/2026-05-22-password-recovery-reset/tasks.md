## 1. Exploración y configuración

- [x] 1.1 Confirmar convenciones en `auth.module.ts`, `UserEntity`, `MailerService` y `email-templates.ts`
- [x] 1.2 Agregar `FRONTEND_PUBLIC_URL` a `env.validation.ts`, `configuration.ts` y `anyjobs-back/.env.example` (sin barra final)

## 2. Persistencia backend

- [x] 2.1 Crear migración TypeORM `password_reset_tokens` (`user_id`, `token_hash`, `expires_at`, `used_at`, `created_at`)
- [x] 2.2 Implementar `PasswordResetTokenEntity` y adapter/repositorio TypeORM
- [x] 2.3 Implementar hash de token (SHA-256 del valor URL-safe) y generación con `crypto.randomBytes`

## 3. Use cases y API auth

- [x] 3.1 `RequestPasswordResetUseCase`: normalizar email, buscar usuario ACTIVE, invalidar tokens activos, crear token 15 min, enviar mail
- [x] 3.2 `ResetPasswordUseCase`: validar token (existe, no usado, no expirado), validar contraseña fuerte, hashear con `ScryptPasswordHasher`, marcar usado en transacción
- [x] 3.3 DTOs `ForgotPasswordRequestDto`, `ResetPasswordRequestDto` con class-validator
- [x] 3.4 Exponer `POST /auth/forgot-password` y `POST /auth/reset-password` en `AuthController` (`@Public()`)
- [x] 3.5 Respuestas genéricas anti-enumeración y errores sin filtrar datos sensibles

## 4. Correo

- [x] 4.1 Crear `buildPasswordRecoveryEmailHtml(fullName, resetUrl)` (sin OTP, copy de 15 minutos)
- [x] 4.2 Integrar envío en forgot-password (asunto, texto plano + HTML)

## 5. Tests backend

- [x] 5.1 Unit tests: use cases (token expirado, usado, invalidación previa, email inexistente)
- [x] 5.2 E2E: forgot → reset → login con nueva contraseña; login con antigua falla; token reutilizado falla

## 6. Frontend

- [x] 6.1 Agregar métodos en `auth.api.ts`: `forgotPassword`, `resetPassword`
- [x] 6.2 Crear feature `password-recovery` (modo email / modo token según query)
- [x] 6.3 Registrar ruta `/recuperar-contrasena` en `app.routes.ts`
- [x] 6.4 Formulario reset: `strongPasswordValidator`, confirmación, estados loading/success/error
- [x] 6.5 Estilos alineados con registro/login (`fieldLabel`, `fieldControl`, `.btn`, tokens `--aj-*`)
- [x] 6.6 Enlace «¿Olvidaste tu contraseña?» en modal de login del `shell`
- [x] 6.7 Tests Vitest del componente (validación match, estados básicos) si el proyecto cubre auth UI

## 7. Validación manual obligatoria

- [x] 7.1 Correo existente → llega mail con enlace (Mailpit en dev)
- [x] 7.2 Correo inexistente → misma respuesta UI/API, sin correo
- [x] 7.3 Token >15 min → reset rechazado
- [x] 7.4 Token usado dos veces → segundo intento rechazado
- [x] 7.5 Segunda solicitud invalida primer enlace
- [x] 7.6 Login con nueva contraseña OK; anterior falla
- [x] 7.7 Vista desktop y mobile coherentes con la app
- [x] 7.8 Registro, verify-email, login y mails de registro sin regresión

## 8. Cierre OpenSpec

- [x] 8.1 Ejecutar `openspec verify --change password-recovery-reset` (o revisión manual si CLI no disponible)
- [ ] 8.2 Archivar/sync specs a main cuando implementación esté completa
