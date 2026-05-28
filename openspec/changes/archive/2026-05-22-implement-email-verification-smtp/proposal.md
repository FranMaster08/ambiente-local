## Why

El flujo de registro de usuario llega a una etapa de verificación de e-mail que actualmente no tiene implementación real: no existe ningún servicio que envíe correos por SMTP, por lo que ningún usuario puede completar la verificación de su cuenta. Además, la verificación por teléfono/SMS está referenciada en el flujo pero no puede usarse en este momento, y los textos visibles al usuario muestran "OTP" en lugar de un término comprensible.

## What Changes

- Se crea un servicio SMTP reutilizable en el backend para enviar e-mails mediante configuración por variables de entorno.
- Se integra el envío real de e-mail con código de seguridad al flujo de registro/verificación de usuario en el backend.
- Se deshabilita temporalmente el flujo de verificación por teléfono/SMS (back y front), sin eliminar el código estructural.
- Se reemplazan todos los textos visibles al usuario con "OTP" por "código de seguridad" (labels, placeholders, mensajes de error/éxito, e-mails, traducciones).
- Se agrega un servicio Docker local (Mailpit) para capturar e-mails en entorno de desarrollo.
- Se actualizan `.env.example` y documentación con las variables SMTP necesarias y cómo usar el entorno local.

## Capabilities

### New Capabilities

- `smtp-email-service`: Servicio backend reutilizable para envío de e-mails vía SMTP. Configurable por variables de entorno (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`, `SMTP_SECURE`). Valida configuración antes de enviar y falla de forma controlada si faltan variables.
- `local-email-dev-environment`: Configuración Docker con Mailpit (o equivalente) que expone puerto SMTP para la app y una interfaz web para inspeccionar correos capturados en local.

### Modified Capabilities

- `anyjobs-back/auth`: El endpoint `POST /auth/register` pasa a disparar el envío real de e-mail con código de seguridad al usuario. El campo `phoneVerificationRequired` MUST retornar `false` mientras la verificación por SMS esté deshabilitada. El endpoint `POST /auth/verify-phone` queda deshabilitado temporalmente (responde `503` o se omite del contrato activo).
- `anyjobs-front/user-contact-verification`: La verificación por teléfono queda deshabilitada visualmente (oculta o marcada como no disponible). El texto "OTP" en labels, placeholders y mensajes se reemplaza por "código de seguridad". El requisito de `phoneVerified` para avanzar como WORKER queda suspendido mientras SMS esté deshabilitado.
- `anyjobs-front/user-registration`: El requisito de teléfono verificado (`phoneVerified === true`) para usuarios `WORKER` queda suspendido temporalmente. La UI no debe mostrar ni solicitar verificación por SMS en ningún paso del flujo.

## Impact

- **Backend**: Nuevo módulo/servicio SMTP en `anyjobs-back`. Integración con el módulo de auth/registro. Variables de entorno SMTP agregadas a la configuración. Endpoint `POST /auth/verify-phone` deshabilitado temporalmente.
- **Frontend**: Componente de verificación de contacto (`user-contact-verification`). Todos los textos visibles con "OTP" en cualquier componente, traducción o mensaje. Lógica de gating que bloquea a WORKERs sin teléfono verificado.
- **Infra/Docker**: `docker-compose.yml` (o equivalente) con servicio Mailpit. Variables SMTP apuntando al SMTP local para desarrollo.
- **Documentación**: `.env.example`, README o doc de Docker con instrucciones de levantado local y acceso a la interfaz de correos.
- **Tests**: Tests unitarios del servicio SMTP. Tests del disparo de e-mail al registrar usuario. Tests de desactivación de SMS. Tests de textos visibles.
