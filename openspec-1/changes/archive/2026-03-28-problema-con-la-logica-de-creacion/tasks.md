## 1. Modelo de onboarding y persistencia

- [x] 1.1 Rediseñar el modelo de `registration flow` para que pueda almacenar el registro incompleto sin depender de un `userId` definitivo
- [x] 1.2 Agregar los campos persistentes necesarios para datos iniciales, verificaciones, progreso del wizard y estado de finalizacion del onboarding
- [x] 1.3 Definir estrategia de expiracion o limpieza para drafts de registro abandonados

## 2. Contrato y logica de backend

- [x] 2.1 Cambiar `POST /auth/register` para crear o actualizar un draft de onboarding y dejar de crear un usuario definitivo en el primer paso
- [x] 2.2 Ajustar la respuesta de registro para devolver estado del flow sin exponer un `userId` definitivo
- [x] 2.3 Adaptar la verificacion de email y telefono para que opere sobre la identidad temporal del onboarding
- [x] 2.4 Crear endpoints de onboarding dedicados para guardar ubicacion, perfiles por rol y datos personales sobre el draft
- [x] 2.5 Implementar un endpoint de finalizacion que revalide unicidad, cree el usuario definitivo y cierre el flow en una operacion atomica
- [x] 2.6 Endurecer `LoginUseCase` y reglas asociadas para impedir autenticacion de registros no finalizados

## 3. Frontend y flujo de registro

- [x] 3.1 Actualizar `AuthApi` y los modelos compartidos para consumir el nuevo contrato de registro sin `userId` definitivo temprano
- [x] 3.2 Ajustar el wizard de registro para guardar y consumir estado de onboarding en progreso en lugar de asumir que la cuenta ya fue creada
- [x] 3.3 Reemplazar el uso de endpoints `users/me/*` por los nuevos endpoints de onboarding durante el alta no autenticada
- [x] 3.4 Actualizar el paso final del frontend para invocar la finalizacion explicita del registro y solo entonces mostrar cuenta creada o siguiente accion

## 4. Validaciones, pruebas y despliegue

- [x] 4.1 Agregar o actualizar pruebas unitarias del backend para registro, verificaciones, finalizacion y bloqueo de login en onboarding incompleto
- [x] 4.2 Agregar o actualizar pruebas del frontend para asegurar que el wizard no trate al usuario como creado despues del primer paso
- [x] 4.3 Agregar pruebas end-to-end del flujo completo desde inicio de registro hasta finalizacion y posterior login exitoso
- [x] 4.4 Validar el manejo de conflictos de email/telefono al momento de finalizar el onboarding
- [x] 4.5 Definir estrategia de rollout y rollback para convivir temporalmente con el flujo actual si hiciera falta
