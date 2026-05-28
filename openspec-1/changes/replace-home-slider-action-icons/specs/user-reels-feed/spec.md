## MODIFIED Requirements

### Requirement: El feed SHALL devolver slides reproducibles

`GET /feed/reels` SHALL devolver un array de objetos con `id` (reelId), `type` (`image`|`video`), `media` (URL absoluta), `caption` opcional y `creatorUserId`. **WHEN** se incluye `avatar`, MUST ser foto real del usuario o omitirse; MUST NOT ser URL de **`ui-avatars.com`**.

#### Scenario: Feed con reels elegibles

- **WHEN** existen reels aprobados en fase testing o scaling
- **THEN** la respuesta SHALL ser un array ordenado por el servicio de ranking y cada ítem SHALL incluir URL de media válida

#### Scenario: Sin contenido elegible

- **WHEN** no hay reels que cumplan criterios de distribución
- **THEN** la respuesta SHALL ser un array vacío

#### Scenario: Creador sin avatar persistido

- **WHEN** el mapper no tiene imagen de perfil para el creador del reel
- **THEN** el ítem del feed MUST NOT incluir `avatar` apuntando a ui-avatars
