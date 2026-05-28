## MODIFIED Requirements

### Requirement: Fuente de datos API con fallback a mock

La aplicación SHALL intentar cargar los slides desde **`GET /promo-slides`** (mismo origen / proxy en desarrollo), incluyendo el query param **`anonymousId`** del actor anónimo estable para personalización del orden. **WHEN** esa petición falla, SHALL cargar **`/mock/home-promo-slides.mock.json`** como respaldo. **WHEN** ambas fallan o la lista es inválida/vacía según implementación, SHALL mostrar estado de error o vacío sin tumbar la aplicación.

#### Scenario: Carga exitosa desde API

- **WHEN** el API devuelve un arreglo válido de slides
- **THEN** Home pasa el arreglo al input **`slides`** del slider en el orden devuelto por el API
