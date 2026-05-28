## 1. Persistencia y almacenamiento

- [x] 1.1 Migración `media_assets` + `user_reels` + entidades TypeORM
- [x] 1.2 `LocalUserMediaStorageProvider` en `uploads/user-media/`
- [x] 1.3 Límites MIME/tamaño en servicio de subida

## 2. APIs backend

- [x] 2.1 `POST /user-media/assets` (multipart)
- [x] 2.2 `GET /user-media/assets/:assetId`
- [x] 2.3 `POST /user-reels`, `GET /user-reels/me`, `PATCH`, `DELETE`
- [x] 2.4 `GET /users/:userId/reels` (público, solo aprobados)

## 3. Módulo y calidad

- [x] 3.1 Registrar `UserMediaModule` en `AppModule`
- [x] 3.2 E2e: subida, crear reel, publicar, listado público
- [x] 3.3 E2e: denegar acceso a asset ajeno
