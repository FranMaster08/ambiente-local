## Context

El monorepo incluye `anyjobs-back` (API) y `anyjobs-front` (cliente). Las **requests** (solicitudes abiertas) admiten **postulaciones/propuestas** de otros usuarios. Hoy falta visibilidad para el creador sobre **quién postuló** y existe el agujero de permitir **auto-postulación** del owner. El front no puede ser la única barrera: la regla debe vivir en el servidor.

## Goals / Non-Goals

**Goals:**

- Validación **autoritativa** al crear postulación: comparar usuario autenticado con owner/creador de la request objetivo.
- Endpoint de **lectura** de postulaciones por request con **autorización** acorde (típicamente solo el creador de la request).
- UI para el creador: lista de postulantes, vacío, carga, errores coherentes con el resto de la app.
- UX defensiva: deshabilitar/ocultar postular en requests propias + manejo del error HTTP si se fuerza el intento.

**Non-Goals:**

- Rediseñar el flujo de **creación** de requests ni cambiar modelo de datos salvo que sea indispensable.
- Exponer campos de usuario (p. ej. email) que el sistema **no** expone hoy en otros endpoints similares.
- Cambiar rutas públicas o contratos existentes sin necesidad estricta.

## Decisions

1. **Código HTTP del rechazo por auto-postulación**  
   Elegir **400 Bad Request** (regla de negocio sobre el recurso solicitado) o **403 Forbidden** (acción prohibida para este sujeto) según la convención ya usada en `anyjobs-back` para conflictos “usuario vs recurso”. Documentar la elección en el mismo estilo de excepciones/DTO de error del proyecto.

2. **Dónde validar**  
   Centralizar en el **servicio de dominio** (o capa equivalente) que crea la postulación, invocable solo desde el controlador autenticado, de modo que no quede lógica duplicada y sea fácil de testear.

3. **Listado de postulantes**  
   Preferir **un endpoint dedicado** bajo el recurso request (p. ej. anidado bajo la misma jerarquía que ya use el API para requests) en lugar de mezclar payloads pesados en el listado general de requests, salvo que el proyecto ya tenga un patrón establecido para “expand” o “includes”.

4. **Permisos**  
   Por defecto: **solo el creador** de la request lee el listado. Si existen roles admin en el proyecto, alinearse con el patrón existente de autorización (guards, policies, `@Roles`) en lugar de inventar uno nuevo.

5. **Front**  
   Reutilizar componentes de tabla/lista, spinners y mensajes vacíos ya presentes en vistas de requests o propuestas; no introducir un sistema de notificaciones nuevo si ya hay uno (toast/snackbar/service central).

## Risks / Trade-offs

- **[Riesgo] Fuga de datos personales** al enriquecer la lista de postulantes → **[Mitigación]** Reutilizar el mismo “shape” de usuario público que otros endpoints de listados sociales ya devuelven; no añadir email si no hay precedente.

- **[Riesgo] Doble postulación** → **[Mitigación]** Respetar restricción única existente (BD o servicio); si no existe, evaluar índice único `(request_id, user_id)` solo si encaja con el modelo actual sin migración invasiva (dejar como decisión de implementación acotada en tareas).

- **[Riesgo] N+1 queries** al listar postulantes con usuario → **[Mitigación]** Joins o carga eager según ORM del back; medir en el endpoint nuevo.

## Migration Plan

- Despliegue **back-end primero** (validación + endpoint) y luego front que consume el listado y deshabilita la acción, para evitar UI que llame a rutas inexistentes. Si el despliegue es simultáneo, usar feature flag solo si el proyecto ya lo usa; si no, coordinar release único.

## Open Questions

- ¿Existe hoy un endpoint parcialmente implementado para listar postulaciones que deba **corregirse** en lugar de crearse uno nuevo?
- ¿Cuál es el **formato exacto** de errores del API (cuerpo JSON) que el front ya parsea?
- ¿Hay **roles** además del creador que deban ver postulantes (moderación, soporte)?
