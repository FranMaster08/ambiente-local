## ADDED Requirements

### Requirement: Protected endpoints MUST reject invalid session with 401

For any endpoint that requires authentication (not marked public), the system MUST respond with HTTP `401 Unauthorized` when the `Authorization` header is missing, malformed, or contains a Bearer token that is not registered in the active session registry.

The response body MUST use the global error contract with `errorCode` from the authentication catalog (for example `AUTH.UNAUTHORIZED`) and MUST NOT include token values, registry internals, or stack traces.

#### Scenario: Missing Authorization header
- **WHEN** a client calls a protected endpoint without `Authorization`
- **THEN** the system MUST respond `401` with `errorCode` `AUTH.UNAUTHORIZED` and MUST NOT return private data

#### Scenario: Invalid or unknown Bearer token
- **WHEN** a client calls a protected endpoint with `Authorization: Bearer <unknown-or-revoked-token>`
- **THEN** the system MUST respond `401` with `errorCode` `AUTH.UNAUTHORIZED` and MUST NOT return private data

#### Scenario: Malformed Authorization header
- **WHEN** a client calls a protected endpoint with a non-Bearer or malformed `Authorization` value
- **THEN** the system MUST respond `401` with `errorCode` `AUTH.UNAUTHORIZED`

### Requirement: Authentication errors MUST NOT be confused with authorization or server errors

When the caller is not authenticated, the system MUST use `401`. When the caller is authenticated but lacks permission, the system MUST use `403` per RBAC rules. Authentication failures MUST NOT be returned as `500` or generic validation `400` unless the failure is strictly input validation on a public endpoint.

#### Scenario: Unauthenticated vs forbidden
- **WHEN** a valid token is present but the user lacks required permissions
- **THEN** the system MUST respond `403` (not `401`)

#### Scenario: No token on protected route
- **WHEN** no valid session is established
- **THEN** the system MUST respond `401` (not `403` and not `200`)

### Requirement: Login invalid credentials remain distinct from session expiration

`POST /auth/login` with invalid credentials MUST continue to respond `401` with an appropriate auth/login error shape consistent with existing login UX, without exposing whether the email exists.

#### Scenario: Wrong password on login
- **WHEN** the client sends `POST /auth/login` with invalid credentials
- **THEN** the system MUST respond `401` and MUST NOT issue a session token
