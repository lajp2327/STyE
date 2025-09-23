import 'package:flutter/foundation.dart';

/// Configuración estática para Azure AD y Dataverse.
///
/// Sustituye los valores con los de tu inquilino antes de compilar:
/// - [tenantId]: ID del tenant Entra ID.
/// - [clientId]: ID de la aplicación registrada.
/// - [organizationHost]: URL base de Dataverse (termina con .crm.dynamics.com).
/// - [redirectUriAndroid] y [redirectUriIos]: deben coincidir con los Redirect URIs
///   configurados en el registro de la app.
/// - [scopes]: incluye `.default` del recurso Dataverse y los scopes básicos.
class AuthConfig {
  const AuthConfig._();

  static const String tenantId = '<TENANT_ID>';
  static const String clientId = '<CLIENT_ID>';
  static const String organizationHost = 'https://<ORG>.crm.dynamics.com';
  static const String redirectUriAndroid = 'com.example.app:/oauthredirect';
  static const String redirectUriIos = 'com.example.app:/oauthredirect';

  /// Incluye `.default` para Dataverse y `offline_access` para refresh tokens.
  static const List<String> scopes = <String>[
    'openid',
    'profile',
    'offline_access',
    'https://<ORG>.crm.dynamics.com/.default',
  ];

  static const String _authorizationEndpointTemplate =
      'https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/authorize';
  static const String _tokenEndpointTemplate =
      'https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token';

  static String get authorizationEndpoint =>
      _authorizationEndpointTemplate.replaceFirst('<TENANT_ID>', tenantId);

  static String get tokenEndpoint =>
      _tokenEndpointTemplate.replaceFirst('<TENANT_ID>', tenantId);

  /// Devuelve el redirect URI correcto según la plataforma actual.
  ///
  /// Para Web se debe usar MSAL (msal-browser) o implementar un flujo PKCE
  /// manual; `flutter_appauth` no soporta Web.
  static String redirectUriForPlatform() {
    if (kIsWeb) {
      throw UnsupportedError(
        'TODO: usar MSAL (msal-browser) o un flujo PKCE manual para Web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return redirectUriAndroid;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return redirectUriIos;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Ajusta este valor si registras URIs específicos para escritorio.
        return redirectUriAndroid;
      default:
        return redirectUriAndroid;
    }
  }
}
