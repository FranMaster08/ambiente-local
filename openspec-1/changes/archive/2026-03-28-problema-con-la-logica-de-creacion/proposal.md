## Why

Hoy el flujo de alta de usuario crea una cuenta persistida apenas se completa el primer paso con el email. Eso rompe la regla de negocio esperada, porque el usuario no deberia existir ni poder autenticarse hasta haber completado todos los pasos obligatorios del proceso.

## What Changes

- Cambiar el flujo de registro para que el usuario no se cree de forma definitiva en el primer paso.
- Exigir que todos los pasos obligatorios del alta se completen antes de persistir la cuenta y habilitar la autenticacion.
- Reservar temporalmente email y telefono mientras exista un draft de onboarding activo para evitar duplicados durante el proceso.
- Ajustar la logica del backend para validar estados intermedios del registro y evitar usuarios incompletos.
- Ajustar el frontend para reflejar correctamente el estado pendiente del proceso y no tratar al usuario como creado antes de tiempo.

## Capabilities

### New Capabilities
- `registro-usuario-completo`: Define el flujo de creacion de usuario de punta a punta, asegurando que la cuenta solo se cree y quede autenticable cuando se completan todos los pasos obligatorios.

### Modified Capabilities
- Ninguna; actualmente no hay capacidades base en `openspec/specs/` para extender.

## Impact

- `anyjobs-back`: logica de registro, persistencia del usuario, validaciones de estado y reglas de autenticacion.
- `anyjobs-front`: flujo paso a paso de registro, manejo del estado parcial del alta y mensajes/UX asociados.
- APIs de registro/autenticacion: pueden requerir cambios en contratos o validaciones para representar usuarios pendientes versus usuarios completados.
- Persistencia y migraciones: expansion de `auth_registration_flows` para almacenar el draft completo de onboarding y soportar despliegue sobre bases ya existentes.
- Infraestructura de testing/runtime: compatibilidad de la persistencia del flow entre `postgres` y `sqljs`, y cierre transaccional del onboarding para evitar estados parciales.
