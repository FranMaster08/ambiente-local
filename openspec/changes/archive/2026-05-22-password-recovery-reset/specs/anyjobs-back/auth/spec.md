## ADDED Requirements

### Requirement: Forgot password endpoint MUST accept email and return generic success

The system MUST expose `POST /auth/forgot-password` under the `/auth` base path as a public endpoint (no Bearer required). The request body MUST be JSON:

- `email: string` (required, valid email format)

The system MUST respond `200` with JSON:

- `message: string` — fixed generic text, e.g. «Si el correo está registrado, recibirás un enlace para restablecer tu contraseña.»

The response MUST be identical whether the email exists or not. On match with an `ACTIVE` user, the system MUST issue a reset token, invalidate prior active tokens for that user, and send the recovery email. On no match, the system MUST NOT send email.

#### Scenario: Forgot password returns 200 for valid payload
- **WHEN** the client sends `POST /auth/forgot-password` with `{ "email": "user@example.com" }`
- **THEN** the system MUST respond `200` with `{ "message": "<generic>" }` regardless of whether the account exists

#### Scenario: Invalid email format returns 400
- **WHEN** the client sends `POST /auth/forgot-password` with a malformed email
- **THEN** the system MUST respond `400` with the global error contract and MUST NOT send email

### Requirement: Reset password endpoint MUST accept token and new password

The system MUST expose `POST /auth/reset-password` as a public endpoint. The request body MUST be JSON:

- `token: string` (required, non-empty)
- `password: string` (required; MUST satisfy strong password rules: min 8 chars, uppercase, lowercase, digit, symbol)

On success, the system MUST respond `200` with JSON:

- `message: string` — e.g. «Contraseña actualizada correctamente.»

On invalid, expired, or already-used token, the system MUST respond `400` with a generic message such as «Enlace inválido o expirado.» without revealing which condition failed.

On weak password, the system MUST respond `400` with a validation message aligned with registration strength rules.

#### Scenario: Reset succeeds with valid token and strong password
- **WHEN** the client sends `POST /auth/reset-password` with a valid unused unexpired token and a compliant password
- **THEN** the system MUST respond `200`, MUST update `password_hash` for the user, and MUST mark the token as used

#### Scenario: Reset fails with expired token
- **WHEN** the client sends `POST /auth/reset-password` with a token older than 15 minutes
- **THEN** the system MUST respond `400` with a generic error and MUST NOT update the password

#### Scenario: Reset fails with already-used token
- **WHEN** the client sends `POST /auth/reset-password` with a token that was already consumed
- **THEN** the system MUST respond `400` with a generic error and MUST NOT update the password

### Requirement: FRONTEND_PUBLIC_URL MUST configure recovery links

The system MUST read `FRONTEND_PUBLIC_URL` from environment (validated at bootstrap, no trailing slash). Recovery emails MUST build reset URLs using this base URL.

#### Scenario: Missing FRONTEND_PUBLIC_URL prevents startup
- **WHEN** `FRONTEND_PUBLIC_URL` is unset or empty in environment
- **THEN** the application MUST fail configuration validation at startup
