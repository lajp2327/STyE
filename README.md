# Sistema Tickets y EDIs

Demo en Flutter para autenticarse contra Azure AD y consumir Dataverse.

## Modo demo web sin conexión

Puedes navegar por la interfaz sin configurar Azure ni Dataverse compilando con el flag `WEB_PREVIEW`:

```bash
flutter run -d chrome --dart-define=WEB_PREVIEW=true
# o bien
flutter build web --dart-define=WEB_PREVIEW=true
```

En este modo:

- La pantalla principal se muestra sin requerir login con Azure AD.
- Los tickets se almacenan en memoria local (no se envían a Dataverse).
- Puedes crear, editar y eliminar tickets de demostración para validar el flujo UI.

Compila sin el flag para restaurar la integración real con Azure AD + Dataverse.
