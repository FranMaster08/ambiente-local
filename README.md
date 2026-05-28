# implemetacion-ambiente-local

Repositorio principal para el entorno local de Anyjobs.

## Estructura

- `anyjobs-back/` — Submódulo: backend (NestJS)
- `anyjobs-front/` — Submódulo: frontend (Angular)
- `openspec/` — Especificaciones y cambios (no es submódulo)
- `docker-compose.yml` y `prod-compose.yml` — Archivos de orquestación Docker

## Clonado del repositorio

```bash
git clone --recurse-submodules git@github.com:TU_USUARIO/implemetacion-ambiente-local.git
```

Si ya clonaste sin submódulos:

```bash
git submodule update --init --recursive
```

## Actualizar submódulos

```bash
git submodule update --remote
```

## Levantar entorno local

```bash
docker-compose up --build
```

## Notas
- Realiza cambios en los submódulos desde sus propios repositorios.
- Para agregar nuevas dependencias, hazlo dentro de cada submódulo y luego actualiza el commit del submódulo en este repo principal.
