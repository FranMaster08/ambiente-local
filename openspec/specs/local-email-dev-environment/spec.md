## Purpose

Entorno local de desarrollo con Mailpit en Docker para capturar y revisar correos enviados por el backend.

## Requirements

### Requirement: El entorno Docker local MUST incluir un servicio Mailpit para capturar e-mails
El sistema MUST agregar el servicio `mailpit` al `docker-compose.yml` de la raíz usando la imagen `axllent/mailpit`. El servicio MUST levantarse junto con el resto del stack local.

#### Scenario: Stack local levantado incluye Mailpit
- **WHEN** el desarrollador ejecuta `docker compose up` desde la raíz del proyecto
- **THEN** el sistema MUST levantar el servicio `mailpit` junto con `postgres`, `anyjobs-back` y `anyjobs-front`

### Requirement: Mailpit MUST exponer puerto SMTP en 1025 y UI web en 8025
El servicio Mailpit MUST mapear:

- Puerto `1025` del contenedor al host para recibir e-mails SMTP.
- Puerto `8025` del contenedor al host para acceder a la interfaz web de revisión de correos.

#### Scenario: Aplicación backend envía e-mail al SMTP local
- **WHEN** el backend tiene configurado `SMTP_HOST=mailpit` y `SMTP_PORT=1025`
- **THEN** el sistema MUST entregar el e-mail al contenedor Mailpit sin errores de conexión

#### Scenario: Desarrollador accede a la UI de Mailpit
- **WHEN** el desarrollador abre `http://localhost:8025` en el navegador con el stack levantado
- **THEN** el sistema MUST mostrar la interfaz web de Mailpit con los correos capturados

### Requirement: Las variables de entorno locales MUST apuntar al SMTP de Mailpit por defecto
El archivo `.env.example` de `anyjobs-back` MUST incluir valores SMTP pre-configurados para usar Mailpit en desarrollo local:

- `SMTP_HOST=mailpit`
- `SMTP_PORT=1025`
- `SMTP_FROM=noreply@anyjobs.local`
- `SMTP_USER=` (vacío)
- `SMTP_PASSWORD=` (vacío)
- `SMTP_SECURE=false`

#### Scenario: Desarrollador copia .env.example y levanta el stack
- **WHEN** el desarrollador copia `.env.example` a `.env` y ejecuta `docker compose up`
- **THEN** el backend MUST conectarse a Mailpit sin configuración adicional y MUST poder enviar e-mails al registro de nuevo usuario

### Requirement: La documentación MUST explicar cómo usar el entorno local de e-mails
El `README` del proyecto o la documentación de Docker MUST incluir:

- Cómo levantar el stack local con `docker compose up`
- La URL de la interfaz web de Mailpit (`http://localhost:8025`)
- Instrucciones para crear un usuario nuevo y verificar que el e-mail aparece en Mailpit
- Las variables de entorno necesarias para conectar el backend a Mailpit

#### Scenario: Desarrollador nuevo puede probar el flujo de verificación de e-mail
- **WHEN** el desarrollador sigue las instrucciones del README y levanta el entorno
- **THEN** el sistema MUST permitir registrar un usuario y ver el correo de verificación capturado en la UI de Mailpit en `http://localhost:8025`
