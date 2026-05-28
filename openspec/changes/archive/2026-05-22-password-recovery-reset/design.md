## Context

- **Backend**: NestJS 10, hexagonal en `modules/auth/`. Contraseñas con `ScryptPasswordHasher` (`scrypt$salt$hash`). Login emite token UUID en memoria (`AuthTokenRegistry`). Rutas auth en `AuthController` marcadas `@Public()`.
- **Mail**: `MailerModule` + `MailerService.sendMail(to, subject, text, html?)`. Plantilla existente `buildSecurityCodeEmailHtml` para registro (código de 6 dígitos, TTL 7 días del flow). **No reutilizar** esa plantilla para recuperación.
- **Frontend**: Angular 21 standalone. Login en modal del `shell`. Registro en `/registro` con `strongPasswordValidator` (mín. 8, mayúscula, minúscula, número, símbolo). No existe ruta de recuperación.
- **Gap**: Cero endpoints y cero UI de password reset.

## Goals / Non-Goals

**Goals:**

- Flujo solicitud → correo con enlace → página reset → contraseña nueva en ≤15 min, token de un solo uso.
- Respuesta genérica en forgot-password (mismo mensaje si el email existe o no).
- Al solicitar de nuevo, invalidar tokens activos previos del usuario; solo el más reciente es válido.
- Token aleatorio no predecible; persistir **solo hash** del token (nunca el valor en claro en DB).
- Reutilizar `MailerService` y estilo visual de correos/página existente.
- Validación de contraseña alineada con registro en backend y frontend.

**Non-Goals:**

- Rate limiting / CAPTCHA (deuda documentada; no bloquea MVP).
- Recuperación por SMS.
- Invalidar sesiones Bearer existentes tras el reset (el registry es en memoria; opcional futuro).
- Cambiar login/registro/verify-email ni renombrar campos OTP del registro.
- JWT para tokens de recuperación.

## Decisions

### 1. Persistencia: tabla `password_reset_tokens`

**Decisión**: Entidad TypeORM `PasswordResetTokenEntity` con:

| Campo | Tipo | Notas |
|-------|------|--------|
| `id` | uuid PK | |
| `user_id` | FK → users | índice |
| `token_hash` | string | hash del token entregado al usuario |
| `expires_at` | timestamptz | `created_at + 15 minutes` exactos |
| `used_at` | timestamptz nullable | no null ⇒ consumido |
| `created_at` | timestamptz | |

**Índices**: `(user_id, used_at)` para invalidar activos; búsqueda por `token_hash` único.

**Alternativas**: Redis TTL — rechazado (nueva dependencia, patrón del proyecto es TypeORM). Reutilizar `registration_flow` — rechazado (dominio distinto, mezcla estados).

### 2. Token en claro vs almacenado

**Decisión**: Generar `token = crypto.randomBytes(32).toString('base64url')` (~43 caracteres URL-safe). Persistir `token_hash = SHA-256(token)` (o HMAC con pepper si existe en env; si no, SHA-256 es suficiente para token de alta entropía). En reset, hashear el token recibido y buscar por `token_hash`.

**Rationale**: Mismo principio que sesiones/opacos: filtración de DB no permite reset directo. La entropía del token hace innecesario scrypt en cada lookup.

### 3. TTL exacto de 15 minutos

**Decisión**: `expires_at = new Date(Date.now() + 15 * 60 * 1000)` al crear. Validación: `now > expires_at` ⇒ error `400` con mensaje genérico «Enlace inválido o expirado» (sin distinguir expirado vs inválido vs usado en respuesta al cliente).

### 4. Un solo uso y re-solicitud

**Decisión**:

- Tras reset exitoso: `used_at = now()` en la misma transacción que actualiza `password_hash`.
- Antes de crear token nuevo: `UPDATE ... SET used_at = now() WHERE user_id = ? AND used_at IS NULL AND expires_at > now()` (invalidar activos no vencidos).
- Intento con token ya usado o expirado: mismo error controlado que token inexistente.

### 5. Endpoints y contrato

| Método | Ruta | Body | Respuesta |
|--------|------|------|-----------|
| `POST` | `/auth/forgot-password` | `{ email: string }` | `200` `{ message: string }` mensaje fijo |
| `POST` | `/auth/reset-password` | `{ token: string, password: string }` | `200` `{ message: string }` éxito; `400` error genérico |

