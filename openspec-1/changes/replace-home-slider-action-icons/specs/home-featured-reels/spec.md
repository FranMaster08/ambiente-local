## MODIFIED Requirements

### Requirement: Contrato de slide para Home

Cada ítem SHALL incluir al menos: **`id`** (reelId), **`type`** (`image`|`video`), **`media`** (URL absoluta o relativa resoluble), **`creatorUserId`** o equivalente, y **`user`** (nombre del creador) cuando esté disponible. Campos opcionales (`caption`, `avatar`, `music`, `counts`) MAY omitirse sin invalidar el slide. **WHEN** `avatar` está presente, MUST ser una URL de foto real del producto o CDN propio; MUST NOT ser URL de **`ui-avatars.com`** ni servicios equivalentes de avatar generado por terceros.

#### Scenario: Slide de video con caption

- **WHEN** el reel tiene caption y asset de video listo
- **THEN** el objeto incluye `type: 'video'`, `media` reproducible y `caption` opcional para el overlay

#### Scenario: Slide sin foto de perfil

- **WHEN** el creador no tiene imagen de perfil almacenada
- **THEN** el objeto MAY omitir `avatar` o enviarlo vacío y MUST NOT incluir URL de ui-avatars

#### Scenario: Slide con foto de perfil

- **WHEN** el creador tiene URL de avatar persistida en el sistema
- **THEN** el objeto incluye `avatar` con esa URL resoluble por el cliente
