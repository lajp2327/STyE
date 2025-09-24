import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../config/auth_config.dart';
import '../config/preview_config.dart';
import 'token_store/token_store.dart';
import 'web_auth/web_auth_client.dart';

class AuthService {
  AuthService({
    FlutterAppAuth? appAuth,
    TokenStore? tokenStore,
    WebAuthClient? webAuthClient,
    DateTime Function()? now,
    bool? previewMode,
  })  : _previewMode = previewMode ?? kUsePreviewBackend,
        _appAuth = kIsWeb ? null : (appAuth ?? const FlutterAppAuth()),
        _tokenStore = tokenStore ?? createTokenStore(),
        _webAuthClient =
            kIsWeb && !(previewMode ?? kUsePreviewBackend)
                ? (webAuthClient ?? createWebAuthClient())
                : null,
        _now = now ?? DateTime.now;

  final FlutterAppAuth? _appAuth;
  final TokenStore _tokenStore;
  final WebAuthClient? _webAuthClient;
  final DateTime Function() _now;
  final bool _previewMode;

  bool _previewSessionSeeded = false;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _expiryKey = 'auth_access_token_expiry';
  static const String _accountIdKey = 'auth_account_id';

  bool get isPreview => _previewMode;

  Future<void> login() async {
    if (_previewMode) {
      await _ensurePreviewSession();
      return;
    }

    if (kIsWeb) {
      final WebAuthClient client = _requireWebClient();
      try {
        final WebAuthResult result =
            await client.login(scopes: AuthConfig.scopes);
        await _persistTokens(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          expiry: result.expiresOn ??
              _now().toUtc().add(const Duration(hours: 1)),
          accountId: result.accountId,
        );
      } catch (error) {
        await logout();
        throw AuthException(
          'Error durante el inicio de sesión web: $error',
          error,
        );
      }
      return;
    }

    final FlutterAppAuth appAuth = _requireAppAuth();
    try {
      final AuthorizationTokenResponse? response =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUriForPlatform(),
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: AuthConfig.authorizationEndpoint,
            tokenEndpoint: AuthConfig.tokenEndpoint,
          ),
          scopes: AuthConfig.scopes,
          promptValues: const <String>['select_account'],
        ),
      );

      if (response == null || response.accessToken == null) {
        throw const AuthException(
          'No se recibió un accessToken válido durante el inicio de sesión.',
        );
      }

      await _persistTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken,
        expiry: response.accessTokenExpirationDateTime ??
            _now().toUtc().add(const Duration(hours: 1)),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      await logout();
      throw AuthException('Error durante el inicio de sesión: $error', error);
    }
  }

  Future<void> refreshIfNeeded() async {
    if (_previewMode) {
      return;
    }

    final DateTime? expiry = await _readExpiry();
    if (expiry == null) {
      return;
    }

    final Duration difference = expiry.difference(_now().toUtc());
    if (difference.inSeconds > 60) {
      return;
    }

    if (kIsWeb) {
      await _refreshWebToken();
    } else {
      await _refreshNativeToken();
    }
  }

  Future<void> logout() async {
    if (_previewMode) {
      _previewSessionSeeded = false;
    }

    if (kIsWeb) {
      final String? accountId = await _tokenStore.read(_accountIdKey);
      try {
        await _webAuthClient?.logout(accountId: accountId);
      } catch (_) {
        // Ignorar errores al cerrar sesión del lado MSAL.
      }
    }

    await _tokenStore.deleteAll(
      <String>[_accessTokenKey, _refreshTokenKey, _expiryKey, _accountIdKey],
    );
  }

  Future<String> getAccessToken() async {
    if (_previewMode) {
      await _ensurePreviewSession();
      final String? stored = await _tokenStore.read(_accessTokenKey);
      return stored ?? _previewAccessToken;
    }

    await refreshIfNeeded();
    String? accessToken = await _tokenStore.read(_accessTokenKey);

    if ((accessToken == null || accessToken.isEmpty) && kIsWeb) {
      await _refreshWebToken();
      accessToken = await _tokenStore.read(_accessTokenKey);
    }

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('No hay una sesión válida. Ejecuta login().');
    }
    return accessToken;
  }

  Future<bool> hasValidSession() async {
    if (_previewMode) {
      await _ensurePreviewSession();
      return true;
    }

    final String? accessToken = await _tokenStore.read(_accessTokenKey);
    final DateTime? expiry = await _readExpiry();

    if (kIsWeb) {
      final String? accountId = await _tokenStore.read(_accountIdKey);
      if (accountId == null || accountId.isEmpty) {
        return false;
      }

      if (accessToken == null || accessToken.isEmpty || expiry == null) {
        try {
          await _refreshWebToken();
        } on AuthException {
          return false;
        }
      } else {
        try {
          await refreshIfNeeded();
        } on AuthException {
          return false;
        }
      }

      final String? refreshedToken = await _tokenStore.read(_accessTokenKey);
      return refreshedToken != null && refreshedToken.isNotEmpty;
    }

    if (accessToken == null || accessToken.isEmpty || expiry == null) {
      return false;
    }

    if (expiry.isBefore(_now().toUtc())) {
      try {
        await _refreshNativeToken();
      } on AuthException {
        return false;
      }
    } else {
      try {
        await refreshIfNeeded();
      } on AuthException {
        return false;
      }
    }

    final String? refreshedToken = await _tokenStore.read(_accessTokenKey);
    return refreshedToken != null && refreshedToken.isNotEmpty;
  }

  Future<void> _refreshNativeToken() async {
    final FlutterAppAuth appAuth = _requireAppAuth();
    final String? storedRefreshToken = await _tokenStore.read(_refreshTokenKey);
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw const AuthException(
        'No hay refresh_token disponible. Inicia sesión nuevamente.',
      );
    }

    try {
      final TokenResponse? response = await appAuth.token(
        TokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUriForPlatform(),
          refreshToken: storedRefreshToken,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: AuthConfig.authorizationEndpoint,
            tokenEndpoint: AuthConfig.tokenEndpoint,
          ),
          scopes: AuthConfig.scopes,
        ),
      );

      if (response == null || response.accessToken == null) {
        throw const AuthException(
          'No se recibió un accessToken válido al refrescar.',
        );
      }

      await _persistTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken ?? storedRefreshToken,
        expiry: response.accessTokenExpirationDateTime ??
            _now().toUtc().add(const Duration(hours: 1)),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      await logout();
      throw AuthException('Error al refrescar el token: $error', error);
    }
  }

  Future<void> _refreshWebToken() async {
    if (_previewMode) {
      throw const AuthException(
        'La autenticación web no está disponible en modo preview.',
      );
    }

    final WebAuthClient client = _requireWebClient();
    final String? accountId = await _tokenStore.read(_accountIdKey);
    if (accountId == null || accountId.isEmpty) {
      throw const AuthException(
        'No hay una cuenta web disponible. Inicia sesión nuevamente.',
      );
    }

    try {
      final WebAuthResult result = await client.acquireTokenSilent(
        scopes: AuthConfig.scopes,
        accountId: accountId,
      );
      await _persistTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiry: result.expiresOn ??
            _now().toUtc().add(const Duration(hours: 1)),
        accountId: result.accountId ?? accountId,
      );
    } catch (error) {
      await logout();
      throw AuthException('Error al refrescar el token web: $error', error);
    }
  }

  Future<void> _persistTokens({
    required String accessToken,
    String? refreshToken,
    required DateTime expiry,
    String? accountId,
  }) async {
    await _tokenStore.write(_accessTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _tokenStore.write(_refreshTokenKey, refreshToken);
    } else {
      await _tokenStore.delete(_refreshTokenKey);
    }
    await _tokenStore.write(_expiryKey, expiry.toUtc().toIso8601String());
    if (accountId != null && accountId.isNotEmpty) {
      await _tokenStore.write(_accountIdKey, accountId);
    } else {
      await _tokenStore.delete(_accountIdKey);
    }
  }

  Future<DateTime?> _readExpiry() async {
    final String? storedExpiry = await _tokenStore.read(_expiryKey);
    if (storedExpiry == null) {
      return null;
    }
    try {
      return DateTime.parse(storedExpiry).toUtc();
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensurePreviewSession() async {
    if (!_previewMode) {
      return;
    }
    if (_previewSessionSeeded) {
      return;
    }

    final DateTime expiry = _now().toUtc().add(const Duration(days: 30));
    await _persistTokens(
      accessToken: _previewAccessToken,
      refreshToken: _previewRefreshToken,
      expiry: expiry,
      accountId: _previewAccountId,
    );
    _previewSessionSeeded = true;
  }

  static const String _previewAccessToken = 'preview-access-token';
  static const String _previewRefreshToken = 'preview-refresh-token';
  static const String _previewAccountId = 'preview-account';

  FlutterAppAuth _requireAppAuth() {
    final FlutterAppAuth? appAuth = _appAuth;
    if (appAuth == null) {
      throw const AuthException(
        'La autenticación nativa no está disponible en esta plataforma.',
      );
    }
    return appAuth;
  }

  WebAuthClient _requireWebClient() {
    final WebAuthClient? client = _webAuthClient;
    if (client == null) {
      throw const AuthException(
        'La autenticación web no está configurada para esta plataforma.',
      );
    }
    return client;
  }
}

class AuthException implements Exception {
  const AuthException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'AuthException: $message${cause != null ? ' (causa: $cause)' : ''}';
}
