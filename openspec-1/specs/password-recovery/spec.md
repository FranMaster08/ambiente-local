## Purpose

Recuperación y restablecimiento de contraseña: tokens de un solo uso, correo de recuperación y hashing coherente con registro/login.

## Requirements

### Requirement: Password reset tokens MUST be single-use with exact 15-minute expiry

The system MUST persist password recovery tokens in durable storage associated with exactly one user. Each token MUST expire exactly 15 minutes after creation (`expires_at = created_at + 15 minutes`). Each token MUST be usable at most once: after a successful password reset, `used_at` MUST be set and the token MUST NOT allow another reset.

When a user requests recovery again while prior tokens are still active (not used and not expired), the system MUST invalidate those prior active tokens for that user and MUST leave only the most recently issued token valid.

#### Scenario: Token expires after 15 minutes
- **WHEN** more than 15 minutes have elapsed since the token was created
- **THEN** the system MUST reject password reset with a controlled error and MUST NOT update the user's password

#### Scenario: Token cannot be reused after successful reset
- **WHEN** a password reset completes successfully for a token
- **THEN** a second attempt with the same token MUST fail with a controlled error and MUST NOT change the password again

#### Scenario: New request invalidates previous active tokens
- **WHEN** a user requests recovery twice within 15 minutes
- **THEN** only the token from the most recent request MUST be valid for reset

### Requirement: Tokens MUST be unpredictable and stored hashed

The system MUST generate tokens using a cryptographically secure random source (e.g. 32 bytes encoded URL-safe). The system MUST NOT store the raw token in the database; it MUST store only a one-way hash of the token sufficient to verify the value presented on reset.

The system MUST NOT log raw tokens, reset links, or new passwords in application logs, API responses, or error payloads.

#### Scenario: Database leak does not expose usable reset links
- **WHEN** an attacker obtains only database rows for password reset tokens
- **THEN** they MUST NOT be able to derive the URL token without the raw value sent by email

### Requirement: Forgot-password MUST not reveal account existence

The system MUST accept a password recovery request with an email address and MUST respond with the same success message whether or not an active account exists for that email. The system MUST NOT send email when no matching active user exists.

#### Scenario: Unknown email receives generic success
- **WHEN** the client requests recovery for an email not registered as an active user
- **THEN** the system MUST respond with the same success body as for a known email and MUST NOT send any email

#### Scenario: Known active email triggers email
- **WHEN** the client requests recovery for an email belonging to an active user
- **THEN** the system MUST create a valid token, MUST send recovery email via the existing mail module, and MUST respond with the generic success message

### Requirement: Recovery email MUST use existing mailer with clear temporary link

The system MUST send recovery email through the existing `MailerService` (no parallel mail stack). The email MUST include a link to the frontend containing the raw token as a query parameter. The email MUST state that the link is temporary and expires in 15 minutes. The email MUST NOT contain passwords, OTP codes, or registration verification copy.

#### Scenario: Email contains frontend reset link
- **WHEN** recovery is requested for an active user
- **THEN** the email MUST include a URL of the form `{FRONTEND_PUBLIC_URL}/recuperar-contrasena?token=<token>` and MUST NOT include a numeric security code for typing in the app

### Requirement: Password reset MUST use existing password hashing

On successful token validation, the system MUST hash the new password with the same `PasswordHasherPort` / scrypt mechanism used for registration and login. The system MUST NOT store plaintext passwords. After reset, login with the new password MUST succeed and login with the old password MUST fail.

#### Scenario: New password works at login
- **WHEN** reset completes with a valid token and compliant password
- **THEN** `POST /auth/login` with the new password MUST return `200` with token and user

#### Scenario: Old password no longer works
- **WHEN** reset completes successfully
- **THEN** `POST /auth/login` with the previous password MUST fail authentication
