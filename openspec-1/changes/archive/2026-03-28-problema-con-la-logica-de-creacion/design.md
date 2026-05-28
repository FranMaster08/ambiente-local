## Context

El flujo actual de registro crea un `User` en el primer paso (`POST /auth/register`) y luego usa `registration_flow.userId` para continuar con verificaciones OTP y con los pasos posteriores de onboarding. Esto hace que exista una cuenta persistida desde el inicio, aunque el usuario todavia no haya completado ubicacion, perfiles por rol ni datos personales.

En backend, esta decision aparece en dos puntos:
- `RegisterUseCase` crea el usuario inmediatamente y despues genera el flow.
- `UserProfileController` resuelve los pasos de onboarding desde la cookie `aj_reg_flow`, pero finalmente carga y actualiza un `userId` ya existente.

En frontend, la pantalla de registro ya funciona como wizard multi-step y consume `register`, `verify-email`, `verify-phone` y luego endpoints de `users/me/*`. Sin embargo, el primer paso ya devuelve `userId`, lo que refuerza la idea de que la cuenta fue creada aunque el onboarding siga incompleto.

El cambio necesita mantener el flujo guiado actual, pero garantizar que la cuenta autenticable solo exista al finalizar todos los pasos obligatorios.

## Goals / Non-Goals

**Goals:**
- Evitar la creacion definitiva del usuario en el primer paso del registro.
- Mantener un estado persistente de onboarding entre pasos, usando el flow actual como identificador tecnico.
- Permitir verificaciones OTP y carga de datos intermedios sin requerir login.
- Crear el usuario final solo cuando el flujo tenga todas las verificaciones y datos obligatorios completos.
- Bloquear el login de registros incompletos o drafts no finalizados.

**Non-Goals:**
- Rediseñar la UX completa del wizard de registro.
- Cambiar la estrategia de OTP o introducir un proveedor nuevo de verificacion.
- Resolver en este cambio migraciones masivas de usuarios ya creados previamente.
- Unificar todo el dominio de onboarding y autenticacion en una sola refactorizacion amplia.

## Decisions

### 1. Separar el borrador de registro del usuario definitivo reutilizando `auth_registration_flows`

Se introducira un estado de registro persistente independiente del `User` definitivo, pero sin crear una tabla nueva. La implementacion reutiliza `auth_registration_flows` como fuente de verdad del onboarding y la expande para almacenar los datos del draft mientras el registro este incompleto.

Esto implica que `POST /auth/register`:
- valida email y telefono contra usuarios definitivos y drafts activos,
- guarda los datos iniciales del registro en el flow/draft,
- emite la cookie `aj_reg_flow`,
- devuelve estado del onboarding, pero no un `userId` definitivo.

Implementacion aplicada:
- `auth_registration_flows` ahora guarda identidad inicial, password hash, roles, verificaciones, datos intermedios del wizard, `nextStage`, `expiresAt` y `completedAt`;
- `userId` pasa a ser opcional y solo se completa cuando el usuario definitivo se crea;
- se agrego una migracion incremental para soportar bases existentes;
- la entidad de flow usa una definicion de fechas compatible con `postgres` en runtime y `sqljs` en tests end-to-end, para evitar divergencias entre motores.

Rationale:
- modela correctamente la regla de negocio: completar onboarding no es lo mismo que existir como usuario activo;
- evita cuentas huerfanas o incompletas en la tabla de usuarios;
- permite expirar o limpiar registros abandonados sin afectar usuarios reales.

Alternativas consideradas:
- Mantener `User` en estado `PENDING`: se descarta porque sigue creando una cuenta real en el primer paso, que es precisamente el problema funcional a corregir.
- Crear el usuario y luego borrarlo si no termina el flujo: se descarta por complejidad operativa, riesgo de datos huérfanos y efectos colaterales en auditoria/duplicados.

### 2. Reusar la cookie de flow para todo el onboarding no autenticado

La cookie `aj_reg_flow` seguira siendo el mecanismo para correlacionar las acciones del wizard antes de la autenticacion. Las verificaciones OTP y los pasos de perfil/ubicacion/personal info operaran sobre el draft asociado al flow, no sobre `users/me` resuelto desde un usuario ya creado.

En la practica, hay dos opciones validas de implementacion:
- adaptar los endpoints existentes de `users/me/*` para que, cuando haya `aj_reg_flow` sin token, actualicen el draft; o
- introducir endpoints de onboarding dedicados (`/auth/registration/*`) y dejar `users/me/*` para usuarios ya autenticados.

La decision propuesta es introducir endpoints de onboarding dedicados. Esto separa claramente responsabilidades:
- `auth/registration/*` para datos previos a la creacion del usuario;
- `users/me/*` para perfiles de usuarios ya creados y autenticados.

Implementacion aplicada:
- `PATCH /auth/registration/location`
- `PATCH /auth/registration/worker-profile`
- `PATCH /auth/registration/client-profile`
- `PATCH /auth/registration/personal-info`
- `POST /auth/registration/complete`

Rationale:
- evita sobrecargar `users/me` con dos modelos de identidad distintos;
- hace mas explicito el contrato entre frontend y backend;
- reduce ambiguedad en permisos y resolucion de contexto.

Alternativa considerada:
- Reusar `users/me/*` con branching interno por cookie/token: es mas barata en el corto plazo, pero mezcla onboarding anonimo con perfil autenticado y complica la evolucion futura.

