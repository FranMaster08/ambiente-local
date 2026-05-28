## 1. OpenSpec y dependencias

- [x] 1.1 Crear change `improve-publish-request-form` con proposal, design y specs
- [x] 1.2 Añadir dependencia `driver.js` al front

## 2. Backend — contacto desde usuario autenticado

- [x] 2.1 Hacer `contactEmail` y `contactPhone` opcionales en `CreateOpenRequestDto`
- [x] 2.2 Resolver contacto desde `AUTH_USER_REPOSITORY` en `OpenRequestsController.create` (ignorar body)
- [x] 2.3 Exportar `AUTH_USER_REPOSITORY` desde `AuthModule` e importar en `OpenRequestsModule`
- [x] 2.4 Actualizar tests unitarios/e2e de creación de solicitud

## 3. Frontend — eliminar contacto visible

- [x] 3.1 Quitar sección Contacto y controles `contactEmail`/`contactPhone` del template
- [x] 3.2 Eliminar validaciones y pre-fill de contacto del componente
- [x] 3.3 Actualizar `CreateOpenRequestInput` y `buildOpenRequestCreateFormData` (sin contacto en multipart)

## 4. Frontend — ubicación estructurada

- [x] 4.1 Añadir controles país/división/municipio/barrio con `LocationGeographyService`
- [x] 4.2 Implementar resets en cascada y validaciones obligatorias
- [x] 4.3 Construir `locationLabel` con `formatProfileLocationLine` al enviar
- [x] 4.4 Añadir utilidad/tests para composición de ubicación

## 5. Frontend — tour guiado

- [x] 5.1 Añadir botón de ayuda en el encabezado con `data-tour` anchors
- [x] 5.2 Implementar servicio/helper del tour con `driver.js`
- [x] 5.3 Estilos acotados al componente

## 6. Validación

- [x] 6.1 Actualizar `open-request-create.spec.ts`
- [x] 6.2 Ejecutar tests front (`ng test`) y back relevantes
- [x] 6.3 Marcar tareas completadas en este archivo
