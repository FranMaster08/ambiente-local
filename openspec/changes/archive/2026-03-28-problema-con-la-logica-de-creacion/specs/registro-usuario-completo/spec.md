## ADDED Requirements

### Requirement: El registro inicial no crea un usuario definitivo
El sistema SHALL registrar el primer paso de alta como un flow o draft de onboarding y MUST NOT crear un usuario definitivo ni autenticable al recibir los datos iniciales de registro.

#### Scenario: Inicio de registro exitoso
- **WHEN** una persona envia nombre, email, telefono, password y roles validos al endpoint de inicio de registro
- **THEN** el sistema crea o actualiza un flow de onboarding, devuelve el estado inicial del proceso y no persiste una cuenta definitiva de usuario

#### Scenario: Respuesta del inicio de registro sin identidad definitiva
- **WHEN** el sistema responde a un inicio de registro exitoso
- **THEN** la respuesta representa el estado del onboarding y no expone un `userId` definitivo como señal de cuenta creada

### Requirement: La disponibilidad de credenciales contempla drafts activos
El sistema SHALL considerar no disponible un email o telefono cuando exista un draft de onboarding activo que ya este usando ese dato, aunque todavia no exista un usuario definitivo creado.

#### Scenario: Email reservado por un draft activo
- **WHEN** una persona consulta la disponibilidad de un email despues de que otro registro en progreso ya lo reservo en un flow activo
- **THEN** el sistema responde que ese email no esta disponible

#### Scenario: Telefono reservado por un draft activo
- **WHEN** una persona consulta la disponibilidad de un telefono despues de que otro registro en progreso ya lo reservo en un flow activo
- **THEN** el sistema responde que ese telefono no esta disponible

### Requirement: El onboarding incompleto se gestiona mediante identidad temporal
El sistema SHALL permitir que las verificaciones y los pasos intermedios del onboarding se ejecuten usando una identidad temporal asociada al flow de registro, sin requerir que exista un usuario definitivo ni una sesion autenticada.

#### Scenario: Verificacion OTP sobre flow temporal
- **WHEN** una persona envia un codigo OTP valido durante un registro en progreso
- **THEN** el sistema aplica la verificacion al flow activo asociado a la identidad temporal del onboarding

#### Scenario: Carga de datos intermedios sin usuario definitivo
- **WHEN** una persona completa pasos posteriores del wizard como ubicacion, perfil por rol o datos personales antes de finalizar el alta
- **THEN** el sistema guarda esos datos en el contexto del onboarding en progreso sin requerir un usuario definitivo ya creado

### Requirement: La cuenta se crea solo al completar todos los pasos obligatorios
El sistema SHALL crear la cuenta definitiva de usuario unicamente cuando el registro tenga completas las verificaciones obligatorias y todos los datos requeridos por el flujo y por los roles seleccionados.

#### Scenario: Finalizacion exitosa del onboarding
- **WHEN** una persona alcanza el paso final con todas las verificaciones y datos obligatorios completos
- **THEN** el sistema crea la cuenta definitiva, deja el registro marcado como finalizado y habilita el estado esperado para autenticacion posterior

#### Scenario: Intento de finalizacion con pasos faltantes
- **WHEN** una persona intenta finalizar el alta sin haber completado una verificacion obligatoria o un dato requerido
- **THEN** el sistema rechaza la finalizacion y mantiene el registro como incompleto

### Requirement: La finalizacion revalida unicidad y consistencia
El sistema SHALL revalidar email, telefono y consistencia del estado del onboarding en el momento de crear la cuenta definitiva para evitar duplicados o cierres invalidos.

#### Scenario: Conflicto de unicidad al finalizar
- **WHEN** el email o el telefono del registro en progreso ya no estan disponibles al momento de finalizar
- **THEN** el sistema rechaza la creacion del usuario definitivo e informa que el registro debe corregirse antes de completarse

#### Scenario: Finalizacion atomica
- **WHEN** el sistema crea la cuenta definitiva desde un onboarding valido
- **THEN** la creacion del usuario y el cierre del flow ocurren dentro de una misma operacion transaccional consistente y no dejan estados parcialmente creados

### Requirement: El login solo acepta cuentas finalizadas
El sistema SHALL autenticar exclusivamente cuentas definitivas y finalizadas y MUST NOT permitir inicio de sesion para registros en progreso o usuarios incompletos.

#### Scenario: Login rechazado para onboarding incompleto
- **WHEN** una persona intenta autenticarse con credenciales asociadas a un registro que no fue finalizado
- **THEN** el sistema rechaza el login y no emite token ni sesion autenticada

#### Scenario: Login exitoso despues de finalizar
- **WHEN** una persona intenta autenticarse con una cuenta creada tras completar el onboarding obligatorio
- **THEN** el sistema permite el login de acuerdo con las reglas normales de autenticacion

### Requirement: El frontend debe reflejar un registro en progreso y no una cuenta creada
El frontend SHALL modelar el proceso como un onboarding en progreso hasta recibir confirmacion explicita de finalizacion y MUST NOT tratar la cuenta como creada solo por haber completado el primer paso.

#### Scenario: Wizard mantiene estado de onboarding
- **WHEN** el frontend recibe la respuesta del primer paso de registro
- **THEN** la interfaz actualiza el estado del wizard usando la informacion del flow y no presenta al usuario como ya creado o autenticado

#### Scenario: Confirmacion de cuenta creada solo al cierre
- **WHEN** el backend confirma que el onboarding fue finalizado correctamente
- **THEN** el frontend recien en ese momento muestra el registro como completado y habilita el siguiente paso esperado del producto
