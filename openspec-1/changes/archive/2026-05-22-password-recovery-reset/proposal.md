## Why

Los usuarios que olvidan su contraseña no tienen forma de recuperar el acceso: no existe flujo de solicitud por correo, ni persistencia de tokens temporales, ni página en el frontend para definir una nueva contraseña. Esto bloquea cuentas activas y genera soporte manual innecesario. El proyecto ya dispone de `MailerService` y plantillas HTML alineadas con la marca; es el momento de reutilizarlos para un flujo seguro de recuperación sin romper login, registro ni verificación de email existentes.

## What Changes

- Nuevo modelo persistente de tokens de recuperación (un solo uso, expiración exacta de 15 minutos, asociados a usuario).
- `POST /auth/forgot-password`: solicitud por email con respuesta genérica anti-enumeración; invalidación de tokens activos previos del mismo usuario; envío de correo con enlace al frontend.
- `POST /auth/reset-password`: validación de token, contraseña fuerte, actualización con `ScryptPasswordHasher` existente y marcado del token como usado.
- Nueva plantilla de correo de recuperación (sin códigos OTP ni textos de registro).
- Variable de entorno `FRONTEND_PUBLIC_URL` para construir el enlace del correo.
- Nueva ruta y página Angular `/recuperar-contrasena` con formulario (contraseña + confirmación), estados de carga/éxito/error y redirección al login.
- Enlace «¿Olvidaste tu contraseña?» desde el modal de login hacia la solicitud de recuperación (página o flujo dedicado según diseño).
- Tests e2e/unitarios alineados con el estándar del módulo auth.

## Capabilities

### New Capabilities

- `password-recovery`: Flujo completo de recuperación (tokens, endpoints, correo, reglas de seguridad y validaciones obligatorias).
- `anyjobs-front/password-reset-page`: Página de restablecimiento que lee el token desde la URL, valida contraseñas en cliente y consume `POST /auth/reset-password`.

### Modified Capabilities

- `anyjobs-back/auth`: Contrato API con `POST /auth/forgot-password` y `POST /auth/reset-password` bajo `/auth`, públicos (`@Public()`), sin alterar endpoints existentes.
- `anyjobs-front/user-login-session`: Punto de entrada desde el modal de login hacia la solicitud de recuperación.

## Impact

- **Backend (`anyjobs-back`)**: Nueva entidad/migración TypeORM, repositorio, use cases, DTOs, controlador auth, plantilla en `email-templates.ts`, `env.validation.ts` / `configuration.ts` (`FRONTEND_PUBLIC_URL`). Sin nuevo sistema de mail.
- **Frontend (`anyjobs-front/anyjobs`)**: Nueva feature bajo `features/auth/`, ruta en `app.routes.ts`, cliente API en `shared/api/auth.api.ts`, reutilización de `strongPasswordValidator` y tokens de diseño (`styles.scss`, `fieldLabel`, `fieldControl`, `.btn`).
- **Infra**: Actualizar `.env.example` en backend con `FRONTEND_PUBLIC_URL`.
- **Sin impacto** en registro, verificación de email por código, login Bearer, ni `MailerService` base salvo nueva plantilla y llamadas desde forgot-password.
