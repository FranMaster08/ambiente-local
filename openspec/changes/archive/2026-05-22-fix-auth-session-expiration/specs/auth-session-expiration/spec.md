## ADDED Requirements

### Requirement: Session invalidation MUST be centralized in the frontend

The frontend MUST expose a single entry point (for example `invalidateSession`) that clears persisted `token` and `user`, resets global authentication state to not authenticated, resets dependent stores (such as notifications), and MUST be invoked by all session-expiration flows instead of ad hoc per-component cleanup.

#### Scenario: First protected request returns 401
- **WHEN** the user has a persisted session and a protected API call returns HTTP `401` with an authentication error code from the global error contract (for example `AUTH.UNAUTHORIZED`)
- **THEN** the system MUST invoke centralized session invalidation exactly once for that expiration wave and MUST NOT leave private user data in memory or persistent storage

#### Scenario: Subsequent parallel 401 responses
- **WHEN** multiple protected requests fail with `401` after session invalidation has already started
- **THEN** the system MUST NOT trigger repeated full invalidation loops or duplicate user-facing expiration messages for the same wave

### Requirement: HTTP layer MUST detect authentication failures globally

The frontend MUST implement a centralized HTTP response handler (interceptor) that detects authentication failures on protected API calls and triggers session invalidation without requiring each feature component to handle `401` independently.

#### Scenario: Protected endpoint returns unauthorized
- **WHEN** a response from a protected API prefix returns HTTP `401` with `errorCode` indicating authentication failure
- **THEN** the interceptor MUST trigger centralized session invalidation

#### Scenario: Login failure must not trigger session expiration handling
- **WHEN** `POST /auth/login` returns HTTP `401` due to invalid credentials
- **THEN** the interceptor MUST NOT treat this as session expiration and MUST NOT clear an unrelated existing session as part of the login attempt error path

#### Scenario: Public auth endpoints without session
- **WHEN** a public auth endpoint (register, forgot-password, reset-password, availability checks) is called without a Bearer token
- **THEN** the interceptor MUST NOT apply session-expiration side effects to navigation

### Requirement: Private API requests MUST be suppressed after invalidation

After session invalidation, the frontend MUST NOT attach Bearer tokens to new protected requests and SHOULD avoid issuing further protected requests until the user authenticates again.

#### Scenario: User remains on page after expiration
- **WHEN** session invalidation completes while the user stays on the current route
- **THEN** the system MUST NOT continue firing protected API requests with the previous token

### Requirement: Navigation after expiration MUST respect public vs private routes

After session invalidation, the system MUST redirect to the login entry flow only when the current route requires authentication. On public routes, the system MUST clear session without forcing login navigation.

#### Scenario: Expiration on private route
- **WHEN** session invalidation occurs while the user is on a route that requires authentication
- **THEN** the system MUST navigate to the established login entry (for example `/home?login=1` or equivalent shell pattern) and MUST NOT keep showing the user as logged in

#### Scenario: Expiration on public route
- **WHEN** session invalidation occurs while the user is on a public route (for example `/home`, browse flows)
- **THEN** the system MUST clear session and MUST NOT force an unnecessary full-page redirect solely for login

### Requirement: User-facing session expiration feedback MUST be controlled

When session invalidation is triggered by expiration or invalid token (not explicit logout), the system MUST show a single controlled, non-technical message indicating that the session expired and login is required again, when the UI shell allows it.

#### Scenario: Session expires during authenticated work
- **WHEN** centralized invalidation runs with reason expiration or invalid token
- **THEN** the user MUST see a friendly message (for example via i18n key) and MUST NOT see raw stack traces or internal error codes in the UI

### Requirement: Feature components MUST rely on centralized expiration

Feature components MUST NOT implement their own `auth.clear()` on `401` for standard protected API calls once the centralized handler exists; they MUST react to `isLoggedIn === false` for UI state.

#### Scenario: Profile load unauthorized
- **WHEN** `GET /users/me/profile` returns `401`
- **THEN** centralized invalidation handles cleanup and the profile view MUST show unauthenticated state without retaining private profile data
