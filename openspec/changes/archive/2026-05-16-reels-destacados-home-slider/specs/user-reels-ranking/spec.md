## ADDED Requirements

### Requirement: Campo persistido ranking_score en user_reels

El sistema SHALL almacenar en cada fila de **`user_reels`** un campo numérico **`ranking_score`** con valor por defecto **0**, apto para materializar puntuaciones calculadas en el futuro.

#### Scenario: Reel recién creado

- **WHEN** se crea un reel nuevo
- **THEN** `ranking_score` SHALL ser `0` hasta que un proceso o servicio lo actualice

#### Scenario: Consulta para ordenamiento en este change

- **WHEN** el servicio de ranking resuelve el score efectivo de un reel durante este change
- **THEN** SHALL usar score calculado on-read; `ranking_score` en BD permanece en `0` salvo actualización manual — la materialización del valor calculado queda para un change posterior

#### Scenario: Materialización futura

- **WHEN** un job o change posterior persiste el score calculado
- **THEN** actualiza `ranking_score` sin cambiar el contrato de los endpoints consumidores

### Requirement: Servicio aislado de puntuación de Reels

El backend SHALL exponer un servicio dedicado (p. ej. **`UserReelRankingScoreService`**) responsable de calcular o resolver la puntuación de un reel. La fórmula definitiva (retención, interacciones, relevancia por usuario, etc.) SHALL definirse en iteraciones posteriores; en MVP el servicio MAY devolver el score calculado existente o el valor persistido.

#### Scenario: Cálculo sin métricas suficientes

- **WHEN** un reel tiene menos impresiones que el umbral de cold start
- **THEN** el score efectivo SHALL basarse principalmente en señales temporales (`published_at` / `created_at`) según la implementación acordada, documentada en el servicio

#### Scenario: Extensión futura de fórmula

- **WHEN** producto define nuevos pesos o señales
- **THEN** solo el servicio de puntuación y jobs asociados requieren cambio; consumidores (`GET /feed/reels`, `GET /home/featured-reels`) mantienen el mismo contrato de salida ordenada

## MODIFIED Requirements

### Requirement: El feed SHALL ordenar por score cuando hay datos suficientes

Con al menos 10 impresiones en ventana, el orden SHALL basarse en el **score efectivo** calculado on-read por el servicio de puntuación (completion, interacciones normalizadas y penalización por skip temprano). En este change **`ranking_score`** en BD no se actualiza automáticamente; la lectura del valor persistido se habilitará cuando exista materialización.

#### Scenario: Cold start

- **WHEN** un reel tiene menos de 10 impresiones
- **THEN** su posición depende principalmente de `published_at` descendente (o score temporal equivalente documentado en el servicio)

#### Scenario: Orden descendente en Home

- **WHEN** se invoca el listado para Home o feed
- **THEN** los reels elegibles aparecen ordenados por score efectivo de mayor a menor dentro de cada grupo de personalización (vistos / no vistos)
