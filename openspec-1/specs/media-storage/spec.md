## Purpose

Almacenamiento y registro de **media assets** de usuario: subida, metadatos, límites y URLs de acceso.

## Requirements

### Requirement: El sistema SHALL registrar assets con metadatos mínimos

Tras subida exitosa, `media_assets` SHALL persistir `owner_user_id`, `storage_key`, `mime_type`, `media_kind`, `file_size_bytes`, y opcionalmente `width`, `height`, `duration_ms`.

#### Scenario: Subida de vídeo MP4 válido

- **WHEN** el dueño envía `POST /user-media/assets` con un archivo `video/mp4` bajo el límite de tamaño
- **THEN** el sistema SHALL guardar el archivo en almacenamiento configurado, SHALL marcar el asset `status=ready`, y SHALL devolver `id` y URL pública resuelta

#### Scenario: Archivo demasiado grande

- **WHEN** el archivo supera el límite configurado (50 MB en MVP)
- **THEN** el sistema SHALL rechazar la petición sin persistir el asset

#### Scenario: MIME no permitido

- **WHEN** el MIME no está en la lista permitida
- **THEN** el sistema SHALL responder con error de validación

### Requirement: Solo el dueño SHALL subir y leer assets privados

`POST /user-media/assets` y `GET /user-media/assets/:id` para assets no publicados SHALL requerir autenticación y coincidencia de `owner_user_id`.

#### Scenario: Otro usuario lee asset privado

- **WHEN** un usuario autenticado solicita un asset que no le pertenece y no está ligado a reel público aprobado
- **THEN** el sistema SHALL denegar el acceso

### Requirement: Las URLs devueltas SHALL ser absolutas cuando exista base pública

Las respuestas API SHALL usar `resolvePublicAssetUrl` con la configuración `app.publicUrl` para rutas relativas de almacenamiento local.

#### Scenario: Respuesta con URL de reproducción

- **WHEN** el backend devuelve un asset o reel con URL de media
- **THEN** la URL SHALL ser absoluta si `publicBaseUrl` está configurada

### Requirement: El almacenamiento local SHALL usar ruta dedicada

Los archivos SHALL guardarse bajo `uploads/user-media/` y exponerse vía el middleware estático `/uploads` existente.

#### Scenario: Cliente reproduce vídeo subido

- **WHEN** el navegador solicita la URL pública devuelta por la API
- **THEN** el archivo SHALL ser servido desde el directorio de uploads sin autenticación adicional en MVP local