### 3. Finalizar el usuario en un paso explicito de cierre

Cuando el draft cumpla todas las condiciones obligatorias, backend ejecutara una finalizacion atomica:
- valida nuevamente unicidad de email/telefono,
- crea el `User`,
- crea/actualiza la informacion asociada de perfil,
- marca el flow como completado/finalizado,
- opcionalmente limpia datos sensibles del draft que ya no se necesiten.

La finalizacion puede ocurrir en el ultimo paso del wizard o en un endpoint dedicado de `complete-registration`. La recomendacion es usar un endpoint explicito de finalizacion para que el frontend tenga una transicion clara entre "flujo incompleto" y "cuenta creada".

Implementacion aplicada:
- el frontend invoca `completeRegistration()` de forma explicita;
- para `CLIENT`, el cierre puede ocurrir sin datos personales adicionales;
- para `WORKER`, la finalizacion exige telefono verificado, categorias y datos personales requeridos.
- el cierre final se ejecuta dentro de una transaccion de TypeORM para que la creacion del usuario y el marcado del flow como completado ocurran como una sola unidad consistente.

Rationale:
- concentra la consistencia en una sola transaccion o unidad de trabajo;
- evita estados parcialmente creados entre el ultimo PATCH y la activacion del usuario;
- facilita retries controlados y validaciones finales.

Alternativa considerada:
- Crear el usuario implicitamente en el ultimo PATCH: funciona, pero hace menos visible el cambio de estado y complica la semantica de errores del ultimo paso.

### 4. El login solo debe aceptar usuarios finalizados

`LoginUseCase` debe autenticar unicamente usuarios definitivos y habilitados. Los drafts de onboarding no deben ser visibles para login porque no existiran en el repositorio de usuarios, y los usuarios existentes con estado no finalizado tampoco deben emitir token.

Rationale:
- refuerza la regla de negocio en la capa de autenticacion;
- evita accesos parciales con perfiles incompletos;
- simplifica el modelo mental: solo hay sesion cuando ya existe una cuenta completa.

Implementacion aplicada:
- `LoginUseCase` rechaza credenciales de usuarios cuyo `status` no sea `ACTIVE`.

Alternativa considerada:
- Permitir login parcial y restringir acciones despues: se descarta porque reintroduce la confusion entre draft y usuario real.

### 5. El frontend debe modelar “registro en progreso”, no “sesion de usuario”

La feature de `registration` debe dejar de depender de `userId` como señal de creacion. El estado del wizard debe derivarse de:
- `stage`,
- flags de verificacion,
- estado de completitud del draft,
- respuesta del endpoint final de cierre.

Hasta que el backend confirme la finalizacion, el frontend no debe crear sesion ni asumir que existe un usuario autenticable. En la implementacion actual, el flujo no inicia sesion automaticamente: despues de completar el onboarding, la siguiente accion esperada sigue siendo autenticarse manualmente.

Rationale:
- alinea la UI con la regla de negocio;
- evita tratar un draft como cuenta valida;
- reduce errores de navegacion o mensajes engañosos del tipo "usuario creado" antes de tiempo.

## Risks / Trade-offs

- [Mayor complejidad del modelo de onboarding] -> Mitigar centralizando el draft en una unica abstraccion (`registration flow` o `registration draft`) con reglas claras de transicion de estado.
- [Cambios de contrato entre frontend y backend] -> Mitigar versionando DTOs y actualizando primero el contrato del wizard antes de tocar pantallas no relacionadas.
- [Colision de unicidad si otro usuario toma email/telefono antes de finalizar] -> Mitigar con validacion inicial y revalidacion obligatoria en el paso de finalizacion.
- [Flows abandonados ocupando datos temporales] -> Mitigar guardando `expiresAt` en el draft y dejando preparada una futura limpieza operativa de registros vencidos.
- [Regresiones en endpoints actuales de perfil] -> Mitigar separando endpoints de onboarding y conservando `users/me/*` para usuarios autenticados.

## Migration Plan

1. Extender `auth_registration_flows` para almacenar datos del registro incompleto sin requerir `userId`.
2. Cambiar `POST /auth/register` para crear/actualizar el draft y devolver estado del flow sin crear usuario definitivo.
3. Mover verificaciones OTP y pasos posteriores del wizard a endpoints que operen sobre el draft.
4. Implementar un endpoint de finalizacion que cree el usuario y sus perfiles asociados de forma atomica.
5. Ajustar el frontend para usar el nuevo contrato y eliminar cualquier dependencia de `userId` antes del cierre.
6. Endurecer login y validaciones para aceptar solamente usuarios finalizados.
7. Agregar `expiresAt` al draft, una migracion incremental para bases existentes y pruebas end-to-end del flujo completo.
8. Garantizar que la definicion de columnas de fecha del draft sea portable entre `postgres` y `sqljs`, para mantener consistencia entre runtime y test suite.

Rollback:
- mantener temporalmente el codigo viejo detras de una bandera de despliegue o por compatibilidad de endpoint;
- si el nuevo flujo falla, volver a la implementacion anterior de registro mientras se preservan los usuarios ya finalizados.

## Open Questions

- ¿Hace falta un proceso programado para borrar drafts vencidos o alcanza con tratarlos como expirados a nivel funcional?
- ¿Es necesario migrar o depurar usuarios `PENDING` ya existentes creados por el flujo anterior?