Ambos `@Public()`. Email normalizado (`trim`, lowercase) como en login.

**Anti-enumeración**: Si no hay usuario ACTIVE con ese email, responder `200` con el mismo `message` y **no** enviar correo. No loguear el email en nivel info en este path.

### 6. Validación de contraseña en backend

**Decisión**: Validador compartido o duplicado mínimo en use case:

- Mínimo 8 caracteres
- Al menos una mayúscula, una minúscula, un dígito y un símbolo no alfanumérico

Coherente con `strongPasswordValidator` del frontend. DTO con `class-validator` + validación en use case antes de hashear.

**Nota**: `RegisterRequestDto` sigue con `@MinLength(6)` — fuera de scope; solo reset usa reglas fuertes.

### 7. Correo y enlace

**Decisión**:

- Nueva función `buildPasswordRecoveryEmailHtml(fullName, resetUrl)` en `email-templates.ts` (misma estructura de card/logo que la plantilla de seguridad, copy distinto: enlace temporal 15 min, botón CTA, sin dígitos OTP).
- Asunto: `Restablece tu contraseña · anyjobs`
- URL: `${FRONTEND_PUBLIC_URL}/recuperar-contrasena?token=${encodeURIComponent(token)}`
- Nueva env **`FRONTEND_PUBLIC_URL`** (requerida en Zod, sin barra final), p. ej. `http://localhost:4200` en dev.

### 8. Frontend

**Decisión**:

- Ruta pública `/recuperar-contrasena` (y opcional `/olvide-contrasena` solo con formulario email que llama forgot-password — puede ser la misma página con dos modos o ruta separada `/solicitar-recuperacion`; **implementación recomendada**: una página `/recuperar-contrasena` sin token muestra formulario email; con `?token=` muestra formulario nueva contraseña).
- Formulario reset: `password`, `passwordConfirm`, validador cruzado, `strongPasswordValidator` en password.
- Estados: loading, success (mensaje + botón «Ir a iniciar sesión» abre shell `?login=1`), error (token inválido/expirado/usado).
- Estilos: copiar patrones de `registration.scss` / `shell.scss` (`.fieldLabel`, `.fieldControl`, `.btn`, variables `--aj-*`).

**Login**: En modal, enlace «¿Olvidaste tu contraseña?» → `/recuperar-contrasena` (modo solicitud).

### 9. Arquitectura hexagonal en auth

**Decisión**: 

- `RequestPasswordResetUseCase` (forgot)
- `ResetPasswordUseCase` (reset)
- `PasswordResetTokenRepositoryPort` + adapter TypeORM
- Inyectar `MailerService`, `PasswordHasherPort`, `UserRepositoryPort`

## Risks / Trade-offs

- **[Riesgo] Abuso de forgot-password (spam de correos)** → Mitigación: invalidar tokens previos limita acumulación; rate-limit queda como deuda.
- **[Riesgo] `FRONTEND_PUBLIC_URL` mal configurada en prod** → Mitigación: Zod required at bootstrap; documentar en `.env.example`.
- **[Trade-off] Mensajes de error genéricos en reset** → Mejor seguridad; UX menos específica (aceptado).
- **[Riesgo] Desfase validación front (fuerte) vs register backend (6 chars)** → Solo afecta registro legacy; reset exige fuerte en ambos lados.

## Migration Plan

1. Migración TypeORM: tabla `password_reset_tokens`.
2. Entidad, repositorio, use cases, DTOs, controller endpoints.
3. Plantilla email + `FRONTEND_PUBLIC_URL` en config.
4. Tests unitarios use cases + e2e forgot/reset.
5. Frontend: ruta, componentes, `auth.api.ts`, enlace en login modal.
6. Verificación manual según tasks.md (Mailpit en dev).

**Rollback**: Eliminar endpoints del controller (o feature flag); tabla puede quedar vacía. Sin cambios destructivos en `users`.

## Open Questions

- ¿Página única con dos modos (email / reset) o dos rutas? → **Recomendado**: una ruta `/recuperar-contrasena` con bifurcación por query `token` (menos rutas, mismo look and feel).
- ¿Limitar solicitudes por IP? → Fuera de scope; documentar en deuda técnica.
