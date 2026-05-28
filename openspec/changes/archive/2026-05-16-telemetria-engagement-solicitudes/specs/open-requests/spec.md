## ADDED Requirements

### Requirement: Track open request interactions

The system SHALL expose `POST /open-requests/interactions` under the `/open-requests` base path and respond with HTTP `204` on success.

#### Scenario: Interactions endpoint is under open-requests

- **WHEN** the client posts to `<host>/open-requests/interactions`
- **THEN** the system accepts the body defined in `open-requests-engagement-analytics` and responds `204`
