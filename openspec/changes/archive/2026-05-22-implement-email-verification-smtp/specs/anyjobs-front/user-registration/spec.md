## MODIFIED Requirements

### Requirement: Stage ACCOUNT MUST validar disponibilidad de email y teléfono con validadores asíncronos
El sistema MUST validar que `email` no esté ya registrado usando un validador asíncrono con debounce, exponiendo el error `emailTaken`. La validación asíncrona de `phoneNumber` (error `phoneTaken`) MUST mantenerse en el código pero MUST quedar deshabilitada funcionalmente mientras la verificación por SMS esté deshabilitada: el sistema MUST NOT bloquear el avance por `phoneTaken` si la verificación de teléfono está deshabilitada.

#### Scenario: Email ya existe bloquea el avance
- **WHEN** el usuario introduce un email ya registrado y el validador asíncrono finaliza
- **THEN** el sistema MUST marcar el control `email` con un error equivalente a `emailTaken` y MUST impedir continuar

#### Scenario: Teléfono ya existe no bloquea el avance mientras SMS está deshabilitado
- **WHEN** el usuario introduce un teléfono ya registrado y el validador asíncrono finaliza
- **THEN** el sistema MUST NOT bloquear el avance si la verificación por SMS está deshabilitada (el error `phoneTaken` puede omitirse o ignorarse en el gating de la etapa)

## ADDED Requirements

### Requirement: La respuesta de registro MUST reflejar phoneVerificationRequired=false cuando SMS está deshabilitado
El sistema MUST leer el campo `phoneVerificationRequired` de la respuesta de `POST /auth/register` y MUST usar ese valor para determinar si mostrar o no la etapa de verificación de teléfono. Cuando `phoneVerificationRequired === false`, el sistema MUST omitir la UI de verificación por teléfono en el flujo.

#### Scenario: Registro retorna phoneVerificationRequired=false — UI omite verificación de teléfono
- **WHEN** la API responde a `POST /auth/register` con `phoneVerificationRequired: false`
- **THEN** el sistema MUST NOT mostrar la etapa ni el formulario de verificación por teléfono al usuario
