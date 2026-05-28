## 1. Backend — enums, DTOs y policy

- [x] 1.1 Añadir `CC` a `DocumentType` (domain type, entity, DTOs, Swagger `@IsIn`, tests).
- [x] 1.2 Hacer `area` y `countryCode` obligatorios en `UpdateLocationRequestDto` con validación de formato (`countryCode` 2 letras).
- [x] 1.3 Extender `UserProfilePolicy.validatePersonalInfoRequiredForWorker` y validación en `complete-onboarding-registration` para `gender` y `nationality` en WORKER.
- [x] 1.4 Validar ubicación completa (`city`, `municipality`, `area`, `countryCode`) en `validateSupportedLocation`.
- [x] 1.5 Respuestas `AppException('VALIDATION.INVALID_INPUT')` con `fieldErrors` granulares.
- [x] 1.6 Actualizar tests: `complete-registration.use-case.spec.ts`, `auth.e2e-spec.ts`, `supported-location.catalog.spec.ts`.

## 2. Frontend — validaciones por etapa

- [x] 2.1 Cuenta: `type="email"` / `type="tel"`, estado `pending` async, copy disponibilidad, Continuar si `invalid || pending || busy`.
- [x] 2.2 Verificación: OTP con `inputmode="numeric"`.
- [x] 2.3 Ubicación: required en país, división, municipio y barrio; validadores catálogo; i18n sin “Opcional” engañoso.
- [x] 2.4 Perfil: deshabilitar `finish` si WORKER sin categorías.
- [x] 2.5 Personal: `CC`, género y nacionalidad WORKER; payload completo vía `register/complete`.
- [x] 2.6 Personal: no avanzar WORKER si formulario inválido.

## 3. Frontend — errores y API

- [x] 3.1 Mapper `registration-error.utils.ts` + `registration-form-errors.ts` con `fieldErrors` y class-validator.
- [x] 3.2 Integrar errores en wizard; `regErrorSummary` por etapa.
- [x] 3.3 Logs sin PII sensible.
- [x] 3.4 Tests `registration.spec.ts`, `registration.validators.spec.ts`, `registration-error.utils.spec.ts`.

## 4. Documentación y contrato

- [x] 4.1 Actualizar contratos en código (DTOs, models, auth.api).
- [x] 4.2 Alinear `registration.models.ts` / `auth.api.ts` con backend.

## 5. Registro atómico y disponibilidad

- [x] 5.1 `RegistrationDraftService` (sessionStorage) para progreso del wizard.
- [x] 5.2 `POST /auth/register/complete` + `CompleteOnboardingRegistrationUseCase`.
- [x] 5.3 `check-email-available` / `check-phone-available` solo usuarios en `users`.
- [x] 5.4 Front: Cuenta ya no llama `POST /register` al continuar; finalización única en Personal.

## 6. Catálogo geográfico y municipio

- [x] 6.1 Migraciones `geo_divisions`, `geo_municipalities`, `geo_neighborhoods`; columna `municipality` en `users`.
- [x] 6.2 Seeder departamentos CO y provincias AR + municipios/barrios de referencia.
- [x] 6.3 API `GET /auth/location-catalog` (divisiones y municipios por división).
- [x] 6.4 Front: cascada país → división → municipio; carga async catálogo.

## 7. Barrio texto libre y validación ubicación

- [x] 7.1 `area` como `<input type="text">` (no combo de barrios).
- [x] 7.2 Validación longitud barrio (2–120) front y back.
- [x] 7.3 Eliminar `areaInMunicipalityValidator` / validación cerrada de barrios.

## 8. Personal — mayor de edad y nacionalidad mundial

- [x] 8.1 `minimumAgeValidator(18)` + `birthDateMax` en input; `isAdultBirthDate` en back.
- [x] 8.2 `world-countries.data.ts` + select nacionalidad con nombres localizados.
- [x] 8.3 Validación `isIsoCountryCode` en policy y DTOs (`IsIn` ISO_COUNTRY_CODES).

## 9. UX errores y estabilidad backend

- [x] 9.1 Resumen “Corrige lo siguiente:” con lista por campo; sin duplicar genérico.
- [x] 9.2 Parser mensajes Nest `property X should not exist`.
- [x] 9.3 Fix `auth.controller.ts`: `resumeFlowId ?? undefined` (compilación Docker).

## 10. QA manual mobile

- [ ] 10.1 Flujo WORKER hasta DONE: CO → división → municipio → barrio libre; CC; nacionalidad cualquier país; ≥18 años.
- [ ] 10.2 Sin “email ya existe” en Cuenta por draft previo (mismo email, registro nuevo).
- [ ] 10.3 Errores muestran campo concreto (no solo “Revisa los datos del formulario”).
- [ ] 10.4 Flujo CLIENT-only hasta DONE.
- [ ] 10.5 Teclados mobile email, tel, OTP.
